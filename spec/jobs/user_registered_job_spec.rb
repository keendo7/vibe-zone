RSpec.describe UserRegisteredJob, type: :job do
  Sidekiq::Testing.fake! do
    describe '#perform' do
      let(:user) { User.new }
      
      it "enqueues user registered job" do
        described_class.perform_async(user.id)
        expect(described_class.jobs.size).to eq(1)
      end
    end
  end
end