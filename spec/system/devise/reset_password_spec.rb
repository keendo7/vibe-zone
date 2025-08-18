require 'rails_helper'

RSpec.describe 'User requests password reset' do
  let!(:user) { create(:user) }

  scenario 'with valid email' do
    reset_with(user.email)

    expect(page).to have_content I18n.t("devise.passwords.send_instructions")
  end

  scenario 'with blank email' do
    reset_with('')

    expect(page).to have_content("Email can't be blank")
  end

  scenario 'with non existing email' do
    reset_with('invalid_email')

    expect(page).to have_content('Email not found')
  end

  def reset_with(email)
    visit new_user_password_path

    fill_in 'user_email', with: email
    click_button 'Send reset link'
  end
end
