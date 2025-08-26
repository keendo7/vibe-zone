require 'rails_helper'

RSpec.describe 'Create comment' do
  let(:user) { create :user }
  let(:post) { create :post }
  let!(:comment) { create :comment, commenter: user, commentable: post, content: 'first comment' }

  before do 
    login_as(user) 
  end

  context 'with valid content' do
    scenario 'on a post' do
      visit post_path(post)

      fill_in 'comment_content', with: 'comment content'
      click_button 'Create Comment'

      expect(page).to have_current_path(post_path(post))
      expect(page).to have_content('comment content')
    end

    scenario 'reply to a comment' do
      visit post_path(post)
      click_button 'Reply'
      
      within("turbo-frame#comment_#{comment.id}") do
        fill_in 'comment_content', with: 'reply content'
        click_button 'Create Comment'
      end

      expect(page).to have_current_path(post_path(post))
      expect(page).to have_button '1 reply'
    end
  end
end
