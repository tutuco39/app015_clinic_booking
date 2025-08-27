class CreateReservations < ActiveRecord::Migration[7.2]
  def change
    create_table :reservations do |t|
      t.string :name
      t.string :email
      t.string :tel
      t.string :menu
      t.text :message
      t.datetime :starts_at

      t.timestamps
    end
  end
end
