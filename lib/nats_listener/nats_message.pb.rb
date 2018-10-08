# encoding: utf-8

##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf'

module NatsListener
  ::Protobuf::Optionable.inject(self) { ::Google::Protobuf::FileOptions }

  ##
  # Message Classes
  #
  class NatsMessage < ::Protobuf::Message; end


  ##
  # Message Fields
  #
  class NatsMessage
    required :string, :sender_service_name, 1
    required :string, :receiver_action_name, 2
    repeated :string, :receiver_action_parameters, 3
    required :int64, :message_timestamp, 4
    required :string, :transaction_id, 5
  end

end

