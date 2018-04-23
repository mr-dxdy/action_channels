require 'spec_helper'

RSpec.describe ActionChannels::Channels::NewsChannel do
  context '#subscribe' do
    let(:message) { ActionChannels::Message.new channel: 'My channel', type: 'subscribe', author: double('author') }
    let(:channel) { described_class.new name: 'My channel', message_sender: ActionChannels::MessageSenders::Buffer.new }

    it 'should send message #subscribed' do
      channel.process_message message
      receiver, sended_message = channel.message_sender.queue.first

      expect(receiver).to eq(message.author)
      expect(sended_message.channel).to eq(message.channel)
      expect(sended_message.type).to eq('subscribed')
      expect(sended_message.details).to eq({})
    end

    it 'should run callback #after_message_subscribe' do
      expect(channel).to receive(:after_message_subscribe) do |message|
        expect(message).to eq(message)
      end

      channel.process_message message
    end
  end

  context '#unsubscribe' do
    let(:message) { ActionChannels::Message.new channel: 'My channel', type: 'unsubscribe', author: double('author') }
    let(:channel) { described_class.new name: 'My channel', message_sender: ActionChannels::MessageSenders::Buffer.new }

    it 'should send message #unsubscribed' do
      channel.process_message message
      receiver, sended_message = channel.message_sender.queue.first

      expect(receiver).to eq(message.author)
      expect(sended_message.channel).to eq(message.channel)
      expect(sended_message.type).to eq('unsubscribed')
      expect(sended_message.details).to eq({})
    end

    it 'should run callback #after_message_subscribe' do
      expect(channel).to receive(:after_message_unsubscribe) do |message|
        expect(message).to eq(message)
      end

      channel.process_message message
    end
  end

  it '#publish' do
    client_1 = double('client')

    message = ActionChannels::Message.new channel: 'My channel', type: 'publish', author: double('author'), details: { description: {} }
    channel = described_class.new name: 'My channel', message_sender: ActionChannels::MessageSenders::Buffer.new
    channel.add_client client_1

    channel.process_message message
    receiver, sended_message = channel.message_sender.queue.first

    expect(receiver).to eq(client_1)
    expect(sended_message.channel).to eq('My channel')
    expect(sended_message.type).to eq('news')
    expect(sended_message.details).to eq(message.details)

    receiver, sended_message = channel.message_sender.queue.last
    expect(receiver).to eq(message.author)
    expect(sended_message.channel).to eq('My channel')
    expect(sended_message.type).to eq('published')
    expect(sended_message.details).to eq({})
  end

  it '#unknown_type_message' do
    message = ActionChannels::Message.new channel: 'My channel', type: 'foo', author: double('author')
    channel = described_class.new name: 'My channel', message_sender: ActionChannels::MessageSenders::Buffer.new

    channel.process_message message
    receiver, sended_message = channel.message_sender.queue.first

    expect(receiver).to eq(message.author)
    expect(sended_message.channel).to eq(message.channel)
    expect(sended_message.type).to eq('invalid_message')
    expect(sended_message.details).to have_key(:error)
  end
end
