class ThanksReward < ActiveRecord::Base
  unloadable

  attr_accessible :user_id, :title, :points

  has_many :thanks, class_name: 'Thanks', foreign_key: :reward_id

  belongs_to :manager, class_name: 'User'
  belongs_to :user

  validates_presence_of :manager_id, :user_id, :points, :title
  validates_numericality_of :points, :only_integer => true, :greater_than_or_equal_to => 1
  validate :user_has_enough_points
  validate :user_is_rewardable
  validate :manager_has_permissions

  after_save :mark_thanks

  private

  def user_thanks_to_use
    user.received_thanks.to_use
  end

  def manager_has_permissions
    return if manager.blank?
    group_managers = Setting.plugin_redmine_say_thanks['group_managers'] || {}
    unless group_managers.values.flatten.include?(manager.id.to_s)
      errors.add(:base, "Current user doesn't have manager privileges.")
    end
  end

  def user_is_rewardable
    if user && !user.in_group_permitted_to_thanks?
      errors.add(:base, "User doesn't take part in Say Thanks.")
    end
  end

  def user_has_enough_points
    return unless user.present? && points.present?
    unless user_thanks_to_use.count >= points
      errors.add(:base, "User doesn't have enough spare points.")
    end
  end

  def mark_thanks
    rewarded_thanks_ids = user_thanks_to_use.take(points).map(&:id)
    user.received_thanks.where(id: rewarded_thanks_ids).mark_as_rewarded(self.id)
  end
end
