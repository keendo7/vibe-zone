require 'rails_helper'

RSpec.describe 'Upload banner', js: true do
  let(:user) { create :user }
  let(:other_user) { create :user }
  let(:banner_image_path) { Rails.root.join('spec/fixtures/files/banner1.png') }
  let(:invalid_banner) do
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
      upload_banner(banner_image_path)

      expect(page).to have_content I18n.t('messages.user.banner_updated')
      expect(page.find('#banner')[:src]).to have_content('banner1.png')
    end

    scenario 'with invalid image size' do
      upload_banner(invalid_banner)
      accept_alert

      expect(user.reload.banner).not_to be_attached
    end
  end

  context 'when user is not current_user' do
    scenario 'dropdown is not visible' do
      visit user_path(other_user)
      
      within('.banner_container') do
        expect(page).not_to have_css('#dropdownMenu2')
      end
    end
  end

  def upload_banner(image)
    visit user_path(user)

    within('.banner_container') do
      find('#dropdownMenu2').click
      attach_file('banner', image, visible: false)
    end
  end
end
