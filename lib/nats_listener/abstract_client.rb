# frozen_string_literal: true

require_relative './client_logger'
require_relative './client_catcher'

module NatsListener
  # Abstract client for nats and nats-streaming connections
  class AbstractClient
    # @!method Accessor to singleton object of nats client
    def self.current
      @current ||= self.class.new
    end

    def self.current=(value)
      @current = value
    end

    attr_reader :logger, :skip, :nats, :config, :client_catcher

    def log(action:, message:)
      logger.log(
        action: action,
        message: message,
        service_name: service_name,
        )
    end

    def with_connection
      return if skip

      begin
        reestablish_connection
        yield
      rescue StandardError => exception
        on_rescue(exception)
      end
    end

    def on_rescue(exception)
      log(action: :error, message: exception)
      client_catcher.call(exception)
    end

    # Raw method to publish subject to data
    def publish(subject, message)
      with_connection do
        log(action: :publish, message: message)
        nats.publish(subject, message)
      end
    end

    # Raw method, beware of using it in favor of Subscribers objects
    def subscribe(subject, opts, &callback)
      with_connection do
        nats.subscribe(subject, opts, &callback)
      end
    end

    # Raw method, beware of using it in favor of Subscribers objects
    def unsubscribe(sid)
      with_connection do
        nats.unsubscribe(sid)
      end
    end

    def service_name
      return unless config

      config.fetch(:service_name) { :service_name }
    end
  end
end
