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

# This script builds a tarball of the package on a single platform.
# Usage: build-on.sh PACKAGE CONFIGURE_OPTIONS MAKE PREFIX PREREQUISITES

package="$1"
configure_options="$2"
make="$3"
prefix="$4"
prerequisites="$5"
install_optional_dependencies_command="$6"

set -x

case "$configure_options" in
  --host=riscv*) cross_compiling=true ;;
  *)             cross_compiling=false ;;
esac

# Build and install the prerequisites.
for prereq in $prerequisites; do
  tar xfz $prereq.tar.gz
  cd $prereq
  # --disable-shared avoids problem 1) with rpath on ELF systems, 2) with DLLs on Windows.
  ./configure $configure_options --disable-shared --prefix="$prefix" > log1 2>&1; rc=$?; cat log1; test $rc = 0 || exit 1
  $make > log2 2>&1; rc=$?; cat log2; test $rc = 0 || exit 1
  $make install > log4 2>&1; rc=$?; cat log4; test $rc = 0 || exit 1
  cd ..
done

# Unpack the tarball.
tarfile="$package".tar.gz
packagedir=`echo "$tarfile" | sed -e 's/\.tar\.gz$//'`
tar xfz "$tarfile"
test "$packagedir" = testdir-all || mv "$packagedir" testdir-all
cd testdir-all || exit 1

# First, without the optional dependencies.
mkdir build
cd build

# Configure.
CPPFLAGS="$CPPFLAGS -DCONTINUE_AFTER_ASSERT" \
FORCE_UNSAFE_CONFIGURE=1 ../configure --config-cache --with-included-libunistring $configure_options > log1 2>&1; rc=$?; cat log1; test $rc = 0 || exit 1

# Build.
if false; then
  $make 2>&1 | gawk '{ print strftime("%H:%M:%S"), $0; fflush(); }' | tee log2
else
  $make > log2 2>&1; rc=$?; cat log2; test $rc = 0 || exit 1
fi

if $cross_compiling; then
  # Run the tests.
  if false; then
    $make check 2>&1 | gawk '{ print strftime("%H:%M:%S"), $0; fflush(); }' | tee log3
  else
    $make check > log3 2>&1; rc=$?; cat log3; test $rc = 0 || exit 1
  fi
fi

cd ..

if test -n "$install_optional_dependencies_command"; then
  # Install the optional dependencies.
  sh -c "$install_optional_dependencies_command"

  # Build again, this time with optional packages installed.
  mkdir build-full
  cd build-full

  # Configure.
  CPPFLAGS="$CPPFLAGS -DCONTINUE_AFTER_ASSERT" \
  FORCE_UNSAFE_CONFIGURE=1 ../configure --config-cache --with-included-libunistring $configure_options > log1 2>&1; rc=$?; cat log1; test $rc = 0 || exit 1

  # Build.
  $make > log2 2>&1; rc=$?; cat log2; test $rc = 0 || exit 1

  if $cross_compiling; then
    # Run the tests.
    $make check > log3 2>&1; rc=$?; cat log3; test $rc = 0 || exit 1
  fi

  cd ..
fi

exit 0
