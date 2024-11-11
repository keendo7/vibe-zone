require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'relationships' do
    it { is_expected.to have_many(:authored_posts).class_name("Post").dependent(:destroy).with_foreign_key(:author_id)}
    it { is_expected.to have_many(:created_comments).class_name("Comment").dependent(:destroy).with_foreign_key(:commenter_id)}
    it { is_expected.to have_many(:friendships).dependent(:destroy) }
    it { is_expected.to have_many(:friends).through(:friendships) }
    it { is_expected.to have_many(:received_friendships).class_name("Friendship").dependent(:destroy).with_foreign_key(:friend_id) }
    it { is_expected.to have_many(:received_friends).through(:received_friendships) }
    it { is_expected.to have_many(:likes).dependent(true) }
    it { is_expected.to have_many(:notifications).dependent(:destroy) }
    it { is_expected.to have_one_attached(:avatar) }
  end

  describe 'validations' do
    subject { FactoryBot.create(:user) }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
  end

  describe 'validates first_name' do
    it { is_expected.to allow_value('first-name').for(:first_name) }
    it { is_expected.to_not allow_value('f1r5t-n4m3').for(:first_name) }
    it { is_expected.to_not allow_value('x').for(:first_name) }
  end

  describe 'validates last_name' do
    it { is_expected.to allow_value('last-name').for(:last_name) }
    it { is_expected.to_not allow_value('l4st-n4m3').for(:last_name) }
    it { is_expected.to_not allow_value('x').for(:last_name) }
  end

  describe 'validates email' do
    it { is_expected.to allow_value('example@example.com').for(:email) }
    it { is_expected.to allow_value('example_example@example.com').for(:email) }
    it { is_expected.to allow_value('example-example@example.com').for(:email) }
    it { is_expected.not_to allow_value('exampłe@example.com').for(:email) }
    it { is_expected.not_to allow_value('example@exampłe.com').for(:email) }
    it { is_expected.not_to allow_value('example.com').for(:email) }
  end

  describe '.search' do
    before do
      create :user, first_name: 'Firstname', last_name: 'Lastname', email: 'example1@example.com'
      create :user, first_name: 'Firstnamea', last_name: 'Lastnamea', email: 'example2@example.com'
      create :user, first_name: 'Firstnameb', last_name: 'Lastnameb', email: 'example3@example.com'
    end

    context 'with query which returns all users' do
      it { expect(described_class.search('firstname').count).to eq(3) }
    end

    context 'with query which returns exactly one user' do
      it { expect(described_class.search('lastnameb').count).to eq(1) }
    end

    context 'with query which does not match any user' do
      it { expect(described_class.search('bogdan').count).to eq(0) }
    end

    context 'with query which has mixed case' do
      it { expect(described_class.search('lAsTnAmE').count).to eq(3) }
    end

    context 'with query which is a part of last name' do
      it { expect(described_class.search('lastnameb').count).to eq(1) }
    end

    context 'with query which is a full name' do
      it { expect(described_class.search('firstnameb lastnameb').count(1)).to eq(1) }
    end

    context 'with empty query' do
      it { expect(described_class.search('').count).to eq(3) }
    end
  end

  describe '#full_name' do
    let(:user) { build :user }
    let(:expected_result) { "#{user.first_name} #{user.last_name}" }

    it { expect(user.full_name).to eq(expected_result) }
  end

  describe '#active_friends' do
    let(:user1) { build :user }
    let(:user2) { build :user }

    before do
      user1.friends << user2
      user2.friends << user1
    end

    it { expect(user1.active_friends).to eq([user2]) }
  end

  describe '#pending_friends' do
    let(:user1) { build :user }
    let(:user2) { build :user }

    before do
      user1.friends << user2
    end

    it { expect(user1.pending_friends).to eq([user2]) }
  end

  describe '#mutual_friends' do
    let(:user1) { create :user }
    let(:user2) { create :user }
    let(:user3) { create :user }
    let(:user4) { create :user }

    before do
      user1.friendships.create(friend: user2)
      user1.friendships.create(friend: user3)
      user1.friendships.create(friend: user4)

      user2.friendships.create(friend: user4)
      user2.friendships.create(friend: user1)

      user3.friendships.create(friend: user4)
      user3.friendships.create(friend: user1)
    end

    context 'when users have 1 mutual friend' do
      it { expect(user1.mutual_friends(user2).first.friend).to eq(user4) }
    end
    
    context 'when users have multiple mutual friends' do 
      it { expect(user2.mutual_friends(user3).count).to eq(2) }
    end

    context 'when users have no mutual friends' do
      it { expect(user1.mutual_friends(user4)).to eq([]) }
    end
  end
end