module Puppet::Parser::Functions
  newfunction(:monit_validate_tests, :type => :rvalue, :doc => <<-EOS
    Validate monit tests and transforms some parts into monit language.
    EOS
  ) do |args|

    TEST_TYPES = {
      'DIRECTORY'   => [],
      'FIFO'        => [],
      'FILE'        => [],
      'FILESYSTEM'  => [
        'FSFLAGS', 'SPACE', 'INODE', 'PERM', 'PERMISSION'
      ],
      'HOST'        => [],
      'PROCESS'     => [
        'CPU', 'TOTAL CPU', 'CHILDREN', 'TOTAL MEMORY',
        'MEM', 'MEMORY', 'LOADAVG(1MIN)', 'LOADAVG(5MIN)', 'LOADAVG(15MIN)'
      ],
      'PROGRAM'     => [],
      'SERVICE'     => [],
      'SYSTEM'      => [
        'CPU(USER)', 'CPU(SYSTEM)', 'CPU(WAIT)', 'SWAP',
        'MEM', 'MEMORY', 'LOADAVG(1MIN)', 'LOADAVG(5MIN)', 'LOADAVG(15MIN)'
      ],
    }
    TEST_ACTIONS   = ['ALERT', 'RESTART', 'START', 'STOP', 'EXEC', 'UNMONITOR']
    TEST_OPERATORS = [
      '<', '>', '!=', '==',
      'GT', 'LT', 'EQ', 'NE',
      'GREATER', 'LESS', 'EQUAL', 'NOTEQUAL',
    ]

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

      # Validate value and build test condition.
      #
      # # Cases:
      # # RESOURCE TESTING: IF resource operator value THEN action
      # # SPACE TESTING: IF SPACE operator value unit THEN action
      # # INODE TESTING: IF INODE operator value [unit] THEN action
      # # Note: We don't mind "unit", it must be part of the value.

      if ['PROCESS', 'SYSTEM', 'SERVICE'].include? check_type or ['SPACE', 'INODE'].include? test['type']
        unless test.key? 'operator'
          raise Puppet::ParseError, exception_prefix + "'operator' is mandatory"
        end
        unless test.key? 'value'
          raise Puppet::ParseError, exception_prefix + "'value' is mandatory"
        end
        test['operator'] = test['operator'].upcase
        test['condition'] = "#{test['type']} #{test['operator']} #{test['value']}"
      end

      # FILESYSTEM FLAGS TESTING
      if test['type'] == 'FSFLAGS'
        test['condition'] = "CHANGED #{test['type']}"
      end

      # PERMISSION TESTING
      if ['PERM', 'PERMISSION'].include? test['type']
        unless test.key? 'value'
          raise Puppet::ParseError, exception_prefix + "'value' is mandatory"
        end
        test['condition'] = "FAILED #{test['type']} #{test['value']}"
      end

      tests[index] = test
    end

    return tests
  end
end

