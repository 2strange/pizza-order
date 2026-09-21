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

    // one field for both kinds — the server sorts them and says so on the chip
    cy.get('.code').within(() => {
      cy.get('input').type('ZWEIKLEINESALAMIFUEREINS')
      cy.contains('button', 'Einlösen').click()
      cy.contains('.chip', 'ZWEIKLEINESALAMIFUEREINS').should('contain', 'Aktion')
    })
    cy.contains('.breakdown__sum--adjustment', '2 kleine Salami für 1').contains(/-4,20\s€/)

    cy.get('.code').within(() => {
      cy.get('input').type('GIBTSNICHT')
      cy.contains('button', 'Einlösen').click()
      cy.get('.code__error').should('contain', 'GIBTSNICHT')
      cy.get('input').type('5PROZENTAUFALLES')
      cy.contains('button', 'Einlösen').click()
      cy.contains('.chip', '5PROZENTAUFALLES').should('contain', 'Rabatt')
    })
    cy.contains('.breakdown__sum--adjustment', '5 % auf alles').contains(/-0,21\s€/)
    cy.contains('.breakdown__sum--total', /3,99\s€/)

    cy.get('.cart__name input').type('Mia')
    cy.contains('button', 'Bestellen').click()

    cy.get('.confirmation').should('contain', 'Danke, Mia')
    cy.get('.confirmation__number').invoke('text').should('match', /^#\d{4,}$/)
    cy.get('.confirmation .breakdown__sum--total').contains(/3,99\s€/)
  })

  // Taking things back out: a line and a code leave the cart, the total follows.
  it('lets the customer remove a pizza and a code again', () => {
    cy.visit('/')

    cy.contains('.pizza', 'Salami').click()
    cy.get('.configurator').within(() => {
      cy.contains('label', 'Klein').click()
      cy.get('input[type="number"]').clear().type('2')
      cy.contains('button', 'In den Warenkorb').click()
    })
    cy.contains('.pizza', 'Margherita').click()
    cy.get('.configurator').within(() => cy.contains('button', 'In den Warenkorb').click())
    cy.get('.breakdown__line').should('have.length', 2)
    cy.contains('.breakdown__sum--total', /13,40\s€/) // 8,40 + 5,00

    cy.contains('.breakdown__line', 'Margherita').find('.breakdown__remove').click()
    cy.get('.breakdown__line').should('have.length', 1)
    cy.contains('.breakdown__sum--total', /8,40\s€/)

    // typed in lower case: the chip and the receipt show the code as the server knows it
    cy.get('.code').within(() => {
      cy.get('input').type('zweikleinesalamifuereins')
      cy.contains('button', 'Einlösen').click()
      cy.contains('.chip', 'ZWEIKLEINESALAMIFUEREINS').should('contain', 'Aktion')
    })
    cy.contains('.breakdown__sum--total', /4,20\s€/)

    cy.get('.chip__remove').click()
    cy.get('.chip').should('not.exist')
    cy.get('.breakdown__sum--adjustment').should('not.exist')
    cy.contains('.breakdown__sum--total', /8,40\s€/)
  })
})
