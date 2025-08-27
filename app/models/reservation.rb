class Reservation < ApplicationRecord
  validates :name, :email, :starts_at, presence: true
  validate  :within_business_hours
  validate  :on_30min_mark

  # 水曜/土曜の午後休、日祝休の想定
  BUSINESS = {
    morning: { start: "09:00", end: "12:00" }, # 終了は予約開始の上限
    afternoon: { start: "16:00", end: "19:00" }
  }

  def self.open_slots_for(date)
    date = Date.parse(date.to_s)
    # 日曜は全休
    return [] if date.sunday?

    slots = []

    # 午前は 月〜土 あり
    slots += half_hour_slots(date, BUSINESS[:morning][:start], BUSINESS[:morning][:end])

    # 午後は 月火木金のみ（= 水・土は午後なし）
    unless date.wednesday? || date.saturday?
      slots += half_hour_slots(date, BUSINESS[:afternoon][:start], BUSINESS[:afternoon][:end])
    end

    # 既存予約を除外
    reserved = Reservation.where(starts_at: slots).pluck(:starts_at)
    slots - reserved
  end

  def self.half_hour_slots(date, from_str, to_str)
    from = Time.zone.parse("#{date} #{from_str}")
    to   = Time.zone.parse("#{date} #{to_str}")
    out  = []
    t = from
    while t < to
      out << t
      t += 30.minutes
    end
    out
  end

  private

  def on_30min_mark
    return if starts_at.blank?
    unless starts_at.min.in?([0,30]) && starts_at.sec.zero?
      errors.add(:starts_at, "は30分刻みで選択してください")
    end
  end

  def within_business_hours
    return if starts_at.blank?
    date = starts_at.to_date
    # 日曜は全休
    if date.sunday?
      errors.add(:starts_at, "は休診日に当たります")
      return
    end

    morning_ok  = time_in_range?(starts_at, date, BUSINESS[:morning])
    afternoon_ok = !(date.wednesday? || date.saturday?) && time_in_range?(starts_at, date, BUSINESS[:afternoon])

    unless morning_ok || afternoon_ok
      errors.add(:starts_at, "は診療時間外です（水曜・土曜の午後は休診）")
    end
  end

  def time_in_range?(time, date, range)
    s = Time.zone.parse("#{date} #{range[:start]}")
    e = Time.zone.parse("#{date} #{range[:end]}")
    time >= s && time < e
  end
end
