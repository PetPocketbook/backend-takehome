import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// Dev: Vite serves the SPA on :5173 and proxies API + public assets to Rails on :3000.
// Prod: `npm run build` copies frontend/dist/ into backend/public/frontend/ for Rails to serve.
export default defineConfig(({ mode }) => ({
  base: mode === 'production' ? '/frontend/' : '/',
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/api': 'http://localhost:3000',
      '/images': 'http://localhost:3000',
    },
  },
  build: {
    outDir: 'dist',
    emptyOutDir: true,
  },
}));
