<script setup>
import { computed, ref } from 'vue'
import CodeField from './CodeField.vue'
import PriceBreakdown from './PriceBreakdown.vue'

// The cart as the server prices it: the breakdown of the latest quote, the
// codes, and the checkout form. All numbers come from `cart.state.quote`.
const props = defineProps({ cart: { type: Object, required: true } })
const emit = defineEmits(['placed'])

const state = props.cart.state
const customerName = ref('')
const submitting = ref(false)

const errorsAbout = (kind) => computed(() => state.errors.filter((error) => error.startsWith(`Unknown ${kind} code`)))
const promotionErrors = errorsAbout('promotion')
const discountErrors = errorsAbout('discount')
const otherErrors = computed(() => state.errors.filter((error) => !error.startsWith('Unknown')))

async function submit() {
  submitting.value = true
  try {
    if (await props.cart.placeOrder(customerName.value)) emit('placed')
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
        <CodeField label="Aktionscode" :applied="state.promotionCodes" :errors="promotionErrors" @apply="cart.addPromotionCode" @clear="cart.removePromotionCode" />
        <CodeField
          label="Rabattcode"
          :applied="state.discountCode ? [state.discountCode] : []"
          :errors="discountErrors"
          @apply="cart.setDiscountCode"
          @clear="cart.setDiscountCode('')"
        />
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
