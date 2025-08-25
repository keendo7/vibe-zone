require 'rails_helper'

RSpec.describe 'Destroy user', js: true do
  let(:user) { create :user }

  before do
    login_as(user)
  end

  scenario 'when user deletes their account' do
    visit details_path

    click_button 'Destroy account'
    accept_alert

    expect(page).to have_current_path(new_user_session_path)
    validate_user_presence(user.email)
  end

  def validate_user_presence(email)
    user = User.find_by(email: email)
    expect(user).not_to be_present
  end
end
