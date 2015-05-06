class AddTimestampsToThanksRewards < ActiveRecord::Migration
  def change
    add_timestamps :thanks_rewards
  end
end
