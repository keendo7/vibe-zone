require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'relationships' do
    it { is_expected.to belong_to(:commenter).class_name("User") }
    it { is_expected.to belong_to(:commentable) }
    it { is_expected.to belong_to(:parent).class_name("Comment").with_foreign_key(:parent_id).optional(:true) }
    it { is_expected.to have_many(:likes).dependent(:destroy) }
    it { is_expected.to have_many(:replies).class_name("Comment").with_foreign_key(:parent_id).dependent(:destroy) }
    it { is_expected.to have_many(:notifications).dependent(:destroy) }
  end

  describe 'validates content' do
    it { is_expected.to validate_length_of(:content) }
    it { is_expected.not_to allow_value('').for(:content) }
    it { is_expected.not_to allow_value('x' * 251).for(:content) }
    it { is_expected.to allow_value("content").for(:content) }
  end

  describe '.of_parents' do
    context 'when parent comment exists' do
      let!(:parent_comment) { create(:comment) }
      it { expect(described_class.of_parents).to eq([parent_comment]) }
      it { expect(parent_comment.parent_id).to be nil }
    end
  end
end