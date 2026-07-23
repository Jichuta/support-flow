<template>
  <div class="form-group">
    <label v-if="label" class="form-label" :for="inputId">{{ label }}</label>
    <select
      :id="inputId"
      :value="modelValue"
      class="form-input"
      :class="{ 'form-input--error': error }"
      @change="$emit('update:modelValue', $event.target.value)"
    >
      <option v-if="placeholder" value="">{{ placeholder }}</option>
      <option
        v-for="option in options"
        :key="option.value"
        :value="option.value"
      >
        {{ option.label }}
      </option>
    </select>
    <span v-if="error" class="form-error">{{ error }}</span>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: { type: String, default: '' },
  label: { type: String, default: '' },
  placeholder: { type: String, default: '' },
  options: { type: Array, default: () => [] },
  error: { type: String, default: '' },
  id: { type: String, default: '' }
})

defineEmits(['update:modelValue'])

const inputId = computed(() => props.id || `select-${props.label?.toLowerCase().replace(/\s+/g, '-') || 'field'}`)
</script>
