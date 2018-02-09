require 'set'

require "action_channels/version"
require "action_channels/errors"
require "action_channels/message"
require "action_channels/message_senders"
require "action_channels/channel"
require "action_channels/channel_repository"
require "action_channels/server"

module ActionChannels
  class << self
    attr_accessor :logger

    def configure(&block)
      yield(self)
    end
  end
end
