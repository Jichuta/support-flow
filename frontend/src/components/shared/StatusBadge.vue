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
  status: {
    type: String,
    required: true
  }
})

const label = computed(() => {
  const map = {
    open: 'Open',
    in_progress: 'In Progress',
    resolved: 'Resolved',
    closed: 'Closed'
  }
  return map[props.status] || props.status
})

const chipColor = computed(() => {
  const map = {
    open: 'blue',
    in_progress: 'amber-darken-2',
    resolved: 'green-darken-1',
    closed: 'grey'
  }
  return map[props.status] || 'grey'
})
</script>
