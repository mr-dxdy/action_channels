require 'spec_helper'

RSpec.describe ActionChannels::Server do
  let(:url) do
    "ws://www.example.com/socket"
  end

  let(:port) { 5070 }

  it 'add custom channels to server' do
    rss_channel = double(:channel, name: 'RSS channel')
    server = described_class.new(port: port, channels: [rss_channel])

    expect(
      server.channel_repository.find_by_name('RSS channel')
    ).to eq(rss_channel)
  end

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

    context 'should remove client' do
      let(:server) { described_class.new(port: port)  }
      let(:channel) { server.channel_repository.find_by_name_or_create 'custom_channel' }

      before do
        channel.add_client client
      end

      it 'after connection closed' do
        expect(channel.clients.to_a).to eq([client])

        server.process_client(client)
        client.emit :close, WebSocket::Driver::CloseEvent.new
        expect(channel.clients).to be_empty
      end

      it 'after error' do
        expect(channel.clients.to_a).to eq([client])

        server.process_client(client)
        client.emit :error, WebSocket::Driver::ProtocolError.new('Not a WebSocket request')
        expect(channel.clients).to be_empty
      end

      it 'after io_error without arguments' do
        expect(channel.clients.to_a).to eq([client])

        server.process_client(client)
        client.emit :io_error
        expect(channel.clients).to be_empty
      end

      it 'after io_error with argument' do
        expect(channel.clients.to_a).to eq([client])

        server.process_client(client)
        client.emit :io_error, WebSocket::Driver::ProtocolError.new('Not a WebSocket request')
        expect(channel.clients).to be_empty
      end
    end

  end
end
