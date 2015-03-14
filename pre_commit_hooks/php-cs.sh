#!/bin/bash

# Bash PHP Codesniffer Hook
# This script fails if the PHP Codesniffer output has the word "ERROR" in it.
# Does not support failing on WARNING AND ERROR at the same time.
#
# Exit 0 if no errors found
# Exit 1 if errors were found
#
# Requires
# - php
#
# Arguments
# - None

# Echo Colors
msg_color_magenta='\e[1;35m'
msg_color_yellow='\e[0;33m'
msg_color_none='\e[0m' # No Color

# Loop through the list of paths to run php codesniffer against
echo -en "${msg_color_yellow}Begin PHP Codesniffer ...${msg_color_none} \n"
phpcs_local_exec="phpcs.phar"
phpcs_command="php $phpcs_local_exec"

# Check vendor/bin/phpunit
phpcs_vendor_command="vendor/bin/phpcs"
phpcs_global_command="phpcs"
if [ -f "$phpcs_vendor_command" ]; then
	phpcs_command=$phpcs_vendor_command
else
    if hash phpcs 2>/dev/null; then
        phpcs_command=$phpcs_global_command
    else
        if [ -f "$phpcs_local_exec" ]; then
            phpcs_command=$phpcs_command
        else
            echo "No valid PHP Codesniffer executable found! Please have one available as either $phpcs_vendor_command, $phpcs_global_command or $phpcs_local_exec"
            exit 1
        fi
    fi
fi

phpcs_files_to_check="${@:2}"
phpcs_args=$1
# Without this escape field, the parameters would break if there was a comma in it
escape_comma="/,"
phpcs_args_parsed="${phpcs_args:escape_comma:,}"
phpcs_command="$phpcs_command $phpcs_args_parsed --standard=ruleset.xml -p $phpcs_files_to_check"

echo "Running command $phpcs_command"
command_result=`eval $phpcs_command`
if [[ $command_result =~ ERROR ]]
then
    echo -en "${msg_color_magenta}Errors detected by PHP CodeSniffer ... ${msg_color_none} \n"
    echo "$command_result"
    exit 1
fi

exit 0
