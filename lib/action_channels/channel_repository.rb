module ActionChannels
  class ChannelRepository
    def initialize(channels = [])
      @channels = Set.new channels
    end

    def all
      channels.to_a
    end

    def find_by_name(channel_name)
      channels.find { |channel| channel.name.eql? channel_name }
    end

    def find_by_name_or_create(channel_name)
      find_by_name(channel_name) || create(channel_name)
    end

    def add(channel)
      channels.add channel
    end

    def delete(channel)
      channels.delete channel
    end

    private

    attr_reader :channels

    def create(channel_name)
      channel = Channel.new name: channel_name
      channels << channel
      channel
    end
  end
end
