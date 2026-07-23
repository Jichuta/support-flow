module Api
  module V1
    class SupportRequestsController < ApplicationController
      def index
        support_requests = filtered_support_requests.includes(:creator, :assignee).order(created_at: :desc)

        render json: { support_requests: support_requests.map { |support_request| support_request_payload(support_request) } }
      end

      def show
        support_request = SupportRequest.includes(:creator, :assignee, comments: :team_member).find(params[:id])

        render json: support_request_payload(support_request, include_comments: true)
      end

      def create
        support_request = SupportRequest.new(support_request_params)

        if support_request.save
          render json: support_request_payload(support_request), status: :created
        else
          render_validation_errors(support_request)
        end
      end

      def update
        support_request = SupportRequest.find(params[:id])

        if support_request.update(support_request_params)
          render json: support_request_payload(support_request)
        else
          render_validation_errors(support_request)
        end
      end

      private

      def filtered_support_requests
        scope = SupportRequest.all
        scope = scope.where(status: params[:status]) if SupportRequest.statuses.key?(params[:status])
        scope = scope.where(priority: params[:priority]) if SupportRequest.priorities.key?(params[:priority])
        scope = scope.where(assignee_id: params[:team_member_id]) if params[:team_member_id].present?
        scope = scope.overdue if boolean_param?(:overdue)
        scope = scope.where(assignee_id: nil) if boolean_param?(:unassigned)

        if params[:q].present?
          query = ActiveRecord::Base.sanitize_sql_like(params[:q].downcase)
          scope = scope.where("LOWER(title) LIKE ?", "%#{query}%")
        end

        scope
      end

      def boolean_param?(key)
        ActiveModel::Type::Boolean.new.cast(params[key])
      end

      def support_request_params
        params.require(:support_request).permit(
          :title,
          :description,
          :status,
          :priority,
          :due_date,
          :creator_id,
          :assignee_id
        )
      end

      def support_request_payload(support_request, include_comments: false)
        payload = {
          id: support_request.id,
          title: support_request.title,
          description: support_request.description,
          status: support_request.status,
          priority: support_request.priority,
          due_date: support_request.due_date,
          resolved_at: support_request.resolved_at,
          overdue: support_request.overdue?,
          creator: team_member_payload(support_request.creator),
          assignee: team_member_payload(support_request.assignee),
          created_at: support_request.created_at,
          updated_at: support_request.updated_at
        }

        payload[:comments] = support_request.comments.order(:created_at).map { |comment| comment_payload(comment) } if include_comments
        payload
      end

      def team_member_payload(team_member)
        return nil unless team_member

        {
          id: team_member.id,
          name: team_member.name,
          email: team_member.email,
          role: team_member.role,
          active: team_member.active
        }
      end

      def comment_payload(comment)
        {
          id: comment.id,
          body: comment.body,
          author_name: comment.team_member.name,
          team_member_id: comment.team_member_id,
          support_request_id: comment.support_request_id,
          created_at: comment.created_at
        }
      end

      def render_validation_errors(record)
        render json: { error: "Validation failed", details: record.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end