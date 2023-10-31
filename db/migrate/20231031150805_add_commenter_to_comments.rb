class AddCommenterToComments < ActiveRecord::Migration[7.0]
  def change
    add_column :comments, :commenter_id, :bigint
  end
end
