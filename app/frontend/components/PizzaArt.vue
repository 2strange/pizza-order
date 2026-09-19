<script setup>
// Placeholder artwork. The designer's pizzas replace the SVG below, one per
// `name`; colours come from the --pizza-* tokens so a theme can tint them.
defineProps({ name: { type: String, required: true } })
</script>

<template>
  <svg class="pizza-art" viewBox="0 0 64 64" aria-hidden="true" focusable="false">
    <circle cx="32" cy="32" r="30" class="pizza-art__crust" />
    <circle cx="32" cy="32" r="24" class="pizza-art__sauce" />
    <circle cx="24" cy="26" r="5" class="pizza-art__topping" />
    <circle cx="40" cy="30" r="5" class="pizza-art__topping" />
    <circle cx="30" cy="42" r="5" class="pizza-art__topping" />
  </svg>
</template>
