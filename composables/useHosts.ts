export interface Host {
  id: string
  filename: string
  routerName: string
  rule: string
  service: string
  middlewares: string[]
  tls: boolean
}

export interface HostForm {
  hostname: string
  target: string
  port: string | number
  tls: boolean
  middlewares?: string[]
}

export interface ConfigurationError {
  configured: boolean
  error: string
  configDir: string
}

export const useHosts = () => {
  const hosts = ref<Host[]>([])
  const pending = ref(false)
  const error = ref<string | null>(null)
  const configurationError = ref<ConfigurationError | null>(null)

  const fetchHosts = async () => {
    try {
      pending.value = true
      error.value = null
      configurationError.value = null
      
      const response = await $fetch<{ data: Host[], configured: boolean, configDir: string }>('/api/hosts')
      hosts.value = response.data || []
    } catch (err: any) {
      if (err.status === 503 && err.data?.configured === false) {
        configurationError.value = {
          configured: false,
          error: err.data.error,
          configDir: err.data.configDir
        }
      } else {
        error.value = err instanceof Error ? err.message : 'Error loading hosts'
      }
      console.error('Error fetching hosts:', err)
    } finally {
      pending.value = false
    }
  }

  const createHost = async (hostData: HostForm) => {
    try {
      await $fetch('/api/hosts', {
        method: 'POST',
        body: hostData
      })
      await fetchHosts()
      return { success: true }
    } catch (err: any) {
      if (err.status === 503 && err.data?.configured === false) {
        return { 
          success: false, 
          error: 'Traefik configuration not available',
          configurationError: err.data
        }
      }
      const message = err instanceof Error ? err.message : 'Error creating host'
      return { success: false, error: message }
    }
  }

  const updateHost = async (id: string, hostData: HostForm) => {
    try {
      await $fetch(`/api/hosts/${id}`, {
        method: 'PUT',
        body: hostData
      })
      await fetchHosts()
      return { success: true }
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Error updating host'
      return { success: false, error: message }
    }
  }

  const deleteHost = async (id: string) => {
    try {
      await $fetch(`/api/hosts/${id}`, {
        method: 'DELETE'
      })
      await fetchHosts()
      return { success: true }
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Error deleting host'
      return { success: false, error: message }
    }
  }

  const extractHostname = (rule: string): string => {
    const match = rule.match(/Host\(`([^`]+)`\)/)
    return match ? match[1] : rule
  }

  const getHostById = (id: string): Host | undefined => {
    return hosts.value.find(host => host.id === id)
  }

  return {
    hosts: readonly(hosts),
    pending: readonly(pending),
    error: readonly(error),
    configurationError: readonly(configurationError),
    fetchHosts,
    createHost,
    updateHost,
    deleteHost,
    extractHostname,
    getHostById
  }
}
