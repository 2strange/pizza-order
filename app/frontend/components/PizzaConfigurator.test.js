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

  it('shows every price for the chosen size, the way the server charges it', async () => {
    const wrapper = mount(PizzaConfigurator, { props: { pizza, sizes, extras } })
    const notes = () => wrapper.findAll('.choice__note').map((note) => note.text().replace(/\s/g, ' '))

    // medium is preselected: extras at menu price
    expect(notes()).toEqual(['4,20 € · ×0,7', '6,00 € · ×1,0', '7,80 € · ×1,3', '+ 1,00 €', '+ 2,00 €', '+ 2,50 €'])

    await wrapper.find('input[value="small"]').setValue()
    // small: extras scale with the size too, rounded half up like Size#scale
    expect(notes().slice(3)).toEqual(['+ 0,70 €', '+ 1,40 €', '+ 1,75 €'])
  })

  it('limits the quantity to what the server accepts', () => {
    const wrapper = mount(PizzaConfigurator, { props: { pizza, sizes, extras, maxQuantity: 50 } })
    expect(wrapper.find('input[type="number"]').attributes('max')).toBe('50')
  })
})
