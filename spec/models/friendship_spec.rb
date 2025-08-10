require 'rails_helper'

RSpec.describe Friendship, type: :model do
  let(:user) { create :user }
  let(:friend) { create :user }

  describe 'relationships' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:friend).class_name("User") }
    it { is_expected.to have_many(:notifications).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:friend_id) }
  end

  describe 'validate uniqueness of user and friend' do
    context 'when user is equal friend' do
      let(:friendship) { build(:friendship, user: user, friend: user) }

      it { expect(friendship).not_to be_valid }
    end

    context 'when user id not equal friend' do
      let(:friendship) { build(:friendship, user: user, friend: friend) }

      it { expect(friendship).to be_valid }
    end
  end

  describe '#is_mutual?' do
    context 'when friendship is not mutual' do
      let(:friendship) { create(:friendship, user: user, friend: friend) }

      it { expect(friendship.is_mutual?).to be false }
    end

    context 'when friendship is mutual' do
      let(:friendship) { create(:friendship, :for_mutual, user: user, friend: friend) }

      it { expect(friendship.is_mutual?).to be true }
    end
  end
end
