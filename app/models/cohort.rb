WEEK_IN_SEC = 7 * 24 * 3600
WeekStats = Struct.new(:total_week_orderers, :first_time_week_orderers)

class Cohort < ApplicationRecord

  def get(weeks_limit)
    cohorts = {}
    users = User.order(:created_at).reverse
    latest_time = users.first.created_at.to_time.to_i

    # Get user ids.
    users.each do |u|
      weeks_diff = (latest_time - u.created_at.to_time.to_i)/WEEK_IN_SEC
      break if weeks_diff >= weeks_limit
      key = latest_time - (weeks_diff * WEEK_IN_SEC)

      if cohorts[key]
        cohorts[key][0] << u.id
      else
        cohorts[key] = [[u.id], []]
      end
    end

    # Collect order stats.
    cohorts.keys.sort.reverse.each do |k|
      k.step(latest_time, WEEK_IN_SEC) do |week_end|
        week_start = week_end - WEEK_IN_SEC

        orders = Order.where(user_id: cohorts[k][0],
                             created_at: Time.at(week_start)..Time.at(week_end))
        cohorts[k][1] << WeekStats.new(orders.distinct.count(:user_id),
                                       orders.where(order_num: 1).count)
      end
    end

    # Replace arrays of user ids with their respective total counts.
    cohorts.keys.each {|k| cohorts[k][0] = cohorts[k][0].size}
    cohorts
  end

end
