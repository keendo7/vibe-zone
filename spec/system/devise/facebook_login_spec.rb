require 'rails_helper'

RSpec.describe 'User logs in through Facebook' do
  after { OmniAuth.config.mock_auth[:facebook] = nil }
  let(:provider) { "facebook" }
  let(:uid) { "1234567" }

  context 'with valid credentials' do
    before do
      OmniAuth.config.mock_auth[:facebook] =
        OmniAuth::AuthHash.new(
          provider: provider,
          uid: uid,
          info: {
            first_name: user.first_name,
            last_name: user.last_name,
            email: user.email,
            image: 'http://graph.facebook.com/1234567/picture?type=square'
          }
        )
      
    end

    context 'for a user that does not exist' do
      let(:user) { build :user }

      scenario 'user attempts to log in' do
        visit new_user_session_path
        click_button 'Login with Facebook'

        verify_user_exists(user.email)
      end
    end

    context 'for a user that exists' do
      let(:user) { create :user }

      scenario 'user attempts to log in' do
        visit new_user_session_path
        click_button 'Login with Facebook'

        verify_user_exists(user.email)
      end
    end
  end

  context 'with invalid credentials' do
    before { OmniAuth.config.mock_auth[:facebook] = :invalid_credentials }

    scenario 'user attempts to log in' do
      visit new_user_session_path
      click_button "Login with Facebook"

      expect(page).to have_content("Authentication failed, please try again")
      expect(page).to have_current_path(new_user_session_path)
    end
  end

  def verify_user_exists(email)
    user = User.find_by(email: email)
    expect(user).to be_present
    expect(user.provider).to eq(provider)
    expect(user.uid).to eq(uid)
  end
end
