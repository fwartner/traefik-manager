<template>
  <div class="bg-white shadow rounded-lg">
    <div class="px-4 py-5 sm:p-6">
      <div class="text-center py-12">
        <div class="text-red-400 mb-4">
          <svg class="mx-auto h-16 w-16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z" />
          </svg>
        </div>
        
        <h3 class="text-xl font-semibold text-gray-900 mb-4">
          Traefik configuration not available
        </h3>
        
        <div class="max-w-md mx-auto text-left bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
          <h4 class="font-medium text-red-800 mb-2">Missing configuration:</h4>
          <p class="text-sm text-red-700 mb-3">{{ error }}</p>
          
          <div class="text-xs text-red-600">
            <strong>Expected path:</strong><br>
            <code class="bg-red-100 px-1 py-0.5 rounded">{{ configDir }}</code>
          </div>
        </div>

        <div class="space-y-4">
          <div class="text-sm text-gray-600 text-left max-w-lg mx-auto">
            <h4 class="font-medium text-gray-900 mb-2">How to fix this:</h4>
            <ol class="list-decimal list-inside space-y-1">
              <li>Make sure Traefik is installed</li>
              <li>Create the configuration directory: 
                <code class="bg-gray-100 px-1 py-0.5 rounded text-xs">{{ configDir }}</code>
              </li>
              <li>Set the environment variable <code class="bg-gray-100 px-1 py-0.5 rounded text-xs">TRAEFIK_CONFIG_DIR</code> if needed</li>
              <li>Make sure the application has read/write permissions</li>
            </ol>
          </div>
          
          <div class="flex justify-center space-x-3">
            <button 
              @click="$emit('retry')"
              class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-red-600 hover:bg-red-700 transition-colors"
            >
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
              </svg>
              Try again
            </button>
            
            <a 
              href="https://doc.traefik.io/traefik/getting-started/configuration-overview/" 
              target="_blank"
              rel="noopener noreferrer"
              class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 transition-colors"
            >
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"></path>
              </svg>
              Traefik Documentation
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  error: string
  configDir: string
}

defineProps<Props>()
defineEmits<{
  retry: []
}>()
</script>
