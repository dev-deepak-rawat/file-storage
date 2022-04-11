class User < ApplicationRecord
  has_many :documents
  has_secure_password
  validates :username, presence: true, uniqueness: true, length: { maximum: 15 }
  validates :password, presence: true, length: { maximum: 20 }
end
