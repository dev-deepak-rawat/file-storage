class AddPermissionsToDocument < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :permissions, :string, null: false, default: ''
  end
end
