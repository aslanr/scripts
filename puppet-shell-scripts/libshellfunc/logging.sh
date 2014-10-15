##############################################################################
# name: logging.sh
# description: Utility functions to log/output text.
##############################################################################

# Sets up a file descriptor to which we shall log our output.
# This should be configurable but exec gets really antsy when you try to
# pass in a variable.
exec 3>&2

# Low-level logger called by other log functions.
# It always prepends the output with a timestamp generated by calling the
# `now` function. It will also justify the output (meaning it will pad the
# output with spaces to fill it up to the desired length).
#
# Parameters:
#  ${1}: The string to log.
#  ${justify}: The length at which to justify the string. If not passed in defaults
#        to whatever LIBSF_JUSTIFY was set.
#  ${newline}: Defines
#        whether we will add a newline to the string that is to be echoed.
#        Defaults to true.
#
# Examples:
#
# call:    log "hi there"
# returns: "15:09:48 +0100 hi there" padded to the length of JUSTIFY-16 with
#          a line break at the end.
#
# call:    log "hi there" newline=false
#          echo "OK"
# returns: "15:09:48 +0100 hi there +bunch_of_whitespace JUSTIFY-22+ OK".
#
# call:    log "hi there" 125
# returns: "15:09:48 +0100 hi there" padded to the length of 125-16 with a
#          linebreak at the end.
#
# call:    log "hi there" 125 newline=false
#          echo "OK"
# returns: "15:09:48 +0100 hi there +bunch_of_whitespace 125-22+ OK".

log () {
    # Check if we were passed at least a message to log
    if test $# -eq 0; then
        error "log(): needs at least a message to log"
        return
    fi

    # Assign the message to a variable
    log_message=${1}
    # Shift the first argument out
    shift 1
    # Create local variables for the rest
    local $*

    # If justify was not passed as an argument
    if test -z ${justify}; then
        typeset -ri justify=${LIBSF_JUSTIFY}
    fi

    # If newline was not passed as an argument
    if test -z ${newline}; then
        typeset -r newline="true"
        typeset -r return_char="\n"
    fi


    # If we want a \n at the end of line, use the full length
    # 16 is the length of the string printed by calling `now`.
    if test ${newline} == "true"; then
        end=`expr ${justify} - 16`
    # If de don't want a \n that's probably because we want to echo something
    # to the end of the line so cut out a smaller string. This ensures we
    # have enough space left to echo something like 'OK'
    else
        end=`expr ${justify} - 22`
    fi

    # Here comes the magic
    # TODO: It would be nice if we could break on words, not character count.
    length=${#log_message}
    if test ${length} -gt ${end}; then
        string=${log_message}
        printf "%-${justify}s\n" "${BLUE}`now`${RESET} ${string:0:${end}}" >&3
        start=${end}
        length=`expr ${length} - ${end}`
        string=${string:${end}:${length}}
        while test ${length} -gt ${end}; do
            _string=${string:0:${end}}
            printf "%-${justify}s\n" "${BLUE}..............${RESET} ${_string}" >&3
            start=${end}
            length=`expr ${length} - ${end}`
            string=${string:${end}:${length}}
        done
        printf "%-${justify}s${return_char}" "${BLUE}..............${RESET} ${string}" >&3

    else
        printf "%-${justify}s${return_char}" "${BLUE}`now`${RESET} ${log_message}" >&3
    fi
}
# The following three functions just format text, they don't do anything
# log-level like where messages are only displayed according to the loglevel.
# They should be used in a similar fashion as loglevels though:

# Inform the user of something, like completion of a command
info () {
    if test $# -gt 1; then
        error "info(): accepts only one parameter"
        return
    fi
    log "${GREEN}INFO${RESET}: ${1}"
}

# Inform the user that there might be an issue but nothing critical
warn () {
    if test $# -gt 1; then
        error "warn(): accepts only one parameter"
        return
    fi
    log "${YLW}WARN${RESET}: ${1}"
}

# Inform the user that something went wrong and if passed an exit code, exit
# with that code.
error () {
    if test $# -gt 2; then
        error "error(): accepts upto two parameters"
        return
    fi
    log "${RED}ERROR${RESET}: ${1}"
    if test ${2}; then
        exit ${2}
    fi
}

# This is the only one that functions as an actual log level and only outputs
# text if a global SH_DEBUG is set to 1.
debug () {
    if test $# -gt 1; then
        error "debug(): accepts only one parameter"
        return
    fi
    if test ${LIBSF_DEBUG} -eq 1; then
        log "${PURPLE}DEBUG${RESET}: ${1}"
    fi
}
