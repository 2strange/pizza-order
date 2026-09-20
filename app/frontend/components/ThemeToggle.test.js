import { describe, it, expect, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import ThemeToggle from './ThemeToggle.vue'

const themeOnHtml = () => document.documentElement.dataset.theme
const button = (wrapper, label) => wrapper.findAll('button').find((b) => b.text() === label)

describe('ThemeToggle', () => {
  beforeEach(() => {
    localStorage.clear()
    delete document.documentElement.dataset.theme
  })

  it('starts with the light theme', () => {
    mount(ThemeToggle)
    expect(themeOnHtml()).toBe('light')
  })

  it('switches the theme on the document', async () => {
    const wrapper = mount(ThemeToggle)
    await button(wrapper, 'Dunkel').trigger('click')
    expect(themeOnHtml()).toBe('dark')
  })

  it('turns on the easter egg when Nerd is tapped while already on', async () => {
    const wrapper = mount(ThemeToggle)
    await button(wrapper, 'Nerd').trigger('click')
    expect(themeOnHtml()).toBe('nerd')
    await button(wrapper, 'Nerd').trigger('click')
    expect(themeOnHtml()).toBe('c64')
  })

  it('leaves the easter egg through any listed theme', async () => {
    const wrapper = mount(ThemeToggle)
    await button(wrapper, 'Nerd').trigger('click')
    await button(wrapper, 'Nerd').trigger('click')
    await button(wrapper, 'Hell').trigger('click')
    expect(themeOnHtml()).toBe('light')
  })
})
