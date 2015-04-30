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

        def can_use_thanks_plugin?
          logged? && in_group_permitted_to_thanks?
        end

        def can_give_thanks?
          # TODO: sprawdzamy czy oddał już głos w okresie frequency z konfiga
        end

        def can_manage_thanks?
          return false unless in_group_permitted_to_thanks?

          usr_group_ids = groups.pluck(:id).map(&:to_s)
          group_permissions = Setting.plugin_redmine_say_thanks['group_managers'] || {}

          perm = false
          usr_group_ids.each do |id|
            if group_permissions['id'].try(:include?, id)
              perm = true
              break
            end
          end
          perm
        end

        def in_group_permitted_to_thanks?
          (groups.pluck(:id).map(&:to_s) & (Setting.plugin_redmine_say_thanks['group_ids'] || [])).any?
        end
      end
    end
  end
end
