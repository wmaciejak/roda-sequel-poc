require 'pry'
require 'sidekiq'
module Services
  class ProcessReservation
    include ::Sidekiq::Worker

    REQUEST_TTL = (Time.now + 60).to_i

    def perform(reservation_id, requested_at, params)
      ::DB.transaction do
        begin
          reservation = Reservation.create(
            id: reservation_id,
            sector_id: params["sector_id"],
            tickets_count: params["tickets_count"],
            status: "requested",
            requested_at: requested_at,
          )

          if Time.now.to_i - Time.parse(requested_at).to_i > REQUEST_TTL
            reservation.update(status: "request_timed_out")
            return
          end

          if Sector[params["sector_id"]].available_tickets_count < params["tickets_count"].to_i
            reservation.update(status: "not_enough_tickets_in_sector")
            return
          end

          reservation.update(status: "payment_pending")
          DB[:sectors].where(id: params["sector_id"]).update(
            available_tickets_count: Sequel.expr(:available_tickets_count) - params["tickets_count"],
          )

        rescue Sequel::CheckConstraintViolation
          reservation.update(status: "not_enough_tickets_in_sector")
        end
      end
    end
  end
end
