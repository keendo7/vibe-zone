require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do
  let(:user1) { create :user }
  
  before do
    sign_in user1
  end

  describe '[GET] #index' do
    let!(:user2) { create :user }
    let!(:friendship) { create(:friendship, user: user2, friend: user1) }
    let!(:notification) { create(:notification, :for_friendship, sender: user2, user: user1, notifiable: friendship) }

    let(:get_request) { get :index }

    it 'assigns @notifications' do
      get_request
      expect(assigns(:notifications)).to eq([notification])
    end

    it 'changes notification was_read status from false to true' do
      expect{get_request}.to change{notification.reload.was_read}.from(false).to(true)
    end

    it 'renders index template' do
      get_request
      expect(response).to render_template('index')
    end

    it 'accepts html format' do
      get_request
      expect(response.media_type).to eq('text/html')
      expect(response.content_type).to eq('text/html; charset=utf-8')
    end

    it 'returns code status ok' do
      get_request
      expect(response).to have_http_status(:ok)
    end
  end
end
