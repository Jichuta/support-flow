<template>
  <div>
    <!-- Page Header -->
    <div class="d-flex flex-column flex-sm-row align-start align-sm-center justify-space-between ga-3 mb-5">
      <div>
        <h1 class="text-h5 font-weight-bold">Team Members</h1>
        <p class="text-body-2 text-medium-emphasis">Manage your support team members and their roles</p>
      </div>
      <v-btn color="primary" @click="showAddPanel = true">
        <v-icon start>mdi-plus</v-icon>
        Add Member
      </v-btn>
    </div>

    <!-- Error -->
    <v-alert
      v-if="store.error"
      type="error"
      variant="tonal"
      rounded="lg"
      class="mb-5"
    >
      {{ store.error.message || 'Failed to load team members.' }}
      <template #append>
        <v-btn variant="outlined" size="small" color="error" @click="store.fetchMembers()">Retry</v-btn>
      </template>
    </v-alert>

    <!-- Loading -->
    <v-card v-if="store.loading" rounded="lg">
      <div class="overflow-x-auto">
        <v-table>
          <thead>
            <tr>
              <th>Name</th>
              <th class="d-none d-sm-table-cell">Email</th>
              <th>Role</th>
              <th class="text-end">Status</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="i in 5" :key="i">
              <td><v-skeleton-loader type="text" width="120" /></td>
              <td class="d-none d-sm-table-cell"><v-skeleton-loader type="text" width="160" /></td>
              <td><v-skeleton-loader type="chip" width="80" /></td>
              <td class="text-end"><v-skeleton-loader type="button" width="60" /></td>
            </tr>
          </tbody>
        </v-table>
      </div>
    </v-card>

    <!-- Empty State -->
    <v-card v-else-if="store.members.length === 0" rounded="lg">
      <EmptyState
        icon="mdi-account-group-outline"
        title="No team members yet"
        subtitle="Add your first team member to get started."
      >
        <v-btn color="primary" class="mt-2" @click="showAddPanel = true">Add Member</v-btn>
      </EmptyState>
    </v-card>

    <!-- Data Table -->
    <v-card v-else rounded="lg">
      <div class="overflow-x-auto">
        <v-table hover>
          <thead>
            <tr>
              <th>Name</th>
              <th class="d-none d-sm-table-cell">Email</th>
              <th>Role</th>
              <th class="text-end">Status</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="member in store.members" :key="member.id">
              <td class="font-weight-bold">{{ member.name }}</td>
              <td class="d-none d-sm-table-cell text-medium-emphasis">{{ member.email }}</td>
              <td>
                <v-chip
                  :color="roleColors[member.role]"
                  size="small"
                  label
                  variant="flat"
                >
                  {{ member.role }}
                </v-chip>
              </td>
              <td class="text-end">
                <v-switch
                  :model-value="member.active"
                  color="primary"
                  density="compact"
                  hide-details
                  inline
                  @update:model-value="memberToToggle = member"
                />
                <span
                  class="text-caption font-weight-medium"
                  :class="member.active ? 'text-primary' : 'text-medium-emphasis'"
                >
                  {{ member.active ? 'Active' : 'Inactive' }}
                </span>
              </td>
            </tr>
          </tbody>
        </v-table>
      </div>
    </v-card>

    <!-- Confirm Toggle Modal -->
    <ConfirmModal
      v-if="memberToToggle"
      :title="memberToToggle.active ? 'Deactivate Member?' : 'Activate Member?'"
      :message="memberToToggle.active
        ? 'This member will no longer be assignable to new requests.'
        : 'This member will be available for assignment again.'"
      icon="mdi-alert"
      variant="warning"
      :confirm-label="memberToToggle.active ? 'Deactivate' : 'Activate'"
      @confirm="confirmToggle"
      @cancel="memberToToggle = null"
    />

    <!-- Add Member Side Panel -->
    <v-navigation-drawer
      v-model="showAddPanel"
      location="right"
      temporary
      :width="panelWidth"
    >
      <TeamMemberForm
        v-if="showAddPanel"
        @close="showAddPanel = false"
        @success="onMemberCreated"
      />
    </v-navigation-drawer>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useTeamMemberStore } from '@/stores/teamMemberStore'
import { useToastStore } from '@/stores/toastStore'
import EmptyState from '@/components/shared/EmptyState.vue'
import ConfirmModal from '@/components/shared/ConfirmModal.vue'
import TeamMemberForm from '@/components/TeamMemberForm.vue'

const store = useTeamMemberStore()
const toast = useToastStore()

const showAddPanel = ref(false)
const memberToToggle = ref(null)

const windowWidth = ref(window.innerWidth)
const panelWidth = computed(() => windowWidth.value < 960 ? '100%' : 480)
function onResize() { windowWidth.value = window.innerWidth }

const roleColors = {
  developer: 'blue',
  qa: 'amber-darken-2',
  support: 'green'
}

onMounted(() => {
  store.fetchMembers()
  window.addEventListener('resize', onResize)
})

onUnmounted(() => window.removeEventListener('resize', onResize))

function onMemberCreated() {
  showAddPanel.value = false
  store.fetchMembers()
}

async function confirmToggle() {
  const member = memberToToggle.value
  memberToToggle.value = null
  try {
    await store.toggleActive(member.id, !member.active)
    toast.success(`Member ${member.active ? 'deactivated' : 'activated'}`)
  } catch (err) {
    toast.error(err.message || 'Failed to update member')
  }
}
</script>
