<script setup>
import PriceBreakdown from './PriceBreakdown.vue'

// The placed order: number, name, receipt.
defineProps({ order: { type: Object, required: true } })
defineEmits(['again'])
</script>

<template>
  <section class="confirmation" aria-labelledby="confirmation-title">
    <h2 id="confirmation-title" class="confirmation__title">Danke, {{ order.customer_name }}!</h2>
    <p class="confirmation__lead">
      Deine Bestellung <strong class="confirmation__number">{{ order.number }}</strong> ist in der Küche.
    </p>
    <PriceBreakdown :quote="order.quote" />
    <button type="button" class="button" @click="$emit('again')">Neue Bestellung</button>
  </section>
</template>
