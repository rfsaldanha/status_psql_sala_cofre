# Packages
suppressMessages({
  library(cli)
  library(lubridate)
  library(glue)
  library(ntfy)
  library(RPostgres)
})

# Setup
ntfy_topic <- "ocs_status_sala_cofre_psql"

cli_h1("Check PSQL Sala Cofre")

con <- tryCatch(
  {
    dbConnect(
      RPostgres::Postgres(),
      dbname = "observatorio",
      host = "psql.icict.fiocruz.br",
      port = 5432,
      user = Sys.getenv("weather_user"),
      password = Sys.getenv("weather_password")
    )
  },
  error = function(e) {
    cli_alert_warning("Could not connect to database.")
    ntfy_send(
      message = glue("Could not connect to database."),
      tags = tags$rotating_light,
      topic = ntfy_topic
    )
    ntfy_send(
      message = e,
      topic = ntfy_topic
    )
    message(e)
    cli_h1("END")
    cli_abort("Abort.")
  }
)

ntfy_send(
  message = glue("Connection to database was successfull."),
  tags = tags$white_check_mark,
  topic = ntfy_topic
)

dbDisconnect(con)

cli_h1("END")
