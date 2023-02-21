#!/bin/sh

# ======================================
# simple templating engine for sh
# ======================================

if [ $# -eq 0 ]; then
    template=$(cat; ret=$?; echo . && exit "$ret")
    ret=$? template=${template%.}
else
    tmp="$IFS"
    IFS=
    template="$*"
    IFS="$tmp"
fi

RE_VARNAME='[A-Za-z_][A-Za-z0-9_]*'

if ! echo "$template" | grep -qoP '\{\{'"$RE_VARNAME"'(=.+?)?\}\}'; then
    echo "Warning: No variable was found in template, syntax is {{VAR}}" >&2
    printf '%s' "$template"
    exit 0
fi

vars=$(printf '%s' "${template}" | grep -oE '\{\{'"$RE_VARNAME"'\}\}' | sort | uniq | sed -e 's/^{{//' -e 's/}}$//')

var_value() {
    eval echo \$$1
}

replaces=""

# Reads default values defined as {{VAR=value}} and delete those lines
# There are evaluated, so you can do {{PATH=$HOME}} or {{PATH=`pwd`}}
# You can even reference variables defined in the template before
defaults=$(printf '%s' "${template}" | grep -oP '\{\{'"$RE_VARNAME"'+=.+?\}\}' | sed -e 's/^{{//' -e 's/}}$//')
for default in ${defaults}; do
    var=$(printf '%s' "${default}" | grep -oE "^$RE_VARNAME")
    current="$(var_value ${var})"

    # Replace only if var is not set
    if [ -z "${current}" ]; then
        eval ${default}
    fi

    # remove define line
    replaces="-e '/^{{${var}=/d' ${replaces}"
    vars="${vars}
    ${current}"
done

vars=$(printf '%s' "$vars" | sort | uniq)

# Replace all {{VAR}} by $VAR value
for var in ${vars}; do
    value="$(var_value ${var})"
    if [ -z "${value}" ]; then
        echo "Warning: ${var} is not defined and no default is set, replacing by empty" >&2
    fi

    # Escape slashes
    value=$(printf '%s' "$value" | sed 's/\//\\\//g');
    replaces="-e 's/{{$var}}/${value}/g' ${replaces}"
done
printf '%s' "${template}" | eval sed ${replaces}