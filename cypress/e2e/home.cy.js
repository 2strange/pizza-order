describe('home page', () => {
  it('shows the app title', () => {
    cy.visit('/')
    cy.get('h1').should('contain', 'Pizza Order')
  })
})
