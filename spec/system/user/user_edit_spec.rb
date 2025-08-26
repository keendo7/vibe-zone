require 'rails_helper'

RSpec.describe 'Edit user' do
  let(:user) { create :user }

  before do
    login_as(user)
  end

  scenario 'with valid credentials' do
    edit_user_with('Edited', 'User', 'edited_user@mail.com')

    expect(page).to have_current_path(details_path)
    expect(page).to have_content I18n.t('messages.user.updated')
  end

  scenario 'with blank first name' do
    edit_user_with('', user.last_name, user.email)

    expect(page).to have_current_path(details_path)
    expect(page).to have_content "First name can't be blank"
  end

  scenario 'with blank last name' do
    edit_user_with(user.first_name, '', user.email)

    expect(page).to have_current_path(details_path)
    expect(page).to have_content "Last name can't be blank"
  end

  scenario 'with invalid email' do
    edit_user_with(user.first_name, user.last_name, 'invalid_email')

    expect(page).to have_current_path(details_path)
    expect(page).to have_content "Email is invalid"
  end

  def edit_user_with(first_name, last_name, email)
    visit details_path

    fill_in 'user_first_name', with: first_name
    fill_in 'user_last_name', with: last_name
    fill_in 'user_email', with: email

    click_button 'Submit'
  end
end
