require 'rails_helper'

RSpec.describe FriendshipsController, type: :routing do
  describe 'routing' do
    it 'routes to #create' do
      expect(post: 'friendships').to route_to('friendships#create')
    end

    it 'routes to #destroy' do
      expect(delete: 'friendships/1').to route_to('friendships#destroy', id: '1')
    end

    it 'routes to #decline' do
      expect(delete: 'friendships/1/decline').to route_to('friendships#decline', id: '1')
    end
  end
end