<script setup>
import { formatCents } from '../money.js'
import PizzaArt from './PizzaArt.vue'

// The menu as a list of pizzas. Tapping one opens its configurator right below
// it (the `configurator` slot), tapping again closes it.
defineProps({
  pizzas: { type: Array, required: true },
  selectedId: { type: Number, default: null },
})
defineEmits(['select'])
</script>

<template>
  <ul class="menu">
    <li v-for="pizza in pizzas" :key="pizza.id" class="menu__item" :class="{ 'is-selected': pizza.id === selectedId }">
      <button type="button" class="pizza" :aria-expanded="pizza.id === selectedId" @click="$emit('select', pizza)">
        <PizzaArt :name="pizza.name" class="pizza__art" />
        <span class="pizza__text">
          <span class="pizza__name">{{ pizza.name }}</span>
          <span class="pizza__recipe">{{ pizza.ingredients.map((ingredient) => ingredient.name).join(', ') }}</span>
        </span>
        <span class="pizza__price">{{ formatCents(pizza.base_price_cents) }}</span>
      </button>
      <slot v-if="pizza.id === selectedId" name="configurator" />
    </li>
  </ul>
</template>
