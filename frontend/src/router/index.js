import { createRouter, createWebHistory } from 'vue-router'
import AppLayout from '@/components/layout/AppLayout.vue'
import Dashboard from '@/views/Dashboard.vue'
import RequestList from '@/views/RequestList.vue'
import RequestNew from '@/views/RequestNew.vue'
import RequestDetail from '@/views/RequestDetail.vue'
import RequestEdit from '@/views/RequestEdit.vue'
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
        path: 'requests/new',
        name: 'RequestNew',
        component: RequestNew
      },
      {
        path: 'requests/:id',
        name: 'RequestDetail',
        component: RequestDetail,
        props: true
      },
      {
        path: 'requests/:id/edit',
        name: 'RequestEdit',
        component: RequestEdit,
        props: true
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
