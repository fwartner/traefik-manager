import { checkTraefikConfig } from '~/utils/traefik'

export default defineEventHandler(async (event) => {
  const config = await checkTraefikConfig()
  
  return {
    status: config.isConfigured ? 'healthy' : 'unhealthy',
    traefik: {
      configured: config.isConfigured,
      configDir: config.configDir,
      error: config.error || null
    },
    timestamp: new Date().toISOString()
  }
})
