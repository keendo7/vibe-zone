class AddCommentableCountToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :commentable_count, :integer, default: 0, null: false
  end
end
