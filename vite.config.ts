import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import FullReload from 'vite-plugin-full-reload' // Install this if you haven't!

export default defineConfig({
  plugins: [
    RubyPlugin(),
    FullReload(['config/routes.rb', 'app/views/**/*'], { delay: 200 }),
  ],
    server: {
    // Ensures file changes are reliably intercepted (critical inside Docker/WSL)
    watch: {
      usePolling: true,
    }}
})
