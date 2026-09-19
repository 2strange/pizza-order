import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import PriceBreakdown from './PriceBreakdown.vue'

// The golden order as the server quotes it.
const quote = {
  items: [
    { pizza: 'Salami', size: 'Mittel', quantity: 1, extras: ['Zwiebeln'], removed: ['Käse'],
      base_price_cents: 600, extras_price_cents: 100, unit_price_cents: 700, line_price_cents: 700 },
    { pizza: 'Salami', size: 'Klein', quantity: 3, extras: [], removed: [],
      base_price_cents: 420, extras_price_cents: 0, unit_price_cents: 420, line_price_cents: 1260 },
  ],
  adjustments: [
    { label: 'ZWEIKLEINESALAMIFUEREINS', amount_cents: -840 },
    { label: '5PROZENTAUFALLES', amount_cents: -86 },
  ],
  subtotal_cents: 2555,
  total_cents: 1629,
}

const text = (wrapper, selector) => wrapper.findAll(selector).map((node) => node.text().replace(/\s+/g, ' '))
const sums = (wrapper, selector) => wrapper.findAll(selector).map((row) => [row.find('dt').text(), row.find('dd').text().replace(/\s/g, ' ')])

describe('PriceBreakdown', () => {
  it('shows every line with its parts', () => {
    const wrapper = mount(PriceBreakdown, { props: { quote } })

    expect(text(wrapper, '.breakdown__title')).toEqual(['Salami · Mittel · 1×', 'Salami · Klein · 3×'])
    expect(text(wrapper, '.breakdown__amount')).toEqual(['7,00 €', '12,60 €'])
    expect(text(wrapper, '.breakdown__detail')[0]).toBe('6,00 € + 1,00 € (Zwiebeln) = 7,00 € je Pizza')
    expect(text(wrapper, '.breakdown__detail')[1]).toBe('4,20 € = 4,20 € je Pizza')
    expect(text(wrapper, '.breakdown__removed')).toEqual(['ohne Käse'])
  })

  it('shows every adjustment, the subtotal and the total', () => {
    const wrapper = mount(PriceBreakdown, { props: { quote } })

    expect(sums(wrapper, '.breakdown__sum--adjustment')).toEqual([['ZWEIKLEINESALAMIFUEREINS', '-8,40 €'], ['5PROZENTAUFALLES', '-0,86 €']])
    expect(sums(wrapper, '.breakdown__sum')[0]).toEqual(['Zwischensumme', '25,55 €'])
    expect(sums(wrapper, '.breakdown__sum--total')).toEqual([['Gesamt', '16,29 €']])
  })

  it('offers to remove a line only when asked to', async () => {
    expect(mount(PriceBreakdown, { props: { quote } }).find('.breakdown__remove').exists()).toBe(false)

    const wrapper = mount(PriceBreakdown, { props: { quote, removable: true } })
    await wrapper.findAll('.breakdown__remove')[1].trigger('click')

    expect(wrapper.emitted('remove')).toEqual([[1]])
  })
})
