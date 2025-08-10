class AddUniqueIndexToFriendship < ActiveRecord::Migration[7.0]
  def change
    add_index :friendships, [:user_id, :friend_id], unique: true
  end
end
