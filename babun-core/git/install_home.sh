#!/bin/bash
set -o pipefail
set -f

declare -A gitconfig
declare -A gitalias

# general config
gitconfig['color.ui']='true'
gitconfig['core.editor']='vim'
gitconfig['credential.helper']='cache --timeout=3600'

# alias config
gitalias['alias.cp']='cherry-pick'
gitalias['alias.st']='status -s'
gitalias['alias.cl']='clone'
gitalias['alias.ci']='commit'
gitalias['alias.co']='checkout'
gitalias['alias.br']='branch'
gitalias['alias.dc']='diff --cached'
gitalias['alias.lg']='log --graph --decorate --format=oneline --abbrev-commit --all'
gitalias['alias.last']='git log -1 --stat'

#TODO configure merge tool

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
apply_git_config "$(declare -p gitalias)"
