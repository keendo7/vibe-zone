require 'rails_helper'

RSpec.describe 'Submit post' do
  let(:user) { create :user }
  let(:post_image_path) { Rails.root.join('spec/fixtures/files/avatar1.png') }

  before do
    login_as(user)
  end

  context 'with valid content' do
    let(:post) { build :post }

    scenario 'without image' do
      create_post_with(post.content)

      expect(page).to have_text(post.content)
      expect(page).to have_current_path(post_path(Post.last))
    end

    scenario 'including image' do
      create_post_with(post.content, post_image_path)

      expect(page).to have_text(post.content)
      expect(page.find('#post-image')[:src]).to have_content('avatar1.png')
    end
  end

  context 'with invalid content' do
    scenario 'submit button is disabled' do
      visit root_path
      fill_in 'post_content', with: ''

      expect(find_button('Create Post')[:class]).to include('disabled')
    end
  end

  def create_post_with(content, image = nil)
    visit root_path

    fill_in 'post_content', with: content
    attach_file('post[image]', image) unless image.nil?

    click_button 'Create Post'
  end
end
