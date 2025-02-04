require 'rails_helper'

RSpec.describe CleanupNotificationsJob, type: :job do
  Sidekiq::Testing.fake! do
    describe '#perform' do
      it 'enqueues cleanup notifications job' do
        described_class.perform_async()
        expect(described_class.jobs.size).to eq(1)
      end
    end
  end
end
