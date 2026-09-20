import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { useCart } from './useCart.js'

const salami = { pizza_id: 2, size: 'small', quantity: 2, extra_ids: [], removed_ingredient_ids: [] }
const quoted = { items: [], adjustments: [], subtotal_cents: 840, total_cents: 840 }

function fakeApi() {
  return { quote: vi.fn().mockResolvedValue({ ok: true, data: quoted }), placeOrder: vi.fn() }
}

describe('useCart', () => {
  beforeEach(() => vi.useFakeTimers())
  afterEach(() => vi.useRealTimers())

  it('sends items and codes exactly as the server expects them', async () => {
    const api = fakeApi()
    const cart = useCart(api)

    cart.addItem(salami)
    await vi.runAllTimersAsync()
    await cart.addCode('ZWEIKLEINESALAMIFUEREINS')
    await cart.addCode('5PROZENTAUFALLES')

    expect(api.quote).toHaveBeenLastCalledWith({
      items: [salami],
      codes: ['ZWEIKLEINESALAMIFUEREINS', '5PROZENTAUFALLES'],
    })
    expect(cart.state.quote).toEqual(quoted)
    expect(cart.state.errors).toEqual([])
  })

  it('quotes item changes once, after a pause', async () => {
    const api = fakeApi()
    const cart = useCart(api)

    cart.addItem(salami)
    cart.addItem(salami)
    cart.removeItem(0)
    expect(api.quote).not.toHaveBeenCalled()

    await vi.runAllTimersAsync()
    expect(api.quote).toHaveBeenCalledTimes(1)
    expect(api.quote.mock.calls[0][0].items).toEqual([salami])
  })

  it('does not ask the server to price an empty cart', async () => {
    const api = fakeApi()
    const cart = useCart(api)

    cart.addItem(salami)
    cart.removeItem(0)
    await vi.runAllTimersAsync()

    expect(api.quote).not.toHaveBeenCalled()
    expect(cart.state.quote).toBeNull()
  })

  it('drops a code the server refuses and keeps the message', async () => {
    const api = fakeApi()
    api.quote.mockResolvedValueOnce({ ok: false, data: { errors: ['Unknown code: NOPE'] } })
    const cart = useCart(api)
    cart.state.items.push(salami)

    await cart.addCode('NOPE')

    expect(cart.state.codes).toEqual([])
    expect(cart.state.errors).toEqual(['Unknown code: NOPE'])
  })

  it('places the order with the customer name and keeps the answer', async () => {
    const api = fakeApi()
    const placed = { id: 1, number: '#0001', customer_name: 'Mia', quote: quoted }
    api.placeOrder.mockResolvedValue({ ok: true, data: placed })
    const cart = useCart(api)
    cart.state.items.push(salami)

    expect(await cart.placeOrder('Mia')).toBe(true)

    expect(api.placeOrder).toHaveBeenCalledWith({ items: [salami], codes: [], customer_name: 'Mia' })
    expect(cart.state.order).toEqual(placed)
  })
})
