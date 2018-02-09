require 'json'

module ActionChannels
  class Message
    attr_accessor(
      :channel, # [String]
      :type, # [String]
      :author, # [WebSocket::Driver]
      :details # Hash
    )

    class << self
      def parse(message_raw)
        command_json  = JSON.parse message_raw

        new(
          channel: command_json['channel'],
          type: command_json['type'],
          details: command_json.fetch('details', {})
        )
      rescue JSON::ParserError => exp
        raise Errors::NotParseMessage, exp.message
      end

      def parse_and_setup_author(message_raw, author)
        command = parse(message_raw)
        command.author = author
        command
      end
    end

    def initialize(channel:, type:, author: nil, details: {})
      @channel = channel
      @type = type
      @author = author
      @details = details
    end

    def to_raw
      JSON.generate(channel: channel, type: type, details: details)
    end
  end
end
