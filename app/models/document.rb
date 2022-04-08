class Document < ApplicationRecord
  belongs_to :user
  has_one :doc_file
  validates :file, presence: true, uniqueness: true
end
