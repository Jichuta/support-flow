<template>
  <div class="form-group">
    <label v-if="label" class="form-label" :for="inputId">{{ label }}</label>
    <textarea
      :id="inputId"
      :value="modelValue"
      :placeholder="placeholder"
      :rows="rows"
      class="form-input"
      :class="{ 'form-input--error': error }"
      @input="$emit('update:modelValue', $event.target.value)"
    />
    <span v-if="error" class="form-error">{{ error }}</span>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: { type: String, default: '' },
  label: { type: String, default: '' },
  placeholder: { type: String, default: '' },
  rows: { type: Number, default: 4 },
  error: { type: String, default: '' },
  id: { type: String, default: '' }
})

defineEmits(['update:modelValue'])

const inputId = computed(
  () => props.id || `textarea-${props.label?.toLowerCase().replace(/\s+/g, '-') || 'field'}`
)
</script>
