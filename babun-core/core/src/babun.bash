# IMPORTANT NOTE!
# DO NOT MODIFY THIS FILE -> IT WILL BE OVERWRITTEN ON UPDATE
# If you want to some options modify the following file: ~/.bashrc

# no git prompt
#PS1='\[\033[01;32m\]\u\[\033[01;34m\]::\[\033[01;31m\]\h \[\033[00;34m\]{ \[\033[01;34m\]\w \[\033[00;34m\]}\[\033[01;32m\]-> \[\033[00m\]'

# slow git prompt
#PS1="\[\033[01;32m\]\u\[\033[01;34m\]::\[\033[01;31m\]\h \[\033[00;34m\]{ \[\033[01;34m\]\w \[\033[00;34m\]}\[\033[01;32m\] \$( sed -E 's/(.*)\/(.*)/(\2)/' \$( git rev-parse --git-dir )/HEAD 2> /dev/null ) -> \[\033[00m\]"

# other combinations
# git branch 2> /dev/null | sed -n '/\* /s/.+/(\1)/p';
# sed -E 's/(.*)\/(.*)/(\2)/' $( git rev-parse --git-dir 2> /dev/null)/HEAD 2> /dev/null
# git rev-parse --abbrev-ref HEAD 2> /dev/null | sed -n "s/.+/(/1)/p"

# mkpasswd -l -c >> /etc/passwd; mkgroup -l -c >> /etc/group
# https://github.com/mavnn/mintty-colors-solarized
# https://github.com/seebi/dircolors-solarized
# https://github.com/square/maximum-awesome/tree/master/iterm2-colors-solarized


# quicker git prompt
PS1="\[\033[01;32m\]\u\[\033[01;34m\]::\[\033[01;31m\]\h \[\033[00;34m\]{ \[\033[01;34m\]\w \[\033[00;34m\]}\[\033[01;32m\] \$( git branch 2> /dev/null ) -> \[\033[00m\]"
