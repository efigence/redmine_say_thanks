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

          scope :in_groups, lambda {|group_ids|
            where("#{User.table_name}.id IN (SELECT gu.user_id FROM #{table_name_prefix}groups_users#{table_name_suffix} gu WHERE gu.group_id IN (?))", group_ids)
          }

          scope :thankable, lambda {
            permitted_group_ids = Setting.plugin_redmine_say_thanks['group_ids'] || []
            in_groups(permitted_group_ids).where.not(id: User.current.id)
          }

        end
      end
      module InstanceMethods

        def can_access_thanks?
          logged? && in_group_permitted_to_thanks?
        end

        def can_give_thanks?
          next_thanks_date <= Date.today
        end

        def next_thanks_date
          last_thanks = sent_thanks.last
          if last_thanks
            last_thanks.created_at.to_date + eval(Thanks.permitted_vote_frequency).day
          else
            Date.today
          end
        end

        def pretty_next_thanks_date
          next_thanks_date.strftime('%d %B, %Y')
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
          permitted_group_ids = Setting.plugin_redmine_say_thanks['group_ids']
          return false if permitted_group_ids.blank?
          admin? || (groups.pluck(:id).map(&:to_s) & permitted_group_ids).any?
        end
      end
    end
  end
end
