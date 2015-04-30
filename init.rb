Redmine::Plugin.register :redmine_say_thanks do
  name 'Say Thanks plugin'
  author 'Jacek Grzybowski'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/efigence/redmine_say_thanks'
  author_url 'https://github.com/efigence'

  menu :top_menu,
      :thanks,
      { :controller => 'thanks', :action => 'index' },
      :caption => 'Thanks',
      :if => Proc.new { User.current.logged? }
      # TODO: user musi nalezec do grupy ktora jest wlaczona w ustawieniach

  settings :default => {
    'group_ids' => [],
    'group_managers' => {},
    'unroll_period' => '7',
    'vote_frequency' => '1'
  }, :partial => 'settings/say_thanks_settings'

end

ActionDispatch::Callbacks.to_prepare do
  User.send(:include, SayThanks::Patches::UserPatch)
end
