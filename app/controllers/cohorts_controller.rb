class CohortsController < ApplicationController
  def show
    weeks = params[:weeks].to_i
    weeks = 8 if weeks == 0
    @cohorts = Cohort.new.get(weeks)
    #render json: @cohorts
  end
end
