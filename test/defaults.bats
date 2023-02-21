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
    run --keep-empty-lines tmpl.sh '{{myfoo=foo}}'
    assert_output 'foo'
}

@test 'sole var multiple lines' {
    bats_require_minimum_version 1.5.0
    run --keep-empty-lines tmpl.sh '{{myfoo=foo}}'$'\n''{{myfoo}}'
    assert_output 'foo'$'\n''foo'
}

@test 'sole var within text' {
    bats_require_minimum_version 1.5.0
    run --keep-empty-lines tmpl.sh 'my {{myfoo=foo}} here'
    assert_output 'my foo here'
}

@test 'sole var within multiline text' {
    bats_require_minimum_version 1.5.0
    run --keep-empty-lines tmpl.sh 'my {{myfoo=foo}} here'$'\n''or here: {{myfoo}}'
    assert_output 'my foo here'$'\n''or here: foo'
}

@test 'sole var with ending new line' {
    bats_require_minimum_version 1.5.0
    run --keep-empty-lines tmpl.sh '{{myfoo=foo}}'$'\n'
    assert_output 'foo'$'\n'
}

@test 'multiple vars' {
    bats_require_minimum_version 1.5.0
    run --keep-empty-lines tmpl.sh '{{myfoo=foo}} {{mybar=bar}}'
    assert_output 'foo bar'
}

@test 'multiple vars multiple lines' {
    bats_require_minimum_version 1.5.0
    run --keep-empty-lines tmpl.sh '{{myfoo=foo}} {{mybar=bar}}'$'\n''{{mybar}}{{myfoo}}'
    assert_output 'foo bar'$'\n''barfoo'
}

@test 'multiple vars within text' {
    bats_require_minimum_version 1.5.0
    run --keep-empty-lines tmpl.sh 'my {{myfoo=foo}} and {{mybar=bar}} here'
    assert_output 'my foo and bar here'
}

@test 'multiple vars within multiline text' {
    bats_require_minimum_version 1.5.0
    run --keep-empty-lines tmpl.sh 'my {{myfoo=foo}} and {{mybar=bar}} here'$'\n''or here: {{mybar}}{{myfoo}}'
    assert_output 'my foo and bar here'$'\n''or here: barfoo'
}

@test 'multiple vars with ending new line' {
    bats_require_minimum_version 1.5.0
    run --keep-empty-lines tmpl.sh '{{myfoo=foo}} {{mybar=bar}}'$'\n'
    assert_output 'foo bar'$'\n'
}

@test 'using sed delimiter' {
    bats_require_minimum_version 1.5.0
    run --keep-empty-lines tmpl.sh '{{myfoo=|}}'
    assert_output '|'
}
