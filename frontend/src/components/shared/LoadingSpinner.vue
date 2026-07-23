<template>
  <div class="loading-spinner">
    <div class="spinner" :class="`spinner--${size}`" />
    <span v-if="message" class="spinner-message">{{ message }}</span>
  </div>
</template>

<script setup>
defineProps({
  message: { type: String, default: '' },
  size: { type: String, default: 'md' }
})
</script>
