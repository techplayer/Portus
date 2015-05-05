class TeamUsersController < ApplicationController
  after_action :verify_authorized
  before_action :set_team, only: [:update, :destroy]
  respond_to :js

  # POST /team_users
  # POST /team_users.json
  def create
    team = Team.find_by!(name: params['team_user']['team'])
    user = User.find_by(username: params['team_user']['user'])

    @team_user = TeamUser.new(team: team, user: user, role: params['team_user']['role'])
    authorize @team_user

    if user.nil?
      @team_user.errors.add(:user, 'cannot be found')
    end

    if @team_user.errors.empty? && @team_user.save
      respond_with @team_user
    else
      respond_with @team_user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /team_users/1
  # DELETE /team_users/1.json
  def destroy
    authorize @team_user
    team = @team_user.team
    locals = {}
    if team.owners.exists?(@team_user.user.id) &&
      team.owners.count == 1
      locals[:error] = 'Cannot remove the only owner of the team'
    else
      @team_user.destroy
      locals[:team_user_id] = params[:id]
    end
    render template: 'team_users/destroy', locals: locals
  end

  # PATCH/PUT /team_users/1
  # PATCH/PUT /team_users/1.json
  def update
    authorize @team_user
    team_user_params = params.require(:team_user).permit(:role)
    team = @team_user.team
    if team.owners.exists?(@team_user.user.id) &&
      team.owners.count == 1 &&
      team_user_params['role'] != 'owner'
      @team_user.errors.add(:role, 'cannot be changed for the only owner of the team')
    else
      @team_user.update(team_user_params)
    end
    render template: 'team_users/update', locals: { team_user: @team_user }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_team
    @team_user = TeamUser.find(params[:id])
  end


end
