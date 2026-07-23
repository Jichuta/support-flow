<template>
  <div class="text-center py-16">
    <v-icon v-if="icon" :icon="icon" size="64" color="grey-lighten-1" class="mb-4" />
    <h3 class="text-h6 font-weight-bold mb-2">{{ title }}</h3>
    <p v-if="subtitle" class="text-body-2 text-medium-emphasis mb-4">{{ subtitle }}</p>
    <slot />
  </div>
</template>

<script setup>
defineProps({
  icon: { type: String, default: '' },
  title: { type: String, required: true },
  subtitle: { type: String, default: '' }
})
</script>
