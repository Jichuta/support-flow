<template>
  <v-select
    :model-value="modelValue"
    :label="label"
    :items="options"
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
  placeholder: { type: String, default: '' },
  options: { type: Array, default: () => [] },
  error: { type: String, default: '' }
})

defineEmits(['update:modelValue'])
</script>
