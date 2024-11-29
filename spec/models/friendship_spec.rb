require 'rails_helper'

RSpec.describe Friendship, type: :model do
  let(:user1) { create :user }
  let(:user2) { create :user }

  describe 'relationships' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:friend).class_name("User") }
    it { is_expected.to have_many(:notifications).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:friend_id) }
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:friend_id) }
  end

  describe 'validate uniqueness of user and friend' do
    context 'when user is equal friend' do
      let(:friendship) { build(:friendship, user: user1, friend: user1) }
      it { expect(friendship).not_to be_valid }
    end

    context 'when user id not equal friend' do
      let(:friendship) { build(:friendship, user: user1, friend: user2) }
      it { expect(friendship).to be_valid }
    end
  end

  describe '#is_mutual' do
    context 'when friendship is not mutual' do
      let(:friendship) { create(:friendship, user: user1, friend: user2) }
      it { expect(friendship.is_mutual).to be false }
    end

    context 'when friendship is mutual' do
      let(:friendship) { create(:friendship, :for_mutual, user: user1, friend: user2) }
      it { expect(friendship.is_mutual).to be true }
    end
  end

  describe '.remove_friendship' do
    context 'when friendship is not mutual' do
      let!(:friendship) { create(:friendship, user: user1, friend: user2) }
      it 'removes the friendship and decreases count by 1' do
        expect { described_class.remove_friendship(friendship) }.to change { described_class.count }.by(-1)
      end
    end

    context 'when friendship is mutual' do
      let!(:friendship) { create(:friendship, :for_mutual, user: user1, friend: user2) }
      it 'removes both friendships and decreases cound by 2' do
        expect { described_class.remove_friendship(friendship) }.to change { described_class.count }.by(-2)
      end
    end
  end
end