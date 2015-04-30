class Thanks < ActiveRecord::Base
  unloadable

  enum status: [:active, :unrolled, :rewarded]

  # Rails 4 but I still need this
  attr_accessible :receiver_id, :status

  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'

  validates_presence_of :sender_id, :receiver_id

  validate :user_can_thank_now, on: :create


  # todo: valiadate that cant unroll if rewarded of time of unrollment is over

  scope :persisted, -> { where "id IS NOT NULL" }

  def self.permitted_vote_frequency
    Setting.plugin_redmine_say_thanks['vote_frequency'] || '1'
  end

  def self.unroll_period
    Setting.plugin_redmine_say_thanks['unroll_period'] || '7'
  end

  def can_be_unrolled?
    active? && !unroll_time_over?
  end

  def unroll_time_over?
    unroll_until < Date.today
  end

  def unroll_until
    created_at.to_date + eval(self.class.unroll_period).days
  end

  private

  def user_can_thank_now
    unless sender.can_give_thanks?
      errors.add(:base, "You can say thanks again on #{sender.pretty_next_thanks_date}")
    end
  end
end
