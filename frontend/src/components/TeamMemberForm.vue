<script setup>
import { reactive, ref } from 'vue'
import { useTeamMemberStore } from '@/stores/teamMemberStore'
import { useToastStore } from '@/stores/toastStore'

const emit = defineEmits(['close', 'success'])
const memberStore = useTeamMemberStore()
const toastStore = useToastStore()

const form = reactive({ name: '', email: '', role: '' })
const errors = reactive({})
const loading = ref(false)

const roleItems = [
  { title: 'Developer', value: 'developer' },
  { title: 'QA', value: 'qa' },
  { title: 'Support', value: 'support' }
]

function clearErrors() { Object.keys(errors).forEach((key) => delete errors[key]) }
function addError(key, message) { errors[key] = [...(errors[key] || []), message] }

function validate() {
  clearErrors()
  if (!form.name.trim()) addError('name', 'Name is required.')
  if (!form.email.trim()) {
    addError('email', 'Email is required.')
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) {
    addError('email', 'Email is invalid.')
  }
  if (!form.role) addError('role', 'Role is required.')
  return Object.keys(errors).length === 0
}

function mapBackendErrors(details = []) {
  clearErrors()
  details.forEach((detail) => {
    const key = ['name', 'email', 'role']
      .find((field) => detail.toLowerCase().startsWith(field))
    addError(key || 'general', detail)
  })
}

async function submit() {
  if (!validate()) return
  loading.value = true
  clearErrors()
  try {
    await memberStore.createMember({
      name: form.name.trim(),
      email: form.email.trim(),
      role: form.role
    })
    toastStore.success('Team member added successfully.')
    emit('success')
  } catch (error) {
    mapBackendErrors(error.details || [error.message || 'Failed to create member.'])
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <v-card flat rounded="0" class="d-flex flex-column h-100">
    <v-card-title class="d-flex justify-space-between align-center pa-4">
      <span class="text-h6 font-weight-bold">New Team Member</span>
      <v-btn icon="mdi-close" variant="text" size="small" @click="$emit('close')" />
    </v-card-title>
    <v-divider />

    <v-card-text class="flex-grow-1 pa-4">
      <v-form @submit.prevent="submit">
        <v-alert v-if="errors.general" type="error" variant="tonal" class="mb-4">
          {{ errors.general.join(' ') }}
        </v-alert>

        <v-text-field
          v-model="form.name"
          label="Name"
          placeholder="Enter full name"
          :error-messages="errors.name"
          :disabled="loading"
          class="mb-1"
        />

        <v-text-field
          v-model="form.email"
          label="Email"
          type="email"
          placeholder="user@company.com"
          :error-messages="errors.email"
          :disabled="loading"
          class="mb-1"
        />

        <v-select
          v-model="form.role"
          label="Role"
          :items="roleItems"
          :error-messages="errors.role"
          :disabled="loading"
        />
      </v-form>
    </v-card-text>

    <v-divider />
    <v-card-actions class="pa-4 justify-end">
      <v-btn variant="outlined" :disabled="loading" @click="$emit('close')">Cancel</v-btn>
      <v-btn color="primary" :loading="loading" @click="submit">
        Create Member
      </v-btn>
    </v-card-actions>
  </v-card>
</template>
