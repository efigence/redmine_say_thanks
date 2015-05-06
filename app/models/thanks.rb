class Thanks < ActiveRecord::Base
  unloadable

  enum status: [:active, :unrolled, :rewarded]

  VOTE_FREQUENCY = Setting.plugin_redmine_say_thanks['vote_frequency'] || '1'
  UNROLL_PERIOD = Setting.plugin_redmine_say_thanks['unroll_period'] || '7'

  attr_accessible :receiver_id, :status

  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'
  belongs_to :reward, class_name: 'ThanksReward'

  validates_presence_of :sender_id, :receiver_id

  validate :user_can_thank_now, on: :create

  validate :not_rewarded_yet, if: :just_unrolled?

  validate :unroll_time_not_over, if: :just_unrolled?

  scope :persisted, -> { where "id IS NOT NULL" }

  scope :involving, -> (user_ids) {
    where('sender_id IN (:ids) OR receiver_id IN (:ids)', ids: user_ids)
  }

  scope :sent_by, -> (user_ids) { where(sender_id: user_ids) }

  scope :received_by, -> (user_ids) { where(receiver_id: user_ids) }

  scope :status, -> (status) { where(status: status) }

  scope :date_created, -> (string_date) {
    date = Date.parse(string_date)
    where(created_at: (date.beginning_of_day..date.end_of_day))
   }

  scope :quarantine, -> {
    active.select(&:can_be_unrolled?)
  }

  scope :to_use, -> {
    active.order(created_at: :asc).reject(&:can_be_unrolled?)
  }

  def self.waiting_period_end
    Date.today - eval(UNROLL_PERIOD).days
  end

  def self.mark_as_rewarded(reward_id)
    update_all(reward_id: reward_id, status: 2)
  end

  def self.stats
    {
      total:      where.not(status: 1).count,
      to_spend:   to_use.count,
      quarantine: quarantine.count,
      unrolled:   unrolled.count,
      spent:      rewarded.count
    }
  end

  def status
    if quarantine?
      "quarantine"
    else
      super
    end
  end

  def quarantine?
    active? && can_be_unrolled?
  end

  def can_be_unrolled?
    active? && !unroll_time_over?
  end

  def unroll_time_over?
    unroll_until < Date.today
  end

  def unroll_until
    created_at.to_date + eval(UNROLL_PERIOD).days
  end

  private

  def just_unrolled?
    status_changed? && unrolled?
  end

  def not_rewarded_yet
    if status_was == "rewarded"
      errors.add(:base, "Cannot unroll thanks which was already rewarded")
    end
  end

  def unroll_time_not_over
    if unroll_time_over?
      errors.add(:base, "Unroll time is over")
    end
  end

  def user_can_thank_now
    unless sender.can_give_thanks?
      errors.add(:base, "You can say thanks again on #{sender.pretty_next_thanks_date}")
    end
  end
end
