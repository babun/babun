#!/bin/bash

# If prioritizing Anaconda and Miniconda over pact, shift all Anaconda and
# Miniconda directories in the current ${PATH} to the head of that list while
# preserving the ordering of all other listed directories. This modifies the
# current shell environment and hence *MUST* be sourced in the current shell
# process rather than run in a new bash process (as "start.sh" is).
if [[ "$PRIORITIZE_CONDA_PACKAGES" == true ]]; then
    # To permit the ${IFS} global to be shadowed by a local variable of the same
    # name, this logic is segregated to a temporary function.
    function _prioritize_conda_packages() {
        # If the current shell is bash rather than zsh, define a ${path} list of
        # all paths split from the current colon-delimited ${PATH}. Note that
        # Zsh already defines this list as a global of the same name.
        if [[ -n "${BASH_VERSION:+x}" ]]; then
            # Temporarily disable filename globbing for the duration of this call,
            # preventing expansion of glob-reserved characters (e.g., "*", "?") in
            # filenames parsed below.
            set -f

            # Split shell words on colons. To avoid modifying the ${IFS} global, a
            # local variable of the same name is modified instead.
            local IFS=':'

            # List of all paths split from the current colon-delimited ${PATH}. Note
            # that ${PATH} must *NOT* be double-quoted here.
            local -a path; path=( $PATH )

            # Reenable filename globbing.
            set +f
        fi

        # Split this list into two lists: one containing only Anaconda and
        # Miniconda directories and the other containing all other directories.
        local -a conda_paths nonconda_paths
        local cur_path
        for   cur_path in "${path[@]}"; do
            # For portability both between shells and regex libraries:
            #
            # * This regex is unquoted. While zsh transparently supports both
            #   quoted and unquoted regexes, bash supports only the latter.
            #   Since regex syntax often conflicts with shell syntax and hence
            #   must be explicitly escaped to be used in an unquoted manner,
            #   this was (arguably) a poor design decision on bash's part.
            # * Character classes in this regex are manually defined rather than
            #   predefined (e.g., "[0-9]" rather than "\d"). Oddly, the latter
            #   appear to be unrecognized under oh-my-zsh.
            if [[ "$cur_path" =~ ^(/cygdrive)?/[a-z]/(Ana|Mini)conda[0-9]?(/.*)?$ ]]; then
                conda_paths+=( "$cur_path" )
            else
                nonconda_paths+=( "$cur_path" )
            fi
        done

        # Reconstitute the list of all paths from these lists.
        path=( "${conda_paths[@]}" "${nonconda_paths[@]}" )

        # If the current shell is bash rather than zsh, reconstitute the current
        # colon-delimited ${PATH} from the ${path} list. Due to the above ${IFS}
        # change, this implicitly joins the latter list on ":" into a string
        # scalar then assigned to ${PATH}.
        if [[ -n "${BASH_VERSION:+x}" ]]; then
            PATH="${path[*]}"
        fi
    }

    # Perform such logic.
    _prioritize_conda_packages

    # Undefine our temporary function.
    unset -f _prioritize_conda_packages
fi
