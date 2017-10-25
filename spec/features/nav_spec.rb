describe 'nav features' do
  let!(:user) { User.create(name: 'Test name', email: 'test@test.com', password: 'test') }

  before :each do
    page.set_rack_session(user_id: nil)
    visit '/'
  end

  it 'displays link to all users' do
    expect(page).to have_link('Users', href: '/users')
  end

  context 'when user is not logged in' do
    it 'displays Log in and Sign up links' do
      expect(page).to have_link('Log in', href: '/login')
      expect(page).to have_link('Sign up', href: '/users/new')
    end

    it 'does not display the user\'s name, Friend Requests, and log out links' do
      expect(page).to_not have_link user.name
      expect(page).to_not have_link 'Friend Requests'
      expect(page).to_not have_link 'Log out'
    end
  end

  context 'when user is logged in' do
    before :each do
      page.set_rack_session(user_id: user.id)
      visit '/'
    end

    it 'displays the user\'s name, friend requests, and log out links' do
      expect(page).to have_link(user.name, href: "/users/#{user.id}")
      expect(page).to have_link('Friend Requests', href: '/friend_requests')
      expect(page).to have_link('Log out', href: '/logout')
    end

    it 'does not display Log in and Sign up links' do
      expect(page).to_not have_link 'Log in'
      expect(page).to_not have_link 'Sign up'
    end

    it 'the Log out button logs the user out' do
      click_link 'Log out'
      expect(page.get_rack_session).to_not include('user_id')
    end
  end
end
