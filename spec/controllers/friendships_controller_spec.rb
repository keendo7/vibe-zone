require 'rails_helper'

RSpec.describe FriendshipsController, type: :controller do
  let(:user1) { create :user }
  let(:friend1) { create :user }
  let(:friendship) { create :friendship, user: user1, friend: friend1 }

  describe '[DELETE] #destroy' do
    before(:each) do
      sign_in user1
    end

    let(:delete_request) { delete :destroy, params: params }

    context 'with correct params' do
      let!(:params) { { id: friendship.id } }
        
      it 'assigns @friendship' do
        delete_request
        expect(assigns(:friendship)).to eq(friendship)
      end

      it "decreases user's friendship count" do
        expect{ delete_request }.to change(user1.reload.friendships, :count).by(-1)
      end

      it 'accepts html format' do
        delete_request
        expect(response.media_type).to eq 'text/html'
        expect(response.content_type).to eq 'text/html; charset=utf-8'
      end
    end

    context 'with incorrect params' do
      let!(:params) { { id: -1 } }

      it 'redirects back with alert' do
        request.env['HTTP_REFERER'] = user_path(friend1)
        delete_request
        expect(response).to redirect_to(user_path(friend1))
        expect(flash[:alert]).to eq("Something went wrong")
      end
    end
  end

  describe '[DELETE] #decline' do
    before(:each) do
      sign_in friend1
    end

    let(:delete_request) { delete :decline, params: params }

    context 'with correct params' do
      let!(:params) { { id: friendship.id } }

      it 'assigns @friendship' do
        delete_request
        expect(assigns(:friendship)).to eq(friendship)
      end

      it "decreases user's received friendships count by 1" do
        expect{ delete_request }.to change(friend1.reload.received_friendships, :count).by(-1)
      end

      it 'redirects back' do
        request.env['HTTP_REFERER'] = user_path(user1)
        delete_request
        expect(response).to redirect_to(user_path(user1))
      end

      it 'accepts html format' do
        delete_request
        expect(response.media_type).to eq 'text/html'
        expect(response.content_type).to eq 'text/html; charset=utf-8' 
      end
    end

    context 'with incorrect params' do
      let!(:params) { { id: -1 } }

      it "doesn't change Friendship count" do
        expect { delete_request }.to_not change(Friendship, :count)
      end

      it "redirects back with alert" do
        request.env['HTTP_REFERER'] = user_path(user1)
        delete_request
        expect(response).to redirect_to(user_path(user1))
        expect(flash[:alert]).to eq 'Something went wrong'
      end

      it 'accepts html format' do
        delete_request
        expect(response.media_type).to eq 'text/html'
        expect(response.content_type).to eq 'text/html; charset=utf-8' 
      end
    end
  end

  describe '[POST] #create' do
    before(:each) do
      sign_in user1
    end

    let(:post_request) { post :create, params: params }
    context 'with correct params' do
      let!(:params) do
        {
          user_id: friend1.id
        }
      end

      it 'assigns @user' do
        post_request
        expect(assigns(:user)).to eq(friend1)
      end

      it 'assigns @friendship' do
        post_request
        expect(assigns(:friendship)).to be_a(Friendship)
        expect(assigns(:friendship).friend).to eq(friend1)
        expect(assigns(:friendship).user).to eq(user1)
      end

      it "increases user's friendship count" do
        expect{ post_request }.to change(user1.reload.friendships, :count).by(1)
      end

      it 'redirects back' do
        request.env['HTTP_REFERER'] = user_path(friend1)
        post_request
        expect(response).to redirect_to(user_path(friend1))
      end

      it 'accepts html format' do
        post_request
        expect(response.media_type).to eq 'text/html'
        expect(response.content_type).to eq 'text/html; charset=utf-8'
      end
    end

    context 'with incorrect params' do
      let!(:params) do
        {
          user_id: -1
        }
      end
      
      it 'redirects back with alert' do
        request.env['HTTP_REFERER'] = user_path(friend1)
        post_request
        expect(response).to redirect_to(user_path(friend1))
        expect(flash[:alert]).to eq("Something went wrong")
      end

      it "doesn't change user's friendship count" do
        expect{ post_request }.not_to change(user1.reload.friendships, :count)
      end
    end
  end
end
