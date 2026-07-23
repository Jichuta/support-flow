<template>
  <div class="request-list-page">
    <!-- Page Header -->
    <div class="page-header">
      <div>
        <h1 class="page-title">Support Requests</h1>
        <p class="page-subtitle">Manage, filter, and track technical support requests</p>
      </div>
      <router-link to="/requests/new" class="btn btn-primary mobile-only-btn">
        + New Request
      </router-link>
    </div>

    <!-- Filter Bar -->
    <div class="filter-card">
      <div class="filter-row">
        <!-- Search Input -->
        <div class="filter-group search-group">
          <label class="filter-label" for="search-input">Search</label>
          <div class="input-with-icon">
            <span class="search-icon">🔍</span>
            <input
              id="search-input"
              type="text"
              v-model="searchInput"
              @input="onSearchInput"
              placeholder="Search by title..."
              class="filter-input"
            />
          </div>
        </div>

        <!-- Status Filter -->
        <div class="filter-group">
          <label class="filter-label" for="status-filter">Status</label>
          <select
            id="status-filter"
            :value="store.filters.status"
            @change="onStatusChange"
            class="filter-select"
          >
            <option value="">All Statuses</option>
            <option value="open">Open</option>
            <option value="in_progress">In Progress</option>
            <option value="resolved">Resolved</option>
            <option value="closed">Closed</option>
          </select>
        </div>

        <!-- Priority Filter -->
        <div class="filter-group">
          <label class="filter-label" for="priority-filter">Priority</label>
          <select
            id="priority-filter"
            :value="store.filters.priority"
            @change="onPriorityChange"
            class="filter-select"
          >
            <option value="">All Priorities</option>
            <option value="low">Low</option>
            <option value="medium">Medium</option>
            <option value="high">High</option>
            <option value="critical">Critical</option>
          </select>
        </div>

        <!-- Toggle Checkboxes -->
        <div class="filter-group checkboxes-group">
          <span class="filter-label">Flags</span>
          <div class="checkbox-row">
            <label class="checkbox-label">
              <input
                type="checkbox"
                :checked="store.filters.overdue"
                @change="onOverdueChange"
                class="checkbox-input"
              />
              <span>Overdue</span>
            </label>
            <label class="checkbox-label">
              <input
                type="checkbox"
                :checked="store.filters.unassigned"
                @change="onUnassignedChange"
                class="checkbox-input"
              />
              <span>Unassigned</span>
            </label>
          </div>
        </div>
      </div>

      <!-- Clear Filters Button -->
      <div v-if="hasActiveFilters" class="clear-filters-row">
        <button @click="onClearFilters" class="btn btn-link btn-clear-filters">
          ✕ Clear Filters
        </button>
      </div>
    </div>

    <!-- Error State -->
    <div v-if="store.error" class="alert alert-error">
      <span>{{ store.error.message || 'Failed to load support requests.' }}</span>
      <button @click="store.fetchRequests()" class="btn btn-sm btn-outline ml-2">Retry</button>
    </div>

    <!-- Loading State: Table Skeleton -->
    <div v-if="store.loading" class="table-container">
      <table class="data-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Title</th>
            <th>Status</th>
            <th>Priority</th>
            <th>Assignee</th>
            <th>Due Date</th>
            <th class="text-right">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="i in 5" :key="i" class="skeleton-row">
            <td><div class="skeleton skeleton-text w-8"></div></td>
            <td><div class="skeleton skeleton-text w-48"></div></td>
            <td><div class="skeleton skeleton-badge"></div></td>
            <td><div class="skeleton skeleton-badge"></div></td>
            <td><div class="skeleton skeleton-text w-24"></div></td>
            <td><div class="skeleton skeleton-text w-20"></div></td>
            <td class="text-right"><div class="skeleton skeleton-btn"></div></td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Empty State -->
    <div v-else-if="store.requests.length === 0" class="empty-state">
      <div class="empty-icon">📂</div>
      <h3 class="empty-title">No requests found</h3>
      <p class="empty-subtitle">
        {{ hasActiveFilters ? 'Try adjusting your filters to find what you are looking for.' : 'No support requests have been created yet.' }}
      </p>
      <button v-if="hasActiveFilters" @click="onClearFilters" class="btn btn-secondary mt-3">
        Clear Filters
      </button>
    </div>

    <!-- Table Data View -->
    <div v-else class="table-container">
      <table class="data-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Title</th>
            <th>Status</th>
            <th>Priority</th>
            <th>Assignee</th>
            <th>Due Date</th>
            <th class="text-right">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="req in store.requests"
            :key="req.id"
            :class="{ 'row-overdue': req.overdue }"
          >
            <!-- ID -->
            <td class="id-cell">#{{ req.id }}</td>

            <!-- Title -->
            <td class="title-cell">
              <router-link :to="`/requests/${req.id}`" class="title-link">
                {{ req.title }}
              </router-link>
            </td>

            <!-- Status -->
            <td>
              <StatusBadge :status="req.status" />
            </td>

            <!-- Priority -->
            <td>
              <PriorityBadge :priority="req.priority" />
            </td>

            <!-- Assignee -->
            <td class="assignee-cell">
              <span v-if="req.assignee" class="assignee-name">
                👤 {{ req.assignee.name }}
              </span>
              <span v-else class="unassigned-tag">
                Unassigned
              </span>
            </td>

            <!-- Due Date -->
            <td class="due-date-cell">
              <span
                v-if="req.due_date"
                class="due-date-text"
                :class="{ 'due-date-overdue': req.overdue }"
              >
                {{ formatDate(req.due_date) }}
                <span v-if="req.overdue" class="overdue-badge">⚠ Overdue</span>
              </span>
              <span v-else class="no-due-date">—</span>
            </td>

            <!-- Actions -->
            <td class="actions-cell text-right">
              <div class="actions-group">
                <router-link :to="`/requests/${req.id}`" class="btn btn-sm btn-ghost">
                  View
                </router-link>
                <router-link :to="`/requests/${req.id}/edit`" class="btn btn-sm btn-outline">
                  Edit
                </router-link>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useSupportRequestStore } from '@/stores/supportRequestStore'
import StatusBadge from '@/components/shared/StatusBadge.vue'
import PriorityBadge from '@/components/shared/PriorityBadge.vue'

const store = useSupportRequestStore()
const searchInput = ref('')

let debounceTimer = null

const hasActiveFilters = computed(() => {
  const f = store.filters
  return Boolean(f.status || f.priority || f.overdue || f.unassigned || f.q)
})

const onSearchInput = (e) => {
  const val = e.target.value
  searchInput.value = val
  clearTimeout(debounceTimer)
  debounceTimer = setTimeout(() => {
    store.setFilter('q', val)
    store.fetchRequests()
  }, 300)
}

const onStatusChange = (e) => {
  store.setFilter('status', e.target.value)
  store.fetchRequests()
}

const onPriorityChange = (e) => {
  store.setFilter('priority', e.target.value)
  store.fetchRequests()
}

const onOverdueChange = (e) => {
  store.setFilter('overdue', e.target.checked)
  store.fetchRequests()
}

const onUnassignedChange = (e) => {
  store.setFilter('unassigned', e.target.checked)
  store.fetchRequests()
}

const onClearFilters = () => {
  searchInput.value = ''
  store.clearFilters()
  store.fetchRequests()
}

const formatDate = (dateStr) => {
  if (!dateStr) return '—'
  const date = new Date(dateStr + 'T00:00:00')
  return date.toLocaleDateString(undefined, {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

onMounted(() => {
  searchInput.value = store.filters.q || ''
  store.fetchRequests()
})
</script>

<style scoped>
.request-list-page {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.page-title {
  font-size: 24px;
  font-weight: 700;
  color: #111827;
  margin: 0 0 4px 0;
}

.page-subtitle {
  font-size: 14px;
  color: #6b7280;
  margin: 0;
}

.mobile-only-btn {
  display: none;
}

/* Filter Card */
.filter-card {
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 16px 20px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.filter-row {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr auto;
  gap: 16px;
  align-items: flex-end;
}

@media (max-width: 900px) {
  .filter-row {
    grid-template-columns: 1fr 1fr;
  }
  .mobile-only-btn {
    display: inline-flex;
  }
}

@media (max-width: 600px) {
  .filter-row {
    grid-template-columns: 1fr;
  }
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.filter-label {
  font-size: 12px;
  font-weight: 600;
  color: #374151;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.input-with-icon {
  position: relative;
  display: flex;
  align-items: center;
}

.search-icon {
  position: absolute;
  left: 12px;
  font-size: 14px;
  pointer-events: none;
}

.filter-input {
  width: 100%;
  padding: 8px 12px 8px 34px;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  font-size: 14px;
  outline: none;
  transition: border-color 0.2s, box-shadow 0.2s;
  box-sizing: border-box;
}

.filter-input:focus {
  border-color: #2563eb;
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15);
}

.filter-select {
  padding: 8px 12px;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  font-size: 14px;
  background-color: #ffffff;
  outline: none;
  transition: border-color 0.2s, box-shadow 0.2s;
  box-sizing: border-box;
}

.filter-select:focus {
  border-color: #2563eb;
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15);
}

.checkboxes-group {
  justify-content: flex-end;
}

.checkbox-row {
  display: flex;
  align-items: center;
  gap: 16px;
  height: 38px;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  font-weight: 500;
  color: #374151;
  cursor: pointer;
  user-select: none;
}

.checkbox-input {
  width: 16px;
  height: 16px;
  accent-color: #2563eb;
  cursor: pointer;
}

.clear-filters-row {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid #f3f4f6;
  display: flex;
  justify-content: flex-end;
}

.btn-clear-filters {
  color: #ef4444;
  font-size: 13px;
  font-weight: 600;
  text-decoration: none;
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 6px;
}

.btn-clear-filters:hover {
  background: #fef2f2;
}

/* Table */
.table-container {
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.data-table {
  width: 100%;
  border-collapse: collapse;
  text-align: left;
  font-size: 14px;
}

.data-table th {
  background: #f9fafb;
  padding: 12px 16px;
  font-size: 12px;
  font-weight: 600;
  color: #6b7280;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border-bottom: 1px solid #e5e7eb;
}

.data-table td {
  padding: 14px 16px;
  border-bottom: 1px solid #f3f4f6;
  vertical-align: middle;
}

.data-table tbody tr:last-child td {
  border-bottom: none;
}

.data-table tbody tr:hover {
  background: #f9fafb;
}

.row-overdue {
  background-color: rgba(254, 242, 242, 0.4);
}

.id-cell {
  font-family: ui-monospace, monospace;
  font-size: 13px;
  font-weight: 600;
  color: #6b7280;
  width: 60px;
}

.title-cell {
  max-width: 300px;
}

.title-link {
  font-weight: 600;
  color: #111827;
  text-decoration: none;
  transition: color 0.15s;
}

.title-link:hover {
  color: #2563eb;
  text-decoration: underline;
}

.assignee-cell {
  font-weight: 500;
}

.assignee-name {
  color: #374151;
}

.unassigned-tag {
  color: #9ca3af;
  font-style: italic;
}

.due-date-cell {
  white-space: nowrap;
}

.due-date-text {
  color: #4b5563;
}

.due-date-overdue {
  color: #dc2626;
  font-weight: 600;
}

.overdue-badge {
  display: inline-block;
  margin-left: 6px;
  font-size: 11px;
  font-weight: 700;
  color: #dc2626;
  background: #fee2e2;
  padding: 2px 6px;
  border-radius: 4px;
}

.no-due-date {
  color: #9ca3af;
}

.actions-cell {
  white-space: nowrap;
  width: 130px;
}

.actions-group {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 8px;
}

/* Skeleton Loading */
.skeleton-row td {
  padding: 16px;
}

.skeleton {
  background: linear-gradient(90deg, #f3f4f6 25%, #e5e7eb 50%, #f3f4f6 75%);
  background-size: 200% 100%;
  animation: loading 1.5s infinite;
  border-radius: 4px;
}

.skeleton-text {
  height: 14px;
}

.skeleton-badge {
  height: 22px;
  width: 70px;
  border-radius: 9999px;
}

.skeleton-btn {
  height: 28px;
  width: 50px;
  margin-left: auto;
}

.w-8 { width: 32px; }
.w-20 { width: 80px; }
.w-24 { width: 96px; }
.w-48 { width: 192px; }

@keyframes loading {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

/* Empty State */
.empty-state {
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 48px 24px;
  text-align: center;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.empty-icon {
  font-size: 40px;
  margin-bottom: 12px;
}

.empty-title {
  font-size: 18px;
  font-weight: 600;
  color: #111827;
  margin: 0 0 6px 0;
}

.empty-subtitle {
  font-size: 14px;
  color: #6b7280;
  margin: 0;
}

/* Buttons & Utilities */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 8px 16px;
  font-size: 14px;
  font-weight: 600;
  border-radius: 8px;
  border: 1px solid transparent;
  cursor: pointer;
  text-decoration: none;
  transition: all 0.15s ease;
  line-height: 1.4;
}

.btn-primary {
  background-color: #2563eb;
  color: #ffffff;
}

.btn-primary:hover {
  background-color: #1d4ed8;
}

.btn-secondary {
  background-color: #f3f4f6;
  color: #374151;
  border-color: #d1d5db;
}

.btn-secondary:hover {
  background-color: #e5e7eb;
}

.btn-outline {
  background-color: #ffffff;
  color: #374151;
  border-color: #d1d5db;
}

.btn-outline:hover {
  background-color: #f9fafb;
  border-color: #9ca3af;
  color: #111827;
}

.btn-ghost {
  background: transparent;
  color: #4b5563;
}

.btn-ghost:hover {
  background: #f3f4f6;
  color: #111827;
}

.btn-sm {
  padding: 4px 10px;
  font-size: 12px;
  border-radius: 6px;
}

.text-right {
  text-align: right;
}

.alert {
  padding: 12px 16px;
  border-radius: 8px;
  font-size: 14px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.alert-error {
  background-color: #fef2f2;
  color: #991b1b;
  border: 1px solid #fecaca;
}

.mt-3 { margin-top: 12px; }
.ml-2 { margin-left: 8px; }
</style>
