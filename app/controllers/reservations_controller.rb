class ReservationsController < ApplicationController
  def new
    @reservation = Reservation.new
    prepare_slots
  end


  def create
    @reservation = Reservation.new(reservation_params)
    if @reservation.save
      ReservationMailer.confirmation(@reservation).deliver_later
      ReservationMailer.notify_clinic(@reservation).deliver_later
      redirect_to new_reservation_path, notice: "予約を受け付けました。確認メールを送信しました。"
    else
      prepare_slots
      flash.now[:alert] = @reservation.errors.full_messages.join(" / ")
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @reservation.errors.add(:starts_at, "は既に予約があります。別の時間をお選びください")
    prepare_slots
    flash.now[:alert] = @reservation.errors.full_messages.join(" / ")
    render :new, status: :unprocessable_entity
  end

  def notify_clinic(reservation)
    @reservation = reservation
    mail to: "clinic_staff@example.com", subject: "【新規予約】#{reservation.name}様からの予約"
  end

  def index
    # ?on=YYYY-MM-DD（例: 2025-09-01）で指定。なければ今日。
    @on = begin
      Date.parse(params[:on]) if params[:on].present?
    rescue ArgumentError
      nil
    end || Time.zone.today

    @reservations = Reservation.where(starts_at: @on.all_day).order(:starts_at)
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

  def prepare_slots
    if @reservation.starts_at.present?
      date = @reservation.starts_at.to_date
      @slots = Reservation.open_slots_for(date).map { |t| t.strftime("%H:%M") }
    else
      @slots = []
    end
  end
end
