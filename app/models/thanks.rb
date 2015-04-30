class Thanks < ActiveRecord::Base
  unloadable

  # Rails 4 but I still need this
  attr_accessible :receiver_id

  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'

  validates_presence_of :sender_id, :receiver_id

  validate :user_can_thank_now

  def self.permitted_vote_frequency
    Setting.plugin_redmine_say_thanks['vote_frequency'] || '1'
  end

  private

  def user_can_thank_now
    unless sender.can_give_thanks?
      errors.add(:base, "You can say thanks again on #{sender.pretty_next_thanks_date}")
    end
  end
end
