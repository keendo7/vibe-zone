require 'rails_helper'

RSpec.describe PostsController, type: :routing do
  describe 'routing' do
    it 'routes to #show' do
      expect(get: 'posts/1').to route_to('posts#show', id: '1')
    end

    it 'routes to #index' do
      expect(get: 'posts').to route_to('posts#index')
    end

    it 'routes to #home' do
      expect(get: 'home').to route_to('posts#home')
    end

    it 'routes to #create' do
      expect(post: 'posts').to route_to('posts#create')
    end

    it 'routes to #destroy' do
      expect(delete: 'posts/1', id: '1').to route_to('posts#destroy', id: '1')
    end

    it 'routes to #edit' do
      expect(get: 'posts/1/edit', id: '1').to route_to('posts#edit', id: '1')
    end

    it 'routes to #update' do
      expect(put: 'posts/1', id: '1').to route_to('posts#update', id: '1')
    end

    it 'routes to #new' do
      expect(get: 'posts/new').to route_to('posts#new')
    end

    it 'routes to #like' do
      expect(post: 'posts/1/like', id: '1').to route_to('posts#like', id: '1')
    end

    it 'routes to #unlike' do
      expect(delete: 'posts/1/unlike', id: '1').to route_to('posts#unlike', id: '1')
    end
  end
end