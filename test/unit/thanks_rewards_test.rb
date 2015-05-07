require File.expand_path('../../test_helper', __FILE__)

class ThanksRewardsTest < ActiveSupport::TestCase

  def setup
    Setting.plugin_redmine_say_thanks['group_ids'] = %w(10 11)
    Setting.plugin_redmine_say_thanks['group_managers'] = { '10' => %w(2), '11' => %w(2) }

    100.times do |i|
      Thanks.new.tap do |t|
        t.sender_id = 2
        t.receiver_id = 3
        t.save
        t.created_at = (Date.today - eval(i.to_s).days).to_time
        t.save(validate: false)
      end
    end
  end

  test "user should be able to get a reward if has enough points to use" do
    receiver = users(:andrew)
    manager = users(:manager)
    points_to_use = receiver.received_thanks.to_use.count
    reward = manager.managed_rewards.new(user_id: receiver.id, points: 50, title: 'Reward')
    assert reward.save!
    new_points_to_use = receiver.received_thanks.reload.to_use.count
    assert_equal points_to_use - 50, new_points_to_use
    rewarded_thanks = receiver.received_thanks.rewarded
    assert 50, receiver.received_thanks.rewarded.count
    assert rewarded_thanks.all? { |t| t.reward == reward }
  end

  test "user shouldn't be able to get a reward if hasn't enough points to use" do
    receiver = users(:andrew)
    manager = users(:manager)
    reward = manager.managed_rewards.new(user_id: receiver.id, points: 500, title: 'Reward')
    assert_raise ActiveRecord::RecordInvalid do
      reward.save!
    end
    assert_equal 0, receiver.received_thanks.rewarded.count
  end

  test "user which doesn't take part in say thanks should not be rewarded" do
    receiver = users(:not_permitted)
    manager = users(:manager)
    reward = manager.managed_rewards.new(user_id: receiver.id, points: 1, title: 'Reward')
    assert_raise ActiveRecord::RecordInvalid do
      reward.save!
    end
  end

  test "user which is not manager should not be able to to reward anyone" do
    receiver = users(:andrew)
    manager = users(:not_permitted)
    reward = manager.managed_rewards.new(user_id: receiver.id, points: 50, title: 'Reward')
    assert_raise ActiveRecord::RecordInvalid do
      reward.save!
    end
  end

  test "reward shouldn't be saved with use of quarantine points" do
    receiver = users(:andrew)
    manager = users(:manager)
    points_to_use = receiver.received_thanks.to_use.count
    points_in_quarantine = receiver.received_thanks.quarantine.count
    total = points_to_use + points_in_quarantine
    reward = manager.managed_rewards.new(user_id: receiver.id, points: total, title: 'Reward')
    assert_raise ActiveRecord::RecordInvalid do
      reward.save!
    end
  end
end
