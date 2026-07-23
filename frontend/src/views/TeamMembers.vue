<template>
  <div class="team-members-page">
    <!-- Page Header -->
    <div class="page-header">
      <div>
        <h1 class="page-title">Team Members</h1>
        <p class="page-subtitle">Manage your support team members and their roles</p>
      </div>
      <button class="btn btn-primary mobile-only-btn" @click="openAddPanel">
        + Add Member
      </button>
    </div>

    <!-- Error State -->
    <div v-if="store.error" class="alert alert-error">
      <span>{{ store.error.message || 'Failed to load team members.' }}</span>
      <button @click="store.fetchMembers()" class="btn btn-sm btn-outline ml-2">Retry</button>
    </div>

    <!-- Loading State: Table Skeleton -->
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

    <!-- Empty State -->
    <div v-else-if="store.members.length === 0" class="empty-state">
      <div class="empty-icon">👥</div>
      <h3 class="empty-title">No team members yet</h3>
      <p class="empty-subtitle">Add your first team member to get started.</p>
      <button class="btn btn-primary mt-3" @click="openAddPanel">+ Add Member</button>
    </div>

    <!-- Table Data View -->
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
              <span class="role-badge" :class="`role-${member.role}`">
                {{ member.role }}
              </span>
            </td>
            <td class="text-right">
              <button
                class="toggle-btn"
                :class="{ 'toggle-active': member.active }"
                @click="handleToggle(member)"
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

    <!-- Confirm Toggle Modal -->
    <Teleport to="body">
      <div v-if="memberToToggle" class="modal-overlay" @click="cancelToggle">
        <div class="modal" @click.stop>
          <div class="modal-icon modal-icon--warning">⚠</div>
          <h3 class="modal-title">
            {{ memberToToggle.active ? 'Deactivate Member?' : 'Activate Member?' }}
          </h3>
          <p class="modal-message">
            {{ memberToToggle.active
              ? 'This member will no longer be assignable to new requests.'
              : 'This member will be available for assignment again.' }}
          </p>
          <div class="modal-actions">
            <button class="btn btn-secondary" @click="cancelToggle">Cancel</button>
            <button class="btn btn-primary" @click="confirmToggle">
              {{ memberToToggle.active ? 'Deactivate' : 'Activate' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- Add Member Side Panel -->
    <Teleport to="body">
      <div v-if="showAddPanel" class="panel-overlay" @click="closeAddPanel">
        <div class="panel" @click.stop>
          <div class="panel-header">
            <h3 class="panel-title">New Team Member</h3>
            <button class="panel-close" @click="closeAddPanel">&times;</button>
          </div>
          <div class="panel-body">
            <form @submit.prevent="handleCreate">
              <div class="form-group">
                <label class="form-label">Name</label>
                <input
                  v-model="form.name"
                  type="text"
                  class="form-input"
                  :class="{ 'form-input--error': formErrors.name }"
                  placeholder="Enter full name"
                />
                <span v-if="formErrors.name" class="form-error">{{ formErrors.name }}</span>
              </div>

              <div class="form-group">
                <label class="form-label">Email</label>
                <input
                  v-model="form.email"
                  type="email"
                  class="form-input"
                  :class="{ 'form-input--error': formErrors.email }"
                  placeholder="user@company.com"
                />
                <span v-if="formErrors.email" class="form-error">{{ formErrors.email }}</span>
              </div>

              <div class="form-group">
                <label class="form-label">Role</label>
                <select
                  v-model="form.role"
                  class="form-input"
                  :class="{ 'form-input--error': formErrors.role }"
                >
                  <option value="">Select a role</option>
                  <option value="developer">Developer</option>
                  <option value="qa">QA</option>
                  <option value="support">Support</option>
                </select>
                <span v-if="formErrors.role" class="form-error">{{ formErrors.role }}</span>
              </div>
            </form>
          </div>
          <div class="panel-footer">
            <button class="btn btn-secondary" @click="closeAddPanel">Cancel</button>
            <button
              class="btn btn-primary"
              :disabled="isSubmitting"
              @click="handleCreate"
            >
              {{ isSubmitting ? 'Creating...' : 'Create Member' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useTeamMemberStore } from '@/stores/teamMemberStore'
import { useToastStore } from '@/stores/toastStore'

const store = useTeamMemberStore()
const toast = useToastStore()

const mounted = ref(false)
const showAddPanel = ref(false)
const isSubmitting = ref(false)
const memberToToggle = ref(null)

const form = reactive({ name: '', email: '', role: '' })
const formErrors = reactive({ name: '', email: '', role: '' })

onMounted(() => {
  mounted.value = true
  store.fetchMembers()
})

function openAddPanel() {
  form.name = ''
  form.email = ''
  form.role = ''
  formErrors.name = ''
  formErrors.email = ''
  formErrors.role = ''
  showAddPanel.value = true
}

function closeAddPanel() {
  showAddPanel.value = false
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

function handleToggle(member) {
  memberToToggle.value = member
}

function cancelToggle() {
  memberToToggle.value = null
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

/* Alert */
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

/* Buttons */
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

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-primary {
  background-color: #2563eb;
  color: #ffffff;
}

.btn-primary:hover:not(:disabled) {
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

.btn-sm {
  padding: 4px 10px;
  font-size: 12px;
  border-radius: 6px;
}

.text-right {
  text-align: right;
}

.mt-3 { margin-top: 12px; }
.ml-2 { margin-left: 8px; }

/* Modal */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 2000;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal {
  background: #ffffff;
  border-radius: 12px;
  padding: 24px;
  width: 400px;
  max-width: 90vw;
  text-align: center;
  box-shadow: 0 10px 15px rgba(0, 0, 0, 0.1);
}

.modal-icon {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 16px;
  font-size: 24px;
}

.modal-icon--warning {
  background: #fef3c7;
  color: #f59e0b;
}

.modal-title {
  font-size: 18px;
  font-weight: 600;
  color: #111827;
  margin: 0 0 8px 0;
}

.modal-message {
  font-size: 14px;
  color: #6b7280;
  margin: 0 0 20px 0;
}

.modal-actions {
  display: flex;
  gap: 12px;
  justify-content: center;
}

/* Side Panel */
.panel-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.4);
  z-index: 1000;
  display: flex;
  justify-content: flex-end;
}

.panel {
  width: 480px;
  max-width: 90vw;
  height: 100vh;
  background: #ffffff;
  box-shadow: 0 10px 15px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid #e5e7eb;
}

.panel-title {
  font-size: 18px;
  font-weight: 600;
  color: #111827;
  margin: 0;
}

.panel-close {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #6b7280;
  padding: 0;
  line-height: 1;
}

.panel-close:hover {
  color: #374151;
}

.panel-body {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
}

.panel-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding: 16px 20px;
  border-top: 1px solid #e5e7eb;
}

/* Form */
.form-group {
  margin-bottom: 16px;
}

.form-label {
  display: block;
  font-size: 14px;
  font-weight: 600;
  color: #374151;
  margin-bottom: 6px;
}

.form-input {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  font-size: 14px;
  outline: none;
  transition: border-color 0.2s, box-shadow 0.2s;
  box-sizing: border-box;
}

.form-input:focus {
  border-color: #2563eb;
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15);
}

.form-input--error {
  border-color: #ef4444;
}

.form-input--error:focus {
  border-color: #ef4444;
  box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.15);
}

.form-error {
  display: block;
  font-size: 13px;
  color: #ef4444;
  margin-top: 4px;
}

@media (max-width: 768px) {
  .page-header {
    align-items: flex-start;
    flex-direction: column;
    gap: 12px;
  }

  .mobile-only-btn {
    display: inline-flex;
  }
}
</style>
