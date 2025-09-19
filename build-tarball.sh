#!/bin/sh

# Copyright (C) 2024-2025 Free Software Foundation, Inc.
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
# Its output is three tarballs:
#   - libbacktrace.tar.gz
#   - testdir-all.tar.gz
#   - testdir-all-for-mingw.tar.gz

package="$1"

set -e

. ./init-git.sh

# Fetch prerequisite sources (uses package 'git').
git clone --depth 1 https://github.com/ianlancetaylor/libbacktrace.git
tar cfz libbacktrace.tar.gz libbacktrace

# Fetch sources (uses package 'git').
git clone --depth 1 https://git.savannah.gnu.org/git/gnulib.git

# Apply patches.
#(cd "$package" && patch -p1 < ../patches/...)
(cd "$package" && patch -p1 < ../patches/select.diff)

cd "$package"

# List of modules to avoid.
avoids=
# This test exhibits spurious failures on FreeBSD, NetBSD, OpenBSD, mingw.
avoids="$avoids nonblocking-socket-tests"
# This test exhibits spurious failures on MSVC.
avoids="$avoids nonblocking-pipe-tests"
# This test always fails on 32-bit Cygwin.
avoids="$avoids year2038-tests"
avoids_for_mingw="$avoids"
# This test exhibits spurious failures on mingw and MSVC.
avoids_for_mingw="$avoids_for_mingw asyncsafe-spin-tests"
# These tests produce runtime errors in 'check-sanitized'; cf. N3322.
# To be fixed in clang <https://github.com/llvm/llvm-project/issues/113062>
# and glibc <https://sourceware.org/bugzilla/show_bug.cgi?id=32286>.
avoids="$avoids array-map-tests"
avoids="$avoids array-omap-tests"
avoids="$avoids array-oset-tests"
avoids="$avoids array-set-tests"
avoids="$avoids avltree-omap-tests"
avoids="$avoids avltree-oset-tests"
avoids="$avoids bsearch-tests"
avoids="$avoids hash-map-tests"
avoids="$avoids hash-set-tests"
avoids="$avoids linkedhash-map-tests"
avoids="$avoids linkedhash-set-tests"
avoids="$avoids mbmemcasecmp-tests"
avoids="$avoids memccpy-tests"
avoids="$avoids memchr-tests"
avoids="$avoids memcmp-tests"
avoids="$avoids memcpy-tests"
avoids="$avoids memmove-tests"
avoids="$avoids memset-tests"
avoids="$avoids memset_explicit-tests"
avoids="$avoids qsort-tests"
avoids="$avoids rbtree-omap-tests"
avoids="$avoids rbtree-oset-tests"
avoids="$avoids strncat-tests"
avoids="$avoids strncmp-tests"
avoids="$avoids strncpy-tests"
avoids="$avoids strndup-tests"
avoids="$avoids unicase/u8-casecmp-tests"
avoids="$avoids unicase/u8-casecoll-tests"
avoids="$avoids unicase/u8-casefold-tests"
avoids="$avoids unicase/u8-tolower-tests"
avoids="$avoids unicase/u8-totitle-tests"
avoids="$avoids unicase/u8-toupper-tests"
avoids="$avoids unicase/u16-casecmp-tests"
avoids="$avoids unicase/u16-casecoll-tests"
avoids="$avoids unicase/u16-casefold-tests"
avoids="$avoids unicase/u16-tolower-tests"
avoids="$avoids unicase/u16-totitle-tests"
avoids="$avoids unicase/u16-toupper-tests"
avoids="$avoids unicase/u32-casecmp-tests"
avoids="$avoids unicase/u32-casecoll-tests"
avoids="$avoids unicase/u32-casefold-tests"
avoids="$avoids unicase/u32-tolower-tests"
avoids="$avoids unicase/u32-totitle-tests"
avoids="$avoids unicase/u32-toupper-tests"
avoids="$avoids unilbrk/u8-width-linebreaks-tests"
avoids="$avoids unilbrk/u16-width-linebreaks-tests"
avoids="$avoids unilbrk/u32-width-linebreaks-tests"
avoids="$avoids uninorm/nfc-tests"
avoids="$avoids uninorm/nfd-tests"
avoids="$avoids uninorm/nfkc-tests"
avoids="$avoids uninorm/nfkd-tests"
avoids="$avoids uninorm/u8-normcmp-tests"
avoids="$avoids uninorm/u8-normcoll-tests"
avoids="$avoids uninorm/u16-normcmp-tests"
avoids="$avoids uninorm/u16-normcoll-tests"
avoids="$avoids uninorm/u32-normcmp-tests"
avoids="$avoids uninorm/u32-normcoll-tests"
avoids="$avoids unistdio/u8-vasnprintf-tests"
avoids="$avoids unistdio/u8-vasprintf-tests"
avoids="$avoids unistdio/u16-vasnprintf-tests"
avoids="$avoids unistdio/u16-vasprintf-tests"
avoids="$avoids unistdio/u32-vasnprintf-tests"
avoids="$avoids unistdio/u32-vasprintf-tests"
avoids="$avoids unistdio/ulc-vasnprintf-tests"
avoids="$avoids unistdio/ulc-vasprintf-tests"
avoids="$avoids unistr/u8-chr-tests"
avoids="$avoids unistr/u8-strchr-tests"
avoids="$avoids unistr/u8-to-u16-tests"
avoids="$avoids unistr/u8-to-u32-tests"
avoids="$avoids unistr/u16-chr-tests"
avoids="$avoids unistr/u16-strchr-tests"
avoids="$avoids unistr/u16-to-u32-tests"
avoids="$avoids unistr/u16-to-u8-tests"
avoids="$avoids unistr/u32-to-u16-tests"
avoids="$avoids unistr/u32-to-u8-tests"
avoids="$avoids wcsncmp-tests"
avoids="$avoids wcsncpy-tests"

rm -rf ../testdir-all
./gnulib-tool --create-testdir --dir=../testdir-all --with-c++-tests --without-privileged-tests --single-configure `./all-modules` `for m in $avoids; do echo " --avoid=$m"; done`

rm -rf ../testdir-all-for-mingw
./gnulib-tool --create-testdir --dir=../testdir-all-for-mingw --without-c++-tests --without-privileged-tests --single-configure `./all-modules --for-msvc` `for m in $avoids_for_mingw; do echo " --avoid=$m"; done`

cd ..

tar cfz testdir-all.tar.gz testdir-all
tar cfz testdir-all-for-mingw.tar.gz testdir-all-for-mingw
