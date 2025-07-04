require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:user1) { create :user }
  let(:user2) { create :user }

  describe 'relationships' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:sender).class_name("User") }
    it { is_expected.to belong_to(:notifiable) }
  end

  describe '#is_a_friend_request? and #is_a_friendship?' do
    context 'when notifiable_type does not equal Friendship' do
      let!(:notification) { create(:notification, :for_comment, sender: user1, user: user2) }
      it { expect(notification.is_a_friend_request?).to be false }
      it { expect(notification.is_a_friendship?).to be false }
    end

    context 'when user1 is not a friend of user2' do
      let!(:friendship) { create(:friendship, user: user1, friend: user2) }
      let!(:notification) { create(:notification, :for_friendship, sender: user1, user: user2, notifiable: friendship) }
      it { expect(notification.is_a_friend_request?).to be true }
      it { expect(notification.is_a_friendship?).to be false }
    end

    context 'when user1 is a friend of user2' do
      let!(:friendship) { create(:friendship, :for_mutual, user: user1, friend: user2) }
      let!(:notification) { create(:notification, :for_friendship, sender: user1, user: user2, notifiable: friendship) }
      
      it { expect(notification.is_a_friend_request?).to be false }
      it { expect(notification.is_a_friendship?).to be true }
    end
  end

  describe '#is_a_comment?' do
    context 'when notifiable_type is a comment' do
      let!(:notification) { build(:notification, :for_comment, sender: user1, user: user2) }
      it { expect(notification.is_a_comment?).to be true }
    end

    context 'when notifiable_type is not a comment' do
      let!(:notification) { build(:notification, :for_like, sender: user1, user: user2) }
      it { expect(notification.is_a_comment?).to be false }
    end
  end

  describe '#is_a_like?' do
    context 'when notifiable_type is a like' do
      let!(:notification) { build(:notification, :for_like, sender: user1, user: user2) }
      it { expect(notification.is_a_like?).to be true }
    end

    context 'when notifiable_type is not a like' do
      let!(:notification) { build(:notification, :for_comment, sender: user1, user: user2) }
      it { expect(notification.is_a_like?).to be false }
    end
  end

  describe '#read' do
    let!(:notification) { build(:notification, sender: user1, user: user2) }
    context 'when notification was not read' do
      it { expect(notification.was_read).to be false }
    end

    context 'when notification was read' do
      before do
        notification.read
      end

      it { expect(notification.was_read).to be true }
    end
  end

  describe ".deprecated" do
    context 'when notification was created at least 7 days ago and was read' do
      let!(:notification) { create(:notification, :for_comment, :was_read, sender: user1, user: user2, created_at: 7.days.ago) }
      it { expect(described_class.deprecated).to eq([notification]) }
    end
    
    context 'when notification was created at least 7 days ago and was not read' do
      let!(:notification) { create(:notification, :for_comment, sender: user1, user: user2, created_at: 7.days.ago) }
      it { expect(described_class.deprecated).to eq([]) }
    end

    context 'when notification was created earlier than 7 days ago and was read' do
      let!(:notification) { create(:notification, :for_comment, :was_read, sender: user1, user: user2, created_at: 6.days.ago) }
      it { expect(described_class.deprecated).to eq([]) }
    end

    context 'when notification was created earlier than 7 days ago and was not read' do
      let!(:notification) { create(:notification, :for_comment, sender: user1, user: user2, created_at: 6.days.ago) }
      it { expect(described_class.deprecated).to eq([]) }
    end
  end

  describe 'callbacks' do
    context 'on create' do
      let!(:notification) { build(:notification, :for_comment, sender: user1, user: user2) }

      it 'calls broadcast_notifications_count_create' do
        allow(notification).to receive(:broadcast_notifications_count_create)
        notification.save!
        expect(notification).to have_received(:broadcast_notifications_count_create)
      end
    end

    context 'on destroy' do
      let!(:notification) { create(:notification, :for_comment, sender: user1, user: user2) }

      it 'calls broadcast_notifications_count_destroy' do
        allow(notification).to receive(:broadcast_notifications_count_destroy)
        notification.destroy
        expect(notification).to have_received(:broadcast_notifications_count_destroy)
      end
    end
  end
end