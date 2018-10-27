# frozen_string_literal: true

require 'stan/client'
require_relative './abstract_client'

module NatsListener
  # Implementation of Nats-streaming client
  class StreamingClient < AbstractClient
    # Use this opts:
    # @!attribute :logger - logger used in this service
    # @!attribute :skip - flag attribute used to skip connections(useful for testing)
    # @!attribute :catch_errors - used to catch errors around subscribers/connections(be careful with it!)
    # @!attribute :catch_provider - this class will be called with catch_provider.error(e)
    # @!attribute :disable_nats - if something is passed to that attribute - nats won't be initialized

    def initialize(opts = {})
      @nats = STAN::Client.new unless opts[:disable_nats] # Create nats client
      @logger = ClientLogger.new(opts)
      @skip = opts[:skip] || false
      @client_catcher = ClientCatcher.new(opts)
    end

    # Use this opts for connection:
    # @!attribute :cluster_name - name of nats-streaming cluster that we connect to
    # @!attribute :nats - nats connection info(example: ```{servers: 'nats://127.0.0.1:4223'}```)
    # @!attribute :service_name - name of current service
    # @!attribute :client_id - current service client id(optional)

    def establish_connection(config = {})
      return if skip

      @config = config.to_h
      begin
        # Connect nats to provided configuration
        nats.connect(cluster_name, client_name, config)
        true
      rescue StandardError => exception
        log(action: :connection_failed, message: exception)
        false
      end
    end

    def client_name
      "#{service_name}-#{config.fetch(:client_id) { :client_id }}"
    end

    def cluster_name
      config.fetch(:cluster_name) { :cluster_name }
    end

    def request(subject, message, opts = {})
      with_connection do
        log(action: :request, message: message)
        nats.request(subject, message, opts)
      end
    end

    def disconnected?
      nats&.nats&.status.to_i.zero?
    end

    def reestablish_connection
      establish_connection(config) if disconnected?
    end
  end
end
