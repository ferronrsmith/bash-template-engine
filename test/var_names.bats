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

@test 'name consisting only alphanum and underscore' {
    _MY_var2=test run tmpl.sh '{{_MY_var2}}'
    assert_output 'test'
}

@test 'name not starting with alpha or underscore' {
    bats_require_minimum_version 1.5.0
    run --separate-stderr tmpl.sh '{{2my_var}}'
    assert_output '{{2my_var}}'
    assert_equal "$stderr" 'Warning: No variable was found in template, syntax is {{VAR}}'
}

@test 'word consisting invalid charactars' {
    bats_require_minimum_version 1.5.0
    run --separate-stderr tmpl.sh '{{my-var}}'
    assert_output '{{my-var}}'
    assert_equal "$stderr" 'Warning: No variable was found in template, syntax is {{VAR}}'
}
