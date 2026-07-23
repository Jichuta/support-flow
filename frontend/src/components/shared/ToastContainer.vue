<template>
  <div class="toast-wrapper">
    <v-snackbar
      v-for="toast in toasts"
      :key="toast.id"
      v-model="toast.visible"
      :color="snackbarColor(toast.type)"
      location="top right"
      :timeout="-1"
      multi-line
      class="toast-item"
    >
      {{ toast.message }}
      <template #actions>
        <v-btn variant="text" size="small" @click="remove(toast.id)">
          <v-icon>mdi-close</v-icon>
        </v-btn>
      </template>
    </v-snackbar>
  </div>
</template>

<script setup>
import { computed, watch } from 'vue'
import { useToastStore } from '@/stores/toastStore'

const toastStore = useToastStore()
const toasts = computed(() =>
  toastStore.toasts.map((t) => ({ ...t, visible: true }))
)
const remove = (id) => toastStore.remove(id)

function snackbarColor(type) {
  const map = {
    success: 'success',
    error: 'error',
    warning: 'warning',
    info: 'info'
  }
  return map[type] || 'info'
}
</script>

<style scoped>
.toast-wrapper {
  position: fixed;
  top: 16px;
  right: 16px;
  z-index: 9999;
  display: flex;
  flex-direction: column;
  gap: 8px;
  pointer-events: none;
}
.toast-item {
  pointer-events: auto;
}
</style>
