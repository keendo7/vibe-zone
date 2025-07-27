class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment, only: [:like, :unlike, :edit]

  def new; end

  def edit; end

  def update
    @comment = Comment.find(params[:id])
    if @comment.update(comment_params)
      redirect_to @comment.commentable
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      @comment.is_a_reply? ? notify(@comment.parent.commenter, @comment) : notify(@comment.commentable.author, @comment)
      respond_to do |format|
        format.html { redirect_to @comment.commentable, status: :see_other }
        format.turbo_stream
      end
    else
      flash[:alert] = @comment.errors.full_messages.join(', ')
      redirect_back fallback_location: root_path
    end
  end

  def replies
    @comment = Comment.find(params[:id])
    @pagy, @replies = pagy_countless(@comment.replies, items: 10)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def like
    like = current_user.likes.create(likeable: @comment)
    notify(@comment.commenter, like)
    render partial: 'comments/like_count', locals: { comment: @comment }
  end

  def unlike
    current_user.likes.find_by(likeable: @comment).destroy
    @comment.reload
    render partial: 'comments/like_count', locals: { comment: @comment }
  end

  def destroy
    @comment = Comment.find(params[:id])
    @commentable = @comment.commentable
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to @commentable, status: :see_other }
      format.turbo_stream
    end
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  rescue
    redirect_to(root_path, alert: "Something went wrong")
  end

  def comment_params
    params.require(:comment).permit(:content, :commentable_id, :commentable_type, :parent_id).merge(commenter_id: current_user.id)
  end

  def like_params
    params.require(:like).permit(:user_id, :likeable)
  end

  def notify(recipient, comment)
    return unless recipient != current_user

    Notification.create(user_id: recipient.id, sender_id: current_user.id, notifiable: comment)
  end
end
