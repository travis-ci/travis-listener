require 'spec_helper'

describe Travis::Listener::App do
  let(:app)     { subject }
  let(:auth)    { ['user', '12345'] }
  let(:payload) { Payloads.load(type) }
  let(:redis)   { Redis.new }
  let(:queue)   { Travis::Gatekeeper }

  before { allow(queue).to receive(:push) }
  before { authorize(*auth) }
  before { create }

  def create(opts = {})
    params  = { :payload => (opts[:payload] || payload) }
    headers = { 'HTTP_X_GITHUB_EVENT' => event, 'HTTP_X_GITHUB_GUID' => 'abc123' }
    headers.merge!(opts.delete(:headers) || {})
    post(opts[:url] || '/', params, headers)
  end

  shared_examples_for 'queues the event' do |&block|
    it { expect(queue).to have_received(:push).with('build_requests', hash_including(type: event)) }
  end

  describe 'a push event' do
    let(:type)  { 'push' }
    let(:event) { 'push' }
    include_examples 'queues the event'
  end

  describe 'a pull_request event' do
    let(:type)  { 'pull_request' }
    let(:event) { 'pull_request' }
    include_examples 'queues the event'
  end

  describe 'a branch_created event' do
    let(:type)  { 'branch_created' }
    let(:event) { 'create' }
    include_examples 'queues the event'
  end

  describe 'a branch_deleted event' do
    let(:type)  { 'branch_deleted' }
    let(:event) { 'delete' }
    include_examples 'queues the event'
  end

  describe 'a tag_created event' do
    let(:type)  { 'tag_created' }
    let(:event) { 'create' }
    include_examples 'queues the event'
  end

  describe 'a tag_deleted event' do
    let(:type)  { 'tag_deleted' }
    let(:event) { 'delete' }
    include_examples 'queues the event'
  end

  describe 'a repo_created event' do
    let(:type)  { 'repo_created' }
    let(:event) { 'create' }
    include_examples 'queues the event'
  end

  describe 'a repo_deleted event' do
    let(:type)  { 'repo_deleted' }
    let(:event) { 'delete' }
    include_examples 'queues the event'
  end

  describe 'a repo_privatized event' do
    let(:type)  { 'repo_privatized' }
    let(:event) { 'repository' }
    include_examples 'queues the event'
  end

  describe 'a repo_publicized event' do
    let(:type)  { 'repo_publicized' }
    let(:event) { 'repository' }
    include_examples 'queues the event'
  end
end
