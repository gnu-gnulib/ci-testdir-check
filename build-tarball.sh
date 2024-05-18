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
# Its output is two tarballs:
#   - testdir-all.tar.gz
#   - testdir-all-for-mingw.tar.gz

package="$1"

set -e

# Fetch sources (uses package 'git').
git clone --depth 1 https://git.savannah.gnu.org/git/"$package".git
cd "$package"

# Let the tests continue after the first test failure.
sed -i -e '/abort/d' tests/macros.h

rm -rf ../testdir-all
./gnulib-tool --create-testdir --dir=../testdir-all --with-c++-tests --without-privileged-tests --single-configure `./all-modules`

rm -rf ../testdir-all-for-mingw
./gnulib-tool --create-testdir --dir=../testdir-all-for-mingw --with-c++-tests --without-privileged-tests --single-configure `./all-modules --for-msvc`

cd ..

tar cfz testdir-all.tar.gz testdir-all
tar cfz testdir-all-for-mingw.tar.gz testdir-all-for-mingw
