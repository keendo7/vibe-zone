class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment, only: [:like, :unlike, :destroy, :replies, :update]

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
      redirect_back_or_to root_path
    end
  end

  def update
    if @comment.update(comment_params)
      redirect_to @comment.commentable
    else
      redirect_to @comment.commentable, status: :see_other
    end
  end

  def replies
    @pagy, @replies = pagy_countless(@comment.replies, items: 10)
  end

  def like
    like = current_user.likes.create(likeable: @comment)
    notify(@comment.commenter, like) if like.persisted?

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(
          dom_id(@comment, :like_count),
          partial: "comments/like_count",
          locals: { comment: @comment }
        )
      }  
      format.html { render partial: 'comments/like_count', locals: { comment: @comment } }
    end
  end

  def unlike
    current_user.likes.find_by(likeable: @comment)&.destroy
    @comment.reload
    
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(
        dom_id(@comment, :like_count),
        partial: "comments/like_count",
        locals: { comment: @comment }
      )
    }  
      format.html { render partial: 'comments/like_count', locals: { comment: @comment } }
    end
  end

  def destroy
    @commentable = @comment.commentable
    @comment.destroy

    redirect_to @commentable, status: :see_other
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  rescue
    respond_to do |format|
      format.turbo_stream { 
        flash.now[:alert] = t("errors.comment.not_found")
        render turbo_stream: turbo_stream.update("flash", partial: "layouts/flash")
      }
      format.html { redirect_back_or_to root_path, alert: t("errors.comment.not_found") }
    end
  end

  def comment_params
    params.require(:comment).permit(:content, :commentable_id, :commentable_type, 
                                    :parent_id).merge(commenter_id: current_user.id)
  end

  def like_params
    params.require(:like).permit(:user_id, :likeable)
  end

  def notify(recipient, comment)
    return unless recipient != current_user

    Notification.create(user_id: recipient.id, sender_id: current_user.id, notifiable: comment)
  end
end
