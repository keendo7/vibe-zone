require 'rails_helper'

RSpec.describe "User logs in" do
  let!(:user) { create(:user) }

  scenario 'with valid email and password' do
    login_with(user.email, user.password)

    expect(page).to have_content('Signed in successfully.')
    expect(page).to have_current_path(root_path)
  end

  scenario 'with invalid email' do
    login_with('wrong@example.com', user.password)

    expect(page).to have_content('Invalid Email or password.')
    expect(page).to have_current_path(new_user_session_path)
  end
  
  scenario 'with invalid password' do
    login_with(user.email, 'wrongpassword')

    expect(page).to have_content('Invalid Email or password.')
    expect(page).to have_current_path(new_user_session_path)
  end

  def login_with(email, password)
    visit new_user_session_path
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    click_button 'Log in'
  end
end
