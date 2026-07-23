<template>
  <div>
    <!-- Page Header -->
    <div class="d-flex align-center justify-space-between mb-5">
      <div>
        <h1 class="text-h5 font-weight-bold">Support Requests</h1>
        <p class="text-body-2 text-medium-emphasis">Manage, filter, and track technical support requests</p>
      </div>
      <v-btn color="primary" class="d-none d-sm-flex" @click="openCreate">
        <v-icon start>mdi-plus</v-icon>
        New Request
      </v-btn>
    </div>

    <!-- Filter Bar -->
    <v-card rounded="lg" class="mb-5 pa-4">
      <v-row dense>
        <v-col cols="12" md="4">
          <v-text-field
            v-model="searchInput"
            label="Search"
            placeholder="Search by title..."
            prepend-inner-icon="mdi-magnify"
            density="comfortable"
            variant="outlined"
            hide-details
            clearable
            @update:model-value="onSearchInput"
          />
        </v-col>
        <v-col cols="12" sm="6" md="3">
          <v-select
            :model-value="store.filters.status"
            label="Status"
            :items="statusOptions"
            density="comfortable"
            variant="outlined"
            hide-details
            @update:model-value="onStatusChange"
          />
        </v-col>
        <v-col cols="12" sm="6" md="3">
          <v-select
            :model-value="store.filters.priority"
            label="Priority"
            :items="priorityOptions"
            density="comfortable"
            variant="outlined"
            hide-details
            @update:model-value="onPriorityChange"
          />
        </v-col>
        <v-col cols="12" md="2" class="d-flex align-center ga-4">
          <v-checkbox
            :model-value="store.filters.overdue"
            label="Overdue"
            density="comfortable"
            hide-details
            color="primary"
            @update:model-value="onOverdueChange"
          />
          <v-checkbox
            :model-value="store.filters.unassigned"
            label="Unassigned"
            density="comfortable"
            hide-details
            color="primary"
            @update:model-value="onUnassignedChange"
          />
        </v-col>
      </v-row>
      <div v-if="hasActiveFilters" class="d-flex justify-end mt-2">
        <v-btn variant="text" size="small" color="error" @click="onClearFilters">
          <v-icon start>mdi-close</v-icon>
          Clear Filters
        </v-btn>
      </div>
    </v-card>

    <!-- Error -->
    <v-alert v-if="store.error" type="error" variant="tonal" rounded="lg" class="mb-5">
      {{ store.error.message || 'Failed to load support requests.' }}
      <template #append>
        <v-btn variant="outlined" size="small" color="error" @click="store.fetchRequests()">Retry</v-btn>
      </template>
    </v-alert>

    <!-- Loading Skeleton -->
    <v-card v-if="store.loading" rounded="lg">
      <v-table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Title</th>
            <th>Status</th>
            <th>Priority</th>
            <th>Assignee</th>
            <th>Due Date</th>
            <th class="text-end">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="i in 5" :key="i">
            <td><v-skeleton-loader type="text" width="40" /></td>
            <td><v-skeleton-loader type="text" width="180" /></td>
            <td><v-skeleton-loader type="chip" width="80" /></td>
            <td><v-skeleton-loader type="chip" width="70" /></td>
            <td><v-skeleton-loader type="text" width="100" /></td>
            <td><v-skeleton-loader type="text" width="90" /></td>
            <td class="text-end"><v-skeleton-loader type="button" width="50" /></td>
          </tr>
        </tbody>
      </v-table>
    </v-card>

    <!-- Empty State -->
    <v-card v-else-if="store.requests.length === 0" rounded="lg">
      <EmptyState
        icon="mdi-folder-open-outline"
        title="No requests found"
        :subtitle="hasActiveFilters ? 'Try adjusting your filters to find what you are looking for.' : 'No support requests have been created yet.'"
      >
        <v-btn v-if="hasActiveFilters" variant="outlined" color="primary" class="mt-2" @click="onClearFilters">
          Clear Filters
        </v-btn>
      </EmptyState>
    </v-card>

    <!-- Data Table -->
    <v-card v-else rounded="lg">
      <v-table hover>
        <thead>
          <tr>
            <th>ID</th>
            <th>Title</th>
            <th>Status</th>
            <th>Priority</th>
            <th>Assignee</th>
            <th>Due Date</th>
            <th class="text-end">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="req in store.requests"
            :key="req.id"
            :class="{ 'bg-red-lighten-5': req.overdue }"
          >
            <td class="font-weight-bold text-medium-emphasis" style="font-family: monospace;">
              #{{ req.id }}
            </td>
            <td>
              <button class="text-primary font-weight-bold text-decoration-underline bg-transparent border-none cursor-pointer" @click="openView(req.id)">
                {{ req.title }}
              </button>
            </td>
            <td><StatusBadge :status="req.status" /></td>
            <td><PriorityBadge :priority="req.priority" /></td>
            <td>
              <span v-if="req.assignee" class="text-body-2">{{ req.assignee.name }}</span>
              <span v-else class="text-medium-emphasis font-italic">Unassigned</span>
            </td>
            <td>
              <div v-if="req.due_date">
                <span :class="{ 'text-red-darken-1 font-weight-bold': req.overdue }">
                  {{ formatDate(req.due_date) }}
                </span>
                <v-chip v-if="req.overdue" color="error" size="x-small" label class="ml-2">
                  Overdue
                </v-chip>
              </div>
              <span v-else class="text-medium-emphasis">&mdash;</span>
            </td>
            <td class="text-end">
              <v-btn size="small" variant="text" @click="openView(req.id)">View</v-btn>
              <v-btn size="small" variant="outlined" @click="openEdit(req.id)">Edit</v-btn>
            </td>
          </tr>
        </tbody>
      </v-table>
    </v-card>

    <!-- Create/Edit Side Panel -->
    <v-navigation-drawer
      v-model="panelOpen"
      location="right"
      temporary
      :width="520"
    >
      <SupportRequestForm
        v-if="panelOpen"
        :request-id="editingRequestId"
        @close="closePanel"
        @success="onPanelSuccess"
      />
    </v-navigation-drawer>

    <!-- View Detail Modal -->
    <RequestDetailModal
      v-model="viewDialogOpen"
      :request-id="viewingRequestId"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useSupportRequestStore } from '@/stores/supportRequestStore'
import StatusBadge from '@/components/shared/StatusBadge.vue'
import PriorityBadge from '@/components/shared/PriorityBadge.vue'
import EmptyState from '@/components/shared/EmptyState.vue'
import SupportRequestForm from '@/components/SupportRequestForm.vue'
import RequestDetailModal from '@/components/RequestDetailModal.vue'

const store = useSupportRequestStore()
const searchInput = ref('')

const panelOpen = ref(false)
const editingRequestId = ref(null)
const viewDialogOpen = ref(false)
const viewingRequestId = ref(null)

let debounceTimer = null

const statusOptions = [
  { title: 'All Statuses', value: '' },
  { title: 'Open', value: 'open' },
  { title: 'In Progress', value: 'in_progress' },
  { title: 'Resolved', value: 'resolved' },
  { title: 'Closed', value: 'closed' }
]

const priorityOptions = [
  { title: 'All Priorities', value: '' },
  { title: 'Low', value: 'low' },
  { title: 'Medium', value: 'medium' },
  { title: 'High', value: 'high' },
  { title: 'Critical', value: 'critical' }
]

const hasActiveFilters = computed(() => {
  const f = store.filters
  return Boolean(f.status || f.priority || f.overdue || f.unassigned || f.q)
})

function openCreate() { editingRequestId.value = null; panelOpen.value = true }
function openEdit(id) { editingRequestId.value = id; viewDialogOpen.value = false; panelOpen.value = true }
function closePanel() { panelOpen.value = false; editingRequestId.value = null }
function onPanelSuccess() { closePanel(); store.fetchRequests() }

function openView(id) { viewingRequestId.value = id; viewDialogOpen.value = true }

function onSearchInput(val) {
  clearTimeout(debounceTimer)
  debounceTimer = setTimeout(() => {
    store.setFilter('q', val || '')
    store.fetchRequests()
  }, 300)
}

function onStatusChange(val) { store.setFilter('status', val); store.fetchRequests() }
function onPriorityChange(val) { store.setFilter('priority', val); store.fetchRequests() }
function onOverdueChange(val) { store.setFilter('overdue', val); store.fetchRequests() }
function onUnassignedChange(val) { store.setFilter('unassigned', val); store.fetchRequests() }

function onClearFilters() {
  searchInput.value = ''
  store.clearFilters()
  store.fetchRequests()
}

function formatDate(dateStr) {
  if (!dateStr) return '—'
  const date = new Date(dateStr + 'T00:00:00')
  return date.toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' })
}

onMounted(() => {
  searchInput.value = store.filters.q || ''
  store.fetchRequests()
})
</script>
