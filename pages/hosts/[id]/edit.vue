<template>
  <div>
    <div v-if="loadingHost">
      <LoadingSpinner text="Lade Host-Daten..." />
    </div>

    <div v-else-if="hostError" class="bg-white shadow rounded-lg">
      <div class="px-4 py-5 sm:p-6">
        <div class="text-red-600 text-center py-8">
          <div class="bg-red-50 border border-red-200 rounded-md p-4">
            <div class="flex">
              <div class="ml-3">
                <h3 class="text-sm font-medium text-red-800">
                  Host not found
                </h3>
                <div class="mt-2 text-sm text-red-700">
                  {{ hostError }}
                </div>
                <div class="mt-4">
                  <NuxtLink 
                    to="/"
                    class="bg-red-100 px-3 py-2 rounded-md text-sm font-medium text-red-800 hover:bg-red-200 transition-colors"
                  >
                    Back to overview
                  </NuxtLink>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-else class="bg-white shadow rounded-lg">
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
                  <span class="ml-4 text-sm font-medium text-gray-900">Edit {{ hostname }}</span>
                </div>
              </li>
            </ol>
          </nav>
        </div>

        <div class="mb-8">
          <h1 class="text-2xl font-bold text-gray-900">Edit Host</h1>
          <p class="mt-2 text-sm text-gray-600">
            Edit the configuration for <strong>{{ hostname }}</strong>.
          </p>
        </div>

        <div class="max-w-md">
          <HostForm 
            :initial-data="formData"
            :loading="loading"
            :error="error"
            submit-text="Save changes"
            @submit="handleSubmit"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { HostForm } from '~/composables/useHosts'

const route = useRoute()
const router = useRouter()
const { hosts, fetchHosts, updateHost, extractHostname, getHostById } = useHosts()

const hostId = route.params.id as string

const loading = ref(false)
const loadingHost = ref(true)
const error = ref<string | null>(null)
const hostError = ref<string | null>(null)

const host = ref()
const hostname = ref('')
const formData = ref<HostForm>({
  hostname: '',
  target: '',
  port: '',
  tls: false
})

// Lade Hosts falls noch nicht geladen
if (hosts.value.length === 0) {
  await fetchHosts()
}

// Finde den Host
host.value = getHostById(hostId)

if (!host.value) {
  hostError.value = `Host with ID "${hostId}" was not found.`
  loadingHost.value = false
} else {
  hostname.value = extractHostname(host.value.rule)
  
  // Extrahiere aktuelle Daten für das Formular
  // Da wir die vollständigen Daten nicht direkt verfügbar haben,
  // setzen wir die verfügbaren Werte
  formData.value = {
    hostname: hostname.value,
    target: '', // Würde aus der Service-Konfiguration extrahiert werden
    port: '',   // Würde aus der Service-Konfiguration extrahiert werden  
    tls: host.value.tls
  }
  
  loadingHost.value = false
}

const handleSubmit = async (newFormData: HostForm) => {
  loading.value = true
  error.value = null

  const result = await updateHost(hostId, newFormData)

  if (result.success) {
    await router.push('/')
  } else {
    error.value = result.error || 'Unknown error updating host'
  }

  loading.value = false
}

// SEO Meta
useHead({
  title: () => `Edit ${hostname.value} - Traefik Manager`,
  meta: [
    { name: 'description', content: () => `Edit the configuration for host ${hostname.value}` }
  ]
})
</script>
