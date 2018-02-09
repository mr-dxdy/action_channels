require 'spec_helper'

RSpec.describe ActionChannels::Message do
  it 'should parse message as string' do
    message = described_class.parse '{"channel": "chat", "type": "sign_in"}'

    expect(message.channel).to eq("chat")
    expect(message.type).to eq("sign_in")
    expect(message.details).to eq({})
  end

  it 'should raise error if text of message is invalid' do
    expect {
      described_class.parse "bad message :)"
    }.to raise_error(ActionChannels::Errors::NotParseMessage)
  end

  context '.to_raw' do
    it 'should returns message as string' do
      message = described_class.new(
        channel: "Chat",
        type: "sign_out",
        author: double("author"),
        details: { reason: 'I am tired' }
      )
      expect(message.to_raw).to eq('{"channel":"Chat","type":"sign_out","details":{"reason":"I am tired"}}')
    end
  end
end
