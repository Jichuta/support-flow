<template>
  <v-alert
    type="error"
    variant="tonal"
    rounded="lg"
    class="d-flex align-center"
  >
    <template #text>
      {{ message }}
    </template>
    <template #append v-if="retryable">
      <v-btn
        variant="outlined"
        size="small"
        color="error"
        class="ml-2"
        @click="$emit('retry')"
      >
        Retry
      </v-btn>
    </template>
  </v-alert>
</template>

<script setup>
defineProps({
  message: { type: String, default: 'Something went wrong.' },
  retryable: { type: Boolean, default: false }
})

defineEmits(['retry'])
</script>
