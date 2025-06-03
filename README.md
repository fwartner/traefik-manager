# Traefik Manager

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js](https://img.shields.io/badge/Node.js-20%2B-green.svg)](https://nodejs.org/)
[![Nuxt 3](https://img.shields.io/badge/Nuxt-3-00DC82.svg)](https://nuxt.com/)

A modern web interface for easy management of Traefik configurations. Built with Nuxt 3 and Tailwind CSS.

## ✨ Features

- **📊 Clear Host Management** - All Traefik hosts in one table
- **➕ Easy Adding** - Create new hosts with a click
- **✏️ Editing** - Edit existing hosts directly
- **🗑️ Deletion** - Remove hosts that are no longer needed
- **🔒 TLS Support** - Easily enable/disable SSL/TLS
- **🛡️ Robust Error Handling** - Works even without Traefik configuration
- **🚀 File-based Configuration** - Works with Traefik's Dynamic Configuration
- **📱 Responsive Design** - Works on desktop and mobile

## 🚀 Quick Start

### Option 1: Automatic Installation (recommended)

```bash
# Download and run the installation script
curl -fsSL https://raw.githubusercontent.com/fwartner/traefik-manager/main/install.sh | bash
```

### Option 2: Docker

```bash
# Use Docker Compose
curl -fsSL https://raw.githubusercontent.com/fwartner/traefik-manager/main/docker-compose.yml -o docker-compose.yml

# Adjust configuration
cp .env.example .env
# Edit .env according to your needs

# Start
docker-compose up -d
```

### Option 3: Manual Installation

```bash
# Clone repository
git clone https://github.com/fwartner/traefik-manager.git
cd traefik-manager

# Install dependencies
npm install

# Create configuration
cp .env.example .env
# Edit .env according to your needs

# For development
npm run dev

# For production
npm run build
npm run preview
```

## ⚙️ Configuration

### Environment Variables

```bash
# Port for the application
PORT=3000

# Traefik configuration directory
TRAEFIK_CONFIG_DIR=/etc/traefik/dynamic

# Production environment
NODE_ENV=production
```

### Traefik Integration

Make sure your Traefik configuration supports Dynamic Configuration:

```yaml
# traefik.yml
providers:
  file:
    directory: /etc/traefik/dynamic
    watch: true
```

## 🐋 Docker Setup

### With docker-compose (recommended)

```yaml
version: '3.8'

services:
  traefik-manager:
    image: ghcr.io/fwartner/traefik-manager:latest
    container_name: traefik-manager
    restart: unless-stopped
    
    ports:
      - "3000:3000"
    
    environment:
      - NODE_ENV=production
      - TRAEFIK_CONFIG_DIR=/etc/traefik/dynamic
    
    volumes:
      - /etc/traefik/dynamic:/etc/traefik/dynamic
    
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.traefik-manager.rule=Host(`manager.example.com`)"
      - "traefik.http.routers.traefik-manager.tls=true"
```

### Docker CLI

```bash
docker run -d \\
  --name traefik-manager \\
  --restart unless-stopped \\
  -p 3000:3000 \\
  -v /etc/traefik/dynamic:/etc/traefik/dynamic \\
  -e NODE_ENV=production \\
  -e TRAEFIK_CONFIG_DIR=/etc/traefik/dynamic \\
  ghcr.io/fwartner/traefik-manager:latest
```

## 🛠️ Systemd Service

After automatic installation, Traefik Manager runs as a systemd service:

```bash
# Check service status
sudo systemctl status traefik-manager

# Start/stop/restart service
sudo systemctl start traefik-manager
sudo systemctl stop traefik-manager
sudo systemctl restart traefik-manager

# View logs
sudo journalctl -u traefik-manager -f
```

## 📁 Directory Structure

```
/opt/traefik-manager/          # Application directory
├── .output/                   # Built application
├── .env                       # Environment variables
└── ...

/etc/traefik/dynamic/          # Traefik configuration files
├── host1.yml
├── host2.yml
└── ...
```

## 🔧 Development

```bash
# Clone repository
git clone https://github.com/fwartner/traefik-manager.git
cd traefik-manager

# Install dependencies
npm install

# Start development server
npm run dev

# Linting
npm run lint

# Run tests
npm run test

# Production build
npm run build
```

## 📋 Requirements

### System Requirements

- **Operating System**: Linux (Ubuntu 20.04+, Debian 11+, CentOS 8+)
- **Node.js**: Version 18 or higher
- **RAM**: At least 512 MB
- **Storage**: 200 MB free space
- **Network**: Port 3000 (configurable)

### Traefik Requirements

- **Traefik**: Version 2.0 or higher
- **Dynamic Configuration**: File Provider enabled
- **Permissions**: Read/write access to configuration directory

## 🚨 Security

### Production Recommendations

1. **Reverse Proxy**: Use Traefik or nginx as reverse proxy
2. **TLS**: Enable HTTPS for Traefik Manager
3. **Firewall**: Restrict access to trusted IPs
4. **User**: Runs as dedicated system user `traefik-manager`
5. **Permissions**: Minimal filesystem permissions

### Example Traefik Configuration

```yaml
# traefik-manager.yml
http:
  routers:
    traefik-manager:
      rule: "Host(`manager.example.com`)"
      service: traefik-manager-service
      tls:
        certResolver: letsencrypt
      middlewares:
        - auth

  services:
    traefik-manager-service:
      loadBalancer:
        servers:
          - url: "http://localhost:3000"

  middlewares:
    auth:
      basicAuth:
        users:
          - "admin:$2y$10$..."  # htpasswd generated
```

## 🔍 Troubleshooting

### Common Issues

**Service won't start**
```bash
# Check logs
sudo journalctl -u traefik-manager --no-pager

# Check configuration
sudo systemctl status traefik-manager
```

**Traefik configuration not found**
```bash
# Check directory permissions
ls -la /etc/traefik/dynamic/
sudo chown -R traefik-manager:traefik-manager /etc/traefik/dynamic/
```

**Port already in use**
```bash
# Check port usage
sudo netstat -tlnp | grep :3000

# Configure different port in .env
echo "PORT=3001" >> /opt/traefik-manager/.env
sudo systemctl restart traefik-manager
```

### Health Check

```bash
# API Health Check
curl http://localhost:3000/api/health

# Expected response
{
  "status": "healthy",
  "traefik": {
    "configured": true,
    "configDir": "/etc/traefik/dynamic"
  }
}
```

## 🤝 Contributing

Contributions are welcome! Please read the [Contributing Guidelines](CONTRIBUTING.md).

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## 👨‍💻 Author

**Florian Wartner**
- GitHub: [@fwartner](https://github.com/fwartner)
- Website: [wartner.io](https://wartner.io)

## 🙏 Acknowledgments

- [Nuxt.js](https://nuxt.com/) - The intuitive Vue framework
- [Tailwind CSS](https://tailwindcss.com/) - Utility-first CSS framework
- [Traefik](https://traefik.io/) - The cloud native application proxy

## 📊 Status

![GitHub Stars](https://img.shields.io/github/stars/fwartner/traefik-manager?style=social)
![GitHub Forks](https://img.shields.io/github/forks/fwartner/traefik-manager?style=social)
![GitHub Issues](https://img.shields.io/github/issues/fwartner/traefik-manager)
![GitHub Pull Requests](https://img.shields.io/github/issues-pr/fwartner/traefik-manager)

---

**⭐ If you like this project, give it a star on GitHub!**
