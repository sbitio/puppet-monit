# @summary Validate the value of the ensure parameter for a check
type Monit::Check::Ensure = Variant[Boolean, Enum['true', 'false', 'present', 'absent']]
