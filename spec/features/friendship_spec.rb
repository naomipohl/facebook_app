describe 'friends features' do
  let(:user_data) { { name: 'User One', email: 'user1@test.com', password: 'test' } }
  let!(:user) { User.create(user_data) }
  let(:user2_data) { { name: 'User Two', email: 'user2@test.com', password: 'test' } }
  let!(:user2) { User.create(user2_data) }
  
  before :each do
    page.set_rack_session(user_id: user.id)
  end

  describe '#send_friend_request' do
    it 'creates a new Friendship with a pending status when Send Friend Request is clicked' do
      visit "/users/#{user2.id}"
      click_link 'Send Friend Request'
      expect(status_code).to eql(200)
      expect(current_path).to eql("/users/#{user2.id}")
      expect(Friendship.where(user: user, friend: user2, status: 'pending')).to_not be_empty
    end
  end

  describe '#accept/decline_friend_request' do
    before :each do
      user2.send_friend_request(user)
      page.set_rack_session(user_id: user.id)
      visit "/users/#{user2.id}"
    end

    it 'clicking Accept Friend Request changes status of pending Friendship to accepted' do
      click_link 'Accept Friend Request'
      expect(Friendship.find_by(user: user, friend: user2).status).to eq('accepted')
      expect(Friendship.find_by(user: user2, friend: user).status).to eq('accepted')
    end

    it 'clicking Decline Friend Request deletes the pending Friendship' do
      click_link 'Decline Friend Request'
      expect(Friendship.count).to eql(0)
    end
  end

  describe '#remove_friendship' do
    before :each do
      user.accept_friend_request(user2)
      visit "/users/#{user2.id}"
    end

    it 'deletes the Friendship if Remove Friend is clicked' do
      click_link 'Remove Friend'
      expect(Friendship.count).to eql(0)
    end
  end

  describe '#friend_requests' do
    it 'redirects to root if user is not logged in' do
      page.set_rack_session(user_id: nil)
      visit '/friend_requests'
      expect(current_path).to eq('/')
    end

    it 'loads the correct page successfully' do
      visit '/friend_requests'
      expect(page).to have_text 'Incoming Friend Requests'
      expect(page).to have_text 'Outgoing Friend Requests'
    end

    it 'lists incoming friend requests' do
      user2.send_friend_request(user)
      visit '/friend_requests'

      expect(page).to have_link(user2.name, href: "/users/#{user2.id}")
      expect(page).to have_link('Accept Friend Request', href: "/users/#{user2.id}/accept_friend_request")
      expect(page).to have_link('Decline Friend Request', href: "/users/#{user2.id}/remove_friendship")
    end

    it 'lists outgoing friend requests' do
      user.send_friend_request(user2)
      visit '/friend_requests'

      expect(page).to have_link(user2.name, href: "/users/#{user2.id}")
      expect(page).to have_link('Cancel Friend Request', href: "/users/#{user2.id}/remove_friendship")
    end
  end
end
