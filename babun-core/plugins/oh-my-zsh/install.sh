#!/bin/bash
set -e -f -o pipefail
source "/usr/local/etc/babun.instance"
source "$babun_tools/script.sh"
source "$babun_tools/git.sh"

src="$babun/external/oh-my-zsh"
dest="$babun/home/oh-my-zsh/.oh-my-zsh"

if [ ! -d "$src" ]; then
	PATH=/usr/bin git clone https://github.com/robbyrussell/oh-my-zsh.git "$src" 
	git --git-dir="$src/.git" --work-tree="$src" config core.trustctime false 
	git --git-dir="$src/.git" --work-tree="$src" config core.autocrlf false 
	git --git-dir="$src/.git" --work-tree="$src" rm --cached -r . > /dev/null
	git --git-dir="$src/.git" --work-tree="$src" reset --hard 
fi

if [ ! -d "$dest" ]; then
	mkdir -p "$dest"
    /bin/cp -rf "$src/." "$dest"
    /bin/cp "$dest/templates/zshrc.zsh-template" "$babun/home/.zshrc"
    /bin/cp -rf "$babun_source/babun-core/plugins/oh-my-zsh/src/babun.zsh-theme" "$dest/custom"

    # Set the default oh-my-zsh theme to the Babun theme installed above.
    /bin/sed -i 's/ZSH_THEME=".*"/ZSH_THEME="babun"/' "$babun/home/.zshrc"

    # Avoid prepending the ${PATH} with "/usr/local/bin". Doing so conflicts
    # with plugins also prepending the ${PATH} (e.g., "conda") and is redundant
    # (as "/usr/local/bin" already heads the ${PATH} by default).
    /bin/sed -i '/^export PATH=/s~/usr/local/bin:~~' "$babun/home/.zshrc"
fi

