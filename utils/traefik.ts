import { access, mkdir } from 'fs/promises'
import { join } from 'path'

export interface TraefikConfig {
  isConfigured: boolean
  configDir: string
  error?: string
}

export async function checkTraefikConfig(): Promise<TraefikConfig> {
  const configDir = process.env.TRAEFIK_CONFIG_DIR || '/etc/traefik/dynamic'
  
  try {
    await access(configDir)
    return {
      isConfigured: true,
      configDir
    }
  } catch (error) {
    return {
      isConfigured: false,
      configDir,
      error: `Traefik-Konfigurationsverzeichnis nicht gefunden: ${configDir}`
    }
  }
}

export async function ensureTraefikConfigDir(): Promise<TraefikConfig> {
  const configDir = process.env.TRAEFIK_CONFIG_DIR || '/etc/traefik/dynamic'
  
  try {
    await access(configDir)
    return {
      isConfigured: true,
      configDir
    }
  } catch (error) {
    // Versuche das Verzeichnis zu erstellen
    try {
      await mkdir(configDir, { recursive: true })
      return {
        isConfigured: true,
        configDir
      }
    } catch (createError) {
      return {
        isConfigured: false,
        configDir,
        error: `Kann Traefik-Konfigurationsverzeichnis nicht erstellen: ${configDir}. Fehler: ${(createError as Error).message}`
      }
    }
  }
}
