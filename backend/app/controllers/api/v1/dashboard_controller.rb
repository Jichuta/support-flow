module Api
  module V1
    class DashboardController < ApplicationController
      def index
        render json: {
          total_requests: SupportRequest.count,
          requests_by_status: status_counts,
          requests_by_priority: priority_counts
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
    end
  end
end
