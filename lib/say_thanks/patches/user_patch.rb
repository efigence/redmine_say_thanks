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

          has_many :managed_rewards, class_name: 'ThanksReward', foreign_key: :manager_id
          has_many :received_rewards, class_name: 'ThanksReward', foreign_key: :user_id

          scope :in_groups, lambda {|group_ids|
            where("#{User.table_name}.id IN (SELECT gu.user_id FROM #{table_name_prefix}groups_users#{table_name_suffix} gu WHERE gu.group_id IN (?))", group_ids)
          }

          scope :thankable, lambda {
            permitted_group_ids = Setting.plugin_redmine_say_thanks['group_ids'] || []
            in_groups(permitted_group_ids).where.not(id: User.current.id)
          }

          scope :with_thanks_stats, lambda {
            end_wait_date = Thanks.quarantine_period_end.to_formatted_s(:db)

            select('users.id, users.firstname, users.lastname').
            select('COUNT(distinct s.id) sent').
            select('COUNT(distinct r_active.id) active').
            select('COUNT(distinct r_rewarded.id) rewarded').
            select('COUNT(distinct r_unrolled.id) unrolled').
            select('COUNT(distinct r_waiting.id) waiting').
            joins('LEFT OUTER JOIN thanks s ON s.sender_id = users.id').
            joins("LEFT OUTER JOIN thanks r_active ON r_active.receiver_id = users.id AND r_active.status = 0 AND r_active.created_at <= '#{end_wait_date}'").
            joins('LEFT OUTER JOIN thanks r_rewarded ON r_rewarded.receiver_id = users.id AND r_rewarded.status = 2').
            joins('LEFT OUTER JOIN thanks r_unrolled ON r_unrolled.receiver_id = users.id AND r_unrolled.status = 1').
            joins("LEFT OUTER JOIN thanks r_waiting ON r_waiting.receiver_id = users.id AND r_waiting.status = 0 AND DATE(r_waiting.created_at) > '#{end_wait_date}'").
            group(:id)
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
          last_thanks = sent_thanks.persisted.last
          if last_thanks
            last_thanks.created_at.to_date + eval(Thanks.vote_frequency).days
          else
            Date.today
          end
        end

        def pretty_next_thanks_date
          next_thanks_date.strftime('%d %B, %Y')
        end

        def manageable_thanks_group_ids
          group_ids = groups.pluck(:id).map(&:to_s)
          group_managers = Setting.plugin_redmine_say_thanks['group_managers'] || {}
          if admin?
            group_managers.keys
          else
            group_ids.select { |gid| group_managers[gid].try(:include?, id.to_s) }
          end
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
