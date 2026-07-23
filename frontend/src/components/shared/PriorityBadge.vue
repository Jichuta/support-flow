<template>
  <v-chip
    :color="chipColor"
    size="small"
    label
    variant="flat"
  >
    {{ label }}
  </v-chip>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  priority: {
    type: String,
    required: true
  }
})

const label = computed(() => {
  const map = {
    low: 'Low',
    medium: 'Medium',
    high: 'High',
    critical: 'Critical'
  }
  return map[props.priority] || props.priority
})

const chipColor = computed(() => {
  const map = {
    low: 'grey',
    medium: 'indigo',
    high: 'orange-darken-1',
    critical: 'red-darken-1'
  }
  return map[props.priority] || 'grey'
})
</script>
