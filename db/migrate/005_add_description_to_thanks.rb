class AddDescriptionToThanks < ActiveRecord::Migration
  def change
    add_column :thanks, :description, :text
  end
end
