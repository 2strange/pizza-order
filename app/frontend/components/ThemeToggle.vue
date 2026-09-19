<script setup>
import { ref } from 'vue'

// Light or dark: sets data-theme on <html> (the stylesheet swaps the tokens),
// remembers the choice, and starts from the system preference otherwise.
const KEY = 'pizza-order.theme'

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

function apply() {
  document.documentElement.dataset.theme = theme.value
}

function toggle() {
  theme.value = theme.value === 'dark' ? 'light' : 'dark'
  apply()
  remember(theme.value)
}

apply()
</script>

<template>
  <button type="button" class="theme-toggle" :aria-pressed="theme === 'dark'" @click="toggle">
    {{ theme === 'dark' ? 'Hell' : 'Dunkel' }}
  </button>
</template>
