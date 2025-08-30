class ReservationMailer < ApplicationMailer
  default from: "clinic@example.com"

  def confirmation(reservation)
    @reservation = reservation
    mail to: reservation.email,
    subject: "【しらゆき歯科】ご予約ありがとうございます"
  end

  def notify_clinic(reservation)
    @reservation = reservation
    mail to: "clinic_staff@example.com",
    subject: "【新規予約】#{reservation.name}様からの予約"
  end
end

