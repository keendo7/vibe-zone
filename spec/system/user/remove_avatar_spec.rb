require 'rails_helper'

RSpec.describe 'Remove avatar' do
  let(:user) { create :user, :with_avatar }

  before do
    login_as(user)
  end

  scenario 'when avatar is attached' do
    visit user_path(user)

    within 'turbo-frame#user_avatar' do
      page.find('#remove-avatar').click
    end

    expect(page).to have_content I18n.t('messages.user.avatar_removed')

    within '.avatar_container' do
      expect(page.find('#avatar')[:src]).to include('gravatar')
    end
  end
end
