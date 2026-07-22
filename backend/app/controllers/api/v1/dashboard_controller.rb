module Api
  module V1
    class DashboardController < ApplicationController
      STATUS_NAMES = { 0 => "open", 1 => "in_progress", 2 => "resolved", 3 => "closed" }.freeze
      PRIORITY_NAMES = { 0 => "low", 1 => "medium", 2 => "high", 3 => "critical" }.freeze

      def index
        requests = SupportRequest.all

        render json: {
          total_requests: requests.count,
          requests_by_status: requests.group(:status).count.transform_keys { |key|
            STATUS_NAMES[key] || key.to_s
          },
          requests_by_priority: requests.group(:priority).count.transform_keys { |key|
            PRIORITY_NAMES[key] || key.to_s
          },
          requests_by_team: requests
            .joins(:team)
            .group("team_members.name")
            .count
            .map { |name, count| { name: name, count: count } }
            .sort_by { |entry| entry[:count] }
            .reverse
        }
      end
    end
  end
end
