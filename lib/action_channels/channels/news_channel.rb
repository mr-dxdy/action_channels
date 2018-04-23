module ActionChannels
  module Channels
    class NewsChannel < Base
      def process_custom_message(message)
        case message.type
        when 'publish'
          on_publish message.author, message.details
        else
          on_unknown_type_message message
        end
      end

      private

      def on_publish(speaker, details)
        notify_all Message.new(channel: name, type: 'news', details: details)
        send_message speaker, Message.new(channel: name, type: 'published')
      end
    end
  end
end
