require "rails_helper"

RSpec.describe "Seeds" do
  it "load the menu and are idempotent" do
    expect { Rails.application.load_seed }.to change(Pizza, :count).from(0).to(6)
      .and change(Promotion, :count).to(1)
      .and change(DiscountCode, :count).to(1)

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
