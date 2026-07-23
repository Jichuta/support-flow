import 'vuetify/styles'
import '@mdi/font/css/materialdesignicons.css'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'

const supportFlowTheme = {
  dark: false,
  colors: {
    background: '#f9fafb',
    surface: '#ffffff',
    'surface-variant': '#f3f4f6',
    primary: '#2563eb',
    'primary-darken-1': '#1d4ed8',
    secondary: '#6b7280',
    error: '#ef4444',
    info: '#3b82f6',
    success: '#22c55e',
    warning: '#f59e0b',
    'on-background': '#111827',
    'on-surface': '#111827',
    'on-primary': '#ffffff',
    'on-secondary': '#ffffff',
    'on-error': '#ffffff',
    'on-success': '#ffffff',
    'on-warning': '#111827',
  },
}

export default createVuetify({
  components,
  directives,
  theme: {
    defaultTheme: 'supportFlowTheme',
    themes: {
      supportFlowTheme,
    },
  },
  defaults: {
    VBtn: {
      rounded: 'lg',
      fontWeight: 600,
    },
    VCard: {
      rounded: 'lg',
      elevation: 0,
    },
    VTextField: {
      variant: 'outlined',
      density: 'comfortable',
      color: 'primary',
    },
    VSelect: {
      variant: 'outlined',
      density: 'comfortable',
      color: 'primary',
    },
    VTextarea: {
      variant: 'outlined',
      density: 'comfortable',
      color: 'primary',
    },
    VDataTable: {
      hover: true,
    },
    VChip: {
      rounded: 'lg',
    },
    VDialog: {
      maxWidth: 480,
    },
    VAlert: {
      rounded: 'lg',
    },
  },
})
