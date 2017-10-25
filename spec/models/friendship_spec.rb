describe 'Friendship' do
  let!(:user) { User.create(name: 'User 1', email: 'user1@test.com', password: 'user1') }
  let!(:user2) { User.create(name: 'User 2', email: 'user2@test.com', password: 'user2') }
  let!(:friendship) { Friendship.create(user: user, friend: user2, status: 'pending') }

  it 'belongs to a user and friend' do
    expect(friendship.user).to eq(user)
    expect(friendship.friend).to eq(user2)
  end

  describe 'validations' do
    it 'will not save without a status' do
      expect { Friendship.create(user: user2, friend: user) }.to change(Friendship, :count).by 0
    end

    it 'will not save a duplicate friendship' do
      expect { Friendship.create(user: user, friend: user2, status: 'accepted') }.to change(Friendship, :count).by 0
    end
  end
end
