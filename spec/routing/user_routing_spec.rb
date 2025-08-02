require 'rails_helper'

RSpec.describe UsersController, type: :routing do
  describe 'routing' do
    it 'routes to #show' do
      expect(get: '/users/1').to route_to('users#show', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/users/1').to route_to('users#destroy', id: '1')
    end

    it 'routes to #update' do
      expect(put: '/users/1').to route_to('users#update', id: '1')
    end

    it 'routes to #update_avatar' do
      expect(patch: '/update_avatar').to route_to('users#update_avatar')
    end

    it 'routes to #update_banner' do
      expect(patch: '/update_banner').to route_to('users#update_banner')
    end

    it 'routes to #remove_banner' do
      expect(delete: '/remove_banner').to route_to('users#remove_banner')
    end
  end
end