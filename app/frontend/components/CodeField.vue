<script setup>
import { ref } from 'vue'

// One kind of code: what is applied (as removable chips), a field to add one,
// and the server's verdict when a code was refused.
defineProps({
  label: { type: String, required: true },
  applied: { type: Array, default: () => [] },
  errors: { type: Array, default: () => [] },
})
const emit = defineEmits(['apply', 'clear'])

const draft = ref('')

function apply() {
  const code = draft.value.trim()
  if (!code) return
  emit('apply', code)
  draft.value = ''
}

const CODE = /^Unknown (?:promotion|discount) code: (.+)$/
// The model speaks English; the customer reads German.
const friendly = (message) => (CODE.test(message) ? `Den Code „${message.match(CODE)[1]}“ kennen wir nicht.` : message)
</script>

<template>
  <div class="code">
    <form class="code__form" @submit.prevent="apply">
      <label class="code__label">
        <span>{{ label }}</span>
        <input v-model="draft" type="text" autocomplete="off" autocapitalize="characters" spellcheck="false" />
      </label>
      <button type="submit" class="button">Einlösen</button>
    </form>
    <ul v-if="applied.length" class="code__applied">
      <li v-for="(code, index) in applied" :key="index" class="chip">
        {{ code }}
        <button type="button" class="chip__remove" :aria-label="`${code} entfernen`" @click="$emit('clear', index)">×</button>
      </li>
    </ul>
    <p v-for="error in errors" :key="error" class="code__error" role="alert">{{ friendly(error) }}</p>
  </div>
</template>
