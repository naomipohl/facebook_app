class Friendship < ApplicationRecord
  validates :status, presence: true
  belongs_to :user
  belongs_to :friend, class_name: 'User', foreign_key: 'friend_id'
  validates_uniqueness_of :friend, scope: :user
end
