FactoryBot.define do
  factory :user do
    first_name { 'firstname' }
    last_name { 'lastname' }
    password { 'password123#' }
    password_confirmation { 'password123#' }
    sequence(:email) { |n| "user#{n}@example.com" }
  end
end