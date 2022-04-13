class User < ApplicationRecord
  has_many :permissions, dependent: :destroy
  has_many :documents, through: :permissions
  has_secure_password
  validates :username, presence: true, uniqueness: true, length: { maximum: 15 }
  validates :password, presence: true, length: { maximum: 20 }

  scope :get_user_docs_with_permission, lambda { |user, access|
                                          user.documents.where('permissions.access = ?', access)
                                        }
end
