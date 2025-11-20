import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'Dashboard',
      component: () => import('./views/DashboardView.vue')
    },
    {
      path: '/tags',
      name: 'Tags',
      component: () => import('./views/TagsView.vue')
    },
    {
      path: '/alarms',
      name: 'Alarms',
      component: () => import('./views/AlarmsView.vue')
    },
    {
      path: '/objects',
      name: 'Objects',
      component: () => import('./views/ObjectsView.vue')
    },
    {
      path: '/:pathMatch(.*)*',
      redirect: '/'
    }
  ]
})

export default router