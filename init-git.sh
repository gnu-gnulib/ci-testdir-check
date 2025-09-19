# Mapping from canonical git server URLs to more efficient read-only mirrors.
# See
# https://git-scm.com/docs/git-config#Documentation/git-config.txt-urlltbasegtinsteadOf
# https://git-scm.com/docs/git-clone#_git_urls
git config set --global --append url.git://git.git.savannah.gnu.org/.insteadOf git://git.savannah.gnu.org/
git config set --global --append url.https://https.git.savannah.gnu.org/git/.insteadOf https://git.savannah.gnu.org/git/
git config set --global --append url.https://github.com/coreutils/gnulib.git.insteadOf git://git.savannah.gnu.org/gnulib.git
git config set --global --append url.https://github.com/coreutils/gnulib.git.insteadOf https://git.savannah.gnu.org/git/gnulib.git
