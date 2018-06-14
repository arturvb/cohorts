require 'time_difference'

WEEK_IN_SEC = 7 * 24 * 3600

class User < ApplicationRecord

  def get_cohorts(weeks_limit=8)
    cohorts = {}
    last_time = User.order(:created_at).last.created_at
    last_key = last_time.to_time.to_i

    User.order(:created_at).reverse.each do |u|
      weeks_diff = TimeDifference.between(last_time, u.created_at).in_weeks.to_i
      break if weeks_diff > weeks_limit
      key = last_key - (weeks_diff * WEEK_IN_SEC)

      if cohorts[key]
        cohorts[key] << u.id
      else
        cohorts[key] = [u.id]
      end
    end

    cohorts
  end

end
