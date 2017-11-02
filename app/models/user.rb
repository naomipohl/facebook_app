require 'bcrypt'

class User < ApplicationRecord
  include BCrypt

  validates :name, presence: true, length: { minimum: 2 }
  validates :email, presence: true, uniqueness: true
  validate :name_capitalized
  has_many :statuses, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :friendships, dependent: :destroy

  def password
    @password ||= Password.new(password_hash) unless password_hash.nil?
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  def name_capitalized
    unless name.nil?
      errors.add(:name, 'is not capitalized.') unless name.slice(0, 1) == name.slice(0, 1).upcase
    end
  end

  def remove_friendship(friend)
    friendship1 = Friendship.find_by(user: self, friend: friend)
    friendship2 = Friendship.find_by(user: friend, friend: self)
    friendship1.destroy if friendship1
    friendship2.destroy if friendship2
  end

  def send_friend_request(friend)
    return if friendships.find_by(user: self, friend: friend)
    Friendship.create(user: self, friend: friend, status: 'pending')
  end

  def accept_friend_request(friend)
    new_friendship = Friendship.find_or_initialize_by(user: self, friend: friend)
    new_friendship.update(status: 'accepted')
    another_friendship = Friendship.find_or_initialize_by(user: friend, friend: self)
    another_friendship.update(status: 'accepted')
  end

  def accepted_friends
    friendships.where(status: 'accepted').map(&:friend)
  end

  def outgoing_friend_requests
    friendships.where(status: 'pending').map(&:friend)
  end

  def incoming_friend_requests
    Friendship.where(friend: self, status: 'pending').map(&:user)
  end
end
