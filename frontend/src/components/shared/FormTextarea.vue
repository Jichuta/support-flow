<template>
  <v-textarea
    :model-value="modelValue"
    :label="label"
    :placeholder="placeholder"
    :rows="rows"
    :error-messages="error ? [error] : []"
    density="comfortable"
    variant="outlined"
    color="primary"
    hide-details="auto"
    @update:model-value="$emit('update:modelValue', $event)"
  />
</template>

<script setup>
defineProps({
  modelValue: { type: String, default: '' },
  label: { type: String, default: '' },
  placeholder: { type: String, default: '' },
  rows: { type: Number, default: 4 },
  error: { type: String, default: '' }
})

defineEmits(['update:modelValue'])
</script>
