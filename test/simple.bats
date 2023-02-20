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

@test 'sole var' {
    myvar=test run tmpl.sh '{{myvar}}'
    assert_output 'test'
}

@test 'sole unset var' {
    bats_require_minimum_version 1.5.0
    run --separate-stderr tmpl.sh '{{myvar}}'
    assert_output ''
    assert_equal "$stderr" 'Warning: myvar is not defined and no default is set, replacing by empty'
}

@test 'no var at all' {
    bats_require_minimum_version 1.5.0
    myvar=test run --separate-stderr tmpl.sh 'my text here'
    assert_output 'my text here'
    assert_equal "$stderr" 'Warning: No variable was found in template, syntax is {{VAR}}'
}