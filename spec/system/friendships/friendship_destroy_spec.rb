require 'rails_helper'

RSpec.describe 'Destroy friendship' do
  let(:user) { create :user }
  let(:friend) { create :user }

  before do
    login_as(user)
  end

  context 'when friendship is mutual' do
    before do
      create(:friendship, :for_mutual, user: user, friend: friend)
    end

    scenario 'unfriend user' do
      visit user_path(friend)
      click_button 'Unfriend'

      validate_friendship
    end
  end

  context 'when friendship request was sent' do
    before do
      create(:friendship, user: user, friend: friend)
    end

    scenario 'unfriend user' do
      visit user_path(friend)
      click_button 'Unfriend'

      validate_friendship
    end
  end

  context 'when received a friendship request' do
    before do
      create(:friendship, user: friend, friend: user)
    end

    scenario 'decline friendship request' do
      visit user_path(friend)
      click_button 'Decline'

      validate_friendship
    end
  end

  def validate_friendship
    expect(user.reload.friends).to be_empty
    expect(page).to have_current_path(user_path(friend))
    expect(page.find_button('Befriend')).to be_present
  end
end
