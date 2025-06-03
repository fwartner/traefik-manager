<template>
  <div class="text-center py-8">
    <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
    <p v-if="text" class="mt-2 text-sm text-gray-500">{{ text }}</p>
  </div>
</template>

<script setup lang="ts">
interface Props {
  text?: string
}

defineProps<Props>()
</script>
