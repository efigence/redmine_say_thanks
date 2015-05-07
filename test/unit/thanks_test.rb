require File.expand_path('../../test_helper', __FILE__)

class ThanksTest < ActiveSupport::TestCase

  def setup
    Setting.plugin_redmine_say_thanks['group_ids'] = %w(10 11)
    Setting.plugin_redmine_say_thanks['group_managers'] = { '10' => %w(2), '11' => %w(2) }
    Setting.plugin_redmine_say_thanks['vote_frequency'] = '1'
  end

  test "quarantine should apply to thanks created more than vote_frequency days ago" do
    assert_equal Date.today - 1.day, Thanks.quarantine_period_end
  end

  test "new thanks should be in quarantine period and unrollable" do
    thanks = Thanks.find(2) # created 2 days ago
    assert_equal 'quarantine', thanks.status
    assert thanks.quarantine?
    assert thanks.can_be_unrolled?
    assert_not thanks.unroll_time_over?
    assert Date.today + 7.days, thanks.unroll_until

    assert thanks.unrolled!
    assert thanks.unrolled?
  end

  test "thanks should be active after quarantine period and not unrollable" do
    thanks = Thanks.find(1) # created 10 days ago
    assert_equal 'active', thanks.status
    assert_not thanks.quarantine?
    assert thanks.active?
    assert_not thanks.can_be_unrolled?
    assert thanks.unroll_time_over?
    assert Date.today > thanks.unroll_until

    assert_raise ActiveRecord::RecordInvalid do
      thanks.unrolled!
    end
  end

  test "user can't give thanks more than once in a specified period" do
    user = users(:andrew)
    receiver = users(:manager)
    thanks = user.sent_thanks.create!(receiver_id: receiver.id)
    second_thanks = user.sent_thanks.new(receiver_id: receiver.id)
    assert_not second_thanks.save
  end

  test "to use scope should return only active and not unrollable thanks" do
    assert_equal 1, Thanks.to_use.count
    assert Thanks.to_use.include?(Thanks.find(1))
  end

  test "involving scope should return all sender and receivers with passed ids" do
    assert_equal Thanks.where(id: [1,2]).pluck(:id), Thanks.involving([3]).pluck(:id)
  end
end
