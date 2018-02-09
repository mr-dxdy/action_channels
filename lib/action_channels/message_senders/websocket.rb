module ActionChannels
  module MessageSenders
    class WebSocket < Base
      def do_send(receiver, message)
        receiver.text message.to_raw
      end
    end
  end
end
