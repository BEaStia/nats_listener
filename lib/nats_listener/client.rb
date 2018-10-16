require 'nats/io/client'
require_relative './abstract_client'

module NatsListener
  class Client < AbstractClient
    def self.current
      @current ||= NatsListener::Client.new
    end

    class << self
      attr_writer :current
    end

    # Use this opts:
    # @!attribute logger - logger used in this service
    # @!attribute skip - flag attribute used to skip connections(useful for testing)
    # @!attribute catch_errors - used to catch errors around subscribers/connections(be careful with it!)
    # @!attribute catch_provider - this class will be called with catch_provider.error(e)
    # @!attribute disable_nats - if something is passed to that attribute - nats won't be initialized

    def initialize(opts = {})
      @nats = ::NATS::IO::Client.new unless opts[:disable_nats] # Create nats client
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

    def request(subject, message, opts = {})
      with_connection do
        log(action: :request, message: message)
        @nats.request(subject, message, opts)
      end
    end

    def reestablish_connection
      if @nats.status.zero?
        servers = ENV.fetch('NATS_SERVERS', 'nats://127.0.0.1:4222').split(',')
        establish_connection(servers: servers)
      end
    end
  end
end
