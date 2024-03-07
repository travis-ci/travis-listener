# frozen_string_literal: true

require 'spec_helper'

describe Travis::Listener::App do
  let(:app)                { subject }
  let(:auth)               { %w[user 12345] }
  let(:payload)            { Payloads.load(type) }
  let(:gatekeeper_queue)   { Travis::Sidekiq::Gatekeeper }
  let(:gh_sync_queue)      { Travis::Sidekiq::GithubSync }

  before do
    allow(gatekeeper_queue).to receive(:push)
    allow(gh_sync_queue).to receive(:push)
    authorize(*auth)
    create
  end

  def create(opts = {})
    params = if %w[installation installation_repositories].include? type
               payload
             else
               { payload: (opts[:payload] || payload) }
             end

    headers = { 'HTTP_X_GITHUB_EVENT' => event, 'HTTP_X_GITHUB_DELIVERY' => 'abc123' }
    headers.merge!(opts.delete(:headers) || {})

    post(opts[:url] || '/', params, headers)
  end

  shared_examples_for 'queues gatekeeper event' do
    it { expect(gatekeeper_queue).to have_received(:push).with('build_requests', hash_including(type: event)) }
  end

  shared_examples_for 'does not queue gatekeeper event' do
    it { expect(gatekeeper_queue).not_to have_received(:push).with('build_requests', hash_including(type: event)) }
  end

  describe 'a push event' do
    let(:type)  { 'push' }
    let(:event) { 'push' }

    include_examples 'queues gatekeeper event'
  end

  describe 'a pull_request event' do
    let(:type)  { 'pull_request' }
    let(:event) { 'pull_request' }

    include_examples 'queues gatekeeper event'
  end

  describe 'a branch_created event' do
    let(:type)  { 'branch_created' }
    let(:event) { 'create' }

    include_examples 'queues gatekeeper event'
  end

  describe 'a branch_deleted event' do
    let(:type)  { 'branch_deleted' }
    let(:event) { 'delete' }

    include_examples 'queues gatekeeper event'
  end

  describe 'a tag_created event' do
    let(:type)  { 'tag_created' }
    let(:event) { 'create' }

    include_examples 'queues gatekeeper event'
  end

  describe 'a tag_deleted event' do
    let(:type)  { 'tag_deleted' }
    let(:event) { 'delete' }

    include_examples 'queues gatekeeper event'
  end

  describe 'a repo_created event' do
    let(:type)  { 'repo_created' }
    let(:event) { 'create' }

    include_examples 'queues gatekeeper event'
  end

  describe 'a repo_deleted event' do
    let(:type)  { 'repo_deleted' }
    let(:event) { 'delete' }

    include_examples 'queues gatekeeper event'
  end

  describe 'a repo_privatized event' do
    let(:type)  { 'repo_privatized' }
    let(:event) { 'repository' }

    include_examples 'queues gatekeeper event'
  end

  describe 'a repo_publicized event' do
    let(:type)  { 'repo_publicized' }
    let(:event) { 'repository' }

    include_examples 'queues gatekeeper event'
  end

  describe 'a create_run event' do
    let(:type)  { 'rerequested_check_run' }
    let(:event) { 'check_run' }

    include_examples 'queues gatekeeper event'
  end

  describe 'a create_suite event : ref_type branch' do
    let(:type)  { 'rerequested_check_suite' }
    let(:event) { 'check_suite' }

    include_examples 'queues gatekeeper event'
  end

  describe 'a create_suite tag : ref_type event' do
    let(:type)  { 'rerequested_check_suite_tag_ref_type' }
    let(:event) { 'check_suite' }

    include_examples 'does not queue gatekeeper event'
  end

  describe 'an installation event' do
    let(:type)  { 'installation' }
    let(:event) { 'installation' }

    it {
      expect(gh_sync_queue)
        .to have_received(:push)
        .with('sync.gh_apps', :gh_app_install, hash_including(type: event))
    }
  end

  describe 'an installation_repositories event' do
    let(:type)  { 'installation_repositories' }
    let(:event) { 'installation_repositories' }

    it {
      expect(gh_sync_queue)
        .to have_received(:push)
        .with('sync.gh_apps', :gh_app_repos, hash_including(type: event))
    }
  end

  describe 'a member event' do
    let(:type)  { 'member' }
    let(:event) { 'member' }

    it {
      expect(gh_sync_queue)
        .to have_received(:push)
        .with('sync', :gh_app_member, hash_including(type: event))
    }
  end

  describe 'a bot push' do
    let(:type)  { 'bot_push' }
    let(:event) { 'push' }

    include_examples 'queues gatekeeper event'
  end

  describe 'an organization member removed' do
    let(:type)  { 'organization' }
    let(:event) { 'member_removed' }

    it {
      expect(gh_sync_queue)
        .to have_received(:push)
        .with('sync', :organization, hash_including(type: event))
    }
  end
end
