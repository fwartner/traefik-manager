<template>
  <div>
    <div class="bg-white shadow rounded-lg">
      <div class="px-4 py-5 sm:p-6">
        <div class="mb-6">
          <nav class="flex" aria-label="Breadcrumb">
            <ol class="flex items-center space-x-4">
              <li>
                <NuxtLink to="/" class="text-gray-500 hover:text-gray-700 transition-colors">
                  Hosts
                </NuxtLink>
              </li>
              <li>
                <div class="flex items-center">
                  <svg class="flex-shrink-0 h-5 w-5 text-gray-400" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
                    <path d="M5.555 17.776l8-16 .894.448-8 16-.894-.448z" />
                  </svg>
                  <span class="ml-4 text-sm font-medium text-gray-900">Add new host</span>
                </div>
              </li>
            </ol>
          </nav>
        </div>

        <div class="mb-8">
          <h1 class="text-2xl font-bold text-gray-900">Add New Host</h1>
          <p class="mt-2 text-sm text-gray-600">
            Configure a new host for your Traefik installation.
          </p>
        </div>

        <div class="max-w-md">
          <HostForm 
            :loading="loading"
            :error="error"
            submit-text="Create host"
            @submit="handleSubmit"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { HostForm } from '~/composables/useHosts'

const { createHost } = useHosts()
const router = useRouter()

const loading = ref(false)
const error = ref<string | null>(null)

const handleSubmit = async (formData: HostForm) => {
  loading.value = true
  error.value = null

  const result = await createHost(formData)

  if (result.success) {
    await router.push('/')
  } else {
    error.value = result.error || 'Unknown error creating host'
  }

  loading.value = false
}

// SEO Meta
useHead({
  title: 'Add New Host - Traefik Manager',
  meta: [
    { name: 'description', content: 'Create a new host configuration for Traefik' }
  ]
})
</script>
