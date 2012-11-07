require 'spec_helper'

describe Travis::Listener::App do
  class Travis::Amqp::Publisher
    def publish(payload, queue)

    end
  end

  let(:app)     { subject }
  let(:auth)    { ['user', '12345'] }
  let(:payload) { GITHUB_PAYLOADS['gem-release'] }
  let(:redis)   { Redis.new }
  before(:each) do
    authorize(*auth)
  end

  def create(opts = {})
    params  = { :payload => (opts[:payload] || payload) }
    headers = { 'HTTP_X_GITHUB_EVENT' => 'push' }
    post(opts[:url] || '/', params, headers)
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

  context "with sidekiq enabled" do
    before do
      redis.set('features:build_requests_via_sidekiq:enabled', '1')
    end

    after do
      redis.set('features:build_requests_via_sidekiq:enabled', '0')
    end

    it "should push the message to sidekiq" do
      Travis::Sidekiq::BuildRequest.should_receive(:perform_async).with(QUEUE_PAYLOAD)
      create
    end

    it "shouldn't push the message to amqp" do
      Travis::Amqp::Publisher.any_instance.should_not_receive(:publish)
      create 
    end
  end
end
