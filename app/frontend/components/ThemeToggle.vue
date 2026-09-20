<script setup>
import { ref } from 'vue'

// Three looks, one attribute: sets data-theme on <html> (the stylesheet swaps
// the tokens), remembers the choice, and starts from the system preference
// otherwise. Tapping "Nerd" while it is already on (or shift-clicking any
// option) turns on the Commodore easter egg; any option leads back out.
const KEY = 'pizza-order.theme'

const THEMES = [
  { key: 'light', label: 'Hell', icon: 'M12 3v2M12 19v2M3 12h2M19 12h2M5.6 5.6l1.4 1.4M17 17l1.4 1.4M5.6 18.4 7 17M17 7l1.4-1.4M12 8a4 4 0 1 0 0 8a4 4 0 0 0 0-8z' },
  { key: 'dark', label: 'Dunkel', icon: 'M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z' },
  { key: 'nerd', label: 'Nerd', icon: 'M4 6l5 6-5 6M12 18h8' },
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
const known = (key) => THEMES.some((option) => option.key === key) || key === EASTER_EGG
// a remembered theme that no longer exists falls back to the system preference
const theme = ref(known(stored()) ? stored() : preferred())

function choose(key) {
  theme.value = key
  document.documentElement.dataset.theme = key
  remember(key)
}

function pick(event, key) {
  const again = key === 'nerd' && theme.value === 'nerd'
  choose(event.shiftKey || again ? EASTER_EGG : key)
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
      @click="pick($event, option.key)"
    >
      <svg class="theme-toggle__icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path :d="option.icon" /></svg>
      {{ option.label }}
    </button>
  </div>
</template>
