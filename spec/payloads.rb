module Payloads
  def self.load(path)
    File.read(File.expand_path("../payloads/#{path}.json", __FILE__))
  end
end

GITHUB_PAYLOADS = {
  "gem-release" => %({
    "repository": {
      "url": "http://github.com/svenfuchs/gem-release",
      "name": "gem-release",
      "owner": {
        "email": "svenfuchs@artweb-design.de",
        "name": "svenfuchs"
      }
    },
    "head_commit": {
      "id": "9854592",
      "message": "Bump to 0.0.15"
    },
    "commits": [{
      "id":        "9854592",
      "message":   "Bump to 0.0.15",
      "timestamp": "2010-10-27 04:32:37",
      "committer": {
        "name":  "Sven Fuchs",
        "email": "svenfuchs@artweb-design.de"
      },
      "author": {
        "name":  "Christopher Floess",
        "email": "chris@flooose.de"
      }
    }],
    "ref": "refs/heads/master",
    "compare": "https://github.com/svenfuchs/gem-release/compare/af674bd...9854592"
  })
}

QUEUE_PAYLOAD = {
  :type => 'push',
  :payload => GITHUB_PAYLOADS['gem-release'],
  :uuid => Travis.uuid,
  :github_guid => 'abc123',
  :github_event => 'push'
}
