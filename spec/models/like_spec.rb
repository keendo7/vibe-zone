require 'rails_helper'

RSpec.describe Like, type: :model do
  describe 'relationships' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:likeable) }
    it { is_expected.to have_many(:notifications)}
  end
end