module FormsHelper
  def edit_comment_form(comment)
    render 'comments/form',
            comment: comment,
            commentable_id: comment.commentable.id, 
            commentable_type: "#{comment.commentable.class.name}", 
            parent_id: comment.parent_id
  end

  def reply_comment_form(comment)
    render 'comments/form',
            comment: Comment.new,
            commentable_id: comment.commentable.id, 
            commentable_type: "#{comment.commentable.class.name}", 
            parent_id: comment.is_a_reply? ? comment.parent_id : comment.id
  end
end
