require 'nats/io/client'

module NatsListener
  class Client

    attr_reader :service_name

    def self.current
      @current ||= NatsListener::Client.new
    end

    def self.current=(value)
      @current = value
    end

    def initialize
      @nats = ::NATS::IO::Client.new # Create nats client
    end

    def establish_connection(config)
      @nats.connect(config) # Connect nats to provided configuration
      @service_name = config[:service_name]
    end

    # Raw method, beware of using it in favor of Subscribers objects
    def subscribe(subject, &callback)
      with_connection do
        @nats.subscribe(subject, {}, &callback)
      end
    end

    # Raw method, beware of using it in favor of Subscribers objects
    def unsubscribe(sid)
      with_connection do
        @nats.unsubscribe(sid)
      end
    end

    # Raw method to publish subject to data
    def publish(subject, data)
      with_connection do
        @nats.publish(subject, data)
      end
    end

    def request(subject, message, opts = {})
      with_connection do
        @nats.request(subject, message, opts)
      end
    end

    private

    def with_connection
      servers = ENV.fetch('NATS_SERVERS', 'nats://127.0.0.1:4222').split(',')
      establish_connection(servers: servers) if @nats.status.zero?
      yield
    end
  end
end
