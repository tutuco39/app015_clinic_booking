class AddIndexOnReservationsStartsAt < ActiveRecord::Migration[7.2]
  def change
    add_index :reservations, :starts_at, unique: true
  end
end
