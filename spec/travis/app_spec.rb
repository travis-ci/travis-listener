require 'spec_helper'

describe Travis::Listener::App do
  let(:app)     { subject }
  let(:user)    { User.create!(:login => 'user').tap { |user| user.tokens.create! } }
  let(:auth)    { ActionController::HttpAuthentication::Basic.encode_credentials(user.login, user.tokens.first.token) }
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
end
