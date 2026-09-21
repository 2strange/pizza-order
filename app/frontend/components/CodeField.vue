<script setup>
import { ref } from 'vue'

// The codes: what is applied (as removable chips, each with the kind the server
// recognised), a field to add one, and the server's verdict when one was refused.
defineProps({
  label: { type: String, required: true },
  applied: { type: Array, default: () => [] },
  errors: { type: Array, default: () => [] },
})
const emit = defineEmits(['apply', 'clear'])

const draft = ref('')

function apply() {
  const code = draft.value.trim().toUpperCase()
  if (!code) return
  emit('apply', code)
  draft.value = ''
}

const UNKNOWN = /^Unknown code: (.+)$/
const SECOND_DISCOUNT = /^Only one discount code per order: (.+)$/
const KINDS = { promotion: 'Aktion', discount: 'Rabatt' }
// The server speaks English; the customer reads German.
function friendly(message) {
  if (UNKNOWN.test(message)) return `Den Code „${message.match(UNKNOWN)[1]}“ kennen wir nicht.`
  if (SECOND_DISCOUNT.test(message)) return `Nur ein Rabattcode pro Bestellung — „${message.match(SECOND_DISCOUNT)[1]}“ kam zu spät.`
  return message
}
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
      <li v-for="({ code, kind }, index) in applied" :key="index" class="chip">
        <span v-if="KINDS[kind]" class="chip__kind">{{ KINDS[kind] }}</span>
        {{ code }}
        <button type="button" class="chip__remove" :aria-label="`${code} entfernen`" @click="$emit('clear', index)">×</button>
      </li>
    </ul>
    <p v-for="error in errors" :key="error" class="code__error" role="alert">{{ friendly(error) }}</p>
  </div>
</template>
