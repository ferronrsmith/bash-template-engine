#!/usr/bin/env bats

setup() {
    load /usr/lib/bats/bats-support/load
    load /usr/lib/bats/bats-assert/load
    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
    # make executables in src/ visible to PATH
    PATH="$DIR/..:$PATH"
}

@test 'run with argument not containing variables' {
    bats_require_minimum_version 1.5.0
    run --separate-stderr tmpl.sh 'my test'
    assert_output 'my test'
    assert_equal "$stderr" 'Warning: No variable was found in template, syntax is {{VAR}}'
}

@test 'run with empty template argument' {
    bats_require_minimum_version 1.5.0
    run --separate-stderr tmpl.sh ''
    assert_output ''
    assert_equal "$stderr" 'Warning: No variable was found in template, syntax is {{VAR}}'
}

@test 'run with stdin' {
    bats_require_minimum_version 1.5.0
    run --separate-stderr sh -c "printf '%s' 'my test' | tmpl.sh"
    assert_output 'my test'
    assert_equal "$stderr" 'Warning: No variable was found in template, syntax is {{VAR}}'
}

@test 'run with stdin and template argument' {
    bats_require_minimum_version 1.5.0
    run --separate-stderr sh -c "printf '%s' 'foo' | tmpl.sh 'bar'"
    assert_output 'bar'
    assert_equal "$stderr" 'Warning: No variable was found in template, syntax is {{VAR}}'
}

@test 'run with to many arguments' {
    bats_require_minimum_version 1.5.0
    run --separate-stderr tmpl.sh 'foo' 'bar'
    assert_output 'foobar'
    assert_equal "$stderr" 'Warning: No variable was found in template, syntax is {{VAR}}'
}