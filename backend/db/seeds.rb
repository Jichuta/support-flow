# SupportFlow development data. All natural keys are stable so this can be run repeatedly.

team_member_attributes = [
  { name: "Alice Developer", email: "alice.developer@supportflow.dev", role: :developer, active: true },
  { name: "Bruno QA", email: "bruno.qa@supportflow.dev", role: :qa, active: true },
  { name: "Carla Support", email: "carla.support@supportflow.dev", role: :support, active: true },
  { name: "Diego Developer", email: "diego.developer@supportflow.dev", role: :developer, active: false },
  { name: "Elena Support", email: "elena.support@supportflow.dev", role: :support, active: false },
  { name: "Fatima QA", email: "fatima.qa@supportflow.dev", role: :qa, active: true }
]

team_members = team_member_attributes.to_h do |attributes|
  member = TeamMember.find_or_initialize_by(email: attributes[:email])
  member.assign_attributes(attributes)
  member.save!
  [member.email, member]
end

request_attributes = [
  { title: "Customer portal login failure", description: "Users cannot sign in after the latest portal deployment.", status: :open, priority: :critical, due_date: Date.current - 3.days, assignee: nil, creator: "alice.developer@supportflow.dev", team: "carla.support@supportflow.dev" },
  { title: "Invoice export timeout", description: "Large invoice exports time out before the download begins.", status: :open, priority: :high, due_date: Date.current + 5.days, assignee: "alice.developer@supportflow.dev", creator: "carla.support@supportflow.dev", team: "alice.developer@supportflow.dev" },
  { title: "Mobile layout regression", description: "The navigation overlaps the content on smaller screens.", status: :in_progress, priority: :medium, due_date: Date.current - 2.days, assignee: "bruno.qa@supportflow.dev", creator: "bruno.qa@supportflow.dev", team: "carla.support@supportflow.dev" },
  { title: "Password reset email delay", description: "Password reset messages arrive several minutes late.", status: :resolved, priority: :low, due_date: Date.current - 7.days, assignee: "carla.support@supportflow.dev", creator: "carla.support@supportflow.dev", team: "carla.support@supportflow.dev" },
  { title: "Production database backup alert", description: "The nightly backup alert reports a false failure.", status: :closed, priority: :high, due_date: Date.current - 10.days, assignee: "alice.developer@supportflow.dev", creator: "alice.developer@supportflow.dev", team: "alice.developer@supportflow.dev" },
  { title: "Search results missing tags", description: "Tagged support articles are absent from filtered search results.", status: :open, priority: :medium, due_date: nil, assignee: "bruno.qa@supportflow.dev", creator: "bruno.qa@supportflow.dev", team: "carla.support@supportflow.dev" },
  { title: "Webhook retry visibility", description: "Operators need visibility into webhook retry attempts.", status: :in_progress, priority: :high, due_date: Date.current + 2.days, assignee: "alice.developer@supportflow.dev", creator: "alice.developer@supportflow.dev", team: "alice.developer@supportflow.dev" },
  { title: "Role permission audit", description: "Review role permissions for the quarterly access audit.", status: :resolved, priority: :critical, due_date: Date.current - 5.days, assignee: "bruno.qa@supportflow.dev", creator: "bruno.qa@supportflow.dev", team: "carla.support@supportflow.dev" },
  { title: "Legacy report cleanup", description: "Remove obsolete report definitions from the admin area.", status: :closed, priority: :medium, due_date: Date.current - 12.days, assignee: "carla.support@supportflow.dev", creator: "carla.support@supportflow.dev", team: "carla.support@supportflow.dev" },
  { title: "API rate limit warning", description: "The API should warn operators before rate limits are reached.", status: :open, priority: :low, due_date: Date.current - 1.day, assignee: nil, creator: "alice.developer@supportflow.dev", team: "alice.developer@supportflow.dev" },
  { title: "Queue worker memory growth", description: "Background workers slowly consume memory during long runs.", status: :in_progress, priority: :critical, due_date: Date.current + 1.day, assignee: "alice.developer@supportflow.dev", creator: "alice.developer@supportflow.dev", team: "alice.developer@supportflow.dev" },
  { title: "Support handbook update", description: "Update the handbook with the new escalation process.", status: :resolved, priority: :medium, due_date: Date.current - 4.days, assignee: "carla.support@supportflow.dev", creator: "carla.support@supportflow.dev", team: "carla.support@supportflow.dev" },
  { title: "Stale notification cleanup", description: "Old notification records should be removed from the dashboard.", status: :closed, priority: :low, due_date: Date.current - 15.days, assignee: "bruno.qa@supportflow.dev", creator: "bruno.qa@supportflow.dev", team: "carla.support@supportflow.dev" },
  { title: "Customer data import", description: "Import the next customer data batch and report rejected rows.", status: :open, priority: :high, due_date: Date.current + 10.days, assignee: "carla.support@supportflow.dev", creator: "carla.support@supportflow.dev", team: "carla.support@supportflow.dev" },
  { title: "Slow dashboard aggregation", description: "Dashboard status aggregation is slow with the full dataset.", status: :in_progress, priority: :low, due_date: Date.current - 6.days, assignee: "bruno.qa@supportflow.dev", creator: "alice.developer@supportflow.dev", team: "alice.developer@supportflow.dev" }
]

support_requests = request_attributes.to_h do |attributes|
  request = SupportRequest.find_or_initialize_by(title: attributes[:title])
  unless request.persisted? && request.closed?
    request.assign_attributes(
      description: attributes[:description],
      status: :open,
      priority: attributes[:priority],
      due_date: attributes[:due_date],
      creator: team_members.fetch(attributes[:creator]),
      team: team_members.fetch(attributes[:team]),
      assignee: attributes[:assignee] && team_members.fetch(attributes[:assignee])
    )
    request.save!
  end
  [request.title, request]
end

comment_attributes = [
  ["Customer portal login failure", "Alice reproduced the login failure in production.", "alice.developer@supportflow.dev"],
  ["Customer portal login failure", "Support confirmed the issue affects new sessions.", "carla.support@supportflow.dev"],
  ["Invoice export timeout", "The export query needs pagination for large accounts.", "bruno.qa@supportflow.dev"],
  ["Mobile layout regression", "QA identified the regression on tablet widths.", "bruno.qa@supportflow.dev"],
  ["Password reset email delay", "The mail queue configuration was corrected.", "carla.support@supportflow.dev"],
  ["Production database backup alert", "The alert threshold was corrected and verified.", "alice.developer@supportflow.dev"],
  ["Role permission audit", "All role permissions were reviewed and approved.", "bruno.qa@supportflow.dev"],
  ["Legacy report cleanup", "The obsolete reports were removed successfully.", "carla.support@supportflow.dev"],
  ["Queue worker memory growth", "A memory profile is attached for the next review.", "alice.developer@supportflow.dev"],
  ["Support handbook update", "The escalation examples now match the current workflow.", "carla.support@supportflow.dev"],
  ["Stale notification cleanup", "Notification cleanup completed in the maintenance window.", "bruno.qa@supportflow.dev"],
  ["Slow dashboard aggregation", "The slow query is isolated for optimization.", "alice.developer@supportflow.dev"]
]

comment_attributes.each do |title, body, author_email|
  Comment.find_or_create_by!(support_request: support_requests.fetch(title), body: body) do |comment|
    comment.team_member = team_members.fetch(author_email)
  end
end

request_attributes.each do |attributes|
  request = support_requests.fetch(attributes[:title])
  desired_status = attributes[:status].to_s
  next if request.status == desired_status || request.closed?

  request.update!(status: desired_status)
end

puts "Seed complete: #{TeamMember.count} team members, #{SupportRequest.count} support requests, #{Comment.count} comments"
puts "Overdue: #{SupportRequest.overdue.count}; unassigned: #{SupportRequest.where(assignee_id: nil).count}"
puts "Resolved: #{SupportRequest.resolved.count}; closed: #{SupportRequest.closed.count}"
