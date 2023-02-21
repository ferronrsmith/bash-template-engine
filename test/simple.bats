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
    bats_require_minimum_version 1.5.0
    myfoo=foo run --keep-empty-lines tmpl.sh '{{myfoo}}'
    assert_output 'foo'
}

@test 'sole var multiple lines' {
    bats_require_minimum_version 1.5.0
    myfoo=foo run --keep-empty-lines tmpl.sh '{{myfoo}}'$'\n''{{myfoo}}'
    assert_output 'foo'$'\n''foo'
}

@test 'sole var within text' {
    bats_require_minimum_version 1.5.0
    myfoo=foo run --keep-empty-lines tmpl.sh 'my {{myfoo}} here'
    assert_output 'my foo here'
}

@test 'sole var within multiline text' {
    bats_require_minimum_version 1.5.0
    myfoo=foo run --keep-empty-lines tmpl.sh 'my {{myfoo}} here'$'\n''or here: {{myfoo}}'
    assert_output 'my foo here'$'\n''or here: foo'
}

@test 'sole var with ending new line' {
    bats_require_minimum_version 1.5.0
    myfoo=foo run --keep-empty-lines tmpl.sh '{{myfoo}}'$'\n'
    assert_output 'foo'$'\n'
}

@test 'sole unset var' {
    bats_require_minimum_version 1.5.0
    run --keep-empty-lines --separate-stderr tmpl.sh '{{myfoo}}'
    assert_output ''
    assert_equal "$stderr" 'Warning: myfoo is not defined and no default is set, replacing with empty value'
}

@test 'sole unset var multiple lines' {
    bats_require_minimum_version 1.5.0
    run --keep-empty-lines --separate-stderr tmpl.sh '{{myfoo}}'$'\n''{{myfoo}}'
    assert_output $'\n'
    assert_equal "$stderr" 'Warning: myfoo is not defined and no default is set, replacing with empty value'
}

@test 'sole unset var within text' {
    bats_require_minimum_version 1.5.0
    run --keep-empty-lines --separate-stderr tmpl.sh 'my {{myfoo}} here'
    assert_output 'my  here'
    assert_equal "$stderr" 'Warning: myfoo is not defined and no default is set, replacing with empty value'
}

@test 'sole unset var within multiline text' {
    bats_require_minimum_version 1.5.0
    run --keep-empty-lines --separate-stderr tmpl.sh 'my {{myfoo}} here'$'\n''or here: {{myfoo}}'
    assert_output 'my  here'$'\n''or here: '
    assert_equal "$stderr" 'Warning: myfoo is not defined and no default is set, replacing with empty value'
}

@test 'no var at all' {
    bats_require_minimum_version 1.5.0
    myfoo=test run --keep-empty-lines --separate-stderr tmpl.sh 'my text here'
    assert_output 'my text here'
    assert_equal "$stderr" 'Warning: No variable was found in template, syntax is {{VAR}}'
}

@test 'multiple vars' {
    bats_require_minimum_version 1.5.0
    myfoo=foo mybar=bar run --keep-empty-lines tmpl.sh '{{myfoo}} {{mybar}}'
    assert_output 'foo bar'
}

@test 'multiple vars multiple lines' {
    bats_require_minimum_version 1.5.0
    myfoo=foo mybar=bar run --keep-empty-lines tmpl.sh '{{myfoo}} {{mybar}}'$'\n''{{mybar}}{{myfoo}}'
    assert_output 'foo bar'$'\n''barfoo'
}

@test 'multiple vars within text' {
    bats_require_minimum_version 1.5.0
    myfoo=foo mybar=bar run --keep-empty-lines tmpl.sh 'my {{myfoo}} and {{mybar}} here'
    assert_output 'my foo and bar here'
}

@test 'multiple vars within multiline text' {
    bats_require_minimum_version 1.5.0
    myfoo=foo mybar=bar run --keep-empty-lines tmpl.sh 'my {{myfoo}} and {{mybar}} here'$'\n''or here: {{mybar}}{{myfoo}}'
    assert_output 'my foo and bar here'$'\n''or here: barfoo'
}

@test 'multiple vars with ending new line' {
    bats_require_minimum_version 1.5.0
    myfoo=foo mybar=bar run --keep-empty-lines tmpl.sh '{{myfoo}} {{mybar}}'$'\n'
    assert_output 'foo bar'$'\n'
}

@test 'using sed delimiter' {
    bats_require_minimum_version 1.5.0
    myfoo='|' run --keep-empty-lines tmpl.sh '{{myfoo}}'
    assert_output '|'
}