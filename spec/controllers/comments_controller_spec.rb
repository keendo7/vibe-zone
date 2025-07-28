require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let!(:user1) { create :user }
  let!(:post1) { create :post }
  let!(:comment) { create :comment, commenter: user1, commentable: post1 }

  before do
    sign_in user1
  end

  describe '[POST] #create' do
    let(:post_request) { post :create, params: params }

    context 'with correct params' do
      let!(:params) do
        {
          comment: {
            content: 'content',
            commenter: user1,
            commentable_id: post1.id,
            commentable_type: post1.class.name
          }
        }
      end

      it "changes commentable's comments count by 1" do
        expect { post_request }.to change(post1.reload.comments, :count).by(1)
      end

      it 'redirects to commentable' do
        post_request
        expect(response).to redirect_to(post1)
      end

      it 'returns status code see_other' do
        post_request
        expect(response).to have_http_status(:see_other)
      end
    end

    context 'with incorrect params' do
      let!(:params) do
        {
          comment: {
            content: '',
            commenter: user1,
            commentable_id: post1.id,
            commentable_type: post1.class.name
          }
        }
      end

      it "does not change commentable's comments count" do
        expect { post_request }.to_not change(post1.reload.comments, :count)
      end

      it "renders alert" do
        post_request
        expect(flash[:alert]).to eq("Content is too short (minimum is 1 character)")
      end

      it 'redirects back' do
        request.env['HTTP_REFERER'] = post_path(post1)
        post_request
        expect(response).to redirect_to(post_path(post1))
      end
    end
  end

  describe '[DELETE] #destroy' do
    let(:delete_request) { delete :destroy, params: params }

    context 'when comment exists' do
      let!(:params) { { id: comment.id } }

      it 'assigns @comment' do
        delete_request
        expect(assigns(:comment)).to eq(comment)
      end
  
      it 'redirects to commentable' do
        delete_request
        expect(response).to redirect_to(comment.commentable)
      end
  
      it 'returns status code see_other' do
        delete_request
        expect(response).to have_http_status(:see_other)
      end
  
      it 'accepts html format' do
        delete_request
        expect(response.media_type).to eq 'text/html'
        expect(response.content_type).to eq 'text/html; charset=utf-8'
      end
    end

    context 'when comment does not exist' do
      let!(:params) { { id: -1 } }

      it 'redirects back' do
        request.env['HTTP_REFERER'] = post_path(post1)
        delete_request
        expect(response).to redirect_to(post_path(post1))
      end

      it 'renders alert' do
        delete_request
        expect(flash[:alert]).to eq "Comment doesn't exist" 
      end
    end
  end

  describe '[PUT] #update' do
    let(:put_request) { put :update, params: params }
    context 'with valid params' do
      let!(:params) {
        {
          id: comment.id,
          comment: {
            content: "updated",
            commentable_id: post1.id,
            commentable_type: post1.class.name
          }
        }
      }

      it 'assigns @comment' do
        put_request
        expect(assigns(:comment)).to eq(comment)
      end

      it 'changes content of the comment' do
        expect{ put_request }.to change{ comment.reload.content }.from("content").to("updated")
      end

      it 'redirects to commentable' do
        put_request
        expect(response).to redirect_to(comment.commentable)
      end

      it 'accepts html format' do
        put_request
        expect(response.media_type).to eq 'text/html'
        expect(response.content_type).to eq 'text/html; charset=utf-8'
      end
    end

    context 'with invalid params' do
      let!(:params) {
        {
          id: comment.id,
          comment: {
            content: "",
            commenter: user1,
            commentable_id: post1.id,
            commentable_type: post1.class.name
          }
        }
      }

      it "does not change comment's content" do
        expect{ put_request }.not_to change{ comment.reload.content }
      end

      it 'redirects to commentable' do
        put_request
        expect(response).to redirect_to(comment.commentable)
      end
    
      it 'returns status code see_other' do
        put_request
        expect(response).to have_http_status(:see_other)
      end

      it 'accepts html format' do
        put_request
        expect(response.media_type).to eq 'text/html'
        expect(response.content_type).to eq 'text/html; charset=utf-8'
      end
    end
  end

  describe '[POST] #replies' do
    let(:post_request) { post :replies, params: { id: comment.id }, format: :turbo_stream }
    let!(:reply) { create :comment, commenter: user1, commentable: post1, parent_id: comment.id }

    it 'assigns @comment' do
      post_request
      expect(assigns(:comment)).to eq(comment) 
    end

    it 'assigns @replies' do
      post_request
      expect(assigns(:replies)).to eq([reply])
    end

    it 'accepts turbo_stream format' do
      post_request
      expect(response.media_type).to eq 'text/vnd.turbo-stream.html'
      expect(response.content_type).to eq 'text/vnd.turbo-stream.html; charset=utf-8'
    end
  end

  describe '[POST] #like' do
    let(:post_request) { post :like, params: params }
    let(:turbo_stream_post_request) { post :like, params: params, format: :turbo_stream }

    context 'with correct params' do 
      let!(:params) {
        {
          id: comment.id,
        }
      }

      it "increases comment's like count by 1" do
        expect{ post_request }.to change(comment.likes, :count).by(1)
      end

      it 'renders like_count partial' do
        post_request
        expect(response).to render_template(partial: 'comments/_like_count')
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
    let!(:like) { create :like, :for_comment, likeable: comment, user: user1 }
    let(:delete_request) { delete :unlike, params: params }
    let(:turbo_stream_delete_request) { delete :unlike, params: params, format: :turbo_stream }

    context 'with correct params' do
      let!(:params) { { id: comment.id } }

      it "decreases comment's like count by 1" do
        expect{delete_request}.to change(comment.likes, :count).by(-1)
      end

      it 'renders like_count partial' do
        delete_request
        expect(response).to render_template(partial: 'comments/_like_count')
      end

      it 'accepts html format' do
        delete_request
        expect(response.media_type).to eq 'text/html'
        expect(response.content_type).to eq 'text/html; charset=utf-8'
      end

      it 'accepts turbo_stream format' do
        turbo_stream_delete_request
        expect(response.media_type).to eq 'text/vnd.turbo-stream.html'
        expect(response.content_type).to eq 'text/vnd.turbo-stream.html; charset=utf-8'
      end
    end
  end
end
