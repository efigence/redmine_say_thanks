class CreateThanks < ActiveRecord::Migration
  def change
    create_table :thanks do |t|
      t.integer :sender_id, index: true
      t.integer :receiver_id, index: true
      t.string :status

      t.timestamps
    end
  end
end
