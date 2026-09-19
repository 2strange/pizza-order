require "rails_helper"

RSpec.describe Size do
  it "knows the three sizes" do
    expect(Size.all.map(&:label)).to eq %w[Klein Mittel Groß]
  end

  it "finds a size by key" do
    expect(Size.find(:large).multiplier).to eq BigDecimal("1.3")
    expect(Size.find("small")).to eq Size.find(:small)
  end

  it "fails loudly for an unknown key" do
    expect { Size.find(:family) }.to raise_error ArgumentError, "Unknown size: :family"
  end
end
