<template>
  <div>
    <!-- Configuration Error State -->
    <ConfigurationError 
      v-if="configurationError"
      :error="configurationError.error"
      :config-dir="configurationError.configDir"
      @retry="fetchHosts"
    />
    
    <!-- Normal Application State -->
    <div v-else class="bg-white shadow rounded-lg">
      <div class="px-4 py-5 sm:p-6">
        <div class="flex justify-between items-center mb-6">
          <h1 class="text-2xl font-bold text-gray-900">Managed Hosts</h1>
          <div class="text-sm text-gray-500">
            {{ hosts.length }} {{ hosts.length === 1 ? 'host' : 'hosts' }} configured
          </div>
        </div>
        
        <div v-if="pending">
          <LoadingSpinner text="Loading hosts..." />
        </div>
        
        <div v-else-if="error" class="text-red-600 text-center py-8">
          <div class="bg-red-50 border border-red-200 rounded-md p-4">
            <div class="flex">
              <div class="ml-3">
                <h3 class="text-sm font-medium text-red-800">
                  Error loading hosts
                </h3>
                <div class="mt-2 text-sm text-red-700">
                  {{ error }}
                </div>
                <div class="mt-4">
                  <button 
                    @click="fetchHosts"
                    class="bg-red-100 px-3 py-2 rounded-md text-sm font-medium text-red-800 hover:bg-red-200 transition-colors"
                  >
                    Try again
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <div v-else-if="hosts.length === 0" class="text-center py-12">
          <div class="text-gray-400 mb-4">
            <svg class="mx-auto h-12 w-12" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
            </svg>
          </div>
          <h3 class="text-lg font-medium text-gray-900 mb-2">No hosts configured</h3>
          <p class="text-gray-500 mb-6">Start by configuring your first host.</p>
          <NuxtLink 
            to="/hosts/create"
            class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 transition-colors"
          >
            Add first host
          </NuxtLink>
        </div>
        
        <div v-else>
          <HostTable :hosts="hosts" @delete="handleDeleteHost" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const { hosts, pending, error, configurationError, fetchHosts, deleteHost, extractHostname } = useHosts()

// Lade Hosts beim Seitenaufruf
await fetchHosts()

const handleDeleteHost = async (host: any) => {
  const hostname = extractHostname(host.rule)
  
  if (!confirm(`Really delete host "${hostname}"?`)) {
    return
  }
  
  const result = await deleteHost(host.id)
  
  if (!result.success) {
    alert(`Error deleting host: ${result.error}`)
  }
}

// SEO Meta
useHead({
  title: 'Traefik Manager - Host Overview',
  meta: [
    { name: 'description', content: 'Manage your Traefik hosts through a user-friendly web interface' }
  ]
})
</script>
