require 'rails_helper'

RSpec.describe 'Remove banner' do
  let(:user) { create :user, :with_banner }

  before do
    login_as(user)
  end

  scenario 'when banner is attached' do
    remove_banner(user)

    expect(page).to have_content I18n.t('messages.user.banner_removed')

    within '.banner_container' do
      expect(page.find('#banner')[:src]).not_to have_content('banner1.png')
    end
  end

  def remove_banner(user)
    visit user_path(user)
    within('.banner_container') do
      find('#dropdownMenu2').click
      click_button 'Remove banner'
    end

    accept_alert
  end
end
