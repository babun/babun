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
gitalias['alias.last']='git log -1 --stat'
gitalias['alias.unstage']='reset HEAD --'

# git mergetool config
gitmerge['merge.tool']='vimdiff'
gitmerge['mergetool.prompt']='false'
gitmerge['mergetool.trustExitCode']='false'
gitmerge['mergetool.keepBackups']='false'
gitmerge['mergetool.keepTemporaries']='false'

function apply_git_config {
	eval "declare -A configMap="${1#*=}
	
	for configKey in "${!configMap[@]}"
	do
		git config --list | grep -q "$configKey"
		if [ $? -ne 0 ]; then
			configValue="${configMap[$configKey]}"
			git config --global "$configKey" "$configValue"
		fi
	done
}

apply_git_config "$(declare -p gitconfig)"
apply_git_config "$(declare -p gitmerge)"
apply_git_config "$(declare -p gitalias)"
