RSpec.describe ActionChannels do
  it "has a version number" do
    expect(ActionChannels::VERSION).not_to be nil
  end

  it 'should exists logger' do
    expect(ActionChannels.logger).to be_is_a(Logger)
  end
end
