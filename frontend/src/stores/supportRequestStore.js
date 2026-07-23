import { defineStore } from 'pinia'
import apiClient from '@/api/client.js'
const defaults = () => ({
  status: '',
  priority: '',
  team_member_id: '',
  overdue: false,
  unassigned: false,
  q: ''
})
const run = async (store, request) => {
  store.loading = true
  store.error = null
  try {
    return await request()
  } catch (error) {
    store.error = error
    throw error
  } finally {
    store.loading = false
  }
}
export const useSupportRequestStore = defineStore('supportRequests', {
  state: () => ({
    requests: [],
    currentRequest: null,
    filters: defaults(),
    loading: false,
    error: null
  }),
  getters: {
    activeFilters: (state) =>
      Object.fromEntries(
        Object.entries(state.filters).filter(
          ([, value]) => value !== '' && value !== false && value != null
        )
      )
  },
  actions: {
    setFilter(key, value) {
      if (Object.hasOwn(this.filters, key)) this.filters[key] = value
    },
    clearFilters() {
      this.filters = defaults()
    },
    async fetchRequests() {
      return run(this, async () => {
        const { data } = await apiClient.get('/support_requests', { params: this.activeFilters })
        this.requests = data.support_requests ?? []
        return this.requests
      })
    },
    async fetchRequest(id) {
      return run(this, async () => {
        const { data } = await apiClient.get(`/support_requests/${id}`)
        this.currentRequest = data
        return data
      })
    },
    async createRequest(payload) {
      return run(this, async () => {
        const { data } = await apiClient.post('/support_requests', { support_request: payload })
        this.requests.unshift(data)
        return data
      })
    },
    async updateRequest(id, payload) {
      return run(this, async () => {
        const { data } = await apiClient.patch(`/support_requests/${id}`, {
          support_request: payload
        })
        const comments =
          this.currentRequest?.id === data.id ? this.currentRequest.comments : undefined
        this.currentRequest = comments ? { ...data, comments } : data
        const index = this.requests.findIndex((request) => request.id === data.id)
        if (index !== -1) this.requests.splice(index, 1, data)
        return data
      })
    },
    async addComment(id, payload) {
      return run(this, async () => {
        const { data } = await apiClient.post(`/support_requests/${id}/comments`, {
          comment: payload
        })
        if (this.currentRequest?.id === Number(id))
          this.currentRequest.comments = [...(this.currentRequest.comments ?? []), data]
        return data
      })
    }
  }
})
