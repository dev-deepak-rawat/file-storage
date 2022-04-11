class AddPublicShareToDocument < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :public_share, :boolean, null: false, default: false
  end
end
