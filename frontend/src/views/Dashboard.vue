<script setup>
import { computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { useDashboardStore } from '@/stores/dashboardStore'

const store = useDashboardStore()
const metrics = computed(() => store.metrics ?? {})
const statuses = computed(() => metrics.value.requests_by_status ?? {})
const priorities = computed(() => metrics.value.requests_by_priority ?? {})
const teams = computed(() => metrics.value.requests_by_team ?? [])
const cards = computed(() => [
  ['Total Requests', metrics.value.total_requests ?? 0],
  ['Open', statuses.value.open ?? 0],
  ['In Progress', statuses.value.in_progress ?? 0],
  ['Resolved', statuses.value.resolved ?? 0]
])
const priorityNames = ['low', 'medium', 'high', 'critical']
onMounted(() => store.fetchMetrics().catch(() => {}))
</script>

<template>
  <section class="dashboard">
    <header>
      <div>
        <h2>Support request overview</h2>
        <p>Current request activity across the support team.</p>
      </div>
      <RouterLink :to="{ name: 'RequestList' }">View all requests</RouterLink>
    </header>
    <div v-if="store.loading && !store.metrics" class="metrics" aria-label="Loading dashboard">
      <div v-for="n in 4" :key="n" class="card skeleton" />
    </div>
    <div v-else-if="store.error" class="error" role="alert">
      Unable to load dashboard metrics. <button @click="store.fetchMetrics()">Try again</button>
    </div>
    <template v-else>
      <div class="metrics">
        <article v-for="card in cards" :key="card[0]" class="card">
          <span>{{ card[0] }}</span
          ><strong>{{ card[1] }}</strong>
        </article>
      </div>
      <div class="breakdowns">
        <article class="panel">
          <h3>Requests by Priority</h3>
          <ul>
            <li v-for="name in priorityNames" :key="name">
              <span :class="['priority', name]">{{ name }}</span
              ><strong>{{ priorities[name] ?? 0 }}</strong>
            </li>
          </ul>
        </article>
        <article class="panel">
          <h3>Requests by Team</h3>
          <ul v-if="teams.length">
            <li v-for="team in teams" :key="team.name">
              <span>{{ team.name }}</span
              ><strong>{{ team.count }}</strong>
            </li>
          </ul>
          <p v-else>No team request assignments yet.</p>
        </article>
      </div>
    </template>
  </section>
</template>

<style scoped>
.dashboard {
  max-width: 1100px;
  margin: auto;
  color: #1f2937;
}
.dashboard header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}
.dashboard h2,
.panel h3 {
  margin: 0;
  color: #111827;
}
.dashboard p {
  color: #6b7280;
}
.dashboard a,
.error button {
  background: #2563eb;
  color: #fff;
  border: 0;
  border-radius: 6px;
  padding: 9px 14px;
  text-decoration: none;
  cursor: pointer;
}
.metrics,
.breakdowns {
  display: grid;
  gap: 16px;
}
.metrics {
  grid-template-columns: repeat(4, 1fr);
}
.breakdowns {
  grid-template-columns: repeat(2, 1fr);
  margin-top: 24px;
}
.card,
.panel {
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 20px;
}
.card span {
  display: block;
  color: #6b7280;
  font-size: 14px;
}
.card strong {
  display: block;
  margin-top: 8px;
  color: #111827;
  font-size: 32px;
}
.panel ul {
  list-style: none;
  padding: 0;
  margin: 12px 0 0;
}
.panel li {
  display: flex;
  justify-content: space-between;
  padding: 10px 0;
  border-top: 1px solid #f1f5f9;
}
.priority {
  border-radius: 999px;
  padding: 3px 8px;
  font-size: 12px;
  text-transform: capitalize;
}
.low {
  background: #dcfce7;
  color: #166534;
}
.medium {
  background: #dbeafe;
  color: #1d4ed8;
}
.high {
  background: #fef3c7;
  color: #92400e;
}
.critical {
  background: #fee2e2;
  color: #b91c1c;
}
.skeleton {
  min-height: 60px;
  background: #e5e7eb;
  animation: pulse 1.4s infinite;
}
.error {
  padding: 20px;
  background: #fef2f2;
  color: #991b1b;
  border-radius: 8px;
}
@keyframes pulse {
  50% {
    opacity: 0.45;
  }
}
@media (max-width: 800px) {
  .metrics {
    grid-template-columns: repeat(2, 1fr);
  }
  .breakdowns {
    grid-template-columns: 1fr;
  }
}
@media (max-width: 520px) {
  .dashboard header {
    align-items: flex-start;
    flex-direction: column;
    gap: 12px;
  }
  .metrics {
    grid-template-columns: 1fr;
  }
}
</style>
