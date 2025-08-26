require 'rails_helper'

RSpec.describe 'Upload avatar' do
  let(:user) { create :user }
  let(:other_user) { create :user }
  let(:avatar_image_path) { Rails.root.join('spec/fixtures/files/avatar1.png') }
  let(:invalid_avatar) do
    tmp = Tempfile.new(['file', '.png'])
    tmp.write('0' * 6.megabytes)
    tmp.rewind
    tmp.path
  end

  before do
    login_as(user)
  end

  context 'when user is current_user' do
    scenario 'with valid image' do
      upload_avatar(avatar_image_path)

      expect(page).to have_content I18n.t('messages.user.avatar_updated')
      expect(page.find('#avatar')[:src]).to have_content('avatar1.png')
    end

    scenario 'with invalid image size' do
      upload_avatar(invalid_avatar)
      accept_alert

      expect(page.find('#avatar')[:src]).to include('gravatar')
    end
  end

  context 'when user is not current user' do
    scenario 'upload container is not visible' do
      visit user_path(user)

      within('.avatar_container') do
        expect(page).not_to have_css('.avatar_upload_container')
      end
    end
  end

  def upload_avatar(image)
    visit user_path(user)

    within('.avatar_container') do
      attach_file('avatar', image, visible: false)
    end
  end
end
