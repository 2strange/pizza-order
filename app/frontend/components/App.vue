<script setup>
import { onMounted, ref } from 'vue'
import { api } from '../api.js'
import { useCart } from '../composables/useCart.js'
import Cart from './Cart.vue'
import MenuBoard from './MenuBoard.vue'
import OrderConfirmation from './OrderConfirmation.vue'
import PizzaArt from './PizzaArt.vue'
import PizzaConfigurator from './PizzaConfigurator.vue'
import ThemeToggle from './ThemeToggle.vue'

// The one page: menu with an inline configurator, the cart below it, and the
// confirmation once the order is placed.
const menu = ref(null)
const selected = ref(null)
const cart = useCart()

onMounted(async () => {
  menu.value = (await api.menu()).data
})

function select(pizza) {
  selected.value = selected.value?.id === pizza.id ? null : pizza
}

function add(item) {
  cart.addItem(item)
  selected.value = null
}
</script>

<template>
  <main class="app">
    <header class="app__header">
      <div class="app__brand">
        <PizzaArt name="Margherita" class="app__logo" />
        <div>
          <h1 class="app__title">Pizza Order</h1>
          <p class="app__tagline">Aus dem Steinofen, direkt auf den Bildschirm.</p>
        </div>
      </div>
      <ThemeToggle />
    </header>

    <OrderConfirmation v-if="cart.state.order" :order="cart.state.order" @again="cart.reset()" />

    <template v-else-if="menu">
      <MenuBoard :pizzas="menu.pizzas" :selected-id="selected?.id ?? null" @select="select">
        <template #configurator>
          <PizzaConfigurator :key="selected.id" :pizza="selected" :sizes="menu.sizes" :extras="menu.extras" @add="add" />
        </template>
      </MenuBoard>
      <Cart :cart="cart" />
    </template>

    <p v-else class="app__hint">Speisekarte wird geladen …</p>
  </main>
</template>
