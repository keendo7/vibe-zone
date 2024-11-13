FactoryBot.define do
  factory :post do
    association :author, factory: :user
    content { 'content' }
  end
end