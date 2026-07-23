class SupportRequest < ApplicationRecord
  enum :status, { open: 0, in_progress: 1, resolved: 2, closed: 3 }
  enum :priority, { low: 0, medium: 1, high: 2, critical: 3 }

  belongs_to :creator, class_name: "TeamMember"
  belongs_to :assignee, class_name: "TeamMember", optional: true
  has_many :comments, dependent: :destroy

  validates :title, :description, :status, :priority, :creator, presence: true
  validate :assignee_must_be_active
  validate :must_have_a_comment_to_resolve, if: :transitioning_to_resolved?
  validate :closed_request_cannot_return_to_open
  validate :closed_request_cannot_be_edited, on: :update

  before_save :set_resolved_at, if: :transitioning_to_resolved?
  before_save :clear_resolved_at, if: :leaving_resolved?

  scope :overdue, -> { where("due_date < ?", Date.current).where.not(status: [:resolved, :closed]) }

  def overdue?
    due_date.present? && due_date < Date.current && !resolved? && !closed?
  end

  private

  def assignee_must_be_active
    return if assignee.blank? || assignee.active?

    errors.add(:assignee, "must be active")
  end

  def must_have_a_comment_to_resolve
    errors.add(:comments, "must include at least one comment before resolving") unless comments.exists?
  end

  def closed_request_cannot_return_to_open
    return unless status_in_database == "closed" && open?

    errors.add(:status, "cannot return to open once closed")
  end

  def closed_request_cannot_be_edited
    return unless status_in_database == "closed" && has_changes_to_save?

    errors.add(:base, "Closed requests cannot be edited")
  end

  def transitioning_to_resolved?
    will_save_change_to_status? && resolved?
  end

  def leaving_resolved?
    will_save_change_to_status? && status_in_database == "resolved" && !resolved?
  end

  def set_resolved_at
    self.resolved_at = Time.current
  end

  def clear_resolved_at
    self.resolved_at = nil
  end
end