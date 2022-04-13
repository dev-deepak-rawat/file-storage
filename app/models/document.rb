class Document < ApplicationRecord
  has_many :permissions, dependent: :destroy
  has_many :documents, through: :permissions
  has_one :doc_file
  validates :file, presence: true, uniqueness: true
end
