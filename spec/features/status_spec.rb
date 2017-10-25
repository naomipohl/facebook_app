describe 'status features' do
  describe '#new' do
    let!(:user) { User.create(name: 'Test name', email: 'test@test.com', password: 'test') }

    before :each do
      page.set_rack_session(user_id: user.id)
      visit '/statuses/new'
    end

    it 'loads the correct page successfully' do
      expect(status_code).to eql(200)
      expect(page).to have_text('Create New Status')
    end

    it 'has the correct fields' do
      expect(page).to have_field('status_text')
    end

    it 'creates a new status' do
      fill_in 'status_text', with: 'testing'
      click_button 'Create Status'
      expect(Status.count).to eql(1)
    end

    it 'displays the correct error message' do
      click_button 'Create Status'
      expect(current_path).to eql('/statuses')
      expect(page).to have_text('Text can\'t be blank')
      expect(page).to have_text('Text is too short (minimum is 5 characters)')
    end
  end

  describe '#edit' do
    let!(:user) { User.create(name: 'Test name', email: 'test@test.com', password: 'test') }
    let!(:status) { user.statuses.create(text: 'testing') }

    before :each do
      page.set_rack_session(user_id: user.id)
      visit "/statuses/#{status.id}/edit"
    end

    it 'loads the correct page successfully' do
      expect(status_code).to eql(200)
      expect(page).to have_text('Editing Status')
    end

    it 'pre-fills the form' do
      expect(page).to have_field('status_text')
      expect(find_field('status_text').value).to eql(status.text)
    end

    it 'edits the status correctly' do
      fill_in 'status_text', with: 'editted text'
      click_button 'Update Status'
      expect(current_path).to eql("/users/#{user.id}")
      expect(page).to have_text('editted text')
    end
  end

  describe '#destroy' do
    let!(:user) { User.create(name: 'Test name', email: 'test@test.com', password: 'test') }
    let!(:status) { user.statuses.create(text: 'testing') }

    it 'deletes the status' do
      page.set_rack_session(user_id: user.id)
      visit "/users/#{user.id}"

      click_link 'Delete', href: "/statuses/#{status.id}"
      expect(user.statuses.size).to eql(0)
      expect(current_path).to eql("/users/#{user.id}")
    end
  end
end
