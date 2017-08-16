#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2016-01-17 14:07:17 +0000 (Sun, 17 Jan 2016)
#
#  https://github.com/harisekhon/nagios-plugins
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback
#
#  https://www.linkedin.com/in/harisekhon
#

set -eu #o pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. "$srcdir/utils.sh"

if [ -z "$(find -L "${1:-.}" -maxdepth 2 -name Makefile)" ]; then
    return 0 &>/dev/null || :
    exit 0
fi

section "M a k e"

start_time="$(start_timer)"

if which make &>/dev/null; then
    find -L "${1:-.}" -maxdepth 2 -name Makefile |
    while read makefile; do
        pushd "$(dirname "$makefile")" >/dev/null
        echo "Validating $makefile"
        grep '^[[:alpha:]]\+:' Makefile |
        sort -u |
        sed 's/:$//' |
        while read target; do
            if ! make --warn-undefined-variables -n $target >/dev/null; then
                echo "Makefile validation FAILED"
                exit 1
            fi
        done
        popd >/dev/null
    done
fi

time_taken "$start_time"
section2 "Makefile validation SUCCEEDED"
echo
