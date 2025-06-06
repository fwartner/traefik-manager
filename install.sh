#!/bin/bash

set -e

# Traefik Manager Installation Script
# Author: Florian Wartner
# Repository: https://github.com/fwartner/traefik-manager

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="traefik-manager"
APP_USER="traefik-manager"
APP_DIR="/opt/traefik-manager"
SERVICE_NAME="traefik-manager"
DEFAULT_PORT="3000"
DEFAULT_TRAEFIK_DIR="/etc/traefik/dynamic"

print_header() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    TRAEFIK MANAGER                          ║"
    echo "║                  Installation Script                        ║"
    echo "║                                                              ║"
    echo "║                   by @fwartner                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_warning "Running as root user detected!"
        log_info "While this is supported, it's recommended to run as a normal user."
        log_info "The script will proceed but some security restrictions may be bypassed."
        echo
        read -p "Continue as root? [y/N]: " continue_as_root
        if [[ ! $continue_as_root =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled. Please run as a normal user for better security."
            exit 1
        fi
        log_info "Continuing installation as root user..."
    fi
}

check_system() {
    log_info "Checking system compatibility..."
    
    # Check if systemd is available
    if ! command -v systemctl &> /dev/null; then
        log_error "systemd is required but not available!"
        exit 1
    fi
    
    # Check Linux distribution
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        log_info "Detected distribution: $PRETTY_NAME"
    else
        log_warning "Could not detect distribution. Proceed at your own risk."
    fi
    
    log_success "System check successful"
}

install_dependencies() {
    log_info "Installing system dependencies..."
    
    # Update package list
    if [[ $EUID -eq 0 ]]; then
        apt-get update -qq
    else
        sudo apt-get update -qq
    fi
    
    # Install required packages
    local packages=("curl" "wget" "git" "build-essential")
    
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            log_info "Installing $package..."
            if [[ $EUID -eq 0 ]]; then
                apt-get install -y "$package"
            else
                sudo apt-get install -y "$package"
            fi
        else
            log_info "$package is already installed"
        fi
    done
    
    log_success "System dependencies installed"
}

install_nodejs() {
    log_info "Checking Node.js installation..."
    
    # Check if Node.js is installed and version is >= 18
    if command -v node &> /dev/null; then
        local node_version=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
        if [[ $node_version -ge 18 ]]; then
            log_info "Node.js $(node -v) is already installed"
            return 0
        else
            log_warning "Node.js version is too old ($(node -v)). Need at least v18."
        fi
    fi
    
    log_info "Installing Node.js 20 LTS..."
    
    # Install NodeSource repository
    if [[ $EUID -eq 0 ]]; then
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt-get install -y nodejs
    else
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
    
    # Verify installation
    if command -v node &> /dev/null && command -v npm &> /dev/null; then
        log_success "Node.js $(node -v) and npm $(npm -v) successfully installed"
    else
        log_error "Node.js installation failed!"
        exit 1
    fi
}

create_user() {
    log_info "Creating system user..."
    
    if id "$APP_USER" &>/dev/null; then
        log_info "User $APP_USER already exists"
    else
        if [[ $EUID -eq 0 ]]; then
            useradd --system --home "$APP_DIR" --shell /bin/false "$APP_USER"
        else
            sudo useradd --system --home "$APP_DIR" --shell /bin/false "$APP_USER"
        fi
        log_success "User $APP_USER created"
    fi
}

download_application() {
    log_info "Downloading Traefik Manager..."
    
    # Create application directory
    if [[ $EUID -eq 0 ]]; then
        mkdir -p "$APP_DIR"
    else
        sudo mkdir -p "$APP_DIR"
    fi
    
    # Clone repository
    if [[ -d "$APP_DIR/.git" ]]; then
        log_info "Repository already exists. Updating..."
        cd "$APP_DIR"
        if [[ $EUID -eq 0 ]]; then
            su -s /bin/bash "$APP_USER" -c "git pull"
        else
            sudo -u "$APP_USER" git pull
        fi
    else
        log_info "Cloning repository from GitHub..."
        if [[ $EUID -eq 0 ]]; then
            git clone https://github.com/fwartner/traefik-manager.git "$APP_DIR"
        else
            sudo git clone https://github.com/fwartner/traefik-manager.git "$APP_DIR"
        fi
    fi
    
    # Change ownership
    if [[ $EUID -eq 0 ]]; then
        chown -R "$APP_USER:$APP_USER" "$APP_DIR"
    else
        sudo chown -R "$APP_USER:$APP_USER" "$APP_DIR"
    fi
    
    log_success "Application downloaded"
}

install_app_dependencies() {
    log_info "Installing application dependencies..."
    
    cd "$APP_DIR"
    
    # Install npm dependencies
    if [[ $EUID -eq 0 ]]; then
        su -s /bin/bash "$APP_USER" -c "npm ci --only=production"
    else
        sudo -u "$APP_USER" npm ci --only=production
    fi
    
    # Build application
    log_info "Building application for production..."
    if [[ $EUID -eq 0 ]]; then
        su -s /bin/bash "$APP_USER" -c "npm run build"
    else
        sudo -u "$APP_USER" npm run build
    fi
    
    log_success "Application dependencies installed and built"
}

configure_application() {
    log_info "Configuring application..."
    
    # Create environment file
    if [[ ! -f "$APP_DIR/.env" ]]; then
        log_info "Creating environment configuration..."
        
        # Prompt for configuration
        echo
        read -p "Port for Traefik Manager [${DEFAULT_PORT}]: " APP_PORT
        APP_PORT=${APP_PORT:-$DEFAULT_PORT}
        
        read -p "Traefik configuration directory [${DEFAULT_TRAEFIK_DIR}]: " TRAEFIK_DIR
        TRAEFIK_DIR=${TRAEFIK_DIR:-$DEFAULT_TRAEFIK_DIR}
        
        # Create .env file
        if [[ $EUID -eq 0 ]]; then
            cat > "$APP_DIR/.env" <<EOF
# Traefik Manager Configuration
PORT=${APP_PORT}
TRAEFIK_CONFIG_DIR=${TRAEFIK_DIR}
NODE_ENV=production
NITRO_PORT=${APP_PORT}
NITRO_HOST=0.0.0.0
EOF
            chown "$APP_USER:$APP_USER" "$APP_DIR/.env"
        else
            sudo -u "$APP_USER" tee "$APP_DIR/.env" > /dev/null <<EOF
# Traefik Manager Configuration
PORT=${APP_PORT}
TRAEFIK_CONFIG_DIR=${TRAEFIK_DIR}
NODE_ENV=production
NITRO_PORT=${APP_PORT}
NITRO_HOST=0.0.0.0
EOF
        fi
        
        log_success "Configuration file created"
    else
        log_info "Configuration file already exists"
    fi
    
    # Ensure traefik config directory exists and is accessible
    if [[ ! -d "$TRAEFIK_DIR" ]]; then
        log_warning "Traefik configuration directory $TRAEFIK_DIR does not exist"
        read -p "Should it be created? [y/N]: " create_dir
        if [[ $create_dir =~ ^[Yy]$ ]]; then
            if [[ $EUID -eq 0 ]]; then
                mkdir -p "$TRAEFIK_DIR"
                chown -R "$APP_USER:$APP_USER" "$TRAEFIK_DIR"
            else
                sudo mkdir -p "$TRAEFIK_DIR"
                sudo chown -R "$APP_USER:$APP_USER" "$TRAEFIK_DIR"
            fi
            log_success "Directory $TRAEFIK_DIR created"
        fi
    else
        # Ensure app user can access traefik config
        if [[ $EUID -eq 0 ]]; then
            chown -R "$APP_USER:$APP_USER" "$TRAEFIK_DIR" 2>/dev/null || {
                log_warning "Could not set permissions for $TRAEFIK_DIR"
                log_info "Make sure user $APP_USER has read/write access"
            }
        else
            sudo chown -R "$APP_USER:$APP_USER" "$TRAEFIK_DIR" 2>/dev/null || {
                log_warning "Could not set permissions for $TRAEFIK_DIR"
                log_info "Make sure user $APP_USER has read/write access"
            }
        fi
    fi
}

create_systemd_service() {
    log_info "Creating systemd service..."
    
    if [[ $EUID -eq 0 ]]; then
        cat > /etc/systemd/system/${SERVICE_NAME}.service <<EOF
[Unit]
Description=Traefik Manager - Web interface for Traefik configuration
Documentation=https://github.com/fwartner/traefik-manager
After=network.target
Wants=network.target

[Service]
Type=simple
User=${APP_USER}
Group=${APP_USER}
WorkingDirectory=${APP_DIR}
Environment=NODE_ENV=production
EnvironmentFile=${APP_DIR}/.env
ExecStart=/usr/bin/node ${APP_DIR}/.output/server/index.mjs
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=${SERVICE_NAME}

# Security settings
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=${APP_DIR}
ReadWritePaths=/etc/traefik
PrivateTmp=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true

[Install]
WantedBy=multi-user.target
EOF
    else
        sudo tee /etc/systemd/system/${SERVICE_NAME}.service > /dev/null <<EOF
[Unit]
Description=Traefik Manager - Web interface for Traefik configuration
Documentation=https://github.com/fwartner/traefik-manager
After=network.target
Wants=network.target

[Service]
Type=simple
User=${APP_USER}
Group=${APP_USER}
WorkingDirectory=${APP_DIR}
Environment=NODE_ENV=production
EnvironmentFile=${APP_DIR}/.env
ExecStart=/usr/bin/node ${APP_DIR}/.output/server/index.mjs
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=${SERVICE_NAME}

# Security settings
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=${APP_DIR}
ReadWritePaths=/etc/traefik
PrivateTmp=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true

[Install]
WantedBy=multi-user.target
EOF
    fi
    
    # Reload systemd and enable service
    if [[ $EUID -eq 0 ]]; then
        systemctl daemon-reload
        systemctl enable ${SERVICE_NAME}
    else
        sudo systemctl daemon-reload
        sudo systemctl enable ${SERVICE_NAME}
    fi
    
    log_success "systemd service created and enabled"
}

setup_firewall() {
    log_info "Configuring firewall..."
    
    if command -v ufw &> /dev/null; then
        # Check if ufw is active
        local ufw_status
        if [[ $EUID -eq 0 ]]; then
            ufw_status=$(ufw status)
        else
            ufw_status=$(sudo ufw status)
        fi
        
        if echo "$ufw_status" | grep -q "Status: active"; then
            local port=$(grep "^PORT=" "$APP_DIR/.env" | cut -d'=' -f2)
            read -p "Should port $port be opened in the firewall? [y/N]: " open_port
            if [[ $open_port =~ ^[Yy]$ ]]; then
                if [[ $EUID -eq 0 ]]; then
                    ufw allow "$port"
                else
                    sudo ufw allow "$port"
                fi
                log_success "Port $port opened in firewall"
            fi
        else
            log_info "UFW is not active, skipping firewall configuration"
        fi
    else
        log_info "UFW not available, skipping firewall configuration"
    fi
}

start_service() {
    log_info "Starting Traefik Manager service..."
    
    if [[ $EUID -eq 0 ]]; then
        systemctl start ${SERVICE_NAME}
    else
        sudo systemctl start ${SERVICE_NAME}
    fi
    
    # Wait a moment and check status
    sleep 3
    
    if [[ $EUID -eq 0 ]]; then
        service_active=$(systemctl is-active ${SERVICE_NAME})
    else
        service_active=$(sudo systemctl is-active ${SERVICE_NAME})
    fi
    
    if [[ "$service_active" == "active" ]]; then
        log_success "Service started successfully!"
        
        local port=$(grep "^PORT=" "$APP_DIR/.env" | cut -d'=' -f2)
        echo
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                    INSTALLATION SUCCESSFUL                  ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo
        echo -e "${BLUE}Traefik Manager running on:${NC} http://localhost:${port}"
        echo -e "${BLUE}Service status:${NC} sudo systemctl status ${SERVICE_NAME}"
        echo -e "${BLUE}Service logs:${NC} sudo journalctl -u ${SERVICE_NAME} -f"
        echo -e "${BLUE}Stop service:${NC} sudo systemctl stop ${SERVICE_NAME}"
        echo -e "${BLUE}Restart service:${NC} sudo systemctl restart ${SERVICE_NAME}"
        echo
    else
        log_error "Service could not be started!"
        log_info "Check the logs: sudo journalctl -u ${SERVICE_NAME} --no-pager"
        exit 1
    fi
}

main() {
    print_header
    
    log_info "Starting Traefik Manager installation..."
    echo
    
    check_root
    check_system
    install_dependencies
    install_nodejs
    create_user
    download_application
    install_app_dependencies
    configure_application
    create_systemd_service
    setup_firewall
    start_service
    
    log_success "Installation completed!"
}

# Handle script interruption
trap 'log_error "Installation interrupted!"; exit 1' INT TERM

# Run main function
main "$@"
