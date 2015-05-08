# Redmine Say Thanks plugin

#### Plugin which lets users give thanks to other group members. Obtained points are rewardable by group managers.

## Requirements

Developed and tested on Redmine 3.0.1.

## Installation

1. Go to your Redmine installation's plugins/ directory.
2. `git clone https://github.com/efigence/redmine_say_thanks`
3. Go back to root directory.
4. `rake redmine:plugins:migrate RAILS_ENV=production`
5. Restart Redmine.

## Configuration

Visit Administration -> Plugins. Afterwards, click on `Configure` link next to the plugin name.

Here you can define:

* which groups of users take part in Say Thanks
* which users are going to be the managers of selected groups
* `unroll period` - for how many days users can cancel thanks which he has already sent (defaults to 7 days)
* `vote frequency` - how often user can give thanks to others (defaults to 1 day)

## Usage

##### User

* Give thanks to colegues for helping you out.
* Gather points.
* Use your points to get a reward from manager.
* Unroll your thanks if you happen to change your mind.
* Check stats of your points, sent thanks, received rewards.

##### Manager

* See the list of thanks of all group members.
* See users points statistics.
* Assign rewards to users.
* See rewards history.

## License

    Redmine Say Thanks plugin
    Copyright (C) 2015  efigence S.A.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
