// The happy path end to end: two small Salami with the two-for-one promotion
// and the 5 % discount → 2 × 4,20 − 4,20 = 4,20, minus 5 % = 3,99.
describe('ordering', () => {
  it('configures, redeems codes, checks the receipt and places the order', () => {
    cy.visit('/')
    cy.get('h1').should('contain', 'Pizza Order')

    cy.contains('.pizza', 'Salami').click()
    cy.get('.configurator').within(() => {
      cy.contains('label', 'Klein').click()
      cy.get('input[type="number"]').clear().type('2')
      cy.contains('button', 'In den Warenkorb').click()
    })

    cy.get('.breakdown__line').should('have.length', 1).and('contain', 'Salami · Klein · 2×')
    cy.contains('.breakdown__sum--total', /8,40\s€/)

    cy.contains('.code', 'Aktionscode').within(() => {
      cy.get('input').type('ZWEIKLEINESALAMIFUEREINS')
      cy.contains('button', 'Einlösen').click()
    })
    cy.contains('.breakdown__sum--adjustment', 'ZWEIKLEINESALAMIFUEREINS').contains(/-4,20\s€/)

    cy.contains('.code', 'Rabattcode').within(() => {
      cy.get('input').type('GIBTSNICHT')
      cy.contains('button', 'Einlösen').click()
      cy.get('.code__error').should('contain', 'GIBTSNICHT')
      cy.get('input').type('5PROZENTAUFALLES')
      cy.contains('button', 'Einlösen').click()
      cy.get('.chip').should('contain', '5PROZENTAUFALLES')
    })
    cy.contains('.breakdown__sum--adjustment', '5PROZENTAUFALLES').contains(/-0,21\s€/)
    cy.contains('.breakdown__sum--total', /3,99\s€/)

    cy.get('.cart__name input').type('Mia')
    cy.contains('button', 'Bestellen').click()

    cy.get('.confirmation').should('contain', 'Danke, Mia')
    cy.get('.confirmation__number').invoke('text').should('match', /^#\d{4,}$/)
    cy.get('.confirmation .breakdown__sum--total').contains(/3,99\s€/)
  })
})
