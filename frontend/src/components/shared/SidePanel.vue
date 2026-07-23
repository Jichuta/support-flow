<template>
  <v-navigation-drawer
    :model-value="true"
    location="right"
    temporary
    width="480"
    @update:model-value="$emit('close')"
  >
    <v-card flat rounded="0" class="d-flex flex-column h-100">
      <v-card-title class="d-flex justify-space-between align-center pa-4">
        <span class="text-h6 font-weight-bold">{{ title }}</span>
        <v-btn icon="mdi-close" variant="text" size="small" @click="$emit('close')" />
      </v-card-title>
      <v-divider />
      <v-card-text class="flex-grow-1 overflow-y-auto pa-4">
        <slot />
      </v-card-text>
      <v-divider v-if="$slots.footer" />
      <v-card-actions v-if="$slots.footer" class="pa-4 justify-end">
        <slot name="footer" />
      </v-card-actions>
    </v-card>
  </v-navigation-drawer>
</template>

<script setup>
defineProps({
  title: { type: String, required: true }
})

defineEmits(['close'])
</script>
