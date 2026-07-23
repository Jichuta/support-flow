<script setup>
import { computed, reactive, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import StatusBadge from '@/components/shared/StatusBadge.vue'
import PriorityBadge from '@/components/shared/PriorityBadge.vue'
import { useSupportRequestStore } from '@/stores/supportRequestStore'
import { useTeamMemberStore } from '@/stores/teamMemberStore'
import { useToastStore } from '@/stores/toastStore'

const props = defineProps({ id: { type: [String, Number], required: true } })
const requestStore = useSupportRequestStore()
const memberStore = useTeamMemberStore()
const toastStore = useToastStore()
const form = reactive({ team_member_id: '', body: '' })
const formError = ref('')
const successMessage = ref('')
const submitting = ref(false)

const request = computed(() => requestStore.currentRequest)
const comments = computed(() => request.value?.comments ?? [])
const notFound = computed(() => requestStore.error?.status === 404)
const activeMembers = computed(() => memberStore.members.filter((member) => member.active))
const formatDate = (value) => value ? new Date(value.includes('T') ? value : `${value}T00:00:00`).toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' }) : 'Not set'
const formatDateTime = (value) => value ? new Date(value).toLocaleString(undefined, { dateStyle: 'medium', timeStyle: 'short' }) : ''

async function submitComment() {
  formError.value = ''
  if (!form.team_member_id) { formError.value = 'Choose a comment author.'; return }
  if (form.body.trim().length < 10) { formError.value = 'Comment must be at least 10 characters.'; return }
  submitting.value = true
  try {
    await requestStore.addComment(props.id, { team_member_id: Number(form.team_member_id), body: form.body.trim() })
    form.body = ''
    successMessage.value = 'Comment added successfully.'
    toastStore.success(successMessage.value)
    setTimeout(() => { successMessage.value = '' }, 5000)
  } catch (error) {
    formError.value = error.details?.join(' ') || error.message || 'Unable to add comment.'
  } finally { submitting.value = false }
}

async function loadDetail() {
  requestStore.currentRequest = null
  try { await Promise.all([requestStore.fetchRequest(props.id), memberStore.fetchMembers()]) } catch (_) { /* rendered from store state */ }
}

watch(() => props.id, loadDetail, { immediate: true })
</script>

<template>
  <section class="detail-page">
    <div class="detail-actions"><RouterLink to="/requests">< Back to List</RouterLink><RouterLink v-if="request" :to="`/requests/${request.id}/edit`" class="button">Edit Request</RouterLink></div>
    <div v-if="requestStore.loading && !request" class="loading" aria-live="polite">Loading support request?</div>
    <div v-else-if="notFound" class="state"><h2>Request not found</h2><p>This support request may have been removed or the link is invalid.</p><RouterLink to="/requests">Return to requests</RouterLink></div>
    <div v-else-if="requestStore.error" class="state error" role="alert"><h2>Unable to load request</h2><p>{{ requestStore.error.message }}</p><button @click="requestStore.fetchRequest(id)">Try again</button></div>
    <template v-else-if="request">
      <article class="request-card"><div class="request-heading"><div><span class="request-id">Request #{{ request.id }}</span><h2>{{ request.title }}</h2></div><div class="badges"><StatusBadge :status="request.status" /><PriorityBadge :priority="request.priority" /></div></div><p class="description">{{ request.description }}</p><dl class="metadata"><div><dt>Assignee</dt><dd>{{ request.assignee?.name || 'Unassigned' }}</dd></div><div><dt>Due date</dt><dd>{{ formatDate(request.due_date) }}</dd></div><div><dt>Created</dt><dd>{{ formatDateTime(request.created_at) }}</dd></div></dl></article>
      <p v-if="successMessage" class="toast" role="status">{{ successMessage }}</p>
      <div class="comments-grid"><section class="comments-card"><h3>Comments ({{ comments.length }})</h3><div v-if="comments.length" class="timeline"><article v-for="comment in comments" :key="comment.id" class="comment"><header><strong>{{ comment.author_name }}</strong><time>{{ formatDateTime(comment.created_at) }}</time></header><p>{{ comment.body }}</p></article></div><p v-else class="empty">No comments yet.</p></section>
        <form class="comment-form" @submit.prevent="submitComment"><h3>Add a comment</h3><label for="author">Author</label><select id="author" v-model="form.team_member_id" :disabled="memberStore.loading || submitting"><option value="">Select a team member</option><option v-for="member in activeMembers" :key="member.id" :value="member.id">{{ member.name }}</option></select><label for="body">Comment</label><textarea id="body" v-model="form.body" minlength="10" rows="6" placeholder="Add at least 10 characters?" :disabled="submitting" /><p v-if="formError" class="form-error" role="alert">{{ formError }}</p><button class="button" :disabled="submitting">{{ submitting ? 'Posting?' : 'Post Comment' }}</button></form></div>
    </template>
  </section>
</template>

<style scoped>
.detail-page{max-width:1050px;margin:auto;color:#1f2937}.detail-actions,.request-heading,.badges,.comment header{display:flex;align-items:center}.detail-actions{justify-content:space-between;margin-bottom:20px}.detail-actions a:first-child{color:#2563eb;text-decoration:none}.button{background:#2563eb;color:#fff;border:0;border-radius:7px;padding:9px 14px;text-decoration:none;font-weight:600;cursor:pointer}.button:disabled{opacity:.65;cursor:not-allowed}.request-card,.comments-card,.comment-form,.state,.loading{background:#fff;border:1px solid #e5e7eb;border-radius:10px;padding:22px}.request-heading{justify-content:space-between;gap:18px}.request-id,dt{font-size:12px;font-weight:700;color:#6b7280;text-transform:uppercase}.request-card h2{margin:4px 0 0;color:#111827}.badges{gap:8px}.description{line-height:1.6;white-space:pre-wrap}.metadata{display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin:22px 0 0;padding-top:16px;border-top:1px solid #e5e7eb}.metadata dd{margin:4px 0 0;font-weight:600}.comments-grid{display:grid;grid-template-columns:1.5fr 1fr;gap:18px;margin-top:18px}.comments-card h3,.comment-form h3{margin-top:0}.timeline{display:grid;gap:12px}.comment{border-top:1px solid #e5e7eb;padding-top:12px}.comment header{justify-content:space-between;gap:12px}.comment time{font-size:12px;color:#6b7280}.comment p{white-space:pre-wrap;line-height:1.5}.empty{color:#6b7280}.comment-form{display:flex;flex-direction:column;gap:8px;height:max-content}.comment-form label{font-size:13px;font-weight:600}.comment-form select,.comment-form textarea{font:inherit;border:1px solid #d1d5db;border-radius:7px;padding:9px;box-sizing:border-box}.form-error,.error{color:#b91c1c}.toast{margin:18px 0 0;background:#dcfce7;color:#166534;border-radius:7px;padding:10px 14px}@media(max-width:720px){.request-heading,.detail-actions{align-items:flex-start;flex-direction:column}.metadata,.comments-grid{grid-template-columns:1fr}.badges{flex-wrap:wrap}}
</style>
