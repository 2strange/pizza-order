<script setup>
import PriceBreakdown from './PriceBreakdown.vue'

// The placed order: number, name, receipt.
defineProps({ order: { type: Object, required: true } })
defineEmits(['again'])
</script>

<template>
  <section class="confirmation" aria-labelledby="confirmation-title">
    <!-- the wood-fired oven, pizza inside, steam rising: the order is on its way -->
    <svg class="oven" viewBox="0 -40 200 170" aria-hidden="true" focusable="false">
      <path class="oven__steam" d="M141 -28c-4-6 4-10 0-16" />
      <path class="oven__steam" d="M149 -24c-4-6 4-10 0-16" />
      <path class="oven__steam" d="M157 -28c-4-6 4-10 0-16" />
      <rect class="oven__body" x="136" y="-24" width="22" height="50" rx="2" />
      <rect class="oven__brick" x="133" y="-26" width="28" height="6" rx="1" />
      <path class="oven__body" d="M20 110V70a80 80 0 0 1 160 0v40z" />
      <path class="oven__brick" d="M36 110V72a64 64 0 0 1 128 0v38z" />
      <rect class="oven__body" x="46" y="34" width="22" height="9" rx="2" />
      <rect class="oven__body" x="88" y="20" width="24" height="9" rx="2" />
      <rect class="oven__body" x="132" y="34" width="22" height="9" rx="2" />
      <rect class="oven__body" x="66" y="50" width="20" height="9" rx="2" />
      <rect class="oven__body" x="114" y="50" width="20" height="9" rx="2" />
      <path class="oven__mouth" d="M60 110V88a40 32 0 0 1 80 0v22z" />
      <path class="oven__glow" d="M68 110V92a32 24 0 0 1 64 0v18z" opacity="0.35" />
      <ellipse class="oven__glow" cx="100" cy="106" rx="24" ry="5" />
      <g transform="translate(100 104)">
        <ellipse rx="20" ry="5" class="pizza-art__crust-edge" />
        <ellipse rx="17" ry="3.8" class="pizza-art__sauce" />
        <ellipse rx="13" ry="2.6" class="pizza-art__cheese" />
        <circle cx="-7" cy="-0.5" r="1.8" class="pizza-art__salami" />
        <circle cx="4" cy="0.5" r="1.8" class="pizza-art__salami" />
      </g>
      <rect class="oven__floor" x="10" y="110" width="180" height="10" rx="2" />
      <rect class="oven__body" x="14" y="120" width="172" height="6" rx="1" />
    </svg>
    <h2 id="confirmation-title" class="confirmation__title">Danke, {{ order.customer_name }}!</h2>
    <p class="confirmation__lead">
      Deine Bestellung <strong class="confirmation__number">{{ order.number }}</strong> ist in der Küche.
    </p>
    <PriceBreakdown :quote="order.quote" />
    <button type="button" class="button" @click="$emit('again')">Neue Bestellung</button>
  </section>
</template>
