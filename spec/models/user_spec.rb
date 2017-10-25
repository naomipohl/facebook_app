describe 'User' do
  let!(:user) { User.create(name: 'User 1', email: 'user1@test.com', password: 'user1') }
  let!(:user2) { User.create(name: 'User 2', email: 'user2@test.com', password: 'user2') }
  let!(:user3) { User.create(name: 'User 3', email: 'user3@test.com', password: 'user3') }

  describe 'has_many statuses' do
    before :each do
      user.statuses.create text: 'testing'
    end

    it 'has many statuses' do
      expect { user.statuses.create text: 'testing' }.to change(Status, :count).by(1)
    end

    it 'deletes associated status' do
      num_statuses = user.statuses.size * -1
      expect { user.destroy }.to change(Status, :count).by num_statuses
    end
  end

  describe 'has_many friendships' do
    let(:friendship) { Friendship.create(user: user, friend: user2, status: 'accepted') }
    let(:friendship2) { Friendship.create(user: user2, friend: user, status: 'accepted') }
    let(:friendship3) { Friendship.create(user: user, friend: user3, status: 'accepted') }
    let(:friendship2) { Friendship.create(user: user3, friend: user, status: 'accepted') }

    it 'has many friendships' do
      expect(user.friendships).to include(friendship)
      expect(user.friendships).to include(friendship3)
    end

    it 'deletes associated friendships' do
      num_friendships = user.friendships.size * -1
      expect { user.destroy }.to change(Friendship, :count).by num_friendships
    end

    it 'has many friends through friendships' do
      expect(user.friends).to include(friendship.friend)
      expect(user.friends).to include(friendship3.friend)
    end
  end

  describe 'validations' do
    it 'will not save without a name' do
      expect { User.create(email: 'email@email.com', password: 'password') }.to change(User, :count).by 0
    end

    it 'will not save with a name shorter than 2 characters' do
      expect { User.create(email: 'email@email.com', name: 'F', password: 'password') }.to change(User, :count).by 0
    end

    it 'will not save with a lowercase name' do
      expect { User.create(email: 'email@email.com', password: 'password', name: 'invalid') }.to change(User, :count).by 0
    end

    it 'will not save without an email' do
      expect { User.create(name: 'First Last', password: 'password') }.to change(User, :count).by 0
    end

    it 'will not save a duplicated email' do
      User.create(email: 'email@email.com', name: 'First Last', password: 'password')
      expect { User.create(email: 'email@email.com', name: 'First Last2', password: 'password') }.to change(User, :count).by 0
    end

    it 'will save with proper data' do
      expect { User.create(email: 'email@email.com', name: 'First Last', password: 'password') }.to change(User, :count).by 1
    end
  end

  describe 'uses Bcrypt' do
    it 'includes Bcrypt' do
      expect(User.ancestors).to include(BCrypt)
    end

    it 'has a password method' do
      expect(User.public_instance_methods).to include(:password)
    end

    it 'has a password= method' do
      expect(User.public_instance_methods).to include(:password=)
    end

    it 'does not have a password column' do
      expect(ActiveRecord::Base.connection.column_exists?(:users, :password)).to be false
    end
  end

  describe 'friendship_methods' do
    describe '#remove_friendship' do
      it 'accepts one argument' do
        expect { user.remove_friendship(user2) }.to_not raise_error
      end

      it 'destroys the Friendship instance if it exists' do
        Friendship.create(user: user, friend: user2, status: 'pending')
        expect { user.remove_friendship(user2) }.to change(Friendship, :count).by(-1)
      end

      it 'destroys the reverse Friendship instance if it exists' do
        Friendship.create(user: user, friend: user2, status: 'accepted')
        Friendship.create(user: user2, friend: user, status: 'accepted')
        expect { user.remove_friendship(user2) }.to change(Friendship, :count).by(-2)
      end
    end

    describe '#send_friend_request' do
      it 'accepts one argument' do
        expect { user.send_friend_request(user2) }.to_not raise_error
      end

      it 'creates a Friendship from the current user' do
        expect { user.send_friend_request(user2) }.to change(Friendship, :count).by 1
        expect(Friendship.find_by(user: user, friend: user2)).to_not be_nil
      end

      it 'creates a Friendship instance with status pending' do
        expect { user.send_friend_request(user2) }.to change(Friendship, :count).by 1
        expect(Friendship.find_by(user: user, friend: user2).status).to eq('pending')
      end
    end

    describe '#accept_friend_request' do
      it 'accepts one argument' do
        expect { user.accept_friend_request(user2) }.to_not raise_error
      end

      it 'creates friendships with status accept if they don\'t exist' do
        expect { user.accept_friend_request(user2) }.to change(Friendship, :count).by 2
        expect(Friendship.find_by(user: user, friend: user2).status).to eq('accepted')
        expect(Friendship.find_by(user: user2, friend: user).status).to eq('accepted')
      end

      it 'updates friendships with status accept if they already exist' do
        Friendship.create(user: user, friend: user2, status: 'pending')
        Friendship.create(user: user2, friend: user, status: 'pending')
        expect { user.accept_friend_request(user2) }.to change(Friendship, :count).by 0
        expect(Friendship.find_by(user: user, friend: user2).status).to eq('accepted')
        expect(Friendship.find_by(user: user2, friend: user).status).to eq('accepted')
      end
    end
  end
end
