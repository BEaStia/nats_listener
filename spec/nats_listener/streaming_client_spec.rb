require 'spec_helper'

RSpec.describe NatsListener::StreamingClient do
  describe '.current' do
    context 'with mock' do
      let(:new_client) { NatsListener::StreamingClient.new }
      before { allow(NatsListener::StreamingClient).to receive(:current).and_return(new_client) }
      subject { described_class.current }

      it 'should return nats listener' do
        expect(described_class.current.class).to eq described_class
      end

      it 'should create client instance' do
        subject
        expect(NatsListener::StreamingClient).to have_received(:current)
      end
    end
  end

  describe '#establish_connection' do
    let(:service_name) { 'service_1' }
    let(:client) { described_class.new }

    before { allow_any_instance_of(::STAN::Client).to receive(:connect).and_return(true) }

    subject { client.establish_connection(service_name: service_name) }

    it 'should set service name' do
      expect { subject }.to change { client.service_name }.from(nil)
    end
  end

  describe '#subscribe' do
    let(:service_name) { 'service_1' }
    let(:client) { described_class.new(cluster_name: 'worki_cluster') }
    let(:topic) { 'topic' }

    subject do
      client.subscribe(topic, {start_at: :last_received}) { |_m, _r, _s| }
    end

    it 'should not fail' do
      # This test will fail if real nats is not working. To run it use ```docker run -p 4444:4444 -p 4222:4222 nats -p 4444```
      expect { subject }.not_to raise_exception
    end

    context 'with mock' do
      before do
        allow_any_instance_of(::STAN::Client).to receive(:connect).and_return(true)
        allow_any_instance_of(::STAN::Client).to receive(:subscribe).and_return(true)
      end

      it 'should subscribe' do
        expect(subject).to be_truthy
      end
    end
  end
end