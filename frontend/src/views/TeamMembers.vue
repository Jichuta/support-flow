<template>
  <div class="team-members-page">
    <div class="page-header">
      <div>
        <h1 class="page-title">Team Members</h1>
        <p class="page-subtitle">Manage your support team members and their roles</p>
      </div>
      <button class="btn btn-primary" @click="showAddPanel = true">+ Add Member</button>
    </div>

    <ErrorMessage
      v-if="store.error"
      :message="store.error.message || 'Failed to load team members.'"
      :retryable="true"
      @retry="store.fetchMembers()"
    />

    <div v-if="store.loading" class="table-container">
      <table class="data-table">
        <thead>
          <tr>
            <th>Name</th>
            <th>Email</th>
            <th>Role</th>
            <th class="text-right">Status</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="i in 5" :key="i" class="skeleton-row">
            <td><div class="skeleton skeleton-text w-48"></div></td>
            <td><div class="skeleton skeleton-text w-48"></div></td>
            <td><div class="skeleton skeleton-badge"></div></td>
            <td class="text-right"><div class="skeleton skeleton-btn"></div></td>
          </tr>
        </tbody>
      </table>
    </div>

    <EmptyState
      v-else-if="store.members.length === 0"
      icon="👥"
      title="No team members yet"
      subtitle="Add your first team member to get started."
    >
      <button class="btn btn-primary mt-3" @click="showAddPanel = true">+ Add Member</button>
    </EmptyState>

    <div v-else class="table-container">
      <table class="data-table">
        <thead>
          <tr>
            <th>Name</th>
            <th>Email</th>
            <th>Role</th>
            <th class="text-right">Status</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="member in store.members" :key="member.id">
            <td class="name-cell">{{ member.name }}</td>
            <td class="email-cell">{{ member.email }}</td>
            <td>
              <span class="role-badge" :class="`role-${member.role}`">{{ member.role }}</span>
            </td>
            <td class="text-right">
              <button
                class="toggle-btn"
                :class="{ 'toggle-active': member.active }"
                @click="memberToToggle = member"
              >
                <span class="toggle-knob" />
              </button>
              <span class="status-label" :class="{ 'status-inactive': !member.active }">
                {{ member.active ? 'Active' : 'Inactive' }}
              </span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <ConfirmModal
      v-if="memberToToggle"
      :title="memberToToggle.active ? 'Deactivate Member?' : 'Activate Member?'"
      :message="
        memberToToggle.active
          ? 'This member will no longer be assignable to new requests.'
          : 'This member will be available for assignment again.'
      "
      icon="⚠"
      variant="warning"
      :confirm-label="memberToToggle.active ? 'Deactivate' : 'Activate'"
      @confirm="confirmToggle"
      @cancel="memberToToggle = null"
    />

    <SidePanel v-if="showAddPanel" title="New Team Member" @close="closeAddPanel">
      <form @submit.prevent="handleCreate">
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
      </form>

      <template #footer>
        <button class="btn btn-secondary" @click="closeAddPanel">Cancel</button>
        <button class="btn btn-primary" :disabled="isSubmitting" @click="handleCreate">
          {{ isSubmitting ? 'Creating...' : 'Create Member' }}
        </button>
      </template>
    </SidePanel>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useTeamMemberStore } from '@/stores/teamMemberStore'
import { useToastStore } from '@/stores/toastStore'
import EmptyState from '@/components/shared/EmptyState.vue'
import ErrorMessage from '@/components/shared/ErrorMessage.vue'
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
  { value: 'developer', label: 'Developer' },
  { value: 'qa', label: 'QA' },
  { value: 'support', label: 'Support' }
]

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
      err.details.forEach((d) => toast.error(d))
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

<style scoped>
.team-members-page {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.name-cell {
  font-weight: 600;
  color: #111827;
}

.email-cell {
  color: #6b7280;
}

/* Role Badge */
.role-badge {
  display: inline-flex;
  padding: 3px 10px;
  border-radius: 9999px;
  font-size: 12px;
  font-weight: 600;
  text-transform: capitalize;
  line-height: 1.4;
  white-space: nowrap;
}

.role-developer {
  background-color: #dbeafe;
  color: #1e40af;
}

.role-qa {
  background-color: #fef3c7;
  color: #92400e;
}

.role-support {
  background-color: #dcfce7;
  color: #166534;
}

/* Toggle Button */
.toggle-btn {
  position: relative;
  display: inline-block;
  width: 36px;
  height: 20px;
  border-radius: 9999px;
  border: none;
  cursor: pointer;
  transition: background-color 0.2s ease;
  background-color: #d1d5db;
  padding: 0;
  vertical-align: middle;
  margin-right: 8px;
}

.toggle-btn.toggle-active {
  background-color: #2563eb;
}

.toggle-knob {
  position: absolute;
  top: 2px;
  left: 2px;
  width: 16px;
  height: 16px;
  background-color: #ffffff;
  border-radius: 50%;
  transition: transform 0.2s ease;
  pointer-events: none;
}

.toggle-btn.toggle-active .toggle-knob {
  transform: translateX(16px);
}

.status-label {
  font-size: 13px;
  font-weight: 500;
  color: #2563eb;
}

.status-label.status-inactive {
  color: #9ca3af;
}
</style>
