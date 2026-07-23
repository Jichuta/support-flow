<template>
  <div class="d-flex flex-column align-center justify-center py-16">
    <v-progress-circular
      indeterminate
      :size="sizeMap[size]"
      :width="widthMap[size]"
      color="primary"
    />
    <p v-if="message" class="text-body-2 text-medium-emphasis mt-4">{{ message }}</p>
  </div>
</template>

<script setup>
defineProps({
  message: { type: String, default: '' },
  size: { type: String, default: 'md' }
})

const sizeMap = { sm: 24, md: 40, lg: 56 }
const widthMap = { sm: 2, md: 3, lg: 4 }
</script>
