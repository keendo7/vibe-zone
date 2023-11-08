class PostsController < ApplicationController
  before_action :authenticate_user!

  def home
    @posts = current_user.timeline
    @post = current_user.authored_posts.new
  end

  def show
    @post = Post.find(params[:id])
    @comment = @post.comments.build
  end

  def create
    @post = current_user.authored_posts.new(post_params)
    redirect_to root_path if @post.save  
  end

  private

  def post_params
    params.require(:post).permit(:content)
  end
end
