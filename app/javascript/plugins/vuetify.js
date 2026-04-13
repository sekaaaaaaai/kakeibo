import "vuetify/styles"
import "@mdi/font/css/materialdesignicons.css"

import { createVuetify } from "vuetify"

export const vuetify = createVuetify({
  theme: {
    defaultTheme: "light",
    themes: {
      light: {
        colors: {
          primary: "#0f766e",
          secondary: "#334155",
          success: "#15803d",
          error: "#b91c1c",
          background: "#f8fafc",
          surface: "#ffffff",
        },
      },
    },
  },
})
