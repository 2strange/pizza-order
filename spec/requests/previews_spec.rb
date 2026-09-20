require "rails_helper"

RSpec.describe "Link previews", type: :request do
  it "describes the page for messengers with absolute image and page urls" do
    get root_path

    expect(response.body).to include('<html lang="de">')
    expect(response.body).to include('<meta property="og:title" content="Pizza Order">')
    expect(response.body).to include(%(<meta property="og:image" content="http://www.example.com/og.png">))
    expect(response.body).to include('<meta name="twitter:card" content="summary_large_image">')
  end
end
