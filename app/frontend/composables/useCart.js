import { reactive } from 'vue'
import { api as defaultApi } from '../api.js'

const QUOTE_DELAY = 250

// The cart: what the customer picked (menu ids, sizes, quantities, codes) and the
// latest quote the server gave for it. Item changes re-quote after a short pause,
// a code is checked at once and dropped again if the server does not know it, so
// the quote on screen is always one the server stands behind.
export function useCart(api = defaultApi) {
  const state = reactive({
    items: [],
    codes: [],
    quote: null,
    errors: [],
    pending: false,
    order: null,
  })

  let timer = null
  let sequence = 0

  function requestBody() {
    return { items: state.items, codes: state.codes }
  }

  async function refreshQuote() {
    clearTimeout(timer)
    const ticket = ++sequence
    if (state.items.length === 0) {
      state.quote = null
      state.errors = []
      return true
    }
    state.pending = true
    try {
      const { ok, data } = await api.quote(requestBody())
      if (ticket !== sequence) return ok
      if (ok) {
        state.quote = data
        state.errors = []
      } else {
        state.errors = data.errors
      }
      return ok
    } finally {
      if (ticket === sequence) state.pending = false
    }
  }

  function scheduleQuote() {
    clearTimeout(timer)
    timer = setTimeout(refreshQuote, QUOTE_DELAY)
  }

  function addItem(item) {
    state.items.push(item)
    scheduleQuote()
  }

  function removeItem(index) {
    state.items.splice(index, 1)
    scheduleQuote()
  }

  // One field for both kinds: the server tells promotions and discounts apart
  // and refuses what it does not know (or a second discount).
  async function addCode(code) {
    state.codes.push(code)
    if (!(await refreshQuote())) state.codes.pop()
  }

  function removeCode(index) {
    state.codes.splice(index, 1)
    return refreshQuote()
  }

  async function placeOrder(customerName) {
    const { ok, data } = await api.placeOrder({ ...requestBody(), customer_name: customerName })
    if (ok) state.order = data
    else state.errors = data.errors
    return ok
  }

  function reset() {
    clearTimeout(timer)
    Object.assign(state, { items: [], codes: [], quote: null, errors: [], pending: false, order: null })
  }

  return { state, refreshQuote, addItem, removeItem, addCode, removeCode, placeOrder, reset }
}
