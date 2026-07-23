<template>
  <span class="priority-badge" :class="badgeClass">
    {{ label }}
  </span>
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

const badgeClass = computed(() => `priority-${props.priority}`)
</script>

<style scoped>
.priority-badge {
  display: inline-flex;
  align-items: center;
  padding: 3px 10px;
  border-radius: 9999px;
  font-size: 12px;
  font-weight: 600;
  line-height: 1.4;
  white-space: nowrap;
}

.priority-low {
  background-color: #f3f4f6;
  color: #4b5563;
}

.priority-medium {
  background-color: #e0e7ff;
  color: #3730a3;
}

.priority-high {
  background-color: #ffedd5;
  color: #9a3412;
}

.priority-critical {
  background-color: #fee2e2;
  color: #991b1b;
}
</style>
