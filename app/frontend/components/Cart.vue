<script setup>
import { computed, ref } from 'vue'
import CodeField from './CodeField.vue'
import PriceBreakdown from './PriceBreakdown.vue'

// The cart as the server prices it: the breakdown of the latest quote, the
// codes, and the checkout form. All numbers come from `cart.state.quote`.
const props = defineProps({ cart: { type: Object, required: true } })

const state = props.cart.state
const customerName = ref('')
const submitting = ref(false)

const aboutCodes = (error) => error.startsWith('Unknown code') || error.startsWith('Only one discount code')
const codeErrors = computed(() => state.errors.filter(aboutCodes))
const otherErrors = computed(() => state.errors.filter((error) => !aboutCodes(error)))

// The chips show what the server made of each code: the kind comes back with
// the quote's adjustments (a valid promotion that matches nothing has none).
const applied = computed(() =>
  state.codes.map((code) => ({ code, kind: state.quote?.adjustments.find((a) => a.code === code)?.kind })),
)

async function submit() {
  submitting.value = true
  try {
    await props.cart.placeOrder(customerName.value) // App switches to the confirmation via cart.state.order
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <section id="cart" class="cart" aria-labelledby="cart-title">
    <h2 id="cart-title" class="cart__title">Warenkorb</h2>

    <p v-if="state.items.length === 0" class="cart__empty">Noch leer — such dir oben eine Pizza aus.</p>

    <template v-else>
      <PriceBreakdown v-if="state.quote" :quote="state.quote" removable :class="{ 'is-pending': state.pending }" @remove="cart.removeItem" />
      <p v-else class="cart__empty">Preis wird berechnet …</p>

      <div class="cart__codes">
        <CodeField label="Aktions- oder Rabattcode" :applied="applied" :errors="codeErrors" @apply="cart.addCode" @clear="cart.removeCode" />
      </div>

      <form class="cart__checkout" @submit.prevent="submit">
        <label class="cart__name">
          <span>Dein Name</span>
          <input v-model.trim="customerName" type="text" autocomplete="name" required />
        </label>
        <p v-for="error in otherErrors" :key="error" class="cart__error" role="alert">{{ error }}</p>
        <button type="submit" class="button button--primary" :disabled="submitting || state.pending || !state.quote">Bestellen</button>
      </form>
    </template>
  </section>
</template>
