describe 'session features' do
  describe '#login' do
    before :each do
      visit '/login'
    end

    it 'loads the correct page correctly' do
      expect(status_code).to eql(200)
      expect(page).to have_text('Log In')
    end

    it 'the form has email and password fields' do
      expect(page).to have_field('email')
      expect(page).to have_field('password')
    end

    it 'redirects back to the log in page if incorrect data inputted' do
      fill_in 'email', with: 'test@email.com'
      fill_in 'password', with: 'password'
      click_button 'Log in'
      expect(current_path).to eql('/login')
    end

    it 'logs in the user and redirects to root page' do
      user = User.create(name: 'Test name', email: 'test@test.com', password: 'test')
      fill_in 'email', with: 'test@test.com'
      fill_in 'password', with: 'test'
      click_button 'Log in'
      expect(current_path).to eql("/")
      expect(page.get_rack_session_key('user_id')).to eql(user.id)
    end
  end
end
