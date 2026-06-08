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
      result = ScheduleReplacer.new(date: params[:date], appointments: appointments_from_params).call

      if result.success?
        render json: schedule_payload(result.schedule)
      else
        render json: { error: result.error }, status: result.status
      end
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
      permitted = params.permit(appointments: [:id, :time, { pet: [:name, :type] }])
      permitted[:appointments]&.map(&:to_h)
    end

    def schedule_payload(schedule)
      {
        date: schedule.date.to_s,
        appointments: schedule.appointments
      }
    end
  end
end
