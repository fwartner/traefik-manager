import { unlink } from 'fs/promises'
import { join } from 'path'
import { checkTraefikConfig } from '~/utils/traefik'

export default defineEventHandler(async (event) => {
  const id = getRouterParam(event, 'id')
  
  if (!id) {
    throw createError({
      statusCode: 400,
      statusMessage: 'Host ID is required'
    })
  }

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
    const filename = `${id}.yml`
    const filePath = join(config.configDir, filename)
    
    await unlink(filePath)
    
    return {
      success: true,
      message: 'Host configuration deleted successfully'
    }
  } catch (error) {
    if ((error as any).code === 'ENOENT') {
      throw createError({
        statusCode: 404,
        statusMessage: 'Host configuration not found'
      })
    }
    
    throw createError({
      statusCode: 500,
      statusMessage: 'Failed to delete host configuration'
    })
  }
})
