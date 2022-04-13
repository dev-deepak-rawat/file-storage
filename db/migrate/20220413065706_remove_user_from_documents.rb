class RemoveUserFromDocuments < ActiveRecord::Migration[7.0]
  def change
    remove_reference :documents, :user, null: false, foreign_key: true
  end
end
