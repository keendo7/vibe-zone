class AddParentIdToComment < ActiveRecord::Migration[7.0]
  def change
    add_column :comments, :parent_id, :integer, null: true, index: true
  end
end
