module Api
  class SchedulesController < ApplicationController
    DATE_PATTERN = /\A\d{4}-\d{2}-\d{2}\z/

    def show
      result = ScheduleLoader.new(date: params[:date]).call

      if result.success?
        render json: schedule_payload(result.schedule)
      else
        render json: { error: result.error }, status: result.status
      end
    end

    def update
      date = required_date_param
      return unless date

      appointments = appointments_from_params
      error_message = ScheduleAppointmentValidator.error_message(appointments)
      if error_message
        render json: { error: error_message }, status: :bad_request
        return
      end

      schedule = Schedule.find_or_initialize_by(date: Date.current)
      schedule.replace_appointments(appointments)
      render json: schedule_payload(schedule)
    end

    def destroy
      render json: { error: "Not implemented." }, status: :not_implemented
    end

    private

    def required_date_param
      date = params[:date].to_s
      unless date.match?(DATE_PATTERN)
        render json: { error: "Missing or invalid `date` query param (expected YYYY-MM-DD)." }, status: :bad_request
        return nil
      end

      date
    end

    def appointments_from_params
      Array(params[:appointments]).map do |appointment|
        raw = appointment.respond_to?(:to_unsafe_h) ? appointment.to_unsafe_h : appointment
        raw = raw.deep_stringify_keys if raw.respond_to?(:deep_stringify_keys)
        raw
      end
    end

    def schedule_payload(schedule)
      {
        date: schedule.date.to_s,
        appointments: schedule.appointments
      }
    end
  end
end
