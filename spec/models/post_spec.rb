require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'relationships' do
    it { is_expected.to belong_to(:author).class_name("User") }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to have_many(:notifications).dependent(:destroy) }
    it { is_expected.to have_many(:likes).dependent(:destroy) }
  end

  describe 'validates content' do
    it { is_expected.to validate_length_of(:content) }
    it { is_expected.not_to allow_value('').for(:content) }
    it { is_expected.not_to allow_value('x' * 201).for(:content) }
    it { is_expected.to allow_value("content").for(:content) }
  end

  describe '.search_post' do
    let!(:post1) { create(:post, content: 'post1') }
    let!(:post2) { create(:post, content: 'post2') }
    
    context 'with query which returns all posts' do
      it { expect(described_class.search_post('post')).to eq([post1, post2]) }
    end

    context 'with query which matches posts name' do
      it { expect(described_class.search_post('post2')).to eq([post2]) }
    end

    context 'with empty query' do
      it { expect(described_class.search_post('')).to eq([post1, post2]) }
    end

    context 'with mixed case query' do
      it { expect(described_class.search_post('PoSt')).to eq([post1, post2]) }
    end
  end
end