require 'rails_helper'

RSpec.describe 'Home', type: :request do
  describe 'GET /index' do
    it '200 が返ってくること' do
      get '/'
      expect(response).to have_http_status(:ok)
    end
  end
end
