require 'spec_helper'

describe Travis::Listener::App do
  let(:app)     { subject }
  let(:auth)    { ['user', '12345'] }
  let(:payload) { Payloads.load('push') }
  let(:redis)   { Redis.new }
  let(:queue)   { Travis::Sidekiq::Gatekeeper }

  before do
    authorize(*auth)
    allow(queue).to receive(:push)
  end

  def create(opts = {})
    params  = {}

    if params_payload = (opts[:payload] || payload)
      params[:payload] = params_payload
    end

    headers = { 'HTTP_X_GITHUB_EVENT' => 'push', 'HTTP_X_GITHUB_GUID' => 'abc123' }
    headers.merge!(opts.delete(:headers) || {})

    post(opts[:url] || '/', params, headers)
  end

  it 'results in a 204 if the hook is accepted' do
    create
    expect(last_response.status).to be == 204
  end

  describe 'without a payload' do
    let(:payload) { nil }
    it 'does not accept a hook' do
      create
      expect(last_response.status).to be == 422
    end
  end

  it 'returns 200 when checking if the app is still running' do
    get '/uptime'
    expect(last_response.status).to be == 200
  end

  it "should push the message to sidekiq" do
    create
    expect(queue).to have_received(:push).with('build_requests', QUEUE_PAYLOAD.merge(payload: Payloads.load('push')))
  end

  it "passes the given request ID on" do
    create(headers: { "HTTP_X_REQUEST_ID" => "abc-def-ghi" })
    expect(queue).to have_received(:push).with('build_requests', QUEUE_PAYLOAD.merge(payload: Payloads.load('push'), uuid: "abc-def-ghi"))
  end

  context "with valid_ips provided" do
    before do
      described_class.any_instance.stub(:valid_ips).and_return(['1.2.3.4'])
    end

    context "when ip_validation is turned off" do
      it 'accepts a request from an invalid IP' do
        described_class.any_instance.should_receive(:report_ip_validity)
        create headers: { 'REMOTE_ADDR' => '1.2.3.1' }
        expect(last_response.status).to be == 204
      end
    end

    context "when ip_validation is turned on" do
      before do
        described_class.any_instance.stub(:ip_validation?).and_return(true)
      end

      it 'accepts a request from valid IP' do
        create headers: { 'REMOTE_ADDR' => '1.2.3.4' }
        expect(last_response.status).to be == 204
      end

      it 'rejects a request without a valid IP' do
        create headers: { 'REMOTE_ADDR' => '1.1.1.1' }
        expect(last_response.status).to be == 403
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
      expect(last_response.status).to be == 204

      create headers: { 'REMOTE_ADDR' => '1.1.1.1' }
      expect(last_response.status).to be == 204

      create headers: { 'REMOTE_ADDR' => '1.1.1.2' }
      expect(last_response.status).to be == 204

      create headers: { 'REMOTE_ADDR' => '1.1.1.3' }
      expect(last_response.status).to be == 204
    end

    it 'rejects a request without a valid IP' do
      create headers: { 'REMOTE_ADDR' => '1.1.1.4' }
      expect(last_response.status).to be == 403

      create headers: { 'REMOTE_ADDR' => '1.1.1.10' }
      expect(last_response.status).to be == 403
    end
  end
end
