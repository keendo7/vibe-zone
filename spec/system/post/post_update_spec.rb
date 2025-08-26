require 'rails_helper'

RSpec.describe 'Update post' do
  let(:user) { create :user }
  let(:updated_content) { 'updated' }
  let(:post_image_path) { Rails.root.join('spec/fixtures/files/avatar1.png') }
  let!(:post) { create :post, author: user }

  before do
    login_as(user)
  end

  scenario 'when user is an author' do
    visit root_path

    click_edit_link(post)
    update_post(post, updated_content, post_image_path)
    validate_post(post, updated_content)
  end

  def click_edit_link(post)
    within "##{dom_id(post)}" do
      find('#dropdownMenuLink').click
      click_link 'Edit'
    end
  end

  def update_post(_post, content, image = nil)
    within '.modal' do
      fill_in 'post_content', with: content
      attach_file('post[image]', image) unless image.nil?
      click_button 'Update Post'
    end
  end

  def validate_post(post, content)
    within "##{dom_id(post)}" do
      expect(page).to have_content content
      expect(page).to have_content 'Edited less than a minute ago'
      expect(page).to have_css('#post-image')
    end
  end
end
