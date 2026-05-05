import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    // Pin the dev server to 5173 because the Google OAuth web client only
    // whitelists http://localhost:5173 as an Authorized JavaScript origin.
    // strictPort makes Vite fail loudly if 5173 is occupied (so the user
    // knows to kill the stale process) instead of silently falling back to
    // 5174 and breaking Google Sign-In with origin_mismatch.
    port: 5173,
    strictPort: true,
  },
})
