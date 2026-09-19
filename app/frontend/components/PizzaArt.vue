<script setup>
import { computed } from 'vue'

// One cartoon pizza per menu name. Every shape carries a `pizza-art__*` class
// and takes its colour from the matching --pizza-* token, so a theme can retint
// (or, as the nerd theme does, turn them into wireframes) without touching this.
const props = defineProps({ name: { type: String, required: true } })

const KNOWN = ['margherita', 'salami', 'funghi', 'prosciutto', 'tonno', 'quattro-formaggi']
const kind = computed(() => {
  const key = props.name.toLowerCase().replace(/\s+/g, '-')
  return KNOWN.includes(key) ? key : 'cheese'
})

// Melted cheese: a wobbly blob so a rim of sauce stays visible.
const CHEESE =
  'M51.3,32.0 C51.2,35.8 49.4,39.8 47.2,43.0 C45.0,46.3 41.8,50.3 38.3,51.4 C34.8,52.5 30.0,50.9 26.3,49.6 ' +
  'C22.5,48.4 18.1,46.7 15.8,43.8 C13.5,40.8 12.3,35.8 12.5,32.0 C12.7,28.2 14.8,24.3 17.0,21.1 ' +
  'C19.3,18.0 22.4,14.2 25.8,13.1 C29.3,11.9 34.0,13.3 37.7,14.5 C41.4,15.7 45.7,17.5 47.9,20.4 C50.2,23.3 51.5,28.2 51.3,32.0Z'

const LEAF = 'M0,-7 C4.5,-4.5 4.5,4.5 0,7 C-4.5,4.5 -4.5,-4.5 0,-7Z'
const RIBBON = 'M-9,-3 C-6,-6 -3,0 0,-3 S6,-6 9,-3 L9,3 C6,6 3,0 0,3 S-6,6 -9,3Z'
const RIBBON_FAT = 'M-9,-3 C-6,-6 -3,0 0,-3 S6,-6 9,-3 L9,-1 C6,-4 3,2 0,-1 S-6,-4 -9,-1Z'
const CHUNK = 'M-5,-3 L1,-5 L5,-1 L4,4 L-2,5 L-6,1Z'

// [x, y, rotation] per topping
const basil = [[33, 33, 30], [22, 36, -60], [42, 21, 70]]
const salami = [[24, 25, 0], [40, 24, 40], [32, 35, 80], [22, 40, 120], [42, 41, 160]]
const mushrooms = [[25, 25, -20], [40, 26, 30], [30, 41, 200], [43, 41, 140]]
const ribbons = [[30, 24, -20], [36, 34, 25], [28, 42, -5]]
const chunks = [[24, 25, 0], [40, 26, 60], [28, 40, 120], [42, 40, 200]]
const rings = [[33, 31, 7], [26, 37, 5]] // [x, y, radius]

const place = ([x, y, angle]) => `translate(${x} ${y}) rotate(${angle})`
</script>

<template>
  <svg class="pizza-art" viewBox="0 0 64 64" aria-hidden="true" focusable="false">
    <!-- dough -->
    <circle cx="32" cy="32" r="30" class="pizza-art__crust-edge" />
    <circle cx="32" cy="32" r="27.5" class="pizza-art__crust" />
    <circle cx="32" cy="32" r="23" class="pizza-art__sauce" />

    <!-- Margherita: sauce, mozzarella patches, basil -->
    <template v-if="kind === 'margherita'">
      <ellipse cx="25" cy="26" rx="5.5" ry="4.5" class="pizza-art__topping" />
      <circle cx="40" cy="29" r="5" class="pizza-art__topping" />
      <ellipse cx="29" cy="41" rx="4.5" ry="4" class="pizza-art__topping" />
      <circle cx="41" cy="42" r="3.5" class="pizza-art__topping" />
      <g v-for="leaf in basil" :key="place(leaf)" :transform="place(leaf)">
        <path :d="LEAF" class="pizza-art__basil" />
        <rect x="-0.5" y="-5" width="1" height="10" class="pizza-art__basil-vein" />
      </g>
    </template>

    <!-- everything else sits on melted cheese -->
    <path v-else :d="CHEESE" class="pizza-art__cheese" />

    <!-- Salami: five slices with fat dots -->
    <template v-if="kind === 'salami'">
      <g v-for="slice in salami" :key="place(slice)" :transform="place(slice)">
        <circle r="4.5" class="pizza-art__salami" />
        <circle cx="-1.5" cy="-1" r="0.9" class="pizza-art__salami-dot" />
        <circle cx="1.6" cy="0.4" r="0.8" class="pizza-art__salami-dot" />
        <circle cx="-0.3" cy="2" r="0.7" class="pizza-art__salami-dot" />
      </g>
    </template>

    <!-- Funghi: sliced mushrooms, cap up -->
    <template v-if="kind === 'funghi'">
      <g v-for="mushroom in mushrooms" :key="place(mushroom)" :transform="place(mushroom)">
        <rect x="-2" y="-0.5" width="4" height="5.5" rx="1" class="pizza-art__mushroom" />
        <path d="M-6,0 A6,5 0 0 1 6,0 Z" class="pizza-art__mushroom-cap" />
        <path d="M-3.5,0 A3.5,2.6 0 0 1 3.5,0 Z" class="pizza-art__mushroom" />
      </g>
    </template>

    <!-- Prosciutto: folded ham ribbons with a fat edge -->
    <template v-if="kind === 'prosciutto'">
      <g v-for="ribbon in ribbons" :key="place(ribbon)" :transform="place(ribbon)">
        <path :d="RIBBON" class="pizza-art__ham" />
        <path :d="RIBBON_FAT" class="pizza-art__ham-fat" />
      </g>
    </template>

    <!-- Tonno: tuna chunks and onion rings -->
    <template v-if="kind === 'tonno'">
      <path v-for="chunk in chunks" :key="place(chunk)" :d="CHUNK" :transform="place(chunk)" class="pizza-art__tuna" />
      <circle v-for="[x, y, r] in rings" :key="`${x}-${y}`" :cx="x" :cy="y" :r="r" class="pizza-art__onion" />
    </template>

    <!-- Quattro Formaggi: four quarters, four cheeses, sauce showing in the gaps -->
    <template v-if="kind === 'quattro-formaggi'">
      <path d="M32,32 L32,11.5 A20.5,20.5 0 0 1 52.5,32 Z" transform="translate(0.7 -0.7)" class="pizza-art__cheese" />
      <path d="M32,32 L52.5,32 A20.5,20.5 0 0 1 32,52.5 Z" transform="translate(0.7 0.7)" class="pizza-art__topping" />
      <path d="M32,32 L32,52.5 A20.5,20.5 0 0 1 11.5,32 Z" transform="translate(-0.7 0.7)" class="pizza-art__parmesan" />
      <path d="M32,32 L11.5,32 A20.5,20.5 0 0 1 32,11.5 Z" transform="translate(-0.7 -0.7)" class="pizza-art__gorgonzola" />
      <!-- gorgonzola veins, top left -->
      <circle cx="22" cy="24" r="1.6" class="pizza-art__blue" />
      <circle cx="27" cy="19" r="1.2" class="pizza-art__blue" />
      <circle cx="19" cy="29" r="1.1" class="pizza-art__blue" />
      <!-- parmesan flakes, bottom left -->
      <rect x="20" y="38" width="4" height="2" rx="0.5" transform="rotate(-30 22 39)" class="pizza-art__cheese" />
      <rect x="25" y="44" width="4" height="2" rx="0.5" transform="rotate(20 27 45)" class="pizza-art__cheese" />
    </template>

    <!-- a pizza this file does not know yet: plain cheese -->
    <template v-if="kind === 'cheese'">
      <circle cx="26" cy="27" r="2.5" class="pizza-art__topping" />
      <circle cx="39" cy="36" r="2.5" class="pizza-art__topping" />
    </template>
  </svg>
</template>
