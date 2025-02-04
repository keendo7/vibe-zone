FactoryBot.define do
  factory :notification do
    association :user, factory: :user
    association :sender, factory: :user
    was_read { false }

    trait :for_comment do
      association :notifiable, factory: :comment
    end

    trait :for_friendship do
      association :notifiable, factory: :friendship
    end

    trait :for_like do
      association :notifiable, factory: :like
    end

    trait :was_read do
      was_read { true }
    end
  end
end