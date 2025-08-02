require 'rails_helper'
require 'byebug'

RSpec.describe PostsController, type: :controller do
  let!(:user1) { create :user }
  let!(:user2) { create :user }

  let!(:post1) { create :post, author: user1 }
  let!(:post2) { create :post, author: user2, content: "User2's post" }

  before do
    sign_in user1
  end

  describe '[GET] #home' do
    context 'when user1 has no friends' do
      before do
        get :home
      end
      it 'assigns @posts' do
        expect(assigns(:posts)).to eq([post1])
      end

      it 'renders the home template' do
        expect(response).to render_template('home')
      end

      it 'returns status code ok' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user1 has a friend' do
      let!(:friendship) { create :friendship, :for_mutual, user: user1, friend: user2 }

      before do
        get :home
      end

      it 'assigns @posts' do
        expect(assigns(:posts)).to eq([post2, post1])
      end

      it 'renders the home template' do
        expect(response).to render_template('home')
      end

      it 'returns status code ok' do
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe '[GET] #index' do
    before do
      get :index
    end

    it 'assigns @posts' do
      expect(assigns(:posts)).to eq([post2, post1])
    end

    it 'renders the index template' do
      expect(response).to render_template('index')
    end

    it 'returns status code ok' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe '[GET] #show' do
    let!(:comment) { create :comment, commenter: user2, commentable: post1 }

    before do
      get :show, params: { id: post1.id }
    end

    it 'assigns @post' do
      expect(assigns(:post)).to eq(post1)
    end

    it 'assigns @comments' do
      expect(assigns(:comments)).to eq([comment])
    end

    it 'returns the show template' do
      expect(response).to render_template('show')
    end

    it 'returns status code ok' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe '[GET] #edit' do
    before do
      get :edit, params: { id: post1.id }
    end

    it 'assigns @post' do
      expect(assigns(:post)).to eq(post1)
    end

    it 'renders template edit' do
      expect(response).to render_template('edit')
    end

    it 'returns status ok' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe '[PUT] #update' do
    let(:put_request) { put :update, params: params }

    context 'with correct params' do
      let!(:params) do
        {
          id: post1.id,
          post: {
            content: "updated"
          }
        }
      end
      
      it 'changes content of the post' do
        expect {put_request}.to change { post1.reload.content }.from('content').to('updated')
      end

      it 'redirects to the post' do
        put_request
        expect(response).to redirect_to(post_path(assigns(:post)))
      end
    end

    context 'with incorrect params' do
      let!(:params) do
        {
          id: post1.id,
          post: {
            content: ''
          }
        }
      end

      it 'does not change content of the post' do
        expect { put_request }.to_not change{ post1.reload.content }
      end

      it 'renders edit partial' do
        put_request
        expect(response).to render_template('edit')
      end

      it 'returns status code unprocessable_entity' do
        put_request
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe '[DELETE] #destroy' do
    let(:delete_request) { delete :destroy, params: params }

    context 'when post exists' do
      let!(:params) { { id: post1.id } }

      it 'reduces Post count by 1' do
        expect{ delete_request }.to change(Post, :count).by(-1)
      end

      it 'redirects to root path when on post page' do
        request.env['HTTP_REFERER'] = post_path(post1)
        delete_request
        expect(response).to redirect_to(root_path) 
      end

      it 'redirects back when not on post page' do
        request.env['HTTP_REFERER'] = posts_path
        delete_request
        expect(response).to redirect_to(posts_path)
      end

      it 'renders notice' do
        delete_request
        expect(flash[:notice]).to eq("Post was successfully deleted")
      end
    end

    context 'when post does not exist' do
      let!(:params) { { id: -1 } }

      it 'redirects to root path' do
        delete_request
        expect(response).to redirect_to(root_path)
      end

      it 'renders alert' do
        delete_request
        expect(flash[:alert]).to eq("Post doesn't exist")
      end
    end
  end

  describe '[POST] #create' do  
    let(:post_request) { post :create, params: params }
    
    context 'with correct params' do  
      let!(:params) do
        {
          post: {
            content: 'content',
            author: user1
          }
        }
      end

      it 'changes Post count by 1' do
        expect { post_request }.to change(Post, :count).by(1)
      end

      it 'redirects to the post' do
        post_request
        expect(response).to redirect_to(post_path(assigns(:post)))
      end
    end

    context 'with incorrect content length' do
      let!(:params) do
        {
          post: {
            content: 'y',
            author: user1
          }
        }
      end

      it 'does not change Post count' do
        expect { post_request }.not_to change(Post, :count)
      end

      it 'renders error message' do
        post_request
        expect(flash[:alert]).to eq("Content is too short (minimum is 3 characters)")
      end
    end
  end

  describe '[POST] #like' do
    let(:post_request) { post :like, params: { id: post2.id } }
    let(:turbo_stream_post_request) { post :like, params: { id: post2.id }, format: :turbo_stream }
   
    context 'with correct params' do
      it 'changes likes count for the post' do
        expect{ post_request }.to change(post2.likes, :count).by 1
      end

      it 'renders buttons partial' do
        post_request
        expect(response).to render_template(partial: 'posts/_buttons')
      end

      it 'accepts html format' do
        post_request
        expect(response.media_type).to eq 'text/html'
        expect(response.content_type).to eq 'text/html; charset=utf-8'
      end

      it 'accepts turbo_stream format' do
        turbo_stream_post_request
        expect(response.media_type).to eq 'text/vnd.turbo-stream.html'
        expect(response.content_type).to eq 'text/vnd.turbo-stream.html; charset=utf-8'
      end
    end
  end

  describe '[DELETE] #unlike' do
    let!(:like) { create :like, :for_post, likeable: post1, user: user1 }
    let(:delete_request) { delete :unlike, params: { id: post1.id } }
    let(:turbo_stream_delete_request) { delete :unlike, params: { id: post1.id }, format: :turbo_stream }

    context 'with correct params' do
      it "changes post's like count by -1" do
        expect { delete_request }.to change(post1.likes, :count).by(-1)
      end

      it 'renders buttons partial' do
        delete_request
        expect(response).to render_template(partial: 'posts/_buttons')
      end

      it 'accepts turbo_stream format' do
        turbo_stream_delete_request
        expect(response.media_type).to eq 'text/vnd.turbo-stream.html'
        expect(response.content_type).to eq 'text/vnd.turbo-stream.html; charset=utf-8'
      end
    end
  end
end
