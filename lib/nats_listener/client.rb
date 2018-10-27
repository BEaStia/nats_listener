# frozen_string_literal: true

require 'nats/io/client'
require 'nats_listener_core'

module NatsListener
  # Client for nats implementation
  class Client < NatsListenerCore::AbstractClient
    # Use this opts:
    # @!attribute :logger - logger used in this service
    # @!attribute :skip - flag attribute used to skip connections(useful for testing)
    # @!attribute :catch_errors - used to catch errors around subscribers/connections(be careful with it!)
    # @!attribute :catch_provider - this class will be called with catch_provider.error(e)
    # @!attribute :disable_nats - if something is passed to that attribute - nats won't be initialized

    def initialize(opts = {})
      @nats = ::NATS::IO::Client.new unless opts[:disable_nats] # Create nats client
      @logger =  NatsListenerCore::ClientLogger.new(opts)
      @skip = opts[:skip] || false
      @client_catcher =  NatsListenerCore::ClientCatcher.new(opts)
    end

    # @!method Establish connection with nats server
    # @!attribute :service_name - Name of current service
    # @!attribute :nats - configuration of nats service
    def establish_connection(opts)
      return if skip

      @config = opts.to_h
      begin
        @nats.connect(config) # Connect nats to provided configuration
        true
      rescue StandardError => exception
        log(action: :connection_failed, message: exception)
        false
      end
    end

    def request(subject, message, opts = {})
      with_connection do
        log(action: :request, message: message)
        nats.request(subject, message, opts)
      end
    end

    def reestablish_connection
      establish_connection(config) if nats&.status.to_i.zero?
    end
  end
end
