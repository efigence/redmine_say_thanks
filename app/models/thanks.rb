class Thanks < ActiveRecord::Base
  unloadable

  # Rails 4 but I still need this
  attr_accessible :receiver_id

  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'

  validates_presence_of :sender_id, :receiver_id
end
