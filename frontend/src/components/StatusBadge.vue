<template>
  <span class="status-badge" :class="badgeClass">
    {{ label }}
  </span>
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

const badgeClass = computed(() => `status-${props.status}`)
</script>

<style scoped>
.status-badge {
  display: inline-flex;
  align-items: center;
  padding: 3px 10px;
  border-radius: 9999px;
  font-size: 12px;
  font-weight: 600;
  line-height: 1.4;
  white-space: nowrap;
}

.status-open {
  background-color: #dbeafe;
  color: #1e40af;
}

.status-in_progress {
  background-color: #fef3c7;
  color: #92400e;
}

.status-resolved {
  background-color: #dcfce7;
  color: #166534;
}

.status-closed {
  background-color: #f3f4f6;
  color: #374151;
}
</style>
