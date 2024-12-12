class AddLikeableCountToComments < ActiveRecord::Migration[7.0]
  def change
    add_column :comments, :likeable_count, :integer, default: 0, null: false 
  end
end
