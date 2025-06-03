<template>
  <div class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
    <table class="min-w-full divide-y divide-gray-300">
      <thead class="bg-gray-50">
        <tr>
          <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
            Hostname
          </th>
          <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
            Service
          </th>
          <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
            TLS
          </th>
          <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
            Actions
          </th>
        </tr>
      </thead>
      <tbody class="bg-white divide-y divide-gray-200">
        <tr v-for="host in hosts" :key="host.id">
          <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
            {{ extractHostname(host.rule) }}
          </td>
          <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
            {{ host.service }}
          </td>
          <td class="px-6 py-4 whitespace-nowrap">
            <TlsBadge :enabled="host.tls" />
          </td>
          <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
            <div class="flex justify-end space-x-2">
              <NuxtLink 
                :to="`/hosts/${host.id}/edit`"
                class="text-blue-600 hover:text-blue-900 px-3 py-1 rounded hover:bg-blue-50 transition-colors"
              >
                Edit
              </NuxtLink>
              <button 
                @click="$emit('delete', host)"
                class="text-red-600 hover:text-red-900 px-3 py-1 rounded hover:bg-red-50 transition-colors"
              >
                Delete
              </button>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup lang="ts">
import type { Host } from '~/composables/useHosts'

interface Props {
  hosts: readonly Host[]
}

defineProps<Props>()
defineEmits<{
  delete: [host: Host]
}>()

const { extractHostname } = useHosts()
</script>
