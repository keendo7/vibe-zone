require 'rails_helper'

RSpec.describe UserFriendshipRequestAcceptedJob, type: :job do
  Sidekiq::Testing.fake! do
    describe '#perform' do
      let(:sender) { User.new }
      let(:recipient) { User.new }
      
      it 'enqueues friendship request accepted job' do
        described_class.perform_async(sender.id, recipient.id)
        expect(described_class.jobs.size).to eq(1)
      end
    end
  end
end