# Validate monit tests and transforms some parts into monit language.
Puppet::Functions.create_function('monit_validate_tests') do
  # Validate monit tests
  # @param check_type The check type
  # @param tests The real tests
  # @return
  dispatch :validate do
    param 'String', :check_type
    param 'Tuple', :tests
  end

  # Valid tests for resources.
  # # RESOURCE TESTING: IF resource operator value THEN action
  # # SPACE TESTING: IF SPACE operator value unit THEN action
  # # INODE TESTING: IF INODE operator value [unit] THEN action
  RESOURCE_TESTS = [
    'CPU', 'CPU(USER)', 'CPU(SYSTEM)', 'CPU(WAIT)', 'TOTAL CPU', 'CHILDREN',
    'LOADAVG(1MIN)', 'LOADAVG(5MIN)', 'LOADAVG(15MIN)',
    'TOTAL MEMORY', 'MEMORY', 'SWAP'
  ].freeze
  # Valid operators for resource testing.
  RESOURCE_TESTS_OPERATORS = [
    '<', '>', '!=', '==',
    'GT', 'LT', 'EQ', 'NE',
    'GREATER', 'LESS', 'EQUAL', 'NOTEQUAL'
  ].freeze

  PROTOCOL_TESTS = {
    # TODO: GENERIC, SIP, RADIUS, WEBSOCKET
    # CHANGES: Param 'HOSTHEADER' changed to 'HTTP HEADERS' in monit 5.9, see https://mmonit.com/monit/changes/
    'GENERIC'       => ['SEND', 'EXPECT'],
    'HTTP'          => ['REQUEST', 'STATUS', 'CHECKSUM', 'HOSTHEADER', 'HTTP HEADERS', 'CONTENT'],
    'HTTPS'         => ['REQUEST', 'STATUS', 'CHECKSUM', 'HOSTHEADER', 'HTTP HEADERS', 'CONTENT'],
    'APACHE-STATUS' => ['LOGLIMIT', 'CLOSELIMIT', 'DNSLIMIT', 'KEEPALIVELIMIT', 'REPLYLIMIT', 'REQUESTLIMIT', 'STARTLIMIT', 'WAITLIMIT', 'GRACEFULLIMIT', 'CLEANUPLIMIT'],
  }.freeze

  TEST_TYPES = {
    'DIRECTORY'   => [],
    'FIFO'        => [],
    'FILE'        => ['PERMISSION', 'CHECKSUM', 'UID', 'GID', 'EXIST'],
    'FILESYSTEM'  => [
      'FSFLAGS', 'SPACE', 'INODE', 'PERM', 'PERMISSION'
    ],
    'HOST'        => ['CONNECTION'],
    'PROCESS'     => RESOURCE_TESTS + ['CONNECTION', 'UPTIME'],
    'PROGRAM'     => ['STATUS'],
    'SYSTEM'      => RESOURCE_TESTS + ['UPTIME'],
  }.freeze
  TEST_ACTIONS = ['ALERT', 'RESTART', 'START', 'STOP', 'EXEC', 'UNMONITOR'].freeze

  def validate(check_type, tests)
    check_type = check_type.upcase

    tests.each_with_index do |test, index|
      # Validate test type.
      test['type'] = test['type'].upcase
      unless TEST_TYPES[check_type].include? test['type']
        raise Puppet::ParseError, "Tests for '#{check_type}': invalid test type '#{test['type']}'. Valid types are #{TEST_TYPES[check_type]}"
      end

      exception_prefix = "Tests for '#{check_type}' ('#{test['type']}'): "

      # Validate failure tolerance and convert value to monit jargon.
      # # https://mmonit.com/monit/documentation/monit.html#failure_tolerance
      if test.key? 'tolerance'
        raise Puppet::ParseError, exception_prefix + "tolerance must be a hash with 'cycles' key and optionally 'times'." unless test['tolerance'].class == Hash && test['tolerance'].key?('cycles')
        test['tolerance'] = test['tolerance'].key?('times') ? "#{test['tolerance']['times']} TIMES WITHIN #{test['tolerance']['cycles']} CYCLES" : "#{test['tolerance']['cycles']} CYCLES"
      end

      # Validate action.
      # # https://mmonit.com/monit/documentation/monit.html#action
      if test.key? 'action'
        test['action'] = test['action'].upcase
        raise Puppet::ParseError, exception_prefix + "invalid action '#{test['action']}'" unless TEST_ACTIONS.include? test['action']
        if test['action'] == 'EXEC'
          raise Puppet::ParseError, exception_prefix + 'missing command for exec action' unless test.key? 'exec'
          test['action'] = "EXEC \"#{test['exec']}\""
          if test.key? 'uid'
            test['action'] += " AS UID #{test['uid']}"
          end
          if test.key? 'gid'
            test['action'] += " AS GID #{test['gid']}"
          end
          if test.key? 'repeat_every'
            test['action'] += " REPEAT EVERY #{test['repeat_every']} CYCLES"
          end
        end
      else
        test['action'] = 'ALERT'
      end

      # RESOURCE_TESTS, and other tests that share the same syntax.
      if (RESOURCE_TESTS.include? test['type']) || (['SPACE', 'INODE', 'STATUS', 'UPTIME'].include? test['type'])
        raise Puppet::ParseError, exception_prefix + "'operator' is mandatory" unless test.key? 'operator'
        raise Puppet::ParseError, exception_prefix + "invalid operator: #{test['operator']}" unless RESOURCE_TESTS_OPERATORS.include? test['operator']
        raise Puppet::ParseError, exception_prefix + "'value' is mandatory" unless test.key? 'value'
        test['operator'] = test['operator'].upcase
        test['condition'] = "#{test['type']} #{test['operator']} #{test['value']}"

      # FILESYSTEM FLAGS TESTING
      elsif test['type'] == 'FSFLAGS'
        test['condition'] = "CHANGED #{test['type']}"

      # PERMISSION TESTING
      elsif ['PERM', 'PERMISSION'].include? test['type']
        raise Puppet::ParseError, exception_prefix + "'value' is mandatory" unless test.key? 'value'
        test['condition'] = "FAILED #{test['type']} #{test['value']}"

      # CHECKSUM TESTING
      elsif ['CHECKSUM'].include? test['type']
        test['condition'] = "FAILED #{test['type']}"

      # UID TESTING
      elsif ['UID'].include? test['type']
        raise Puppet::ParseError, exception_prefix + "'value' is mandatory" unless test.key? 'value'
        test['condition'] = "FAILED #{test['type']} #{test['value']}"

      # GID TESTING
      elsif ['GID'].include? test['type']
        raise Puppet::ParseError, exception_prefix + "'value' is mandatory" unless test.key? 'value'
        test['condition'] = "FAILED #{test['type']} #{test['value']}"

      # EXIST TESTING
      elsif ['EXIST'].include? test['type']
        test['condition'] = test['type']

      # CONNECTION TESTING
      elsif test['type'] == 'CONNECTION'
        raise Puppet::ParseError, exception_prefix + "'port' or 'unixsocket' is mandatory" unless (test.key? 'port') || (test.key? 'unixsocket')
        condition = 'FAILED'
        if test.key? 'unixsocket'
          condition += " UNIXSOCKET #{test['unixsocket']}"
        else
          condition += test.key?('host') ? " HOST #{test['host']} PORT #{test['port']}" : " PORT #{test['port']}"
          if test.key? 'socket_type'
            test['socket_type'] = test['socket_type'].upcase
            condition += " TYPE #{test['socket_type']}"
            if test['socket_type'] == 'TCPSSL'
              if test.key? 'socket_type_cypher'
                test['socket_type_cypher'] = test['socket_type_cypher'].upcase
                condition += " #{test['socket_type_cypher']}"
              end
              if test.key? 'socket_type_checksum'
                condition += " CERTMD5 #{test['socket_type_checksum']}"
              end
            end
          end
          if test.key? 'protocol'
            test['protocol'] = test['protocol'].upcase
            condition += "\n    PROTOCOL #{test['protocol']} " unless test['protocol'] == 'GENERIC'
            # Protocol test.
            if test.key? 'protocol_test'
              # If we don't know about specific tests for this protocol,
              # fallback to generic test.
              pt_type = PROTOCOL_TESTS.key?(test['protocol']) ? test['protocol'] : 'GENERIC'
              case pt_type
              when 'HTTP', 'HTTPS', 'APACHE-STATUS'
                pt_options = PROTOCOL_TESTS[pt_type]
                # Validate test options.
                raise Puppet::ParseError, exception_prefix + "protocol_test must be a hash with any of this keys: #{pt_options.join(', ')}." unless test['protocol_test'].class == Hash
                options = test['protocol_test']
                invalid_opts = options.keys.map { |key| key.upcase } - pt_options
                raise Puppet::ParseError, exception_prefix + "invalid options in #{test['protocol']} ckeck: #{invalid_opts.join(', ')}" unless invalid_opts.empty?
                # Enforce REQUEST key to be the first one. Applies only to HTTP test.
                if options.key? 'request'
                  condition += "\n    REQUEST #{options['request']}"
                end
                options.each do |key, value|
                  condition += "\n    #{key.upcase} #{value}" unless key == 'request'
                end
              when 'GENERIC'
                # Validate test options.
                raise Puppet::ParseError, exception_prefix + 'protocol_test must be an array of hashes with send/expect pairs.' unless test['protocol_test'].class == Array
                pt_options = PROTOCOL_TESTS[pt_type]
                test['protocol_test'].each do |pair|
                  # Fail if any option is missing.
                  msg = "missing options in #{test['protocol']} ckeck: #{pt_options.join(', ')} are mandatory."
                  raise Puppet::ParseError, exception_prefix + msg unless pt_options & pair.keys.map { |key| key.upcase } == pt_options
                  pair.each do |key, value|
                    condition += "\n    #{key.upcase} #{value}"
                  end
                end
              end
            end
          end
        end
        if test.key? 'timeout'
          condition += "\n    WITH TIMEOUT #{test['timeout']} SECONDS"
        end
        if test.key? 'retry'
          condition += " RETRY #{test['retry']}"
        end
        test['condition'] = condition
      end

      tests[index] = test
    end
  end
end
