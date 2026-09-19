<script setup>
import { reactive } from 'vue'
import { formatCents } from '../money.js'

// Size, extras, ingredients to leave out, quantity. Emits the item the way the
// server wants it — ids and keys only, no prices.
const props = defineProps({
  pizza: { type: Object, required: true },
  sizes: { type: Array, required: true },
  extras: { type: Array, required: true },
})
const emit = defineEmits(['add'])

const form = reactive({
  size: (props.sizes.find((size) => size.key === 'medium') ?? props.sizes[0]).key,
  quantity: 1,
  extraIds: [],
  removedIds: [],
})

const multiplier = (size) => `×${String(size.multiplier).replace('.', ',')}`

function submit() {
  emit('add', {
    pizza_id: props.pizza.id,
    size: form.size,
    quantity: form.quantity,
    extra_ids: [...form.extraIds],
    removed_ingredient_ids: [...form.removedIds],
  })
}
</script>

<template>
  <form class="configurator" @submit.prevent="submit">
    <fieldset class="configurator__group">
      <legend class="configurator__legend">Größe</legend>
      <label v-for="size in sizes" :key="size.key" class="choice">
        <input v-model="form.size" type="radio" name="size" :value="size.key" />
        <span class="choice__label">{{ size.label }}</span>
        <span class="choice__note">{{ multiplier(size) }}</span>
      </label>
    </fieldset>

    <fieldset class="configurator__group">
      <legend class="configurator__legend">Extras</legend>
      <label v-for="extra in extras" :key="extra.id" class="choice">
        <input v-model="form.extraIds" type="checkbox" :value="extra.id" />
        <span class="choice__label">{{ extra.name }}</span>
        <span class="choice__note">+ {{ formatCents(extra.extra_price_cents) }}</span>
      </label>
    </fieldset>

    <fieldset class="configurator__group">
      <legend class="configurator__legend">Weglassen</legend>
      <label v-for="ingredient in pizza.ingredients" :key="ingredient.id" class="choice">
        <input v-model="form.removedIds" type="checkbox" :value="ingredient.id" />
        <span class="choice__label">ohne {{ ingredient.name }}</span>
      </label>
    </fieldset>

    <div class="configurator__actions">
      <label class="configurator__quantity">
        <span>Menge</span>
        <input v-model.number="form.quantity" type="number" min="1" step="1" required />
      </label>
      <button type="submit" class="button button--primary">In den Warenkorb</button>
    </div>
  </form>
</template>
