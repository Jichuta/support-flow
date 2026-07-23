<template>
  <Teleport to="body">
    <div class="panel-overlay" @click="$emit('close')">
      <div class="panel" @click.stop>
        <div class="panel-header">
          <h3 class="panel-title">{{ title }}</h3>
          <button class="panel-close" @click="$emit('close')">&times;</button>
        </div>
        <div class="panel-body">
          <slot />
        </div>
        <div v-if="$slots.footer" class="panel-footer">
          <slot name="footer" />
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup>
defineProps({
  title: { type: String, required: true }
})

defineEmits(['close'])
</script>
