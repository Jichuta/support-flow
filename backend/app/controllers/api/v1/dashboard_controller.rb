module Api
  module V1
    class DashboardController < ApplicationController
      def index
        render json: {
          total_requests: SupportRequest.count,
          requests_by_status: status_counts,
          requests_by_priority: priority_counts,
          requests_by_team: team_request_counts
        }
      end

      private

      def status_counts
        SupportRequest.group(:status).count.transform_keys { |key|
          SupportRequest.statuses.key(key) || key.to_s
        }
      end

      def priority_counts
        SupportRequest.group(:priority).count.transform_keys { |key|
          SupportRequest.priorities.key(key) || key.to_s
        }
      end

      def team_request_counts
        SupportRequest
          .joins(:team)
          .group("team_members.id", "team_members.name")
          .order("count_all DESC")
          .count
          .map { |(_id, name), count| { name: name, count: count } }
      end
    end
  end
end
