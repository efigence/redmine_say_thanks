Redmine::Plugin.register :redmine_say_thanks do
  name 'Say Thanks plugin'
  author 'Jacek Grzybowski'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/efigence/redmine_say_thanks'
  author_url 'https://github.com/efigence'
end

ActionDispatch::Callbacks.to_prepare do
  User.send(:include, SayThanks::Patches::UserPatch)
end
