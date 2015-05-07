require File.expand_path('../../test_helper', __FILE__)

class UsersTest < ActiveSupport::TestCase

  def setup
    Setting.plugin_redmine_say_thanks['group_ids'] = %w(10 11)
    Setting.plugin_redmine_say_thanks['group_managers'] = { '10' => %w(2), '11' => %w(2) }
  end

  test "user should be permitted to use thanks plugin if belongs to proper group" do
    assert users(:andrew).in_group_permitted_to_thanks?, 'not permitted to use thanks'
    assert users(:andrew).can_access_thanks?, 'cannot access thanks'

    assert_not users(:not_permitted).in_group_permitted_to_thanks?, 'permitted to use thanks'
    assert_not users(:not_permitted).can_access_thanks?, 'can access thanks'
  end

  test "user should get proper manageable group ids" do
    assert_equal %w(10 11), users(:manager).manageable_thanks_group_ids
    assert_equal [], users(:andrew).manageable_thanks_group_ids
  end

  test "thankable scope should return users taking part in thanks but not self" do
    User.current = users(:manager)
    assert_equal User.find(3,4), User.thankable
  end

  test "next thanks date should return today if user can give thanks now" do
    Setting.plugin_redmine_say_thanks['vote_frequency'] = '1'
    user = users(:andrew)
    last_thanks_date = user.sent_thanks.last.created_at

    assert_equal (last_thanks_date + 1.day).to_date, users(:andrew).next_thanks_date
  end

  test "next thanks date should return today + numer of days from config if already voted today" do
    Setting.plugin_redmine_say_thanks['vote_frequency'] = '1'
    user = users(:andrew)
    receiver = users(:manager)
    thanks = user.sent_thanks.create!(receiver_id: receiver.id)
    assert_equal thanks, user.sent_thanks.last
    assert_equal thanks, receiver.received_thanks.last
    assert_equal Date.today + 1.day, user.next_thanks_date
  end

  test "with_thanks_stats scope should return proper values" do
    user_with_stats = User.where(id: 2).with_thanks_stats.first

    assert_equal 1, user_with_stats.active
    assert_equal 0, user_with_stats.waiting
    assert_equal 0, user_with_stats.rewarded
    assert_equal 1, user_with_stats.unrolled
    assert_equal 1, user_with_stats.sent
  end
end
