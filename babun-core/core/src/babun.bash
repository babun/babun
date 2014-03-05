#PS1='\[\033[01;32m\]\u\[\033[01;34m\]::\[\033[01;31m\]\h \[\033[00;34m\]{ \[\033[01;34m\]\w \[\033[00;34m\]}\[\033[01;32m\]-> \[\033[00m\]'


#function parse_git_branch {
#  # git branch 2> /dev/null | sed -e '/^[^]/d' -e 's/ (.*)/(\1)/'
#  ref=$(git-symbolic-ref HEAD 2> /dev/null) || return
#  echo "("${ref#refs/heads/}")"
#}


git_prompt ()
{
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    return 0
  fi

#git_branch=$(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')
#git_branch=$( git rev-parse --abbrev-ref HEAD )
#git_branch=$( git branch )

git_branch=$( git branch | awk '/\*/ { print $2; }' )

#  if git diff --quiet 2>/dev/null >&2; then
#    git_color="${c_git_clean}"
#  else
#    git_color=${c_git_cleanit_dirty}
#  fi

#  echo " [$git_color$git_branch${c_reset}]"
echo " [$git_branch]"
}


PS1="\[\033[01;32m\]\u\[\033[01;34m\]::\[\033[01;31m\]\h \[\033[00;34m\]{ \[\033[01;34m\]\w \[\033[00;34m\]}\[\033[01;32m\]\$(git_prompt) -> \[\033[00m\]"


