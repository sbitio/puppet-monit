module Puppet::Parser::Functions
  newfunction(:monit_validate_tests, :type => :rvalue, :doc => <<-EOS
    Validate monit tests and transforms some parts into monit language.
    EOS
  ) do |args|

    # Valid tests for resources.
    # # RESOURCE TESTING: IF resource operator value THEN action
    # # SPACE TESTING: IF SPACE operator value unit THEN action
    # # INODE TESTING: IF INODE operator value [unit] THEN action
    defined?(RESOURCE_TESTS) or RESOURCE_TESTS = [
      'CPU', 'CPU(USER)', 'CPU(SYSTEM)', 'CPU(WAIT)', 'TOTAL CPU', 'CHILDREN',
      'LOADAVG(1MIN)', 'LOADAVG(5MIN)', 'LOADAVG(15MIN)',
      'TOTAL MEMORY', 'MEMORY', 'SWAP'
    ]
    # Valid operators for resource testing.
    defined?(RESOURCE_TESTS_OPERATORS) or RESOURCE_TESTS_OPERATORS = [
      '<', '>', '!=', '==',
      'GT', 'LT', 'EQ', 'NE',
      'GREATER', 'LESS', 'EQUAL', 'NOTEQUAL',
    ]

    defined?(PROTOCOL_TESTS) or PROTOCOL_TESTS = {
      #TODO: GENERIC, SIP, RADIUS, WEBSOCKET
      #CHANGES: Param 'HOSTHEADER' changed to 'HTTP HEADERS' in monit 5.9, see https://mmonit.com/monit/changes/
      'GENERIC'       => ['SEND', 'EXPECT'],
      'HTTP'          => ['REQUEST', 'STATUS', 'CHECKSUM', 'HOSTHEADER', 'HTTP HEADERS', 'CONTENT'],
      'APACHE-STATUS' => ['LOGLIMIT', 'CLOSELIMIT', 'DNSLIMIT', 'KEEPALIVELIMIT', 'REPLYLIMIT', 'REQUESTLIMIT', 'STARTLIMIT', 'WAITLIMIT', 'GRACEFULLIMIT', 'CLEANUPLIMIT']
    }

    defined?(TEST_TYPES) or TEST_TYPES = {
      'DIRECTORY'   => [],
      'FIFO'        => [],
      'FILE'        => ['PERMISSION', 'CHECKSUM', 'UID', 'GID'],
      'FILESYSTEM'  => [
        'FSFLAGS', 'SPACE', 'INODE', 'PERM', 'PERMISSION'
      ],
      'HOST'        => ['CONNECTION'],
      'PROCESS'     => RESOURCE_TESTS + ['CONNECTION',],
      'PROGRAM'     => ['STATUS'],
      'SYSTEM'      => RESOURCE_TESTS,
    }
    defined?(TEST_ACTIONS) or TEST_ACTIONS = ['ALERT', 'RESTART', 'START', 'STOP', 'EXEC', 'UNMONITOR']

    check_type = args[0].upcase
    tests = args[1]

    tests.each_with_index do |test, index|

      # Validate test type.
      test['type'] = test['type'].upcase
      unless TEST_TYPES[check_type].include? test['type']
        raise Puppet::ParseError, "Tests for '#{check_type}': invalid test type '#{test['type']}'"
      end

      exception_prefix =  "Tests for '#{check_type}' ('#{test['type']}'): "

      # Validate failure tolerance and convert value to monit jargon.
      # # https://mmonit.com/monit/documentation/monit.html#failure_tolerance
      if test.key? 'tolerance'
        unless test['tolerance'].class == Hash and test['tolerance'].key? 'cycles'
          raise Puppet::ParseError, exception_prefix + "tolerance must be a hash with 'cycles' key and optionally 'times'."
        else
          if test['tolerance'].key? 'times'
            test['tolerance'] = "#{test['tolerance']['times']} TIMES WITHIN #{test['tolerance']['cycles']} CYCLES"
          else
            test['tolerance'] = "#{test['tolerance']['cycles']} CYCLES"
          end
        end
      end

      # Validate action.
      # # https://mmonit.com/monit/documentation/monit.html#action
      unless test.key? 'action'
        test['action'] = 'ALERT'
      else
        test['action'] = test['action'].upcase
        unless TEST_ACTIONS.include? test['action']
          raise Puppet::ParseError, exception_prefix + "invalid action '#{test['action']}'"
        else
          if test['action'] == 'EXEC'
            unless test.key? 'exec'
              raise Puppet::ParseError, exception_prefix + "missing command for exec action"
            else
              test['action'] = "EXEC \"#{test['exec']}\""
            end
          end
        end
      end

      # RESOURCE TESTS, SPACE and INODE
      if RESOURCE_TESTS.include? test['type'] or ['SPACE', 'INODE'].include? test['type']
        unless test.key? 'operator'
          raise Puppet::ParseError, exception_prefix + "'operator' is mandatory"
        end
        unless RESOURCE_TESTS_OPERATORS.include? test['operator']
          raise Puppet::ParseError, exception_prefix + "invalid operator: #{test['operator']}"
        end
        unless test.key? 'value'
          raise Puppet::ParseError, exception_prefix + "'value' is mandatory"
        end
        test['operator'] = test['operator'].upcase
        test['condition'] = "#{test['type']} #{test['operator']} #{test['value']}"

      # FILESYSTEM FLAGS TESTING
      elsif test['type'] == 'FSFLAGS'
        test['condition'] = "CHANGED #{test['type']}"

      # PERMISSION TESTING
      elsif ['PERM', 'PERMISSION'].include? test['type']
        unless test.key? 'value'
          raise Puppet::ParseError, exception_prefix + "'value' is mandatory"
        end
        test['condition'] = "FAILED #{test['type']} #{test['value']}"

      # CHECKSUM TESTING
      elsif ['CHECKSUM'].include? test['type']
        test['condition'] = "FAILED #{test['type']}"

      # UID TESTING
      elsif ['UID'].include? test['type']
        unless test.key? 'value'
          raise Puppet::ParseError, exception_prefix + "'value' is mandatory"
        end
        test['condition'] = "FAILED #{test['type']} #{test['value']}"

      # GID TESTING
      elsif ['GID'].include? test['type']
        unless test.key? 'value'
          raise Puppet::ParseError, exception_prefix + "'value' is mandatory"
        end
        test['condition'] = "FAILED #{test['type']} #{test['value']}"

      # STATUS TESTING
      elsif test['type'] == 'STATUS'
        test['operator'] = test['operator'].upcase
        test['condition'] = "#{test['type']} #{test['operator']} #{test['value']}"

      # CONNECTION TESTING
      elsif test['type'] == 'CONNECTION'
        unless test.key? 'port' or test.key? 'unixsocket'
          raise Puppet::ParseError, exception_prefix + "'port' or 'unixsocket' is mandatory"
        end
        condition = 'FAILED'
        if test.key? 'unixsocket'
          condition += " UNIXSOCKET #{test['unixsocket']}"
        else
          if test.key? 'host'
            condition += " HOST #{test['host']} PORT #{test['port']}"
          else
            condition += " PORT #{test['port']}"
          end
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
            unless test['protocol'] == 'GENERIC'
              condition += "\n    PROTOCOL #{test['protocol']} "
            end
            # Protocol test.
            if test.key? 'protocol_test'
              # If we don't know about specific tests for this protocol,
              # fallback to generic test.
              if PROTOCOL_TESTS.key? test['protocol']
                  pt_type = test['protocol']
              else
                pt_type = 'GENERIC'
              end
              case pt_type
                when 'HTTP', 'APACHE-STATUS'
                  pt_options = PROTOCOL_TESTS[pt_type]
                  # Validate test options.
                  unless test['protocol_test'].class == Hash
                    raise Puppet::ParseError, exception_prefix + "protocol_test must be a hash with any of this keys: #{pt_options.join(', ')}."
                  end
                  options = test['protocol_test']
                  invalid_opts = options.keys.map{|key| key.upcase} - pt_options
                  unless invalid_opts.empty?
                    raise Puppet::ParseError, exception_prefix + "invalid options in #{test['protocol']} ckeck: #{invalid_opts.join(', ')}"
                  end
                  # Enforce REQUEST key to be the first one. Applies only to HTTP test.
                  if options.key? 'request'
                    condition += "\n    REQUEST #{options['request']}"
                  end
                  options.each do |key, value|
                    unless key == 'request'
                      condition += "\n    #{key.upcase} #{value}"
                    end
                  end
                when 'GENERIC'
                  # Validate test options.
                  unless test['protocol_test'].class == Array
                    raise Puppet::ParseError, exception_prefix + "protocol_test must be an array of hashes with send/expect pairs."
                  end
                  pt_options = PROTOCOL_TESTS[pt_type]
                  test['protocol_test'].each do |pair|
                    # Fail if any option is missing.
                    unless pt_options & pair.keys.map{|key| key.upcase} == pt_options
                      raise Puppet::ParseError, exception_prefix + "missing options in #{test['protocol']} ckeck: #{pt_options.join(', ')} are mandatory."
                    end
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
          if test.key? 'action'
            test['action'] = test['action'].upcase
          else
            test['action'] = 'ALERT'
        end

        test['condition'] = condition
      end

      tests[index] = test
    end

    return tests
  end
end

