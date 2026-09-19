// Cents from the server → "16,29 €". Formatting only: the division happens
// after every price has been decided.
const euro = new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR' })

export const formatCents = (cents) => euro.format(cents / 100)
