<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useSupportRequestStore } from '@/stores/supportRequestStore'
import { useTeamMemberStore } from '@/stores/teamMemberStore'
import { useToastStore } from '@/stores/toastStore'

const props = defineProps({ requestId: { type: [String, Number], default: null } })
const router = useRouter()
const requestStore = useSupportRequestStore()
const memberStore = useTeamMemberStore()
const toastStore = useToastStore()
const form = reactive({ title: '', description: '', priority: 'medium', due_date: '', assignee_id: '', creator_id: '', team_id: '' })
const errors = reactive({})
const loading = ref(false)
const success = ref('')
const ready = ref(false)
const isEdit = computed(() => Boolean(props.requestId))
const activeMembers = computed(() => memberStore.members.filter((member) => member.active))

function clearErrors() { Object.keys(errors).forEach((key) => delete errors[key]) }
function addError(key, message) { errors[key] = [...(errors[key] || []), message] }
function validate() {
  clearErrors()
  if (!form.title.trim()) addError('title', 'Title is required.')
  if (!form.description.trim()) addError('description', 'Description is required.')
  if (!form.priority) addError('priority', 'Priority is required.')
  if (!isEdit.value && !form.creator_id) addError('creator_id', 'Creator is required.')
  if (!isEdit.value && !form.team_id) addError('team_id', 'Team is required.')
  return Object.keys(errors).length === 0
}
function mapBackendErrors(details = []) {
  clearErrors()
  details.forEach((detail) => {
    const key = ['title', 'description', 'priority', 'due date', 'assignee', 'creator', 'team'].find((field) => detail.toLowerCase().startsWith(field))
    const field = key?.replace(' ', '_')
    const mapped = { assignee: 'assignee_id', creator: 'creator_id', team: 'team_id' }[field] || field || 'general'
    addError(mapped, detail)
  })
}
function payload() {
  const data = { title: form.title.trim(), description: form.description.trim(), priority: form.priority, due_date: form.due_date || null, assignee_id: form.assignee_id || null }
  if (!isEdit.value) { data.creator_id = Number(form.creator_id); data.team_id = Number(form.team_id) }
  return data
}
async function submit() {
  if (!validate()) return
  loading.value = true; clearErrors()
  try {
    const request = isEdit.value ? await requestStore.updateRequest(props.requestId, payload()) : await requestStore.createRequest(payload())
    success.value = isEdit.value ? 'Request updated successfully.' : 'Request created successfully.'
    toastStore.success(success.value)
    router.push({ name: 'RequestDetail', params: { id: request.id } })
  } catch (error) { mapBackendErrors(error.details) } finally { loading.value = false }
}
function cancel() { router.back() }
onMounted(async () => {
  loading.value = true
  try {
    await memberStore.fetchMembers()
    if (isEdit.value) {
      const request = await requestStore.fetchRequest(props.requestId)
      Object.assign(form, { title: request.title, description: request.description, priority: request.priority, due_date: request.due_date || '', assignee_id: request.assignee?.id || '' })
    }
  } catch (error) { mapBackendErrors(error.details || [error.message]) } finally { loading.value = false; ready.value = true }
})
</script>

<template>
  <section class="form-page"><header><h2>{{ isEdit ? 'Edit Support Request' : 'New Support Request' }}</h2><p>Provide the details needed to track this request.</p></header>
    <form v-if="ready" class="request-form" @submit.prevent="submit" novalidate>
      <p v-if="errors.general" class="form-error" role="alert">{{ errors.general.join(' ') }}</p>
      <label>Title<input v-model="form.title" :disabled="loading" /><span v-if="errors.title" class="field-error" role="alert">{{ errors.title[0] }}</span></label>
      <label>Description<textarea v-model="form.description" rows="6" :disabled="loading" /><span v-if="errors.description" class="field-error" role="alert">{{ errors.description[0] }}</span></label>
      <div class="form-grid"><label>Priority<select v-model="form.priority" :disabled="loading"><option value="low">Low</option><option value="medium">Medium</option><option value="high">High</option><option value="critical">Critical</option></select><span v-if="errors.priority" class="field-error" role="alert">{{ errors.priority[0] }}</span></label><label>Due Date<input v-model="form.due_date" type="date" :disabled="loading" /></label><label>Assignee<select v-model="form.assignee_id" :disabled="loading"><option value="">Unassigned</option><option v-for="member in activeMembers" :key="member.id" :value="member.id">{{ member.name }}</option></select><span v-if="errors.assignee_id" class="field-error" role="alert">{{ errors.assignee_id[0] }}</span></label></div>
      <div v-if="!isEdit" class="form-grid required-context"><label>Creator<select v-model="form.creator_id" :disabled="loading"><option value="">Select creator</option><option v-for="member in activeMembers" :key="member.id" :value="member.id">{{ member.name }}</option></select><span v-if="errors.creator_id" class="field-error" role="alert">{{ errors.creator_id[0] }}</span></label><label>Team<select v-model="form.team_id" :disabled="loading"><option value="">Select team</option><option v-for="member in activeMembers" :key="member.id" :value="member.id">{{ member.name }}</option></select><span v-if="errors.team_id" class="field-error" role="alert">{{ errors.team_id[0] }}</span></label></div>
      <div class="actions"><button type="button" class="secondary" :disabled="loading" @click="cancel">Cancel</button><button :disabled="loading">{{ loading ? "Saving..." : isEdit ? "Save Changes" : "Create Request" }}</button></div>
    </form><p v-else class="loading">Loading form...</p><p v-if="success" class="success" role="status">{{ success }}</p>
  </section>
</template>

<style scoped>
.form-page{max-width:800px;margin:auto;color:#1f2937}.form-page h2{margin:0;color:#111827}.form-page header p{color:#6b7280}.request-form{display:grid;gap:16px;margin-top:22px;padding:22px;background:#fff;border:1px solid #e5e7eb;border-radius:10px}.request-form label{display:grid;gap:6px;font-size:14px;font-weight:600}.request-form input,.request-form select,.request-form textarea{font:inherit;padding:9px;border:1px solid #d1d5db;border-radius:7px;box-sizing:border-box}.form-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:14px}.required-context{grid-template-columns:repeat(2,1fr)}.actions{display:flex;justify-content:flex-end;gap:10px}.actions button{border:0;border-radius:7px;padding:10px 14px;background:#2563eb;color:#fff;font-weight:600;cursor:pointer}.actions .secondary{background:#e5e7eb;color:#374151}.field-error,.form-error{color:#b91c1c;font-size:13px}.form-error{margin:0}.success{color:#166534}@media(max-width:650px){.form-grid,.required-context{grid-template-columns:1fr}.actions{justify-content:stretch}.actions button{flex:1}}
</style>
