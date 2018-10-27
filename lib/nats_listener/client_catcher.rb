# frozen_string_literal: true

module NatsListener
  # Client configuration
  class ClientCatcher
    attr_reader :catch_error, :catch_provider

    def initialize(opts)
      @catch_error = opts[:catch_errors] || false
      @catch_provider = opts[:catch_provider]
    end

    def call(exception)
      raise exception unless catch_error

      catch_provider.error(exception)
    end
  end
end
