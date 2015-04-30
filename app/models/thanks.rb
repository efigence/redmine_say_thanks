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
    return if sender_id.blank?
    sender = User.find(sender_id)
    last_thanks = sender.sent_thanks.last
    return unless last_thanks
    perm_freq = self.class.permitted_vote_frequency
    # todo: zmienić na 00:00 do 00:00 za x dni
    if last_thanks.created_at + eval(perm_freq).day > Time.now
      errors.add(:thanks, "cannot be created more often than once in #{perm_freq} days")
    end
  end
end
