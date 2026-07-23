<template>
  <v-navigation-drawer
    v-model="drawer"
    :rail="rail"
    @click="rail = false"
  >
    <div class="pa-4 d-flex align-center">
      <v-icon color="primary" size="28" class="mr-2">mdi-tools</v-icon>
      <span v-if="!rail" class="text-h6 font-weight-bold text-primary">SupportFlow</span>
    </div>

    <v-divider />

    <v-list nav density="comfortable">
      <v-list-item
        v-for="item in navItems"
        :key="item.to"
        :to="item.to"
        :exact="item.exact"
        :prepend-icon="item.icon"
        :title="item.label"
        rounded="lg"
      />
    </v-list>

    <template #append>
      <div class="pa-4 d-flex align-center">
        <v-avatar color="primary" size="32" class="mr-3">
          <span class="text-white text-caption font-weight-bold">E1</span>
        </v-avatar>
        <div v-if="!rail">
          <div class="text-body-2 font-weight-medium">Engineer 1</div>
          <div class="text-caption text-medium-emphasis">Developer</div>
        </div>
      </div>
    </template>
  </v-navigation-drawer>
</template>

<script setup>
import { ref } from 'vue'

const drawer = ref(true)
const rail = ref(false)

const navItems = [
  { to: '/', icon: 'mdi-view-dashboard-outline', label: 'Dashboard', exact: true },
  { to: '/requests', icon: 'mdi-ticket-outline', label: 'Requests' },
  { to: '/members', icon: 'mdi-account-group-outline', label: 'Team Members' }
]
</script>
