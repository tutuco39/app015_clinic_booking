class ReservationsController < ApplicationController
  def new
    @reservation = Reservation.new
  end

  def create
    @reservation = Reservation.new(reservation_params)
    if @reservation.save
      # 患者への確認メール
      ReservationMailer.confirmation(@reservation).deliver_later
      # 医院への通知メール
      ReservationMailer.notify_clinic(@reservation).deliver_later

      redirect_to new_reservation_path, notice: "予約を受け付けました。確認メールを送信しました。"
    else
      flash.now[:alert] = @reservation.errors.full_messages.join(" / ")
      render :new, status: :unprocessable_entity
    end
  end


  def notify_clinic(reservation)
    @reservation = reservation
    mail to: "clinic_staff@example.com", subject: "【新規予約】#{reservation.name}様からの予約"
  end

  def index
    @reservations = Reservation.order(starts_at: :asc).limit(100)
  end

  def slots
    date = params[:date]
    if date.present?
      slots = Reservation.open_slots_for(date).map { |t| t.strftime("%H:%M") }
      render json: { date: date, slots: slots }
    else
      render json: { error: "date を指定してください" }, status: :bad_request
    end
  end

  private

  def reservation_params
    # starts_at を date(YYYY-MM-DD) + time(HH:MM) から合成
    if params[:reservation][:date].present? && params[:reservation][:time].present?
      params[:reservation][:starts_at] = Time.zone.parse("#{params[:reservation][:date]} #{params[:reservation][:time]}")
    end
    params.require(:reservation).permit(:name, :email, :tel, :menu, :message, :starts_at)
  end
end
