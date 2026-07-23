import { defineStore } from 'pinia'
let nextToastId = 1
export const useToastStore = defineStore('toasts', {
  state: () => ({ toasts: [] }),
  actions: {
    add(message, type = 'info', options = {}) {
      const toast = { id: nextToastId++, message, type, duration: options.duration ?? 5000 }
      this.toasts.push(toast)
      if (toast.duration > 0) setTimeout(() => this.remove(toast.id), toast.duration)
      return toast
    },
    remove(id) {
      this.toasts = this.toasts.filter((toast) => toast.id !== id)
    },
    success(message, options) {
      return this.add(message, 'success', options)
    },
    error(message, options) {
      return this.add(message, 'error', options)
    },
    warning(message, options) {
      return this.add(message, 'warning', options)
    },
    info(message, options) {
      return this.add(message, 'info', options)
    }
  }
})
