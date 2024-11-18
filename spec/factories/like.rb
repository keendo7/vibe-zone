FactoryBot.define do
  factory :like do
    user
  
    trait :for_comment do
      association :likeable, factory: :comment
    end

    trait :for_post do
      association :likeable, factory: :post
    end
  end
end