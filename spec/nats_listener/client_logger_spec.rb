require 'spec_helper'

RSpec.describe NatsListener::ClientLogger do
  let(:logger) { double(:stub, info: ->(msg) { :info } ) }

  let(:opts) { { logger: logger } }

  describe '.initialize' do
    subject { described_class.new(opts) }

    context 'with logger' do
      it 'should set logger' do
        expect(subject.logger).to eq logger
      end
    end
  end

  describe '#log' do
    let(:obj) { described_class.new(opts) }
    subject { obj.log(action: 'action', message: 'msg', service_name: 'service') }

    context 'with logger' do
      it 'should call info' do
        expect(logger).to receive(:info)
        subject
      end
    end

    context 'without logger' do
      let(:logger) { nil }

      it 'should not call info' do
        expect(logger).not_to receive(:info)
        subject
      end
    end
  end
end
