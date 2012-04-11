require 'spec_helper'

describe Travis::Listener::App do
  let(:app)     { subject }
  let(:auth)    { ['user', '12345'] }
  let(:payload) { GITHUB_PAYLOADS['gem-release'] }

  before(:each) do
    authorize(*auth)
  end

  def create(opts = {})
    post(opts[:url] || '/', :payload => (opts[:payload] || payload))
  end

  it 'results in a 204 if the hook is accepted' do
    create
    last_response.status.should be == 204
  end

  it 'queues a requests job with AMQP' do
    Travis::Amqp::Publisher.any_instance.should_receive(:publish).with(QUEUE_PAYLOAD, :type => 'request')
    create
  end

  it 'returns 200 when checking if the app is still running' do
    get '/uptime'
    last_response.status.should be == 200
  end
end
