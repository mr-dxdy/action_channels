require 'set'
require 'logger'
require 'nio/websocket'

require "action_channels/version"
require "action_channels/errors"
require "action_channels/driver"
require "action_channels/message"
require "action_channels/message_senders"
require "action_channels/client"
require "action_channels/channels"
require "action_channels/channel_repository"
require "action_channels/server"

module ActionChannels
  class << self
    attr_writer :logger

    def configure(&block)
      yield(self)
    end

    def logger
      @logger ||= Logger.new('action_channels.log')
    end
  end
end
