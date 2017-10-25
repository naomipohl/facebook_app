describe 'user features' do
  describe '#index' do
    let!(:user) { User.create(name: 'Test name', email: 'test@test.com', password: 'test') }

    before :each do
      visit '/users'
    end

    it 'loads the correct page successfully' do
      expect(status_code).to eql(200)
      expect(page).to have_text('Users')
      expect(page).to have_text('Name')
      expect(page).to have_text('Email')
    end

    it 'lists all users' do
      User.create(name: 'Second test', email: 'test1@test.com', password: 'test')
      visit '/users'
      expect(page).to have_text(user.name)
      expect(page).to have_text(user.email)
      expect(page).to have_text('Second test')
      expect(page).to have_text('test1@test.com')
    end

    it 'does not show Edit Profile or Delete Account links if not logged in as user' do
      expect(page).to_not have_text('Edit Profile')
      expect(page).to_not have_text('Delete Account')
    end

    context 'when logged in' do
      let!(:user2) { User.create(name: 'Second test', email: 'test2@test.com', password: 'test') }

      before :each do
        page.set_rack_session(user_id: user.id)
        visit '/users'
      end

      it 'shows Edit Profile and Delete Account links' do
        expect(page).to have_link('Edit Profile', href: "/users/#{user.id}/edit")
        expect(page).to have_link('Delete Account', href: "/users/#{user.id}")
      end

      it 'only shows Edit Profile and Delete Account links for logged in user' do
        expect(page).to have_text('Edit Profile', count: 1)
        expect(page).to have_text('Delete Account', count: 1)
      end

      it 'shows Send Friend Request link next to non-friends' do
        expect(page).to have_link('Send Friend Request', href: "/users/#{user2.id}/send_friend_request")
      end

      it 'shows Remove Friend link next to friends' do
        user.accept_friend_request(user2)
        visit '/users'
        expect(page).to have_link('Remove Friend', href: "/users/#{user2.id}/remove_friendship")
      end

      it 'shows Accept and Decline Friend Request links next to incoming friend requests' do
        user2.send_friend_request(user)
        visit '/users'
        expect(page).to have_link('Accept Friend Request', href: "/users/#{user2.id}/accept_friend_request")
        expect(page).to have_link('Decline Friend Request', href: "/users/#{user2.id}/remove_friendship")
      end

      it 'shows Cancel Friend Request link next to outgoing friend requests' do
        user.send_friend_request(user2)
        visit '/users'
        expect(page).to have_link('Cancel Friend Request', href: "/users/#{user2.id}/remove_friendship")
      end
    end
  end

  describe '#new' do
    before :each do
      visit '/users/new'
    end

    it 'loads the correct page successfully' do
      expect(status_code).to eql(200)
      expect(page).to have_text('Sign up')
    end

    it 'has the name, email, and password fields' do
      expect(page).to have_field('user_name')
      expect(page).to have_field('user_email')
      expect(page).to have_field('user_password')
    end

    it 'does not use password hash' do
      expect(page).to_not have_text('hash')
      expect(page).to_not have_field('user_password_hash')
    end

    it 'creates a new user' do
      fill_in 'user_name', with: 'Test name'
      fill_in 'user_email', with: 'test@test.com'
      fill_in 'user_password', with: 'test'
      click_button 'Create User'
      expect(User.count).to eql(1)
    end

    it 'displays the correct error messages' do
      click_button 'Create User'
      expect(page).to have_text('Name can\'t be blank')
      expect(page).to have_text('Name is too short (minimum is 2 characters)')
      expect(page).to have_text('Email can\'t be blank')
    end

    it 'displays name capitilization error message' do
      fill_in 'user_name', with: 'test name'
      fill_in 'user_email', with: 'test@test.com'
      fill_in 'user_password', with: 'test'
      click_button 'Create User'
      expect(page).to have_text('Name is not capitalized.')
    end

    it 'logs the user in' do
      fill_in 'user_name', with: 'Test name'
      fill_in 'user_email', with: 'test@test.com'
      fill_in 'user_password', with: 'test'
      click_button 'Create User'
      expect(page.get_rack_session).to include('user_id')
    end
  end

  describe '#edit' do
    let!(:user) { User.create(name: 'Test name', email: 'test@test.com', password: 'test') }

    before :each do
      visit "/users/#{user.id}/edit"
    end

    it 'loads the correct page successfully' do
      expect(status_code).to eql(200)
      expect(page).to have_text("Editing #{user.name}")
    end

    it 'has information pre-filled' do
      expect(page).to have_field('user_name')
      expect(page).to have_field('user_email')
      expect(page).to have_field('user_password')
      expect(find_field('user_name').value).to eql('Test name')
      expect(find_field('user_email').value).to eql('test@test.com')
    end
  end

  describe '#show' do
    let!(:user) { User.create(name: 'Test name', email: 'test@test.com', password: 'test') }
    let!(:status) { user.statuses.create(text: 'testing') }

    before :each do
      visit "/users/#{user.id}"
    end

    it 'loads the correct page successfully' do
      expect(status_code).to eql(200)
      expect(page).to have_text(user.name)
      expect(page).to have_text('Friends')
      expect(page).to have_text("#{user.name}'s Profile")
    end

    it 'lists the user\'s statuses' do
      expect(page).to have_text(status.text)
    end

    it 'does not have New Status, Edit Status Edit Profile, and Delete Account links without being logged in' do
      expect(page).to_not have_text('New Status')
      expect(page).to_not have_text('Edit Status')
      expect(page).to_not have_text('Edit Profile')
      expect(page).to_not have_text('Delete Account')
    end

    context 'when logged in' do
      before :each do
        page.set_rack_session(user_id: user.id)
      end

      context 'when page belongs to logged in user' do
        before :each do
          visit "/users/#{user.id}"
        end

        it 'has new status form' do
          expect(page).to have_button('Create Status')
        end

        it 'has Edit link when there are statuses' do
          expect(page).to have_link('Edit', href: "/statuses/#{status.id}/edit")
        end

        it 'has Edit Profile and Delete Account links' do
          expect(page).to have_link('Edit Profile', href: "/users/#{user.id}/edit")
          expect(page).to have_link('Delete Account', href: "/users/#{user.id}")
        end
      end

      context 'when page does not belong to logged in user' do
        let!(:user2) { User.create(name: 'Second test', email: 'test2@test.com', password: 'test') }

        before :each do
          visit "/users/#{user2.id}"
        end

        it 'does not have Edit Profile and Delete Account links' do
          expect(page).to_not have_text('Edit Profile')
          expect(page).to_not have_text('Delete Account')
        end

        it 'has Send Friend Request link when not friends' do
          expect(page).to have_link('Send Friend Request', href: "/users/#{user2.id}/send_friend_request")
        end

        it 'has Remove Friend link when friends' do
          user.accept_friend_request(user2)
          visit "/users/#{user2.id}"
          expect(page).to have_link('Remove Friend', href: "/users/#{user2.id}/remove_friendship")
        end

        it 'has Accept and Decline Friend Request links when incoming friend request' do
          user2.send_friend_request(user)
          visit "/users/#{user2.id}"
          expect(page).to have_link('Accept Friend Request', href: "/users/#{user2.id}/accept_friend_request")
          expect(page).to have_link('Decline Friend Request', href: "/users/#{user2.id}/remove_friendship")
        end

        it 'has Cancel Friend Request link when outgoing friend request' do
          user.send_friend_request(user2)
          visit "/users/#{user2.id}"
          expect(page).to have_link('Cancel Friend Request', href: "/users/#{user2.id}/remove_friendship")
        end
      end
    end
  end

  describe '#destroy' do
    it 'is deleted when Delete Account is clicked' do
      user = User.create(name: 'Test name', email: 'test@test.com', password: 'test')
      page.set_rack_session(user_id: user.id)
      visit "/users/#{user.id}"

      click_link 'Delete Account', href: "/users/#{user.id}"
      expect(current_path).to eql('/users')
      expect(User.count).to eql(0)
    end
  end
end
