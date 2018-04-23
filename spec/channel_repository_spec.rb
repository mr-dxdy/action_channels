require 'spec_helper'

RSpec.describe ActionChannels::ChannelRepository do
  describe '#add' do
    let(:channel_1) { ActionChannels::Channels::NewsChannel.new name: 'My channel' }
    let(:repository) { described_class.new }

    it 'should add channel' do
      repository.add channel_1
      expect(repository.all).to eq([channel_1])
    end

    it 'should not add double of channel' do
      repository.add channel_1
      repository.add channel_1

      expect(repository.all).to eq([channel_1])
    end
  end

  describe '#delete' do
    let(:channel_1) { ActionChannels::Channels::NewsChannel.new name: 'My channel' }
    let(:repository) { described_class.new }

    it 'should delete channel' do
      repository.add channel_1
      repository.delete channel_1
      expect(repository.all).to be_empty
    end
  end

  it '#find_by_name' do
    channel_1 = ActionChannels::Channels::NewsChannel.new name: 'Channel 1'
    channel_2 = ActionChannels::Channels::NewsChannel.new name: 'Channel 2'

    repository = described_class.new [channel_1, channel_2]
    expect(repository.find_by_name('Channel 2')).to eq(channel_2)
    expect(repository.find_by_name('Channel 1')).to eq(channel_1)
    expect(repository.find_by_name('Channel 3')).to be_nil
  end

  it '#find_by_name_or_create' do
    repository = described_class.new
    expect(repository.all).to eq([])

    repository.find_by_name_or_create 'My channel 1'
    expect(repository.all.map(&:name)).to eq(['My channel 1'])

    repository.find_by_name_or_create 'My channel 1'
    expect(repository.all.map(&:name)).to eq(['My channel 1'])
  end
end
