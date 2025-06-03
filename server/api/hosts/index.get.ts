import { readdir, readFile } from 'fs/promises'
import { join } from 'path'
import yaml from 'js-yaml'
import { checkTraefikConfig } from '~/utils/traefik'

export default defineEventHandler(async (event) => {
  const config = await checkTraefikConfig()
  
  if (!config.isConfigured) {
    throw createError({
      statusCode: 503,
      statusMessage: 'Traefik configuration not available',
      data: {
        configured: false,
        error: config.error,
        configDir: config.configDir
      }
    })
  }

  try {
    const files = await readdir(config.configDir)
    const yamlFiles = files.filter(file => file.endsWith('.yml') || file.endsWith('.yaml'))
    
    const hosts = []
    
    for (const file of yamlFiles) {
      try {
        const content = await readFile(join(config.configDir, file), 'utf-8')
        const yamlConfig = yaml.load(content) as any
        
        if (yamlConfig.http?.routers) {
          for (const [routerName, router] of Object.entries(yamlConfig.http.routers)) {
            hosts.push({
              id: file.replace(/\.(yml|yaml)$/, ''),
              filename: file,
              routerName,
              rule: (router as any).rule,
              service: (router as any).service,
              middlewares: (router as any).middlewares || [],
              tls: (router as any).tls || false
            })
          }
        }
      } catch (error) {
        console.error(`Error reading ${file}:`, error)
      }
    }
    
    return { 
      data: hosts,
      configured: true,
      configDir: config.configDir
    }
  } catch (error) {
    throw createError({
      statusCode: 500,
      statusMessage: 'Failed to read Traefik configuration files',
      data: {
        configured: true,
        error: (error as Error).message,
        configDir: config.configDir
      }
    })
  }
})
