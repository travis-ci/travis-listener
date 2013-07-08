require 'spec_helper'

describe Travis::Listener::App do
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
    headers.merge!(opts.delete(:headers) || {})
    post(opts[:url] || '/', params, headers)
  end

  it 'results in a 204 if the hook is accepted' do
    create
    last_response.status.should be == 204
  end

  describe 'without a payload' do
    let(:payload) { nil }
    it 'does not accept a hook' do
      create
      last_response.status.should be == 422
    end
  end

  it 'returns 200 when checking if the app is still running' do
    get '/uptime'
    last_response.status.should be == 200
  end

  it "should push the message to sidekiq" do
    Travis::Sidekiq::BuildRequest.should_receive(:perform_async).with(QUEUE_PAYLOAD)
    create
  end

  context "with valid_ips provided" do
    before do
      described_class.any_instance.stub(:valid_ips).and_return(['1.2.3.4'])
    end

    context "when ip_validation is turned off" do
      it 'accepts a request from an invalid IP' do
        described_class.any_instance.should_receive(:report_ip_validity)
        create headers: { 'REMOTE_ADDR' => '1.2.3.1' }
        last_response.status.should be == 204
      end
    end

    context "when ip_validation is turned on" do
      before do
        described_class.any_instance.stub(:ip_validation?).and_return(true)
      end

      it 'accepts a request from valid IP' do
        create headers: { 'REMOTE_ADDR' => '1.2.3.4' }
        last_response.status.should be == 204
      end

      it 'rejects a request without a valid IP' do
        create headers: { 'REMOTE_ADDR' => '1.1.1.1' }
        last_response.status.should be == 403
      end
    end
  end

  context 'with valid_ips provided as a range' do
    before do
      described_class.any_instance.stub(:valid_ips).and_return(['1.1.1.0/30'])
      described_class.any_instance.stub(:ip_validation?).and_return(true)
    end

    it 'accepts a request from valid IP' do
      create headers: { 'REMOTE_ADDR' => '1.1.1.0' }
      last_response.status.should be == 204

      create headers: { 'REMOTE_ADDR' => '1.1.1.1' }
      last_response.status.should be == 204

      create headers: { 'REMOTE_ADDR' => '1.1.1.2' }
      last_response.status.should be == 204

      create headers: { 'REMOTE_ADDR' => '1.1.1.3' }
      last_response.status.should be == 204
    end

    it 'rejects a request without a valid IP' do
      create headers: { 'REMOTE_ADDR' => '1.1.1.4' }
      last_response.status.should be == 403

      create headers: { 'REMOTE_ADDR' => '1.1.1.10' }
      last_response.status.should be == 403
    end
  end
end
