import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

// Relative base so the build works both locally and under
// https://<user>.github.io/employee_task_tracker/ on GitHub Pages.
export default defineConfig({
  base: './',
  plugins: [react(), tailwindcss()],
})
