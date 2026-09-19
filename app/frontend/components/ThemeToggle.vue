<script setup>
import { ref } from 'vue'

// Four looks, one attribute: sets data-theme on <html> (the stylesheet swaps
// the tokens), remembers the choice, and starts from the system preference
// otherwise. Shift-click any option for the Commodore easter egg.
const KEY = 'pizza-order.theme'

const THEMES = [
  { key: 'light', label: 'Hell', icon: 'M12 3v2M12 19v2M3 12h2M19 12h2M5.6 5.6l1.4 1.4M17 17l1.4 1.4M5.6 18.4 7 17M17 7l1.4-1.4M12 8a4 4 0 1 0 0 8a4 4 0 0 0 0-8z' },
  { key: 'dark', label: 'Dunkel', icon: 'M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z' },
  { key: 'nerd', label: 'Nerd', icon: 'M4 6l5 6-5 6M12 18h8' },
  { key: 'human', label: 'Human', icon: 'M12 20s-7-4.5-7-10a4 4 0 0 1 7-2.5A4 4 0 0 1 19 10c0 5.5-7 10-7 10z' },
]
const EASTER_EGG = 'c64'

function stored() {
  try {
    return localStorage.getItem(KEY)
  } catch {
    return null
  }
}

function remember(theme) {
  try {
    localStorage.setItem(KEY, theme)
  } catch {
    // private mode or blocked storage: the choice just does not survive a reload
  }
}

const preferred = () => (window.matchMedia?.('(prefers-color-scheme: dark)').matches ? 'dark' : 'light')
const theme = ref(stored() ?? preferred())

function choose(key) {
  theme.value = key
  document.documentElement.dataset.theme = key
  remember(key)
}

choose(theme.value)
</script>

<template>
  <div class="theme-toggle" role="group" aria-label="Darstellung">
    <button
      v-for="option in THEMES"
      :key="option.key"
      type="button"
      class="theme-toggle__option"
      :aria-pressed="theme === option.key"
      @click="choose($event.shiftKey ? EASTER_EGG : option.key)"
    >
      <svg class="theme-toggle__icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path :d="option.icon" /></svg>
      {{ option.label }}
    </button>
  </div>
</template>
