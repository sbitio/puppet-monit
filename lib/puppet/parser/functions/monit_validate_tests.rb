module Puppet::Parser::Functions
  newfunction(:monit_validate_tests, :type => :rvalue, :doc => <<-EOS
    Validate monit tests and transforms some parts into monit language.
    EOS
  ) do |args|

    # Valid tests for resources.
    # # RESOURCE TESTING: IF resource operator value THEN action
    # # SPACE TESTING: IF SPACE operator value unit THEN action
    # # INODE TESTING: IF INODE operator value [unit] THEN action
    RESOURCE_TESTS = [
      'CPU', 'CPU(USER)', 'CPU(SYSTEM)', 'CPU(WAIT)', 'TOTAL CPU', 'CHILDREN',
      'LOADAVG(1MIN)', 'LOADAVG(5MIN)', 'LOADAVG(15MIN)',
      'TOTAL MEMORY', 'MEMORY', 'SWAP'
    ]
    # Valid operators for resource testing.
    RESOURCE_TESTS_OPERATORS = [
      '<', '>', '!=', '==',
      'GT', 'LT', 'EQ', 'NE',
      'GREATER', 'LESS', 'EQUAL', 'NOTEQUAL',
    ]

    PROTOCOL_TESTS = {
      #TODO: GENERIC, SIP, RADIUS, WEBSOCKET
      'HTTP'          => ['REQUEST', 'STATUS', 'CHECKSUM', 'HOSTHEADER', 'CONTENT'],
      'APACHE-STATUS' => ['LOGLIMIT', 'CLOSELIMIT', 'DNSLIMIT', 'KEEPALIVELIMIT', 'REPLYLIMIT', 'REQUESTLIMIT', 'STARTLIMIT', 'WAITLIMIT', 'GRACEFULLIMIT', 'CLEANUPLIMIT']
    }

    TEST_TYPES = {
      'DIRECTORY'   => [],
      'FIFO'        => [],
      'FILE'        => [],
      'FILESYSTEM'  => [
        'FSFLAGS', 'SPACE', 'INODE', 'PERM', 'PERMISSION'
      ],
      'HOST'        => ['CONNECTION'],
      'PROCESS'     => RESOURCE_TESTS + ['CONNECTION',],
      'PROGRAM'     => [],
      'SYSTEM'      => RESOURCE_TESTS,
    }
    TEST_ACTIONS   = ['ALERT', 'RESTART', 'START', 'STOP', 'EXEC', 'UNMONITOR']

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
          if test['action'] == 'EXEC' and not test.key? 'exec'
            raise Puppet::ParseError, exception_prefix + "missing command for exec action"
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

      # CONNECTION TESTING
      elsif test['type'] == 'CONNECTION'
        unless test.key? 'port' or test.key? 'unixsocket'
          raise Puppet::ParseError, exception_prefix + "'port' or 'unixsocket' is mandatory"
        end
        condition = 'FAILED '
        if test.key? 'unixsocket'
          condition += "UNIXSOCKET #{test['unixsocket']} "
        else
          if test.key? 'host'
            condition += "HOST #{test['host']} PORT #{test['port']} "
          else
            condition += "PORT #{test['port']} "
          end
          if test.key? 'socket_type'
            test['socket_type'] = test['socket_type'].upcase
            condition += "TYPE #{test['socket_type']} "
            if test['socket_type'] == 'TCPSSL'
              if test.key? 'socket_type_cypher'
                test['socket_type_cypher'] = test['socket_type_cypher'].upcase
                condition += "#{test['socket_type_cypher']} "
              end
              if test.key? 'socket_type_checksum'
                condition += "CERTMD5 #{test['socket_type_checksum']} "
              end
            end
          end
          if test.key? 'protocol'
            test['protocol'] = test['protocol'].upcase
            condition += "PROTOCOL #{test['protocol']} "
            # protocol specific tests.
            if test.key? 'protocol_test'
              unless PROTOCOL_TESTS.key? test['protocol']
                  Puppet.warning exception_prefix + "tests for #{test['protocol']} protocol not implemented"
              end
              invalid_opts = PROTOCOL_TESTS[test['protocol']] & test['protocol_test'].keys
              unless invalid_opts.empty?
                raise Puppet::ParseError, exception_prefix + "invalid options in #{test['protocol']} ckeck: #{invalid_opts.join(', ')}"
              end
              case test['protocol']
                when 'HTTP', 'APACHE-STATUS'
                  ptest = test['protocol_test']
                  PROTOCOL_TESTS[test['protocol']].each do |key|
                    if ptest.key? key
                      condition += "#{key.upcase} #{ptest[key]} "
                    end
                  end
                else
                  Puppet.warning exception_prefix + " #{test['protocol']} protocol tests not implemented"
                end
              end
            end
          end
          if test.key? 'timeout'
            condition += "WITH TIMEOUT #{test['timeout']} SECONDS "
          end
          if test.key? 'retry'
            condition += "RETRY #{test['retry']} "
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

