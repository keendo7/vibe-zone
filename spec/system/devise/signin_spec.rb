require 'rails_helper'

RSpec.describe 'User Sign In', type: :system do
  let!(:user) { build(:user) }

  scenario 'with valid credentials' do
    sign_in_with(user.email, user.first_name, user.last_name, user.password, user.password_confirmation)

    expect(page).to have_content('Welcome! You have signed up successfully.')
    expect(page).to have_current_path(root_path)
  end

  scenario 'with invalid email' do
    sign_in_with('invalid_email', user.first_name, user.last_name, user.password, user.password_confirmation)
    
    expect(page).to have_content('Email is invalid')
  end

  scenario 'without first name' do
    sign_in_with(user.email, '', user.last_name, user.password, user.password_confirmation)

    expect(page).to have_content("First name can't be blank")
  end

  scenario 'without last name' do
    sign_in_with(user.email, user.first_name, '', user.password, user.password_confirmation)

    expect(page).to have_content("Last name can't be blank")
  end

  scenario 'with blank password' do
    sign_in_with(user.email, user.first_name, user.last_name, '', user.password_confirmation)

    expect(page).to have_content("Password can't be blank")
  end

  scenario 'with too short password' do
    sign_in_with(user.email, user.first_name, user.last_name, '123', user.password_confirmation)

    expect(page).to have_content('Password is too short (minimum is 6 characters)')
  end

  scenario 'with invalid password confirmation' do
    sign_in_with(user.email, user.first_name, user.last_name, user.password, 'different_password')

    expect(page).to have_content("Password confirmation doesn't match Password")
  end

  def sign_in_with(email, first_name, last_name, password, password_confirmation)
    visit new_user_session_path
    click_link 'Sign up'

    fill_in 'user_email', with: email
    fill_in 'user_first_name', with: first_name
    fill_in 'user_last_name', with: last_name
    fill_in 'user_password', with: password
    fill_in 'user_password_confirmation', with: password_confirmation
    
    click_button 'Sign up'
  end
end
