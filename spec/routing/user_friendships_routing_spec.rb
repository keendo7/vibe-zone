require 'rails_helper'

RSpec.describe UserFriendshipsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/users/1/friendships').to route_to('user_friendships#index', user_id: '1')
    end

    it 'routes to #mutual_friends' do
      expect(get: '/users/1/mutual_friends').to route_to('user_friendships#mutual_friends', user_id: '1')
    end
  end
end