class CreateThanks < ActiveRecord::Migration
  def change
    create_table :thanks do |t|
      t.integer :sender_id, index: true
      t.integer :receiver_id, index: true
      t.integer :status, default: 0, null: false, index: true

      t.timestamps
    end
  end
end
