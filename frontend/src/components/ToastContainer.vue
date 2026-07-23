<script setup>
import { useToastStore } from '@/stores/toastStore'
const toastStore = useToastStore()
</script>
<template>
  <div class="toasts" aria-live="polite">
    <p v-for="toast in toastStore.toasts" :key="toast.id" :class="['toast', toast.type]" role="status">{{ toast.message }}<button type="button" aria-label="Dismiss" @click="toastStore.remove(toast.id)">x</button></p>
  </div>
</template>
<style scoped>
.toasts{position:fixed;right:20px;bottom:20px;z-index:200;width:min(360px,calc(100vw - 32px));display:grid;gap:8px}.toast{display:flex;justify-content:space-between;margin:0;padding:12px;border-radius:8px;background:#fff;box-shadow:0 8px 20px rgba(0,0,0,.16)}.success{background:#dcfce7;color:#166534}.error{background:#fee2e2;color:#991b1b}.toast button{border:0;background:transparent;color:inherit;cursor:pointer}
</style>
