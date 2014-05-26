#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"

declare -A gitconfig
declare -A gitalias
declare -A gitmerge

# general config
gitconfig['color.ui']='true'
gitconfig['core.editor']='vim'
gitconfig['core.filemode']='false'
gitconfig['credential.helper']='cache --timeout=3600'

# alias config
gitalias['alias.cp']='cherry-pick'
gitalias['alias.st']='status -sb'
gitalias['alias.cl']='clone'
gitalias['alias.ci']='commit'
gitalias['alias.co']='checkout'
gitalias['alias.br']='branch'
gitalias['alias.dc']='diff --cached'
gitalias['alias.lg']="log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %Cblue<%an>%Creset' --abbrev-commit --date=relative --all"
gitalias['alias.last']='log -1 --stat'
gitalias['alias.unstage']='reset HEAD --'

# git mergetool config
gitmerge['merge.tool']='vimdiff'
gitmerge['mergetool.prompt']='false'
gitmerge['mergetool.trustexitcode']='false'
gitmerge['mergetool.keepbackups']='false'
gitmerge['mergetool.keeptemporaries']='false'

function apply_git_config {
	eval "declare -A configMap="${1#*=}
	
	gitcfg=$(git config --list)
	
	for configKey in "${!configMap[@]}"
	do
		if [[ $gitcfg != *$configKey* ]]; then
			configValue="${configMap[$configKey]}"
			git config --global "$configKey" "$configValue"
		fi
	done
}

apply_git_config "$(declare -p gitconfig)"
apply_git_config "$(declare -p gitmerge)"
apply_git_config "$(declare -p gitalias)"

# COMPATIBILITY FIX
# BUG FIX -> aliast.last
gitlast=$(git config --global alias.last || echo "")
if [[ "$gitlast" == "git log -1 --stat" ]]; then
	echo "Fixing broken alias.last"
	git config --global "alias.last" "log -1 --stat"
fi


