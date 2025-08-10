require 'rails_helper'

RSpec.describe Like, type: :model do
  subject { FactoryBot.create(:like, :for_comment) }

  describe 'relationships' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:likeable) }
    it { is_expected.to have_many(:notifications).dependent(:destroy) }
  end

  describe 'validations' do
    it {
      expect(subject).to validate_uniqueness_of(:user_id)
      .scoped_to([:likeable_id, :likeable_type])
      .with_message('can only like this item once.')
    }
  end
end