import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import PizzaConfigurator from './PizzaConfigurator.vue'

const pizza = { id: 2, name: 'Salami', base_price_cents: 600,
  ingredients: [{ id: 4, name: 'Tomatensauce' }, { id: 2, name: 'Käse' }, { id: 5, name: 'Salami' }] }
const sizes = [{ key: 'small', label: 'Klein', multiplier: '0.7' }, { key: 'medium', label: 'Mittel', multiplier: '1.0' }, { key: 'large', label: 'Groß', multiplier: '1.3' }]
const extras = [{ id: 1, name: 'Zwiebeln', extra_price_cents: 100 }, { id: 2, name: 'Käse', extra_price_cents: 200 }, { id: 3, name: 'Oliven', extra_price_cents: 250 }]

const check = (wrapper, legend, label) =>
  wrapper.findAll('fieldset').find((group) => group.find('legend').text() === legend)
    .findAll('label').find((choice) => choice.text().includes(label))
    .find('input').setValue(true)

describe('PizzaConfigurator', () => {
  it('starts with a medium pizza, nothing added, nothing left out', async () => {
    const wrapper = mount(PizzaConfigurator, { props: { pizza, sizes, extras } })
    await wrapper.find('form').trigger('submit')

    expect(wrapper.emitted('add')).toEqual([[{ pizza_id: 2, size: 'medium', quantity: 1, extra_ids: [], removed_ingredient_ids: [] }]])
  })

  it('emits the item as the server wants it: ids, size key, quantity — no prices', async () => {
    const wrapper = mount(PizzaConfigurator, { props: { pizza, sizes, extras } })

    await check(wrapper, 'Größe', 'Klein')
    await check(wrapper, 'Extras', 'Zwiebeln')
    await check(wrapper, 'Extras', 'Oliven')
    await check(wrapper, 'Weglassen', 'Käse')
    await wrapper.find('input[type="number"]').setValue(2)
    await wrapper.find('form').trigger('submit')

    expect(wrapper.emitted('add')).toEqual([[{ pizza_id: 2, size: 'small', quantity: 2, extra_ids: [1, 3], removed_ingredient_ids: [2] }]])
  })

  it('shows the prices the menu names, nothing computed', () => {
    const wrapper = mount(PizzaConfigurator, { props: { pizza, sizes, extras } })
    const notes = wrapper.findAll('.choice__note').map((note) => note.text().replace(/\s/g, ' '))

    expect(notes).toEqual(['×0,7', '×1,0', '×1,3', '+ 1,00 €', '+ 2,00 €', '+ 2,50 €'])
  })
})
