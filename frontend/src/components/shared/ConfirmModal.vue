<template>
  <v-dialog :model-value="true" max-width="420" persistent>
    <v-card rounded="lg" class="text-center pa-4">
      <v-avatar v-if="icon" :color="avatarColor" size="56" class="mb-4 mx-auto">
        <v-icon :color="iconTextColor" size="28">{{ icon }}</v-icon>
      </v-avatar>
      <v-card-title class="text-h6 justify-center">{{ title }}</v-card-title>
      <v-card-text class="text-medium-emphasis">{{ message }}</v-card-text>
      <v-card-actions class="justify-center">
        <v-btn variant="outlined" @click="$emit('cancel')">{{ cancelLabel }}</v-btn>
        <v-btn color="primary" @click="$emit('confirm')">{{ confirmLabel }}</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  title: { type: String, required: true },
  message: { type: String, default: '' },
  icon: { type: String, default: '' },
  variant: { type: String, default: 'warning' },
  confirmLabel: { type: String, default: 'Confirm' },
  cancelLabel: { type: String, default: 'Cancel' }
})

defineEmits(['confirm', 'cancel'])

const avatarColor = computed(() => {
  const map = { warning: 'warning', danger: 'error', info: 'info' }
  return map[props.variant] || 'warning'
})

const iconTextColor = computed(() => {
  const map = { warning: 'white', danger: 'white', info: 'white' }
  return map[props.variant] || 'white'
})
</script>
