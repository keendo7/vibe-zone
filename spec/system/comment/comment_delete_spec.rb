require 'rails_helper'

RSpec.describe "Delete comment" do
  let(:user) { create :user }
  let(:post) { create :post, author: user, content: 'regular ass post' }

  before do
    login_as(user)
  end

  context 'with no replies' do
    let!(:comment) { create :comment, commenter: user, commentable: post, content: 'first comment' }

    scenario 'remove parent comment' do
      visit post_path(post)

      within("turbo-frame#comment_#{comment.id}") do
        page.find('#dropdownMenuLink').click
        click_button 'Delete'
      end

      expect(page).to have_current_path(post_path(post))
      expect(page).not_to have_css("turbo-frame#comment_#{comment.id}")
    end
  end

  context 'with replies' do
    let!(:comment) { create :comment, :with_reply, commenter: user, commentable: post, content: 'first comment' }

    scenario 'remove child' do
      visit post_path(post)
      click_button '1 reply'

      within("turbo-frame#replies_comment_#{comment.id}") do
        page.find('#dropdownMenuLink').click
        
        click_button 'Delete'
      end
      
      expect(page).to have_current_path(post_path(post))
      expect(page).to have_css("turbo-frame#comment_#{comment.id}")
      expect(page).not_to have_button('1 reply')
    end
  end
end
