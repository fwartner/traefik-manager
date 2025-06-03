<template>
  <form @submit.prevent="handleSubmit" class="space-y-6">
    <div>
      <label for="hostname" class="block text-sm font-medium text-gray-700">
        Hostname *
      </label>
      <input 
        id="hostname"
        v-model="formData.hostname" 
        type="text" 
        required
        placeholder="example.domain.com"
        class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
      >
    </div>
    
    <div>
      <label for="target" class="block text-sm font-medium text-gray-700">
        Target IP *
      </label>
      <input 
        id="target"
        v-model="formData.target" 
        type="text" 
        required
        placeholder="192.168.1.100"
        class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
      >
    </div>
    
    <div>
      <label for="port" class="block text-sm font-medium text-gray-700">
        Port *
      </label>
      <input 
        id="port"
        v-model="formData.port" 
        type="number" 
        required
        min="1"
        max="65535"
        placeholder="8080"
        class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
      >
    </div>
    
    <div>
      <label class="flex items-center">
        <input 
          v-model="formData.tls" 
          type="checkbox"
          class="rounded border-gray-300 text-blue-600 shadow-sm focus:ring-blue-500"
        >
        <span class="ml-2 text-sm text-gray-700">Enable TLS</span>
      </label>
    </div>
    
    <div v-if="error" class="text-red-600 text-sm">
      {{ error }}
    </div>
    
    <div class="flex justify-end space-x-3 pt-4">
      <NuxtLink 
        to="/"
        class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300 transition-colors"
      >
        Cancel
      </NuxtLink>
      <button 
        type="submit"
        :disabled="loading"
        class="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:opacity-50 transition-colors"
      >
        {{ loading ? 'Saving...' : submitText }}
      </button>
    </div>
  </form>
</template>

<script setup lang="ts">
import type { HostForm as HostFormData } from '~/composables/useHosts'

interface Props {
  initialData?: Partial<HostFormData>
  submitText?: string
  loading?: boolean
  error?: string | null
}

const props = withDefaults(defineProps<Props>(), {
  submitText: 'Save',
  loading: false,
  error: null
})

const emit = defineEmits<{
  submit: [data: HostFormData]
}>()

const formData = ref<HostFormData>({
  hostname: props.initialData?.hostname || '',
  target: props.initialData?.target || '',
  port: props.initialData?.port || '',
  tls: props.initialData?.tls || false,
  middlewares: props.initialData?.middlewares || []
})

watch(() => props.initialData, (newData) => {
  if (newData) {
    formData.value = {
      hostname: newData.hostname || '',
      target: newData.target || '',
      port: newData.port || '',
      tls: newData.tls || false,
      middlewares: newData.middlewares || []
    }
  }
}, { deep: true })

const handleSubmit = () => {
  emit('submit', formData.value)
}
</script>
