module Api
  class SchedulesController < ApplicationController
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
      parsed_date = ScheduleDate.parse(params[:date])

      if parsed_date.success?
        schedule = Schedule.find_for_date(parsed_date.date)
      else
        render json: { error: parsed_date.error }, status: parsed_date.status
        return
      end

      if schedule
        schedule.remove_appointment!(params[:appointment_id])
        render json: schedule_payload(schedule)
      else
        render json: { error: "Schedule not found." }, status: :not_found
      end
    end

    private

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
