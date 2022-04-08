class CreateDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :documents do |t|
      t.string :title
      t.string :description
      t.string :file
      t.timestamps
    end
  end
end
