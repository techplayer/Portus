class TeamPolicy
  attr_reader :user, :team

  def initialize(user, team)
    raise Pundit::NotAuthorizedError, 'must be logged in' unless user
    @user = user
    @team = team
  end

  def is_member?
    @team.users.exists?(user.id)
  end

  alias_method :show?, :is_member?

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      user.teams
    end
  end

end
