<template>
  <div class="min-h-screen bg-gray-50">
    <nav class="bg-white shadow-sm border-b">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex items-center">
            <NuxtLink to="/" class="text-xl font-semibold text-gray-900 hover:text-gray-700">
              Traefik Manager
            </NuxtLink>
          </div>
          <div class="flex items-center space-x-4">
            <NuxtLink 
              to="/hosts/create"
              class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors disabled:opacity-50"
              :class="{ 'pointer-events-none opacity-50': isConfigurationUnavailable }"
            >
              Add New Host
            </NuxtLink>
          </div>
        </div>
      </div>
    </nav>

    <main class="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
      <slot />
    </main>
  </div>
</template>

<script setup lang="ts">
const { configurationError } = useHosts()

const isConfigurationUnavailable = computed(() => {
  return configurationError.value?.configured === false
})
</script>
