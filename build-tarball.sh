#!/bin/sh

# Copyright (C) 2024 Free Software Foundation, Inc.
#
# This file is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# This file is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# This script builds the package.
# Usage: build-tarball.sh PACKAGE
# Its output is a tarball: $package/$package-*.tar.gz

package="$1"

set -e

# Fetch sources (uses package 'git').
git clone --depth 1 https://git.savannah.gnu.org/git/"$package".git
cd "$package"
./autopull.sh --one-time

# Fetch extra files and generate files (uses packages wget, python3, automake, autoconf, m4).
date=`date --utc --iso-8601 | sed -e 's/-//g'`; sed -i -e "/AM_INIT_AUTOMAKE/s/\\([0-9][0-9.]*\\)/\\1-${date}/" configure.ac
./autogen.sh

# Configure (uses package 'file').
./configure --config-cache CPPFLAGS="-Wall" > log1 2>&1; rc=$?; cat log1; test $rc = 0 || exit 1
# Build (uses packages make, gcc, ...).
make > log2 2>&1; rc=$?; cat log2; test $rc = 0 || exit 1
# Run the tests.
make check > log3 2>&1; rc=$?; cat log3; test $rc = 0 || exit 1
# Check that tarballs are correct.
make distcheck > log4 2>&1; rc=$?; cat log4; test $rc = 0 || exit 1
