require 'rails_helper'

RSpec.describe FriendshipsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: 'users/1/friendships', user_id: '1').to route_to('friendships#index', user_id: '1')
    end

    it 'routes to #create' do
      expect(post: 'users/1/friendships', user_id: '1').to route_to('friendships#create', user_id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: 'friendships/1', id: '1').to route_to('friendships#destroy', id: '1')
    end

    it 'routes to #mutual_friends' do
      expect(get: 'users/1/friendships/mutual_friends', user_id: '1').to route_to('friendships#mutual_friends', user_id: '1')
    end
  end
end