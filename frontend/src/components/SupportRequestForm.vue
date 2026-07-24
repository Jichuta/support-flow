<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useSupportRequestStore } from '@/stores/supportRequestStore'
import { useTeamMemberStore } from '@/stores/teamMemberStore'
import { useToastStore } from '@/stores/toastStore'

const props = defineProps({ requestId: { type: [String, Number], default: null } })
const emit = defineEmits(['close', 'success'])
const requestStore = useSupportRequestStore()
const memberStore = useTeamMemberStore()
const toastStore = useToastStore()

const form = reactive({
  title: '', description: '', priority: 'medium', status: 'open', due_date: '',
  assignee_id: '', creator_id: ''
})
const errors = reactive({})
const loading = ref(false)
const ready = ref(false)
const isEdit = computed(() => Boolean(props.requestId))

const activeMembers = computed(() => memberStore.members.filter((m) => m.active))
const memberItems = computed(() => activeMembers.value.map((m) => ({ title: m.name, value: String(m.id) })))

const priorityItems = [
  { title: 'Low', value: 'low' },
  { title: 'Medium', value: 'medium' },
  { title: 'High', value: 'high' },
  { title: 'Critical', value: 'critical' }
]

const statusItems = [
  { title: 'Open', value: 'open' },
  { title: 'In Progress', value: 'in_progress' },
  { title: 'Resolved', value: 'resolved' },
  { title: 'Closed', value: 'closed' }
]

function clearErrors() { Object.keys(errors).forEach((key) => delete errors[key]) }
function addError(key, message) { errors[key] = [...(errors[key] || []), message] }

function validate() {
  clearErrors()
  if (!form.title.trim()) addError('title', 'Title is required.')
  if (!form.description.trim()) addError('description', 'Description is required.')
  if (!form.priority) addError('priority', 'Priority is required.')
  if (!isEdit.value && !form.creator_id) addError('creator_id', 'Creator is required.')
  return Object.keys(errors).length === 0
}

function mapBackendErrors(details = []) {
  clearErrors()
  details.forEach((detail) => {
    const key = ['title', 'description', 'priority', 'due date', 'assignee', 'creator']
      .find((field) => detail.toLowerCase().startsWith(field))
    const field = key?.replace(' ', '_')
    const mapped = { assignee: 'assignee_id', creator: 'creator_id' }[field] || field || 'general'
    addError(mapped, detail)
  })
}

function payload() {
  const data = {
    title: form.title.trim(), description: form.description.trim(),
    priority: form.priority, due_date: form.due_date || null,
    assignee_id: form.assignee_id || null
  }
  if (isEdit.value) {
    data.status = form.status
  } else {
    data.creator_id = Number(form.creator_id)
  }
  return data
}

async function submit() {
  if (!validate()) return
  loading.value = true
  clearErrors()
  try {
    const request = isEdit.value
      ? await requestStore.updateRequest(props.requestId, payload())
      : await requestStore.createRequest(payload())
    toastStore.success(isEdit.value ? 'Request updated successfully.' : 'Request created successfully.')
    emit('success', request)
  } catch (error) { mapBackendErrors(error.details) } finally { loading.value = false }
}

onMounted(async () => {
  loading.value = true
  try {
    await memberStore.fetchMembers()
    if (isEdit.value) {
      const request = await requestStore.fetchRequest(props.requestId)
      Object.assign(form, {
        title: request.title, description: request.description,
        priority: request.priority, status: request.status,
        due_date: request.due_date || '',
        assignee_id: request.assignee?.id ? String(request.assignee.id) : ''
      })
    }
  } catch (error) { mapBackendErrors(error.details || [error.message]) } finally { loading.value = false; ready.value = true }
})
</script>

<template>
  <v-card flat rounded="0" class="d-flex flex-column h-100">
    <v-card-title class="d-flex justify-space-between align-center pa-4">
      <span class="text-h6 font-weight-bold">{{ isEdit ? 'Edit Request' : 'New Request' }}</span>
      <v-btn icon="mdi-close" variant="text" size="small" @click="$emit('close')" />
    </v-card-title>
    <v-divider />

    <v-card-text class="flex-grow-1 overflow-y-auto pa-4">
      <v-skeleton-loader v-if="!ready" type="article, actions" />

      <v-form v-else @submit.prevent="submit">
        <v-alert v-if="errors.general" type="error" variant="tonal" class="mb-4">
          {{ errors.general.join(' ') }}
        </v-alert>

        <v-text-field
          v-model="form.title"
          label="Title"
          :error-messages="errors.title"
          :disabled="loading"
          class="mb-1"
        />

        <v-textarea
          v-model="form.description"
          label="Description"
          :rows="4"
          :error-messages="errors.description"
          :disabled="loading"
          class="mb-1"
        />

        <v-select
          v-model="form.priority"
          label="Priority"
          :items="priorityItems"
          :error-messages="errors.priority"
          :disabled="loading"
          class="mb-1"
        />

        <v-select
          v-if="isEdit"
          v-model="form.status"
          label="Status"
          :items="statusItems"
          :error-messages="errors.status"
          :disabled="loading"
          class="mb-1"
        />

        <v-text-field
          v-model="form.due_date"
          label="Due Date"
          type="date"
          :disabled="loading"
          class="mb-1"
        />

        <v-select
          v-model="form.assignee_id"
          label="Assignee"
          :items="[{ title: 'Unassigned', value: '' }, ...memberItems]"
          :error-messages="errors.assignee_id"
          :disabled="loading"
          class="mb-1"
        />

        <template v-if="!isEdit">
          <v-select
            v-model="form.creator_id"
            label="Creator"
            :items="[{ title: 'Select creator', value: '' }, ...memberItems]"
            :error-messages="errors.creator_id"
            :disabled="loading"
          />
        </template>
      </v-form>
    </v-card-text>

    <v-divider />
    <v-card-actions class="pa-4 justify-end">
      <v-btn variant="outlined" :disabled="loading" @click="$emit('close')">Cancel</v-btn>
      <v-btn color="primary" :loading="loading" @click="submit">
        {{ isEdit ? 'Save Changes' : 'Create Request' }}
      </v-btn>
    </v-card-actions>
  </v-card>
</template>
