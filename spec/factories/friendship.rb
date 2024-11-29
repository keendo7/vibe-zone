FactoryBot.define do
  factory :friendship do
    association :user, factory: :user
    association :friend, factory: :user

    trait :for_mutual do
      after(:create) do |friendship|
        create(:friendship, user: friendship.friend, friend: friendship.user)
      end
    end
  end
end