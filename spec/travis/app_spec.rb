require 'spec_helper'

describe Travis::Listener::App do
  let(:app)     { subject }
  let(:user)    { User.create!(:login => 'user') }
  let(:auth)    { [user.login, user.tokens.first.token] }
  let(:payload) { GITHUB_PAYLOADS['gem-release'] }

  before(:each) do
    authorize(*auth)
  end

  it 'accepts payloads from github' do
    create = lambda { post '/github', :payload => payload }
    create.should change(Request, :count).by(1)

    request = Request.last
    request.should be_created
    request.payload.should == payload
  end

  it 'does not create a build record when the branch is gh_pages' do
    create = lambda { post '/github', :payload => payload.gsub('refs/heads/master', 'refs/heads/gh_pages') }
    create.should_not change(Request, :count)
  end

  it 'rejects payloads from unkown sites' do
    post '/bitbucket'
    last_response.status.should be == 404
  end

  it 'logs errors to hoptoad if an exception occurs' do
    Request.stub(:create_from) { raise 'bang' }
    Airbrake.should_receive(:notify_or_ignore)
    post '/github', :payload => payload
  end

  it 'returns 200 when checking if the app is still running' do
    get '/uptime'
    last_response.status.should be == 200
  end
end
