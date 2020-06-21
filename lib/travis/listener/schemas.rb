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
        "pusher" => {
          "name" => nil,
        },
        "sender" => {
          "id" => nil,
          "login" => nil
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
        "pusher" => {
          "name" => nil,
        },
        "sender" => {
          "id" => nil,
          "login" => nil
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
        "pusher" => {
          "name" => nil,
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
        "pusher" => {
          "name" => nil,
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
        "pusher" => {
          "name" => nil,
        },
        "sender" => {
          "id" => nil,
          "login" => nil
        }
      }

      def self.event_details(event_type, payload)
        case event_type
        when 'pull_request'
          {
            repository: payload["repository"]["full_name"],
            number:     payload['number'],
            action:     payload['action'],
            source:     payload['pull_request']['head']['repo'] && payload['pull_request']['head']['repo']['full_name'],
            head:       payload['pull_request']['head']['sha'][0..6],
            ref:        payload['pull_request']['head']['ref'],
            user:       payload['pull_request']['head']['user']['login'],
            sender:     parse_sender_from(payload)
          }
        when 'push'
          {
            repository: payload["repository"]["full_name"],
            ref:        payload['ref'],
            head:       payload['head_commit'] && payload['head_commit']['id'][0..6],
            commits:    (payload["commits"] || []).map {|c| c['id'][0..6]}.join(","),
            sender:     parse_sender_from(payload)
          }
        when 'check_suite'
          {
            action:     payload['action'],
            ref_type:   payload['check_suite']['ref_type'],
            repository: payload["repository"]["full_name"],
            sender:     payload['sender']['login']
          }
        when 'create', 'delete', 'repository', 'check_run'
          {
            action:     payload['action'],
            repository: payload["repository"]["full_name"],
            sender:     parse_sender_from(payload)
          }
        when 'installation', 'installation_repositories'
          {
            action:       payload['action'],
            installation: payload["installation"]["account"]["login"],
            sender:       parse_sender_from(payload)
          }
        else
          { }
        end
      end

      # Some payloads come in that are missing a `sender` field for one reason
      #   or another, but they do seem to have a `pusher` field, which has a
      #   `name` field that is the same as the ['sender']['login'] value.
      #
      def self.parse_sender_from(payload)
        if payload['sender']
          payload['sender']['login']
        else
          payload['pusher']['name']
        end
      end
    end
  end
end
