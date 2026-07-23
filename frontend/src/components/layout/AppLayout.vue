<template>
  <v-app>
    <AppSidebar />
    <v-app-bar flat border>
      <v-app-bar-title>{{ title }}</v-app-bar-title>
      <template #append>
        <slot name="top-bar-actions" />
      </template>
    </v-app-bar>
    <v-main>
      <v-container fluid class="pa-6">
        <RouterView />
      </v-container>
    </v-main>
    <ToastContainer />
  </v-app>
</template>

<script setup>
import { computed } from 'vue'
import { RouterView, useRoute } from 'vue-router'
import AppSidebar from '@/components/layout/AppSidebar.vue'
import ToastContainer from '@/components/shared/ToastContainer.vue'

const route = useRoute()

const title = computed(() => {
  const titles = {
    Dashboard: 'Dashboard',
    RequestList: 'Support Requests',
    TeamMembers: 'Team Members'
  }
  return titles[route.name] || 'SupportFlow'
})
</script>
