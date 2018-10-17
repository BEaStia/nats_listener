# frozen_string_literal: true

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message 'NatsListener.NatsMessage' do
    optional :sender_service_name, :string, 1
    optional :receiver_action_name, :string, 2
    repeated :receiver_action_parameters, :string, 3
    optional :message_timestamp, :int64, 4
    optional :transaction_id, :string, 5
  end
end

# Message class offered to be used with protobuf serialization
module NatsListener
  MESSAGE_CLASS = 'NatsListener.NatsMessage'
  NatsMessage = Google::Protobuf::DescriptorPool.generated_pool
                                                .lookup(MESSAGE_CLASS)
                                                .msgclass
end
