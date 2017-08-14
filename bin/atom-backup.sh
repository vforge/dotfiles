#!/bin/sh
#
# Backup Atom packages
#

apm list --packages --bare > ~/.atom/packages.list
