<template>
  <span 
    :class="enabled ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'" 
    class="inline-flex px-2 py-1 text-xs font-semibold rounded-full"
  >
    {{ enabled ? 'Enabled' : 'Disabled' }}
  </span>
</template>

<script setup lang="ts">
interface Props {
  enabled: boolean
}

defineProps<Props>()
</script>
