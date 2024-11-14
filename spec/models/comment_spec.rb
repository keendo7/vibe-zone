require 'rails_helper'

RSpec.describe Comment, type: :model do
  subject { FactoryBot.create(:comment) }

  describe 'relationships' do
    it { is_expected.to belong_to(:commenter).class_name("User") }
    it { is_expected.to belong_to(:commentable) }
    it { is_expected.to have_many(:likes).dependent(:destroy) }
    it { is_expected.to have_many(:notifications).dependent(:destroy) }
  end

  describe 'validates content' do
    it { is_expected.to validate_length_of(:content) }
    it { is_expected.not_to allow_value('').for(:content) }
    it { is_expected.not_to allow_value('x' * 251).for(:content) }
    it { is_expected.to allow_value("content").for(:content) }
  end
end