class AppName
  route "api" do |r|
    r.is 'reservations', String do |reservation_id|
      r.get do
        reservation = Reservation[reservation_id]
        if reservation
          response.status = 200
          { reservation: reservation.values }.to_json
        else
          response.status = 404
          { reservation: "not found" }.to_json
        end
      end

      # r.post "payment_callback" do
      #   "valid"
      # end
    end

    r.post "reservations" do
      reservation_id = SecureRandom.uuid
      Services::ProcessReservation.perform_async(reservation_id, Time.now, r.params["reservation"])

      { reservation_id: reservation_id }.to_json
    end
  end
end
