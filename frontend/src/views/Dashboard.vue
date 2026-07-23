<script setup>
import { computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { useDashboardStore } from '@/stores/dashboardStore'

const store = useDashboardStore()
const metrics = computed(() => store.metrics ?? {})
const statuses = computed(() => metrics.value.requests_by_status ?? {})
const priorities = computed(() => metrics.value.requests_by_priority ?? {})

const cards = computed(() => [
  { title: 'Total Requests', value: metrics.value.total_requests ?? 0, icon: 'mdi-ticket-outline', color: 'primary' },
  { title: 'Open', value: statuses.value.open ?? 0, icon: 'mdi-folder-open-outline', color: 'blue' },
  { title: 'In Progress', value: statuses.value.in_progress ?? 0, icon: 'mdi-progress-clock', color: 'amber-darken-2' },
  { title: 'Resolved', value: statuses.value.resolved ?? 0, icon: 'mdi-check-circle-outline', color: 'green' }
])

const priorityNames = ['low', 'medium', 'high', 'critical']
const priorityColors = { low: 'grey', medium: 'indigo', high: 'orange-darken-1', critical: 'red-darken-1' }

onMounted(() => store.fetchMetrics().catch(() => {}))
</script>

<template>
  <div>
    <div class="d-flex align-center justify-space-between mb-6">
      <div>
        <h2 class="text-h5 font-weight-bold mb-1">Support request overview</h2>
        <p class="text-body-2 text-medium-emphasis">Current request activity across the support team.</p>
      </div>
      <v-btn variant="outlined" :to="{ name: 'RequestList' }">
        View all requests
      </v-btn>
    </div>

    <!-- Loading -->
    <v-row v-if="store.loading && !store.metrics" class="mb-6">
      <v-col v-for="n in 4" :key="n" cols="12" sm="6" md="3">
        <v-skeleton-loader type="card" />
      </v-col>
    </v-row>

    <!-- Error -->
    <v-alert v-else-if="store.error" type="error" variant="tonal" rounded="lg" class="mb-6">
      Unable to load dashboard metrics.
      <template #append>
        <v-btn variant="outlined" size="small" color="error" @click="store.fetchMetrics()">Try again</v-btn>
      </template>
    </v-alert>

    <template v-else>
      <!-- Metric Cards -->
      <v-row class="mb-6">
        <v-col v-for="card in cards" :key="card.title" cols="12" sm="6" md="3">
          <v-card rounded="lg" class="pa-4">
            <div class="d-flex align-center justify-space-between mb-2">
              <span class="text-body-2 text-medium-emphasis">{{ card.title }}</span>
              <v-icon :color="card.color" size="20">{{ card.icon }}</v-icon>
            </div>
            <div class="text-h4 font-weight-bold">{{ card.value }}</div>
          </v-card>
        </v-col>
      </v-row>

      <v-row>
        <!-- Priority Breakdown -->
        <v-col cols="12" md="6">
          <v-card rounded="lg">
            <v-card-title class="text-subtitle-1 font-weight-bold">Requests by Priority</v-card-title>
            <v-list density="comfortable">
              <v-list-item v-for="name in priorityNames" :key="name">
                <template #prepend>
                  <v-chip :color="priorityColors[name]" size="small" label class="mr-3" style="width: 70px; justify-content: center;">
                    {{ name }}
                  </v-chip>
                </template>
                <v-list-item-title class="font-weight-bold">{{ priorities[name] ?? 0 }}</v-list-item-title>
              </v-list-item>
            </v-list>
          </v-card>
        </v-col>
      </v-row>
    </template>
  </div>
</template>
