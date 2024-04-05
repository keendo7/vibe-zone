class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:show, :like, :unlike]

  def home
    @posts = current_user.timeline
    @post = current_user.authored_posts.new
  end
  
  def index
    @posts = Post.all
    @post = current_user.authored_posts.new
  end

  def show
    @comments = @post.comments.where.not(id: nil)
    @comment = @post.comments.build
  end

  def create
    @post = current_user.authored_posts.new(post_params)
    redirect_to root_path if @post.save  
  end

  def destroy
    @post = Post.friendly.find(params[:id])
    @post.destroy
    redirect_to root_path
  end

  def like
    current_user.likes.create(likeable: @post)
    render partial: "posts/post", locals: { post: @post }
  end

  def unlike
    current_user.likes.find_by(likeable: @post).destroy
    render partial: "posts/post", locals: { post: @post } 
  end

  private

  def post_params
    params.require(:post).permit(:content)
  end

  def set_post
    @post = Post.friendly.find(params[:id])
  end
end
