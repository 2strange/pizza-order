import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [RubyPlugin(), vue()],
  test: {
    environment: 'jsdom',
    include: ['**/*.test.{js,ts}'],
  },
})
