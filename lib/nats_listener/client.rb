require 'nats/io/client'

module NatsListener
  class Client

    attr_reader :service_name, :logger, :skip, :catch_errors, :catch_provider

    def self.current
      @current ||= NatsListener::Client.new
    end

    def self.current=(value)
      @current = value
    end

    # Use this opts:
    # @!attribute logger - logger used in this service
    # @!attribute skip - flag attribute used to skip connections(useful for testing)
    # @!attribute catch_errors - used to catch errors around subscribers/connections(be careful with it!)
    # @!attribute catch_provider - this class will be called with catch_provider.error(e)
    # @!attribute disable_nats - if something is passed to that attribute - nats won't be initialized

    def initialize(opts = {})
      @nats = ::NATS::IO::Client.new unless opts[:disable_nats].present? # Create nats client
      @logger = opts[:logger]
      @skip = opts[:skip] || false
      @catch_errors = opts[:catch_errors] || false
      @catch_provider = opts[:catch_provider]
    end

    def establish_connection(config)
      return if skip
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
    def publish(subject, message)
      with_connection do
        log(action: :publish, message: message)
        @nats.publish(subject, message)
      end
    end

    def request(subject, message, opts = {})
      with_connection do
        log(action: :request, message: message)
        @nats.request(subject, message, opts)
      end
    end

    def log(action:, message:)
      logger.log(service: client.service_name, action: action, message: message) if logger
    end

    private

    def with_connection
      return if skip
      begin
        if @nats.status.zero?
          servers = ENV.fetch('NATS_SERVERS', 'nats://127.0.0.1:4222').split(',')
          establish_connection(servers: servers)
        end
        yield
      rescue StandardError => exception
        if catch_errors
          log(action: :error, message: exception)
          catch_provider.error(exception) if catch_provider
        else
          raise exception
        end
      end
    end
  end
end
