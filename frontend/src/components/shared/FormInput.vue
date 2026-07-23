<template>
  <v-text-field
    :model-value="modelValue"
    :label="label"
    :type="type"
    :placeholder="placeholder"
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
  type: { type: String, default: 'text' },
  placeholder: { type: String, default: '' },
  error: { type: String, default: '' }
})

defineEmits(['update:modelValue'])
</script>
