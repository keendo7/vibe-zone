class AddLikesCountToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :likeable_count, :integer, default: 0, null: false 
  end
end
