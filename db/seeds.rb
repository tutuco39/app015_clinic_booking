# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require "faker"

def next_open_date(from = Time.zone.today)
  d = from
  loop do
    return d unless d.sunday?           # 日曜は除外（祝日は後で拡張）
    d += 1.day
  end
end

date  = next_open_date(Time.zone.today + 1.day)
slots = Reservation.open_slots_for(date)

# もし空なら、翌営業日の枠を拾う
if slots.blank?
  date  = next_open_date(date + 1.day)
  slots = Reservation.open_slots_for(date)
end

created = 0
slots.first(10).each do |t|
  r = Reservation.create!(
    name:  Faker::Name.name,
    email: Faker::Internet.email,
    tel:   Faker::Number.number(digits: 11),
    starts_at: t,
    menu:  ["初診（検診・痛み）","再診","クリーニング","矯正相談"].sample,
    message: Faker::Lorem.sentence
  )

  # メール送信
  ReservationMailer.confirmation(r).deliver_now
  ReservationMailer.notify_clinic(r).deliver_now

  created += 1
end

puts "[seed] date=#{date} / generated=#{created} reservations"

