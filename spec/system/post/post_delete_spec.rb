require 'rails_helper'

RSpec.describe 'Delete post' do
  let(:user) { create :user }
  let(:post) { create :post }
  let(:authored_post) { create :post, author: user }

  before do
    login_as(user)
  end

  scenario 'when user is an author' do
    visit post_path(authored_post)

    within "##{dom_id(authored_post)}" do
      find('#dropdownMenuLink').click
      click_button 'Delete'
    end

    expect(page).to have_content('Post was successfully deleted')
    expect(page).to have_current_path(root_path)
  end

  scenario 'when user is not an author' do
    visit post_path(post)

    within "##{dom_id(post)}" do
      expect(page).not_to have_css('#dropdownMenuLink')
    end
  end
end
