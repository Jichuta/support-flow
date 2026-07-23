<template>
  <div class="app-layout">
    <AppSidebar />
    <div class="app-main">
      <AppTopBar :title="pageTitle">
        <template #actions>
          <slot name="top-bar-actions" />
        </template>
      </AppTopBar>
      <main class="app-content">
        <RouterView />
      </main>
    </div>
    <ToastContainer />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { RouterView, useRoute } from 'vue-router'
import AppSidebar from '@/components/layout/AppSidebar.vue'
import AppTopBar from '@/components/layout/AppTopBar.vue'
import ToastContainer from '@/components/shared/ToastContainer.vue'

const route = useRoute()

const pageTitle = computed(() => {
  const titles = {
    Dashboard: 'Dashboard',
    RequestList: 'Support Requests',
    RequestNew: 'New Support Request',
    RequestDetail: 'Request Detail',
    RequestEdit: 'Edit Request',
    TeamMembers: 'Team Members'
  }
  return titles[route.name] || 'SupportFlow'
})
</script>

<style scoped>
.app-layout {
  display: flex;
  min-height: 100vh;
}

.app-main {
  flex: 1;
  margin-left: 200px;
  display: flex;
  flex-direction: column;
}

.app-content {
  flex: 1;
  padding: 24px;
  background: #f9fafb;
}

@media (max-width: 768px) {
  .app-layout {
    flex-direction: column;
  }
  .app-main {
    margin-left: 0;
    min-width: 0;
  }
  .app-content {
    padding: 16px;
  }
}
</style>
