class Thanks < ActiveRecord::Base
  unloadable

  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'
end
