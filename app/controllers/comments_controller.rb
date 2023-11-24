class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment, only: [:like, :unlike]

  def new
    @comment = Comment.new
  end

  def create
    @comment = Comment.new(comment_params)
    redirect_to @comment.commentable if @comment.save      
  end

  def like
    current_user.likes.create(likeable: @comment)
    redirect_to @comment.commentable
  end

  def unlike
    current_user.likes.find_by(likeable: @comment).destroy
    redirect_to @comment.commentable
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content, :commentable_id, :commentable_type).merge(commenter_id: current_user.id)
  end
end
