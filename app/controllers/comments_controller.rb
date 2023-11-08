class CommentsController < ApplicationController
  before_action :authenticate_user!

  def new
    @comment = Comment.new
  end

  def create
    @comment = Comment.new(comment_params)
    redirect_to root_path if @comment.save      
  end

  private
  
  def comment_params
    params.require(:comment).permit(:content, :commentable_id, :commentable_type).merge(commenter_id: current_user.id)
  end
end
