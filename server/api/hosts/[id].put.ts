import { readFile, writeFile } from 'fs/promises'
import { join } from 'path'
import yaml from 'js-yaml'
import { ensureTraefikConfigDir } from '~/utils/traefik'

export default defineEventHandler(async (event) => {
  const id = getRouterParam(event, 'id')
  const body = await readBody(event)
  
  if (!body.hostname || !body.target || !body.port) {
    throw createError({
      statusCode: 400,
      statusMessage: 'Missing required fields: hostname, target, port'
    })
  }

  const config = await ensureTraefikConfigDir()
  
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
    const filename = `${id}.yml`
    const filePath = join(config.configDir, filename)
    
    const hostConfig = {
      http: {
        routers: {
          [body.hostname.replace(/\./g, '-')]: {
            rule: `Host(\`${body.hostname}\`)`,
            service: `${body.hostname.replace(/\./g, '-')}-service`,
            tls: body.tls || false,
            ...(body.middlewares && body.middlewares.length > 0 && { middlewares: body.middlewares })
          }
        },
        services: {
          [`${body.hostname.replace(/\./g, '-')}-service`]: {
            loadBalancer: {
              servers: [
                {
                  url: `http://${body.target}:${body.port}`
                }
              ]
            }
          }
        }
      }
    }
    
    const yamlContent = yaml.dump(hostConfig, { indent: 2 })
    await writeFile(filePath, yamlContent, 'utf-8')
    
    return {
      success: true,
      filename,
      message: 'Host configuration updated successfully'
    }
  } catch (error) {
    throw createError({
      statusCode: 500,
      statusMessage: 'Failed to update host configuration'
    })
  }
})
