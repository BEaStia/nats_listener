require 'stan/client'
require_relative './abstract_client'

module NatsListener
  class StreamingClient < AbstractClient

    def self.current
      @current ||= NatsListener::StreamingClient.new
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
      @nats = STAN::Client.new unless opts[:disable_nats] # Create nats client
      @logger = opts[:logger]
      @skip = opts[:skip] || false
      @catch_errors = opts[:catch_errors] || false
      @catch_provider = opts[:catch_provider]
    end

    def establish_connection(config)
      return if skip
      @config = config
      @service_name = config[:service_name]
      @client_id = config[:client_id]
      begin
        @nats.connect(@client_id, "#{@service_name}-#{@client_id}", config) # Connect nats to provided configuration
      rescue STAN::ConnectError => e
        log(action: :connection_failed, message: e)
        opts = config.dup
        opts[:client_id] = @client_id.to_i + 1
        establish_connection(opts)
      end
    end

    def request(subject, message, opts = {})
      with_connection do
        log(action: :request, message: message)
        @nats.request(subject, message, opts)
      end
    end

    def reestablish_connection
      establish_connection(@config) if nats.nats.status.zero?
    end
  end
end
