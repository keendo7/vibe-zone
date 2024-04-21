class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:show, :like, :unlike]

  def home
    @pagy, @posts = pagy_countless(current_user.timeline, items: 10)
    @post = current_user.authored_posts.new

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  def index
    @pagy, @posts = pagy_countless(Post.all.order(created_at: :desc), items: 10)
    @post = current_user.authored_posts.new

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    @pagy, @comments = pagy_countless(@post.comments.where.not(id: nil), items: 10)
    @comment = @post.comments.build

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @post = current_user.authored_posts.new(post_params)
    redirect_to @post if @post.save
  end

  def destroy
    @post = Post.friendly.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to root_path, status: :see_other }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@post) }
    end
  end

  def like
    like = current_user.likes.create(likeable: @post)
    notify(@post.author, like)
    render partial: "likes/post_buttons", locals: { post: @post }
  end

  def unlike
    current_user.likes.find_by(likeable: @post).destroy
    render partial: "likes/post_buttons", locals: { post: @post }
  end

  private

  def post_params
    params.require(:post).permit(:content)
  end

  def set_post
    @post = Post.friendly.find(params[:id])
  end

  def notify(recipient, post)
    return unless recipient != current_user

    Notification.create(user_id: recipient.id, sender_id: current_user.id, notifiable: post)
  end
end
