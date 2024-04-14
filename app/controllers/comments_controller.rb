class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment, only: [:like, :unlike]

  def new
    @comment = Comment.new
  end

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      notify(@comment.commentable.author, @comment)
      redirect_to @comment.commentable
    end   
  end

  def like
    like = current_user.likes.create(likeable: @comment)
    notify(@comment.commenter, like)
    render partial: 'comments/comment', locals: { comment: @comment }
  end

  def unlike
    current_user.likes.find_by(likeable: @comment).destroy
    render partial: 'comments/comment', locals: { comment: @comment }
  end

  def destroy
    @comment = Comment.find(params[:id])
    @commentable = @comment.commentable

    @comment.destroy
    redirect_to @commentable
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content, :commentable_id, :commentable_type).merge(commenter_id: current_user.id)
  end

  def like_params
    params.require(:like).permit(:user_id, :likeable)
  end

  def notify(recipient, comment)
    return unless recipient != current_user

    Notification.create(user_id: recipient.id, sender_id: current_user.id, notifiable: comment)
  end
end
