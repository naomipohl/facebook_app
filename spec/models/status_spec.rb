describe 'Status' do
  it 'belongs to user' do
    status = Status.create(text: 'test!')
    user = User.create(name: 'Test Name', email: 'test@test.com', password: 'test')
    user.statuses.append status
    expect(status.user).to eq(user)
  end

  describe 'validations' do
    it 'will not save without text' do
      expect { Status.create }.to change(Status, :count).by 0
    end

    it 'will not save with fewer than 5 characters' do
      expect { Status.create(text: 'four') }.to change(Status, :count).by 0
    end

    it 'will save with 5 or more characters' do
      user = User.create(name: 'Test Name', email: 'test@test.com', password: 'test')
      expect { Status.create(text: 'five!', user: user) }.to change(Status, :count).by(1)
    end

    it 'will not save without a user' do
      expect { Status.create(text: 'five!') }.to change(Status, :count).by(0)
    end
  end
end
