<template>
  <div>
    <!-- Page Header -->
    <div class="d-flex align-center justify-space-between mb-5">
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
      <v-table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Email</th>
            <th>Role</th>
            <th class="text-end">Status</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="i in 5" :key="i">
            <td><v-skeleton-loader type="text" width="120" /></td>
            <td><v-skeleton-loader type="text" width="160" /></td>
            <td><v-skeleton-loader type="chip" width="80" /></td>
            <td class="text-end"><v-skeleton-loader type="button" width="60" /></td>
          </tr>
        </tbody>
      </v-table>
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
      <v-table hover>
        <thead>
          <tr>
            <th>Name</th>
            <th>Email</th>
            <th>Role</th>
            <th class="text-end">Status</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="member in store.members" :key="member.id">
            <td class="font-weight-bold">{{ member.name }}</td>
            <td class="text-medium-emphasis">{{ member.email }}</td>
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
    <SidePanel
      v-if="showAddPanel"
      title="New Team Member"
      @close="closeAddPanel"
    >
      <v-form @submit.prevent="handleCreate">
        <FormInput
          v-model="form.name"
          label="Name"
          placeholder="Enter full name"
          :error="formErrors.name"
        />
        <FormInput
          v-model="form.email"
          label="Email"
          type="email"
          placeholder="user@company.com"
          :error="formErrors.email"
        />
        <FormSelect
          v-model="form.role"
          label="Role"
          placeholder="Select a role"
          :options="roleOptions"
          :error="formErrors.role"
        />
      </v-form>

      <template #footer>
        <v-btn variant="outlined" @click="closeAddPanel">Cancel</v-btn>
        <v-btn color="primary" :loading="isSubmitting" @click="handleCreate">
          Create Member
        </v-btn>
      </template>
    </SidePanel>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useTeamMemberStore } from '@/stores/teamMemberStore'
import { useToastStore } from '@/stores/toastStore'
import EmptyState from '@/components/shared/EmptyState.vue'
import ConfirmModal from '@/components/shared/ConfirmModal.vue'
import SidePanel from '@/components/shared/SidePanel.vue'
import FormInput from '@/components/shared/FormInput.vue'
import FormSelect from '@/components/shared/FormSelect.vue'

const store = useTeamMemberStore()
const toast = useToastStore()

const showAddPanel = ref(false)
const isSubmitting = ref(false)
const memberToToggle = ref(null)

const form = reactive({ name: '', email: '', role: '' })
const formErrors = reactive({ name: '', email: '', role: '' })

const roleOptions = [
  { title: 'Developer', value: 'developer' },
  { title: 'QA', value: 'qa' },
  { title: 'Support', value: 'support' }
]

const roleColors = {
  developer: 'blue',
  qa: 'amber-darken-2',
  support: 'green'
}

onMounted(() => {
  store.fetchMembers()
})

function closeAddPanel() {
  showAddPanel.value = false
  form.name = ''
  form.email = ''
  form.role = ''
  formErrors.name = ''
  formErrors.email = ''
  formErrors.role = ''
}

function validate() {
  let valid = true
  formErrors.name = ''
  formErrors.email = ''
  formErrors.role = ''

  if (!form.name.trim()) {
    formErrors.name = 'Name is required'
    valid = false
  }

  if (!form.email.trim()) {
    formErrors.email = 'Email is required'
    valid = false
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) {
    formErrors.email = 'Email is invalid'
    valid = false
  }

  if (!form.role) {
    formErrors.role = 'Role is required'
    valid = false
  }

  return valid
}

async function handleCreate() {
  if (!validate()) return

  isSubmitting.value = true
  try {
    await store.createMember({
      name: form.name.trim(),
      email: form.email.trim(),
      role: form.role
    })
    toast.success('Team member added')
    closeAddPanel()
  } catch (err) {
    if (err.details) {
      err.details.forEach(d => toast.error(d))
    } else {
      toast.error(err.message || 'Failed to create member')
    }
  } finally {
    isSubmitting.value = false
  }
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
