class AddRewardReferencesToThanks < ActiveRecord::Migration
  def change
    add_column :thanks, :reward_id, :integer
  end
end
