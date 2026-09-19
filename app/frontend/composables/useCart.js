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
    promotionCodes: [],
    discountCode: '',
    quote: null,
    errors: [],
    pending: false,
    order: null,
  })

  let timer = null
  let sequence = 0

  function requestBody() {
    return { items: state.items, promotion_codes: state.promotionCodes, discount_code: state.discountCode }
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

  async function addPromotionCode(code) {
    state.promotionCodes.push(code)
    if (!(await refreshQuote())) state.promotionCodes.pop()
  }

  function removePromotionCode(index) {
    state.promotionCodes.splice(index, 1)
    return refreshQuote()
  }

  async function setDiscountCode(code) {
    const previous = state.discountCode
    state.discountCode = code
    if (!(await refreshQuote())) state.discountCode = previous
  }

  async function placeOrder(customerName) {
    const { ok, data } = await api.placeOrder({ ...requestBody(), customer_name: customerName })
    if (ok) state.order = data
    else state.errors = data.errors
    return ok
  }

  function reset() {
    clearTimeout(timer)
    Object.assign(state, { items: [], promotionCodes: [], discountCode: '', quote: null, errors: [], pending: false, order: null })
  }

  return { state, refreshQuote, addItem, removeItem, addPromotionCode, removePromotionCode, setDiscountCode, placeOrder, reset }
}
