require 'spec_helper'

describe Travis::Listener::App do
  let(:app)     { subject }
  let(:user)    { User.create!(:login => 'user') }
  let(:auth)    { [user.login, user.tokens.first.token] }
  let(:payload) { GITHUB_PAYLOADS['gem-release'] }

  before(:each) do
    authorize(*auth)
  end

  def create(opts = {})
    lambda { post(opts[:url] || '/github', :payload => (opts[:payload] || payload)) }
  end

  it 'results in a 204 if the hook is accepted' do
    create.call
    last_response.status.should be == 204
  end

  it 'adds a new Request instance' do
    create.should change(Request, :count).by(1)
  end

  it 'stores the payload in the new Request instance' do
    create.call
    request = Request.last
    request.should be_created
    request.payload.should == payload
  end

  it 'does not create a build record when the branch is gh_pages' do
    request = create :payload => payload.gsub('refs/heads/master', 'refs/heads/gh_pages')
    request.should_not change(Request, :count)
  end

  it 'rejects payloads from unkown sites' do
    create(:url => '/bitbucket').call
    last_response.status.should be == 404
  end

  # it 'logs errors to airbrake if an exception is raised' do
  #   Request.stub(:create_from) { raise 'this error should be caught' }
  #   Airbrake.should_receive(:notify_or_ignore)
  #   create.should raise_error
  # end

  it 'returns 200 when checking if the app is still running' do
    get '/uptime'
    last_response.status.should be == 200
  end
end
