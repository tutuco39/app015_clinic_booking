class Reservation < ApplicationRecord
  BUSINESS = { morning: { start: "09:00", end: "12:00" },
               afternoon: { start: "16:00", end: "19:00" } }
  validates :name, :email, :tel, :menu, :starts_at, presence: true
  validates :tel, format: { with: /\A\d{10,11}\z/, message: "はハイフンなし10〜11桁で入力してください" }
  validates :starts_at, uniqueness: { message: "は既に予約があります。別の時間をお選びください" }


  def self.open_slots_for(date)
    d = Date.parse(date.to_s)
    return [] if d.sunday? # 祝日は後で拡張

    slots = []
    slots += half_hour_slots(d, BUSINESS[:morning][:start], BUSINESS[:morning][:end])
    unless d.wednesday? || d.saturday?
      slots += half_hour_slots(d, BUSINESS[:afternoon][:start], BUSINESS[:afternoon][:end])
    end
    reserved = Reservation.where(starts_at: slots).pluck(:starts_at)
    slots - reserved
  end

  def self.half_hour_slots(date, from_str, to_str)
    from = Time.zone.parse("#{date} #{from_str}")
    to   = Time.zone.parse("#{date} #{to_str}")
    out = []; t = from
    while t < to
      out << t
      t += 30.minutes
    end
    out
  end
end
