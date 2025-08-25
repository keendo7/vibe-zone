FactoryBot.define do
  factory :user do
    first_name { 'firstname' }
    last_name { 'lastname' }
    password { 'password123#' }
    password_confirmation { 'password123#' }
    sequence(:email) { |n| "user#{n}@example.com" }

    trait :with_avatar do
      avatar { Rack::Test::UploadedFile.new("spec/fixtures/files/avatar1.png", "image/png") }
    end

    trait :with_banner do
      banner { Rack::Test::UploadedFile.new("spec/fixtures/files/banner1.png", "image/png") }
    end
  end
end
