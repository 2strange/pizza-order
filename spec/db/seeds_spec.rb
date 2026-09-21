require "rails_helper"

RSpec.describe "Seeds" do
  # The database may already carry the menu (db:prepare seeds a fresh one, and
  # CI starts fresh), so what counts is the state after loading, not the change.
  it "load the menu and are idempotent" do
    Rails.application.load_seed

    expect(Pizza.pluck(:name)).to contain_exactly("Margherita", "Salami", "Funghi", "Prosciutto", "Tonno", "Quattro Formaggi")
    expect(Ingredient.extras.pluck(:name)).to contain_exactly("Zwiebeln", "Käse", "Oliven")
    expect(Promotion.pluck(:code)).to eq [ "ZWEIKLEINESALAMIFUEREINS" ]
    expect(DiscountCode.pluck(:code)).to eq [ "5PROZENTAUFALLES" ]

    expect { Rails.application.load_seed }.not_to change { [ Pizza.count, Ingredient.count, Promotion.count, DiscountCode.count ] }
  end

  it "update prices in place on a second run" do
    Rails.application.load_seed
    Pizza.find_by!(name: "Salami").update!(base_price_cents: 900)

    expect { Rails.application.load_seed }.to change { Pizza.find_by!(name: "Salami").base_price_cents }.from(900).to(600)
  end

  it "refuse to run when the sizes in menu.json drift from Size::ALL" do
    allow(Size).to receive(:all).and_return([ Size.new(:small, "Klein", "0.5"), Size.new(:medium, "Mittel", "1.0"), Size.new(:large, "Groß", "1.3") ])

    expect { Rails.application.load_seed }.to raise_error(/Size Klein \(0.7\) in menu.json does not match Size::ALL/)
  end
end
