class CreateThanksRewards < ActiveRecord::Migration
  def change
    create_table :thanks_rewards do |t|
      t.integer :user_id, index: true
      t.integer :manager_id, index: true
      t.string :title
      t.integer :points
    end
  end
end
