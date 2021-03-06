# Action channels

## Example

``` ruby
require 'action_channels'

class PingPongChannel < ActionChannels::Channels::Base
  def process_custom_message(message)
    case message.type
    when 'ping'
      send_message message.author, ActionChannels::Message.new(channel: name, type: 'pong')
    when 'pong'
      send_message message.author, ActionChannels::Message.new(channel: name, type: 'ping')
    else
      on_unknown_type_message message
    end
  end
end

server = ActionChannels::Server.new(
  port: 3050,
  channels: [PingPongChannel.new(name: 'ping-pong')]
)

server.run
```
