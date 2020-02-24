type Monit::RestartLimit = Struct[{
  restarts => Variant[String, Integer],
  cycles   => Variant[String, Integer],
  action   => String,
}]
