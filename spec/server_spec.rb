require 'spec_helper'

RSpec.describe ActionChannels::Server do
  let(:url) do
    "ws://www.example.com/socket"
  end

  let(:port) { 5070 }

  describe '#process_client' do
    let(:messages) { [] }

    let :socket do
      socket = double(WebSocket)
      allow(socket).to receive(:write) do |message|
        # Nothing
      end
      allow(socket).to receive(:url).and_return(url)
      socket
    end

    let(:client) do
      WebSocket::Driver::Client.new socket
    end

    it 'should process valid message' do
      expect(client).to receive(:text) do |message_raw|
        expect(message_raw).to eq('{"channel":"games","type":"subscribed","details":{}}')
      end

      described_class.new(port: port).process_client(client)
      client.emit :message, WebSocket::Driver::MessageEvent.new('{"channel":"games", "type":"subscribe"}')
    end

    it 'should process invalid message' do
      expect(client).to receive(:text) do |message_raw|
        expect(message_raw).to eq('{"channel":"","type":"bad_request","details":{}}')
      end

      described_class.new(port: port).process_client(client)
      client.emit :message, WebSocket::Driver::MessageEvent.new('random text')
    end

    it 'should remove client after connection closed' do
      server = described_class.new(port: port)
      channel = server.channel_repository.find_by_name_or_create 'custom_channel'
      channel.add_client client
      expect(channel.clients.to_a).to eq([client])

      server.process_client(client)
      client.emit :close, WebSocket::Driver::CloseEvent.new
      expect(channel.clients).to be_empty
    end
  end
end
