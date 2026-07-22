module Api
  module V1
    class TestErrorsController < ApplicationController
      def record_not_found
        raise ActiveRecord::RecordNotFound, "Test record not found"
      end

      def record_invalid
        comment = Comment.new(body: nil, team_member_id: nil, support_request_id: nil)
        comment.save!
      end

      def custom_error
        render_error("Custom error message", ["Detail one", "Detail two"], status: :bad_request)
      end
    end
  end
end
