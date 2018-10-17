require 'spec_helper'

RSpec.describe NatsListener::StreamingSubscriber do
  describe '.client' do
    context 'with mock' do
      let(:new_client) { NatsListener::StreamingClient.new }
      before { allow(NatsListener::StreamingClient).to receive(:current).and_return(new_client) }
      subject { described_class.client }

      it 'should return nats listener' do
        expect(described_class.client.class).to eq NatsListener::StreamingClient
      end

      it 'should create client instance' do
        subject
        expect(NatsListener::StreamingClient).to have_received(:current)
      end

      it 'should return client' do
        expect(subject).to eq new_client
      end
    end
  end
end
