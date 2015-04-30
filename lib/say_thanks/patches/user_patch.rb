require_dependency 'user'

module SayThanks
  module Patches
    module UserPatch
      def self.included(base)
        base.class_eval do
          unloadable
          base.send(:include, InstanceMethods)

          has_many :sent_thanks,     class_name: 'Thanks', foreign_key: :sender_id
          has_many :received_thanks, class_name: 'Thanks', foreign_key: :receiver_id

          scope :thankable, -> { all }

        end
      end
      module InstanceMethods
      end
    end
  end
end
