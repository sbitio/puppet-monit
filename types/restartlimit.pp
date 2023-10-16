# @summary  Validate the data structure of the restart_limit parameter
type Monit::RestartLimit = Struct[{
    restarts => Variant[String, Integer],
    cycles   => Variant[String, Integer],
    action   => String,
}]
