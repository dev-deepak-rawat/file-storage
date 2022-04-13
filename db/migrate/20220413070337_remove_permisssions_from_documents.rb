class RemovePermisssionsFromDocuments < ActiveRecord::Migration[7.0]
  def change
    remove_column :documents, :permissions, :string
  end
end
