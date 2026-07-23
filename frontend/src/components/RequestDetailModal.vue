<script setup>
import { computed, reactive, ref, watch } from 'vue'
import StatusBadge from '@/components/shared/StatusBadge.vue'
import PriorityBadge from '@/components/shared/PriorityBadge.vue'
import { useSupportRequestStore } from '@/stores/supportRequestStore'
import { useTeamMemberStore } from '@/stores/teamMemberStore'
import { useToastStore } from '@/stores/toastStore'

const props = defineProps({
  modelValue: { type: Boolean, default: false },
  requestId: { type: [String, Number], default: null }
})
const emit = defineEmits(['update:modelValue'])

const requestStore = useSupportRequestStore()
const memberStore = useTeamMemberStore()
const toastStore = useToastStore()

const form = reactive({ team_member_id: '', body: '' })
const formError = ref('')
const submitting = ref(false)

const request = computed(() => requestStore.currentRequest)
const comments = computed(() => request.value?.comments ?? [])
const activeMembers = computed(() => memberStore.members.filter((m) => m.active))
const authorItems = computed(() => activeMembers.value.map((m) => ({ title: m.name, value: String(m.id) })))

const formatDate = (value) =>
  value
    ? new Date(value.includes('T') ? value : `${value}T00:00:00`).toLocaleDateString(undefined, {
        year: 'numeric', month: 'short', day: 'numeric'
      })
    : 'Not set'

const formatDateTime = (value) =>
  value
    ? new Date(value).toLocaleString(undefined, { dateStyle: 'medium', timeStyle: 'short' })
    : ''

function close() { emit('update:modelValue', false) }

async function submitComment() {
  formError.value = ''
  if (!form.team_member_id) { formError.value = 'Choose a comment author.'; return }
  if (form.body.trim().length < 10) { formError.value = 'Comment must be at least 10 characters.'; return }
  submitting.value = true
  try {
    await requestStore.addComment(props.requestId, {
      team_member_id: Number(form.team_member_id),
      body: form.body.trim()
    })
    toastStore.success('Comment added successfully.')
    close()
  } catch (error) {
    formError.value = error.details?.join(' ') || error.message || 'Unable to add comment.'
  } finally { submitting.value = false }
}

watch(() => props.modelValue, (val) => {
  if (val && props.requestId) {
    requestStore.currentRequest = null
    Promise.all([requestStore.fetchRequest(props.requestId), memberStore.fetchMembers()]).catch(() => {})
  }
})
</script>

<template>
  <v-dialog :model-value="modelValue" @update:model-value="close" max-width="800" scrollable>
    <v-card rounded="lg">
      <!-- Loading -->
      <div v-if="requestStore.loading && !request" class="pa-6">
        <v-skeleton-loader type="article, actions" />
      </div>

      <template v-else-if="request">
        <!-- Header -->
        <v-card-title class="d-flex align-center justify-space-between pa-5 pb-2">
          <div>
            <div class="text-caption font-weight-bold text-medium-emphasis text-uppercase mb-1">
              Request #{{ request.id }}
            </div>
            <div class="text-h6 font-weight-bold">{{ request.title }}</div>
          </div>
          <v-btn icon="mdi-close" variant="text" size="small" @click="close" />
        </v-card-title>

        <v-card-text class="pa-5">
          <!-- Badges + Meta -->
          <div class="d-flex ga-2 mb-4">
            <StatusBadge :status="request.status" />
            <PriorityBadge :priority="request.priority" />
          </div>

          <p class="text-body-1 mb-5" style="white-space: pre-wrap; line-height: 1.7;">{{ request.description }}</p>

          <v-divider class="mb-4" />

          <v-row class="mb-2">
            <v-col cols="4">
              <div class="text-caption font-weight-bold text-medium-emphasis text-uppercase">Assignee</div>
              <div class="text-body-2 font-weight-medium mt-1">{{ request.assignee?.name || 'Unassigned' }}</div>
            </v-col>
            <v-col cols="4">
              <div class="text-caption font-weight-bold text-medium-emphasis text-uppercase">Due Date</div>
              <div class="text-body-2 font-weight-medium mt-1">{{ formatDate(request.due_date) }}</div>
            </v-col>
            <v-col cols="4">
              <div class="text-caption font-weight-bold text-medium-emphasis text-uppercase">Created</div>
              <div class="text-body-2 font-weight-medium mt-1">{{ formatDateTime(request.created_at) }}</div>
            </v-col>
          </v-row>

          <v-divider class="my-4" />

          <!-- Comments -->
          <h3 class="text-subtitle-1 font-weight-bold mb-3">Comments ({{ comments.length }})</h3>

          <div v-if="comments.length" class="mb-4">
            <div v-for="comment in comments" :key="comment.id" class="mb-3 pa-3" style="background: #f9fafb; border-radius: 8px;">
              <div class="d-flex align-center justify-space-between mb-1">
                <span class="text-body-2 font-weight-bold">{{ comment.author_name }}</span>
                <span class="text-caption text-medium-emphasis">{{ formatDateTime(comment.created_at) }}</span>
              </div>
              <p class="text-body-2" style="white-space: pre-wrap; line-height: 1.5;">{{ comment.body }}</p>
            </div>
          </div>
          <p v-else class="text-medium-emphasis mb-4">No comments yet.</p>

          <!-- Add Comment -->
          <v-divider class="mb-4" />
          <h4 class="text-subtitle-2 font-weight-bold mb-3">Add a comment</h4>
          <v-form @submit.prevent="submitComment">
            <v-select
              v-model="form.team_member_id"
              label="Author"
              :items="authorItems"
              :disabled="memberStore.loading || submitting"
              density="comfortable"
              variant="outlined"
              color="primary"
              class="mb-3"
            />
            <v-textarea
              v-model="form.body"
              label="Comment"
              placeholder="Add at least 10 characters..."
              :rows="3"
              :disabled="submitting"
              density="comfortable"
              variant="outlined"
              color="primary"
              class="mb-2"
            />
            <v-alert v-if="formError" type="error" variant="tonal" density="compact" class="mb-3">
              {{ formError }}
            </v-alert>
          </v-form>
        </v-card-text>

        <v-divider />
        <v-card-actions class="pa-4 justify-end">
          <v-btn variant="outlined" @click="close">Cancel</v-btn>
          <v-btn color="primary" :loading="submitting" @click="submitComment">
            Post Comment
          </v-btn>
        </v-card-actions>
      </template>
    </v-card>
  </v-dialog>
</template>
