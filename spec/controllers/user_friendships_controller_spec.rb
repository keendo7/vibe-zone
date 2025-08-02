require 'rails_helper'

RSpec.describe UserFriendshipsController, type: :controller do
  let!(:user1) { create :user }
  let!(:user2) { create :user }
  let!(:user3) { create :user }
  let!(:friendship) { create(:friendship, :for_mutual, user: user1, friend: user2) }

  before do
    sign_in user1
  end

  describe '[GET] #index' do
    context 'without search params' do

      before do
        get :index, params: { user_id: user1.friendly_id }
      end

      it 'assigns @friendships' do
        expect(assigns(:friendships)).to eq([friendship])
      end
  
      it 'renders the index template' do
        expect(response).to render_template('index')
      end
  
      it 'returns status code ok' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with matching search params' do
      before do
        get :index, params: { user_id: user1.friendly_id, query: 'lastname' }
      end

      it 'assigns @friendships' do
        expect(assigns(:friendships)).to eq([friendship])
      end

      it 'renders the index template' do
        expect(response).to render_template('index')
      end
  
      it 'returns status code ok' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with mismatching search params' do
      before do
        get :index, params: { user_id: user1.friendly_id, query: 'wojtyła' }
      end

      it 'assigns @friendships' do
        expect(assigns(:friendships)).to eq([])
      end

      it 'renders the index template' do
        expect(response).to render_template('index')
      end

      it 'returns status code ok' do
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe '[GET] #mutual_friends' do
    let!(:friendship2) { create(:friendship, :for_mutual, user: user3, friend: user2) }

    context 'without search params' do
      before do
        get :mutual_friends, params: { user_id: user3.friendly_id }
      end

      it 'assigns @mutuals' do
        expect(assigns(:mutuals)).to eq([friendship])
      end
      
      it 'renders the mutual_friends template' do
        expect(response).to render_template('mutual_friends')
      end
  
      it 'returns status code ok' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with matching search params' do
      before do
        get :mutual_friends, params: { user_id: user1.friendly_id, query: 'lastname' }
      end

      it 'assigns @mutuals' do
        expect(assigns(:mutuals)).to eq([friendship])
      end

      it 'renders the index template' do
        expect(response).to render_template('mutual_friends')
      end
  
      it 'returns status code ok' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with mismatching search params' do
      before do
        get :mutual_friends, params: { user_id: user1.friendly_id, query: 'wojtyła' }
      end

      it 'assigns @mutuals' do
        expect(assigns(:mutuals)).to eq([])
      end

      it 'renders the index template' do
        expect(response).to render_template('mutual_friends')
      end
  
      it 'returns status code ok' do
        expect(response).to have_http_status(:ok)
      end
    end
  end
end

