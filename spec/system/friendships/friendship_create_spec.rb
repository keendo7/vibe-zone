require 'rails_helper'

RSpec.describe 'Create friendship' do
  let!(:user) { create :user }
  let!(:friend) { create :user }

  before do
    login_as(user)
  end

  scenario 'when user is not a friend' do
    visit user_path(friend)
    click_button 'Befriend'

    validate_friendship
  end

  context 'when received a friendship request from a friend' do
    before do
      create(:friendship, user: friend, friend: user)
    end

    scenario 'and user accepts' do
      visit user_path(friend)
      click_button 'Accept'

      validate_friendship
    end
  end

  def validate_friendship
    expect(user.reload.friends).to include(friend)
    expect(page).to have_current_path user_path(friend)
    expect(page.find_button('Unfriend')).to be_present
  end
end
