<template>
  <Teleport to="body">
    <div class="modal-overlay" @click="$emit('cancel')">
      <div class="modal" @click.stop>
        <div v-if="icon" class="modal-icon" :class="`modal-icon--${variant}`">{{ icon }}</div>
        <h3 class="modal-title">{{ title }}</h3>
        <p class="modal-message">{{ message }}</p>
        <div class="modal-actions">
          <button class="btn btn-secondary" @click="$emit('cancel')">
            {{ cancelLabel }}
          </button>
          <button class="btn btn-primary" @click="$emit('confirm')">
            {{ confirmLabel }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup>
defineProps({
  title: { type: String, required: true },
  message: { type: String, default: '' },
  icon: { type: String, default: '' },
  variant: { type: String, default: 'warning' },
  confirmLabel: { type: String, default: 'Confirm' },
  cancelLabel: { type: String, default: 'Cancel' }
})

defineEmits(['confirm', 'cancel'])
</script>
