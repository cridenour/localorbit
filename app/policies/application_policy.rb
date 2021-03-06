class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def user_activities
    @user_activities ||= if @user.roles.count > 0
      all_actions = RoleAction.select('lower(description) AS description').where("org_types @> '{#{@user.primary_user_role}}'::character varying[] AND (plan_ids is null OR plan_ids @> '{#{@user.user_organizations.includes(:organization).pluck(:plan_id).compact.join(', ')}}'::character varying[])").distinct.map(&:description).flatten
      user_actions = @user.roles.select(:activities).where(org_type: @user.primary_user_role).distinct.map(&:activities).flatten
      if @user.roles[0].organization_id.nil?
        all_actions + user_actions
      else
        user_actions
      end
    else
      RoleAction.select('lower(description) AS description').where("org_types @> '{#{@user.primary_user_role}}'::character varying[] AND (plan_ids is null OR plan_ids @> '{#{@user.user_organizations.includes(:organization).pluck(:plan_id).compact.join(', ')}}'::character varying[])").distinct.map(&:description).flatten
    end
  end

  def inferred_activity(method)
    "#{@record.to_s.downcase}:#{method.to_s}"
  end

  def method_missing(name,*args)
    if name.to_s.last == '?'
      user_activities.include?(inferred_activity(name.to_s.gsub('?','')))
    else
      super
    end
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end
end
