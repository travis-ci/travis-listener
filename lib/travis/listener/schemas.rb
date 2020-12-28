module Travis
  module Listener
    module Schemas
      PUSH = {
        "ref" => nil,
        "head_commit" => {
          "id" => nil
        },
        "commits" => {
          "id" => nil
        },
        "repository" => {
          "id" => nil,
          "name" => nil,
          "full_name" => nil,
          "owner" => {
            "login" => nil
          },
          "private" => nil
        },
        "sender" => {
          "id" => nil,
          "login" => nil,
          "type" => nil
        }
      }

      PULL_REQUEST = {
        "action" => nil,
        "number" => nil,
        "pull_request" => {
          "head" => {
            "repo" => {
              "full_name" => nil
            },
            "sha" => nil,
            "ref" => nil,
            "user" => {
              "login" => nil
            }
          }
        },
        "repository" => {
          "id" => nil,
          "name" => nil,
          "full_name" => nil,
          "owner" => {
            "login" => nil
          },
          "private" => nil
        },
        "sender" => {
          "id" => nil,
          "login" => nil,
          "type" => nil
        }
      }

      INSTALLATION = {
        "action" => nil,
        "installation" => {
          "id" => nil,
          "account" => {
            "login" => nil
          }
        },
        "sender" => {
          "login" => nil
        }
      }

      CHECK_SUITE = {
        "action" => nil,
        "check_suite" => {
          "ref_type" => nil
        },
        "repository" => {
          "id" => nil,
          "name" => nil,
          "full_name" => nil,
          "owner" => {
            "login" => nil
          },
          "private" => nil
        },
        "sender" => {
          "id" => nil,
          "login" => nil
        }
      }

      REPOSITORY = {
        "action" => nil,
        "repository" => {
          "id" => nil,
          "name" => nil,
          "full_name" => nil,
          "owner" => {
            "login" => nil
          },
          "private" => nil
        },
        "sender" => {
          "id" => nil,
          "login" => nil
        }
      }

      # For MemberEvents
      # (https://developer.github.com/v3/activity/events/types/#memberevent)
      #
      MEMBER = {
        "action"     => nil,
        "member"     => {
          "login" => nil,
          "id"    => nil,
        },
        "changes" => {
          "permission" => {
            "from" => nil,
          }
        },
        "repository" => {
          "id"        => nil,
          "name"      => nil,
          "full_name" => nil,
        },
      }

      FALLBACK = {
        "sender" => {
          "id" => nil,
          "login" => nil
        }
      }

      def self.event_details(event_type, payload)
        case event_type
        when 'pull_request'
          {
            repository:   payload["repository"]["full_name"],
            number:       payload['number'],
            action:       payload['action'],
            source:       payload['pull_request']['head']['repo'] && payload['pull_request']['head']['repo']['full_name'],
            head:         payload['pull_request']['head']['sha'][0..6],
            ref:          payload['pull_request']['head']['ref'],
            user:         payload.dig('pull_request', 'head', 'user', 'login'),
            sender:       payload.dig('sender', 'login'),
            sender_type:  payload.dig('sender', 'type')
          }
        when 'push'
          {
            repository:   payload["repository"]["full_name"],
            ref:          payload['ref'],
            head:         payload['head_commit'] && payload['head_commit']['id'][0..6],
            commits:      (payload["commits"] || []).map {|c| c['id'][0..6]}.join(","),
            sender:       payload.dig('sender', 'login'),
            sender_type:  payload.dig('sender', 'type')
          }
        when 'check_suite'
          {
            action:       payload['action'],
            ref_type:     payload['check_suite']['ref_type'],
            repository:   payload["repository"]["full_name"],
            sender:       payload.dig('sender', 'login'),
            sender_type:  payload.dig('sender', 'type')
          }
        when 'create', 'delete', 'repository', 'check_run'
          {
            action:     payload['action'],
            repository: payload["repository"]["full_name"],
            sender:       payload.dig('sender', 'login'),
            sender_type:  payload.dig('sender', 'type')
          }
        when 'installation', 'installation_repositories'
          {
            action:       payload['action'],
            installation: payload["installation"]["account"]["login"],
            sender:       payload.dig('sender', 'login'),
            sender_type:  payload.dig('sender', 'type')
          }
        else
          { }
        end
      end
    end
  end
end
