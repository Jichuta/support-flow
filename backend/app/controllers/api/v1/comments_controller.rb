module Api
  module V1
    class CommentsController < ApplicationController
      def create
        support_request = SupportRequest.find(params[:support_request_id])
        comment = support_request.comments.build(comment_params)
        comment.save!

        render json: {
          id: comment.id,
          body: comment.body,
          author_name: comment.team_member.name,
          support_request_id: comment.support_request_id,
          created_at: comment.created_at
        }, status: :created
      end

      private

      def comment_params
        params.require(:comment).permit(:body, :team_member_id)
      end
    end
  end
end
