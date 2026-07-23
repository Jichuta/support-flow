<template>
  <aside class="sidebar">
    <div class="sidebar-logo">
      <span class="logo-icon">🔧</span>
      <span class="logo-text">SupportFlow</span>
    </div>

    <nav class="sidebar-nav">
      <RouterLink to="/" class="nav-item" exact-active-class="active">
        <span class="nav-icon">📊</span>
        <span class="nav-label">Dashboard</span>
      </RouterLink>
      <RouterLink to="/requests" class="nav-item" active-class="active">
        <span class="nav-icon">🎫</span>
        <span class="nav-label">Requests</span>
      </RouterLink>
      <RouterLink to="/members" class="nav-item" active-class="active">
        <span class="nav-icon">👥</span>
        <span class="nav-label">Team Members</span>
      </RouterLink>
    </nav>

    <div class="sidebar-footer">
      <div class="user-avatar">E1</div>
      <div class="user-info">
        <div class="user-name">Engineer 1</div>
        <div class="user-role">Developer</div>
      </div>
    </div>
  </aside>
</template>

<style scoped>
.sidebar {
  width: 200px;
  height: 100vh;
  position: fixed;
  top: 0;
  left: 0;
  background: #fff;
  border-right: 1px solid #e5e7eb;
  display: flex;
  flex-direction: column;
  z-index: 100;
}

.sidebar-logo {
  display: flex;
  align-items: center;
  gap: 8px;
  height: 56px;
  padding: 0 16px;
  border-bottom: 1px solid #e5e7eb;
  box-sizing: border-box;
}

.logo-icon {
  font-size: 20px;
}

.logo-text {
  font-size: 16px;
  font-weight: 700;
  color: #111827;
}

.sidebar-nav {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 12px 8px;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 12px;
  border-radius: 8px;
  color: #374151;
  text-decoration: none;
  font-size: 14px;
  font-weight: 500;
  transition: all 150ms ease;
}

.nav-item:hover {
  background: #f3f4f6;
}

.nav-item.active {
  background: rgba(37, 99, 235, 0.1);
  color: #2563eb;
}

.nav-icon {
  font-size: 16px;
  width: 20px;
  text-align: center;
}

.sidebar-footer {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 16px;
  border-top: 1px solid #e5e7eb;
}

.user-avatar {
  width: 32px;
  height: 32px;
  border-radius: 9999px;
  background: #2563eb;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 600;
}

.user-name {
  font-size: 14px;
  font-weight: 500;
  color: #111827;
}

.user-role {
  font-size: 12px;
  color: #6b7280;
}

@media (max-width: 768px) {
  .sidebar {
    position: static;
    width: 100%;
    height: auto;
    min-height: 0;
    box-sizing: border-box;
  }
  .sidebar-logo {
    padding: 0 16px;
  }
  .sidebar-nav {
    flex: initial;
    flex-direction: row;
    gap: 4px;
    overflow-x: auto;
    padding: 8px;
  }
  .nav-item {
    flex: 0 0 auto;
    padding: 8px 10px;
  }
  .nav-label {
    font-size: 13px;
  }
  .sidebar-footer {
    display: none;
  }
}
</style>
