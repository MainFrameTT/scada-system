<template>
  <div id="app">
    <nav class="navbar">
      <div class="nav-brand">
        <h1>🛢️ SCADA System</h1>
        <span class="subtitle">Нефтепровод</span>
      </div>
      <div class="nav-links">
        <router-link to="/" class="nav-link">Дашборд</router-link>
        <router-link to="/tags" class="nav-link">Теги</router-link>
        <router-link to="/alarms" class="nav-link">Аварии</router-link>
        <router-link to="/objects" class="nav-link">Объекты</router-link>
      </div>
      <div class="nav-status">
        <span class="status-indicator" :class="connectionStatus"></span>
        {{ connectionText }}
      </div>
    </nav>

    <main class="main-content">
      <router-view />
    </main>

    <footer class="footer">
      <div class="footer-content">
        <span>SCADA System &copy; 2024</span>
        <span>Версия 1.0.0</span>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useWebSocket } from './composables/useWebSocket'

const { isConnected } = useWebSocket()

const connectionStatus = computed(() => isConnected.value ? 'connected' : 'disconnected')
const connectionText = computed(() => isConnected.value ? 'Подключено' : 'Отключено')
</script>

<style scoped>
.navbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 2rem;
  background: #1e293b;
  border-bottom: 1px solid #334155;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
}

.nav-brand h1 {
  font-size: 1.5rem;
  font-weight: 700;
  color: #60a5fa;
  margin: 0;
}

.subtitle {
  font-size: 0.875rem;
  color: #94a3b8;
  margin-left: 0.5rem;
}

.nav-links {
  display: flex;
  gap: 2rem;
}

.nav-link {
  color: #cbd5e1;
  text-decoration: none;
  padding: 0.5rem 1rem;
  border-radius: 0.375rem;
  transition: all 0.2s;
  font-weight: 500;
}

.nav-link:hover {
  background: #334155;
  color: #f8fafc;
}

.nav-link.router-link-active {
  background: #3b82f6;
  color: white;
}

.nav-status {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.875rem;
  color: #94a3b8;
}

.status-indicator {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  transition: background-color 0.3s;
}

.status-indicator.connected {
  background: #10b981;
  box-shadow: 0 0 10px #10b981;
}

.status-indicator.disconnected {
  background: #ef4444;
  box-shadow: 0 0 10px #ef4444;
}

.main-content {
  min-height: calc(100vh - 120px);
  padding: 2rem;
  background: #0f172a;
}

.footer {
  background: #1e293b;
  border-top: 1px solid #334155;
  padding: 1rem 2rem;
}

.footer-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: #94a3b8;
  font-size: 0.875rem;
}

@media (max-width: 768px) {
  .navbar {
    flex-direction: column;
    gap: 1rem;
    padding: 1rem;
  }

  .nav-links {
    gap: 1rem;
  }

  .main-content {
    padding: 1rem;
  }
}
</style>