import { defineStore } from 'pinia'
import apiClient from '@/api/client.js'
const run = async (store, request) => { store.loading = true; store.error = null; try { return await request() } catch (error) { store.error = error; throw error } finally { store.loading = false } }
export const useTeamMemberStore = defineStore('teamMembers', {
  state: () => ({ members: [], loading: false, error: null }),
  actions: {
    async fetchMembers() { return run(this, async () => { const { data } = await apiClient.get('/team_members'); this.members = data.team_members ?? []; return this.members }) },
    async createMember(payload) { return run(this, async () => { const { data } = await apiClient.post('/team_members', { team_member: payload }); this.members.push(data); this.members.sort((a, b) => a.name.localeCompare(b.name)); return data }) },
    async toggleActive(id, active) { return run(this, async () => { const { data } = await apiClient.patch(`/team_members/${id}`, { team_member: { active } }); const index = this.members.findIndex((member) => member.id === data.id); if (index !== -1) this.members.splice(index, 1, data); return data }) }
  }
})
