class WelcomeController < ApplicationController
  def index
    @status = Status.new
    @statuses = logged_in? ? Status.where(user: current_user.accepted_friends << current_user) : []
  end
end
