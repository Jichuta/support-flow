<script setup>
import SupportRequestForm from '@/components/SupportRequestForm.vue'
defineProps({ id: { type: [String, Number], required: true } })
</script>
<template>
  <SupportRequestForm :request-id="id" />
</template>
