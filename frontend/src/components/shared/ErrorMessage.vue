<template>
  <div class="alert alert-error" role="alert">
    <span>{{ message }}</span>
    <button v-if="retryable" class="btn btn-sm btn-outline ml-2" @click="$emit('retry')">
      Retry
    </button>
  </div>
</template>

<script setup>
defineProps({
  message: { type: String, default: 'Something went wrong.' },
  retryable: { type: Boolean, default: false }
})

defineEmits(['retry'])
</script>
