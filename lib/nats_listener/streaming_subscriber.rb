# frozen_string_literal: true
require_relative './abstract_subscriber'

module NatsListener
  class StreamingSubscriber < AbstractSubscriber
    def client
      NatsListener::StreamingClient.current
    end
  end
end
