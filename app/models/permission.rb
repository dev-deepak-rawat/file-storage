class Permission < ApplicationRecord
  belongs_to :document
  belongs_to :user

  scope :find_by_user_and_doc_id, ->(user_id, document_id) { find_by(user_id: user_id, document_id: document_id)}

  enum access: {
    owner: 0,
    guest: 1
  }
end
