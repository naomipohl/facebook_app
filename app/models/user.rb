class User < ApplicationRecord
  def remove_friendship(friend)
  end

  def send_friend_request(friend)
  end

  def accept_friend_request(friend)
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
