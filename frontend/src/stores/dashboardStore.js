import { defineStore } from 'pinia'
import apiClient from '@/api/client.js'

export const useDashboardStore = defineStore('dashboard', {
  state: () => ({ metrics: null, loading: false, error: null }),
  actions: {
    async fetchMetrics() {
      this.loading = true; this.error = null
      try { const { data } = await apiClient.get('/dashboard'); this.metrics = data; return data }
      catch (error) { this.error = error; throw error }
      finally { this.loading = false }
    }
  }
})
