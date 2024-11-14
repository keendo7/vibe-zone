FactoryBot.define do
  factory :comment do
    association :commenter, factory: :user
    association :commentable, factory: :post
    content { 'content' }
  end
end