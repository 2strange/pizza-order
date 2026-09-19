<script setup>
import { formatCents } from '../money.js'

// The receipt: every line with the parts that make its price, every adjustment
// the server applied, subtotal and total. Read-only — the numbers are the
// server's, this only lays them out.
defineProps({
  quote: { type: Object, required: true },
  removable: { type: Boolean, default: false },
})
defineEmits(['remove'])
</script>

<template>
  <div class="breakdown">
    <ul class="breakdown__lines">
      <li v-for="(item, index) in quote.items" :key="index" class="breakdown__line">
        <div class="breakdown__head">
          <span class="breakdown__title">{{ item.pizza }} · {{ item.size }} · {{ item.quantity }}×</span>
          <span class="breakdown__amount">{{ formatCents(item.line_price_cents) }}</span>
          <button v-if="removable" type="button" class="breakdown__remove" aria-label="Position entfernen" @click="$emit('remove', index)">
            ×
          </button>
        </div>
        <p class="breakdown__detail">
          {{ formatCents(item.base_price_cents) }}
          <template v-if="item.extras.length"> + {{ formatCents(item.extras_price_cents) }} ({{ item.extras.join(', ') }})</template>
          = {{ formatCents(item.unit_price_cents) }} je Pizza
        </p>
        <p v-if="item.removed.length" class="breakdown__removed">ohne {{ item.removed.join(', ') }}</p>
      </li>
    </ul>
    <dl class="breakdown__sums">
      <div class="breakdown__sum">
        <dt>Zwischensumme</dt>
        <dd>{{ formatCents(quote.subtotal_cents) }}</dd>
      </div>
      <div v-for="(adjustment, index) in quote.adjustments" :key="index" class="breakdown__sum breakdown__sum--adjustment">
        <dt>{{ adjustment.label }}</dt>
        <dd>{{ formatCents(adjustment.amount_cents) }}</dd>
      </div>
      <div class="breakdown__sum breakdown__sum--total">
        <dt>Gesamt</dt>
        <dd>{{ formatCents(quote.total_cents) }}</dd>
      </div>
    </dl>
  </div>
</template>
