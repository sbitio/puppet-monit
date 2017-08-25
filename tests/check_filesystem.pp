include '::monit'

monit::check::filesystem { 'somefs':
  path  => '/mount/somefs',
  tests => [
    {'type' => 'fsflags'},
    {'type' => 'permission', 'value' => '0755'},
    {'type' => 'space', 'operator' => '>', 'value' => '80%'},
  ]
}
