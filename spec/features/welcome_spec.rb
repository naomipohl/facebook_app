describe 'welcome features' do
  describe '#index' do
    before :each do
      visit '/'
    end

    it 'loads the correct page successfully' do
      expect(status_code).to eql(200)
    end

    context 'when no user is logged in' do
      it 'displays text telling the user to sign up or log in' do
        expect(page).to have_text('Sign up or log in to get started!')
      end
    end

    context 'when a user is logged in' do
      let!(:user) { User.create(name: 'Testing', email: 'test@test.com', password: 'test') }

      before :each do
        page.set_rack_session('user_id' => user.id)
        visit '/'
      end

      it 'renders the new status form' do
        expect(page).to have_field('status_text', placeholder: "What's on your mind, #{user.name}?")
        expect(page).to have_button('Create Status')
      end

      it 'shows logged in user\'s and friends\' statuses' do
        friend = User.create(name: 'Friend', email: 'test1@test.com', password: 'test')
        user.accept_friend_request(friend)
        user_status = user.statuses.create(text: 'user status')
        friend_status = friend.statuses.create(text: 'friend status')

        visit '/'
        expect(page).to have_link(user.name, href: "/users/#{user.id}")
        expect(page).to have_link(friend.name, href: "/users/#{friend.id}")
        expect(page).to have_text(user_status.text)
        expect(page).to have_text(friend_status.text)
      end
    end
  end
end
