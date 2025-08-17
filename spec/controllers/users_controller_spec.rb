require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let!(:user1) { create :user, first_name: "Bob" }
  let!(:user2) { create :user }
  let!(:user3) { create :user }

  let!(:friendship1) { create :friendship, :for_mutual, user: user1, friend: user3 }
  let!(:friendship2) { create :friendship, :for_mutual, user: user2, friend: user3 }

  let!(:user1_post) { create :post, author: user1 }
  let!(:user2_post) { create :post, author: user2 }
  let!(:user3_post) { create :post, author: user3 }

  let!(:avatar_asset) { fixture_file_upload('/avatar1.png', 'image/png') }
  let!(:banner_asset) { fixture_file_upload('/banner1.png', 'image/png') }
  
  before do
    sign_in user1
  end

  describe "[GET] #show" do
    context 'when user is current_user' do
      before(:each) do
        get :show, params: { id: user1.id } 
      end

      it 'assigns @user' do
        expect(assigns(:user)).to eq(user1)
      end

      it 'assigns @posts' do
        expect(assigns(:posts)).to eq([user1_post])
      end

      it 'renders the show template' do
        expect(response).to render_template('show')
      end

      it 'accepts html format' do
        expect(response.media_type).to eq 'text/html'
        expect(response.content_type).to eq 'text/html; charset=utf-8'
      end

      it 'returns status code ok' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user is a friend' do
      it 'assigns @user' do
        get :show, params: { id: user3.id }
        expect(assigns(:user)).to eq(user3)
      end

      it 'assigns @posts' do
        get :show, params: { id: user3.id }
        expect(assigns(:posts)).to eq([user3_post])
      end

      it 'assigns @friendship and @status' do
        get :show, params: { id: user3.id }
        expect(assigns(:friendship)).to eq(friendship1)
        expect(assigns(:status)).to eq(:friend)
      end

      it 'assigns @mutual_friendship_count to 0 when no mutual friends' do
        get :show, params: { id: user3.id }
        expect(assigns(:mutual_friends_count)).to eq(0)
      end

      it 'assigns @mutual_friends_count to 1 when sharing a mutual friend' do
        create :friendship, :for_mutual, user: user1, friend: user2
        get :show, params: { id: user3.id }
        expect(assigns(:mutual_friends_count)).to eq(1)
      end

      it 'renders the show template' do
        get :show, params: { id: user3.id }
        expect(response).to render_template('show')
      end

      it 'accepts html format' do
        get :show, params: { id: user3.id }
        expect(response.media_type).to eq 'text/html'
        expect(response.content_type).to eq 'text/html; charset=utf-8'
      end

      it 'returns status code ok' do
        get :show, params: { id: user3.id }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user is not a friend' do
      it 'assigns @user' do
        get :show, params: { id: user2.id }
        expect(assigns(:user)).to eq(user2)
      end

      it 'assigns @posts' do
        get :show, params: { id: user2.id }
        expect(assigns(:posts)).to eq([user2_post])
      end

      it 'assigns @friendship to nil and @status to :no_friendship' do
        get :show, params: { id: user2.id }
        expect(assigns(:friendship)).to eq(nil)
        expect(assigns(:status)).to eq(:no_friendship)
      end

      it 'assigns @friendship and @status to :request when received friendship request' do
        friendship = create :friendship, user: user2, friend: user1
        get :show, params: { id: user2.id }
        expect(assigns(:friendship)).to eq(friendship)
        expect(assigns(:status)).to eq(:request)
      end

      it 'renders the show template' do
        get :show, params: { id: user2.id }
        expect(response).to render_template('show')
      end

      it 'accepts html format' do
        get :show, params: { id: user2.id }
        expect(response.media_type).to eq 'text/html'
        expect(response.content_type).to eq 'text/html; charset=utf-8'
      end

      it 'returns status code ok' do
        get :show, params: { id: user2.id }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "[GET] #edit" do
    before do
      get :edit, params: { id: user1.id }
    end

    it 'assigns @user' do
      expect(assigns(:user)).to eq(user1)
    end

    it 'renders template edit' do
      expect(response).to render_template('edit')
    end

    it 'accepts html format' do
      expect(response.media_type).to eq 'text/html'
      expect(response.content_type).to eq 'text/html; charset=utf-8'
    end

    it 'returns status ok' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe "[DELETE] #destroy" do
    let(:delete_request) { delete :destroy, params: {id: user1.id } }

    it 'decreases user count by 1' do
      expect{delete_request}.to change(User, :count).by -1
    end

    it 'redirects to new_user_session_path' do
      delete_request
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'returns status :see_other' do
      delete_request
      expect(response).to have_http_status(:see_other)
    end
  end

  describe "[GET] #search" do
    let(:get_request) { get :search, params: params }

    context 'with matching query' do
      let!(:params) { { query: 'Bob' } }

      before do
        get_request
      end

      it 'assigns @users' do
        expect(assigns(:users)).to eq([user1])
      end

      it 'accepts html format' do
        expect(response.media_type).to eq('text/html')
        expect(response.content_type).to eq('text/html; charset=utf-8')
      end

      it 'returns status code ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'renders the search template' do
        expect(response).to render_template('search')
      end
    end

    context 'with empty query' do
      let!(:params) { { query: ''} }

      before do
        get_request
      end

      it 'assigns @users' do
        expect(assigns(:users)).to eq([user3, user2, user1])
      end

      it 'renders the search template' do
        expect(response).to render_template('search')
      end

      it 'accepts html format' do
        expect(response.media_type).to eq('text/html')
        expect(response.content_type).to eq('text/html; charset=utf-8')
      end

      it 'returns status code ok' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with query not matching' do
      let!(:params) { { query: 'wojtyła' } }

      before do
        get_request
      end

      it 'assigns @users' do
        expect(assigns(:users)).to eq([])
      end

      it 'renders the search template' do
        expect(response).to render_template('search')
      end

      it 'accepts html format' do
        expect(response.media_type).to eq('text/html') 
        expect(response.content_type).to eq('text/html; charset=utf-8')
      end

      it 'returns status code ok' do
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "[PUT] #update" do
    let(:put_request) { put :update, params: params }

    context 'with correct params' do
      let!(:params) { 
        { 
          id: user1.id,
          user: {
            last_name: "bogdanowicz"
          }
        } 
      }

      it 'assigns @user' do
        put_request
        expect(assigns(:user)).to eq(user1)
      end

      it "changes user's params" do
        expect{ put_request }.to change{ user1.reload.last_name }.from('Lastname').to('Bogdanowicz')
      end

      it 'redirects to @user' do
        put_request
        expect(response).to redirect_to(user1.reload)
      end
 
      it 'accepts html format' do
        put_request
        expect(response.media_type).to eq("text/html") 
        expect(response.content_type).to eq("text/html; charset=utf-8")
      end
    end
    
    context 'with incorrect params' do
      let!(:params) do
        {
          id: user1.id,
          user: {
            last_name: ''
          }
        }
      end

      it 'assigns @user' do
        put_request
        expect(assigns(:user)).to eq(user1)
      end

      it 'does not change user params' do
        expect{put_request}.to_not change{user1.reload.last_name}
      end

      it 'renders alert' do
        put_request
        expect(flash[:alert]).to be_present
      end

      it 'renders edit template' do
        put_request
        expect(response).to render_template('edit')
      end

      it 'returns status unprocessable entity' do
        put_request
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'accepts html format' do
        put_request
        expect(response.media_type).to eq("text/html")
        expect(response.content_type).to eq("text/html; charset=utf-8")
      end
    end
  end

  describe "[PATCH] #update_avatar" do
    let(:patch_request) { patch :update_avatar, params: params, format: :turbo_stream }

    context 'with correct params' do
      let!(:params) do
        {
          avatar: avatar_asset
        }
      end

      it 'updates avatar' do
        expect{patch_request}.to change{user1.reload.avatar.attached?}.from(false).to(true)
        expect(user1.avatar.filename.to_s).to eq("avatar1.png")
      end

      it 'renders avatar_container template' do
        patch_request
        expect(response).to render_template(partial: "users/_avatar_container")
      end

      it 'renders flash message' do
        patch_request
        expect(flash.now[:success]).to eq I18n.t('messages.user.avatar_updated')
      end

      it 'uses turbo_stream replace action and accepts turbo_stream format' do
        patch_request
        expect_turbo_stream_response_with_replace_action
      end

      it 'accepts html format and redirects back' do
        request.env['HTTP_REFERER'] = user_path(user1)
        patch :update_avatar, params: params

        expect_html_response_with_redirect_to(user1)
      end
      
      it 'returns status code ok' do
        patch_request
        
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "[DELETE] #remove_avatar" do
    let(:delete_request) { delete :remove_avatar, format: :turbo_stream }
    
    context 'with attached avatar' do
      before do
        user1.avatar.attach(avatar_asset)
      end
  
      it 'removes avatar' do
        expect{delete_request}.to change{user1.reload.avatar.attached?}.from(true).to(false)
      end
  
      it 'renders avatar_container partial' do
        delete_request
        expect(response).to render_template(partial: 'users/_avatar_container')
      end
  
      it 'uses turbo_stream replace action and accepts turbo_stream format' do
        delete_request
        expect_turbo_stream_response_with_replace_action
      end

      it 'renders flash message' do
        delete_request
        expect(flash.now[:success]).to eq I18n.t('messages.user.avatar_removed')
      end
  
      it 'returns status code ok' do
        delete_request
        expect(response).to have_http_status(:ok)
      end
  
      it 'accepts html format and redirects back' do
        request.env['HTTP_REFERER'] = user_path(user1)
        delete :remove_avatar

        expect_html_response_with_redirect_to(user1)
      end
    end
  end

  describe "[PATCH] #update_banner" do
    let(:patch_request) { patch :update_banner, params: params, format: :turbo_stream }

    context 'with correct params' do
      let!(:params) do
        {
          banner: banner_asset
        }
      end

      it 'attaches banner' do
        expect{patch_request}.to change{user1.reload.banner.attached?}.from(false).to(true)
        expect(user1.banner.filename.to_s).to eq("banner1.png")
      end

      it 'renders banner partial' do
        patch_request
        expect(response).to render_template(partial: "users/_banner")
      end

      it 'returns status code ok' do
        patch_request
        expect(response).to have_http_status(:ok)
      end

      it 'uses turbo_stream replace action and accepts turbo_stream format' do
        patch_request
        expect_turbo_stream_response_with_replace_action
      end

      it 'renders flash message' do
        patch_request
        expect(flash.now[:success]).to eq I18n.t('messages.user.banner_updated')
      end

      it 'accepts html format and redirects back' do
        request.env['HTTP_REFERER'] = user_path(user1)
        patch :update_banner, params: params

        expect_html_response_with_redirect_to(user1)
      end
    end
  end

  describe "[DELETE] #remove_banner" do
    let(:delete_request) { delete :remove_banner, format: :turbo_stream }

    context 'with banner attached' do
      before do
        user1.banner.attach(banner_asset)
      end

      it 'removes banner' do
        expect{delete_request}.to change{user1.reload.banner.attached?}.from(true).to(false)
      end

      it 'renders banner partial' do
        delete_request
        expect(response).to render_template(partial: 'users/_banner')
      end

      it 'renders flash message' do
        delete_request
        expect(flash.now[:success]).to eq I18n.t('messages.user.banner_removed')
      end

      it 'uses turbo_stream replace action and accepts turbo_stream format' do
        delete_request
        expect_turbo_stream_response_with_replace_action
      end

      it 'accepts html format and redirects back' do
        request.env['HTTP_REFERER'] = user_path(user1)
        patch :remove_banner

        expect_html_response_with_redirect_to(user1)
      end
    end
  end

  def expect_turbo_stream_response_with_replace_action
    expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    expect(response.content_type).to eq("text/vnd.turbo-stream.html; charset=utf-8")
    expect(response.body).to include('<turbo-stream action="replace"')
  end

  def expect_html_response_with_redirect_to(path)
    expect(response.media_type).to eq("text/html")
    expect(response.content_type).to eq("text/html; charset=utf-8")
    expect(response).to redirect_to(path)
  end
end
