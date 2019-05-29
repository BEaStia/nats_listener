require 'spec_helper'

RSpec.describe NatsListener::Client do
  describe '.initialize' do
    context 'with mock' do
      let(:new_client) { NatsListener::Client.new }
      before { allow(NatsListener::Client).to receive(:current).and_return(new_client) }
      subject { described_class.current }

      it 'should return nats listener' do
        expect(described_class.current.class).to eq described_class
      end

      it 'should create client instance' do
        subject
        expect(NatsListener::Client).to have_received(:current)
      end
    end
  end

  describe '#establish_connection' do
    let(:service_name) { 'service_1' }
    let(:client) { described_class.new }

    before { allow_any_instance_of(::NATS::IO::Client).to receive(:connect).and_return(true) }

    subject { client.establish_connection(service_name: service_name) }

    it 'should set service name' do
      expect { subject }.to change { client.service_name }.from(nil)
    end

    context 'without errors' do
      before { allow_any_instance_of(::NATS::IO::Client).to receive(:connect).and_return(true) }

      it 'should set service name' do
        expect { subject }.to change { client.service_name }.from(nil)
      end

      it 'should return true' do
        expect(subject).to be_truthy
      end
    end

    context 'with received error' do
      before do
        allow_any_instance_of(::NATS::IO::Client).to receive(:connect).and_raise(StandardError.new)
        allow(client).to receive(:log).and_return(true)
      end

      it 'should raise error' do
        expect(subject).to be_falsey
      end
    end
  end

  describe '#subscribe' do
    let(:service_name) { 'service_1' }
    let(:client) do
      described_class.new
    end
    let(:topic) { 'topic' }

    subject do
      client.subscribe(topic, {}) { |_m, _r, _s| }
    end

    it 'should not fail' do
      # This test will fail if real nats is not working. To run it use ```docker run -p 4444:4444 -p 4222:4222 nats -p 4444```
      expect { subject }.not_to raise_exception
    end

    context 'with mock' do
      before do
        allow_any_instance_of(::NATS::IO::Client).to receive(:connect).and_return(true)
        allow_any_instance_of(::NATS::IO::Client).to receive(:subscribe).and_return(true)
      end

      it 'should subscribe' do
        expect(subject).to be_truthy
      end
    end
  end

  describe '#request' do
    let(:service_name) { 'service_1' }
    let(:client) do
      client = described_class.new
      client.establish_connection(
          service_name: 'client_id',
          nats: { servers: ['nats://127.0.0.1:4222']}
      )
      client
    end
    let(:topic) { 'topic' }

    context 'with mock' do
      before do
        allow_any_instance_of(::NATS::IO::Client).to receive(:connect).and_return(true)
        allow_any_instance_of(::NATS::IO::Client).to receive(:request).and_return(true)
      end
      subject { client.request(topic, 'Hi, there!', {}) {|x| p x} }

      it 'should call #with_connection' do
        expect { subject }.not_to raise_exception
      end
    end

    context 'with real connection' do
      let(:messager) { double }

      subject { client.request(topic, 'Hi, there!', {}) {|x| messager.notify(x)} }

      before do
        allow(messager).to receive(:notify).with('request_packet:response_packet').and_return(true)
      end

      it 'should call #with_connection' do
        expect { subject }.not_to raise_exception
      end

      it 'should print message' do
        client.subscribe(topic, {}) do |msg, reply, _subject|
          client.publish(reply, "#{msg}:response_packet")
        end

        client.request(topic, 'request_packet', max: 5) { |response| messager.notify(response) }

        sleep(1)

      end
    end
  end
end
