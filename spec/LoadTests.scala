import io.gatling.core.Predef._
import io.gatling.http.Predef._
import io.gatling.commons.validation._
import scala.concurrent.duration._

class SectorReservationSimulationRorStandard extends Simulation {
  val feeder = (1 to 50).iterator.map(i => Map("sector_id" -> i.toString, "tickets_count" -> 7)).toArray.circular

  val httpConf = http
    .baseURL("http://localhost:9292/api")
    .headers(Map("Accept" -> "application/json", "Content-Type" -> "application/json"))
    .disableCaching

  val reserveSector = http("reserve")
    .post("/reservations")
    .body(StringBody("""{ "reservation": { "sector_id": "${sector_id}", "tickets_count": "${tickets_count}" } }"""))
    .check(status.is(200))
    .check(jsonPath("$.reservation_id").saveAs("reservation_id"))

  val checkReservation = http("check reservation")
    .get("/reservations/${reservation_id}")
    .check(status.is(200))
    .check(jsonPath("$.reservation").saveAs("reservation"))

  val reservationNotFound = (session: Session) => session("reservation")
    .validate[String]
    .map(value => value == "not found")

  val scn = scenario("Test")
    .feed(feeder)
    .exec(reserveSector)
    .exec(checkReservation)
    .asLongAs(reservationNotFound) { pause(5).exec(checkReservation) }

  setUp(scn.inject(atOnceUsers(100)).protocols(httpConf))
}
