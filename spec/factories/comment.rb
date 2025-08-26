FactoryBot.define do
  factory :comment do
    association :commenter, factory: :user
    association :commentable, factory: :post
    content { 'content' }
    parent_id { nil }

    trait :with_reply do
      after(:create) do |comment|
        create(:comment, parent_id: comment.id, content: 'reply', commenter: comment.commenter,
                         commentable: comment.commentable)
      end
    end
  end
end