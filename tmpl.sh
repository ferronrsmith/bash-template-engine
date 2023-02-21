#!/bin/sh

# ======================================
# simple templating engine for sh
# ======================================

if [ $# -eq 0 ]; then
    # read from stdin if no argument is given
    # preserv newline at end of input
    template=$(cat; ret=$?; echo . && exit "$ret")
    ret=$? template=${template%.}
else
    # consume all arguments as one big template
    xIFS="$IFS"
    IFS=
    template="$*"
    IFS="$xIFS"
fi

# regex for a valid identifier
RE_VARNAME='[A-Za-z_][A-Za-z0-9_]*'

# escapes given character
# escape_delimiter <char to escape> [text to process, ...]
escape_delimiter() {
    delimiter="$1"
    shift
    if [ "$delimiter" = '#' ]; then
        DELIM='|'
    else
        DELIM='#'
    fi
    printf '%s' "$@" | sed -e "s${DELIM}[${delimiter}]${DELIM}\\\\${delimiter}${DELIM}g"
}

replaces=""

# Reads default values defined as {{VAR=value}} and delete those lines
# There are evaluated, so you can do {{PATH=$HOME}} or {{PATH=`pwd`}}
# You can even reference variables defined in the template before
defaults=$(printf '%s' "${template}" | grep -oP '\{\{'"$RE_VARNAME"'+=.+?\}\}' | sed -e 's/^{{//' -e 's/}}$//')
xIFS="$IFS"
IFS=${IFS#??} # IFS is only newline
for default in ${defaults}; do
    var=${default%%=*} # variable name is everything before equal sign

    # Replace only if var is not set
    eval "isset=\${$var+x}"
    if [ -z "$isset" ]; then
        current=${default#*=} # value is everthing after equal sign
        eval "export $var='$current'"
    else
        current=$(eval "\${$var}")
    fi

    # replace define line
    current=$(escape_delimiter '/' "$current")
    replaces="-e 's/{{${var}=[^}]\+}}/$current/g' ${replaces}"
done

# Replace all {{VAR}} by $VAR value
vars=$(printf '%s' "${template}" | grep -oE '\{\{'"$RE_VARNAME"'\}\}' | sort -u | sed -e 's/^{{//' -e 's/}}$//')
for var in ${vars}; do
    eval "isset=\${$var+x}"
    if [ -z "$isset" ]; then
        echo "Warning: ${var} is not defined and no default is set, replacing with empty value" >&2
    fi

    # Escape slashes
    eval "value=\$${var}"
    value=$(escape_delimiter '/' "$value")
    replaces="-e 's/{{$var}}/${value}/g' ${replaces}"
done

if [ -z "$replaces" ]; then
    sed_script='cat'
else
    sed_script="sed $replaces"
fi
printf '%s' "${template}" | eval "$sed_script"