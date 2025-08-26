require 'rails_helper'

RSpec.describe 'Update comment' do
  let(:user) { create :user }
  let(:post) { create :post }
  let!(:comment) { create :comment, commenter: user, commentable: post }

  before do
    login_as(user)
  end

  scenario 'with valid params' do
    visit post_path(post)

    within("turbo-frame#comment_#{comment.id}") do
      page.find('#dropdownMenuLink').click
      click_button 'Edit'
    end

    within("#edit-comment-#{comment.id}") do
      fill_in 'comment_content', with: 'updated'
      click_button 'Update Comment'
    end

    expect(page).to have_content 'updated'
    expect(page).to have_content 'Edited less than a minute ago'
  end
end