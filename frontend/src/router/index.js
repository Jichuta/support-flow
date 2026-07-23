import { createRouter, createWebHistory } from 'vue-router'
import AppLayout from '@/components/layout/AppLayout.vue'
import Dashboard from '@/views/Dashboard.vue'
import RequestList from '@/views/RequestList.vue'
import TeamMembers from '@/views/TeamMembers.vue'

const routes = [
  {
    path: '/',
    component: AppLayout,
    children: [
      {
        path: '',
        name: 'Dashboard',
        component: Dashboard
      },
      {
        path: 'requests',
        name: 'RequestList',
        component: RequestList
      },
      {
        path: 'members',
        name: 'TeamMembers',
        component: TeamMembers
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
