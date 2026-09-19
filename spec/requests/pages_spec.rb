require "rails_helper"

RSpec.describe "Pages", type: :request do
  describe "GET /" do
    it "renders the app shell" do
      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('id="app"')
    end
  end
end
