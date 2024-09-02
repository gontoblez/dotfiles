# LUKE SMITH'S configuration with that insults script by DISTROTUBE
# I, quite frankly, don't understand any of this
# Luke's config for the Zoomer Shell

# Enable colors and change prompt:
autoload -U colors && colors

autoload -Uz vcs_info
precmd() { vcs_info }

precmd_functions+=( precmd_vcs_info )

zstyle ':vcs_info:git:*' formats 'on %F{011} %b%f'
setopt PROMPT_SUBST
#PROMPT='%n in %c ${vcs_info_msg_0_}> '

PROMPT='%F{109}%n%f at %F{166}%m%f in %F{035}%c%f ${vcs_info_msg_0_}
%{$fg_bold[white]%}>%{$reset_color%} '
#PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%c%{$fg[red]%}]%{$reset_color%}$%b "

# Autocompletion for BASH script

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh/history

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1
export PATH=$PATH:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.emacs.d/bin:$HOME/node_modules/prettier/prettier

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'block' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' 'lfcd\n'

function_exists () {
    # Zsh returns 0 even on non existing functions with -F so use -f
    declare -f $1 > /dev/null
    return $?
}

#
# The idea below is to copy any existing handlers to another function
# name and insert the message in front of the old handler in the
# new handler. By default, neither bash or zsh has has a handler function
# defined, so the default behaviour is replicated.
#
# Also, ensure the handler is only copied once. If we do not ensure this
# the handler would add itself recursively if this file happens to be
# sourced multiple times in the same shell, resulting in a neverending
# stream of messages.
#

#
# Zsh
#
if function_exists command_not_found_handler; then
    if ! function_exists orig_command_not_found_handler; then
        eval "orig_$(declare -f command_not_found_handler)"
    fi
else
    orig_command_not_found_handler () {
        printf "zsh: command not found: %s\n" "$1" >&2
        return 127
    }
fi

command_not_found_handler () {
    print_message
    orig_command_not_found_handler "$@"
}


#
# Bash
#
if function_exists command_not_found_handle; then
    if ! function_exists orig_command_not_found_handle; then
        eval "orig_$(declare -f command_not_found_handle)"
    fi
else
    orig_command_not_found_handle () {
        printf "%s: %s: command not found\n" "$0" "$1" >&2
        return 127
    }
fi

command_not_found_handle () {
    print_message
    orig_command_not_found_handle "$@"
}




# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Load aliases and shortcuts if existent.
[ -f "$HOME/.zsh/shortcutrc" ] && source "$HOME/.zsh/shortcutrc"
[ -f "$HOME/.zsh/aliasrc" ] && source "$HOME/.zsh/aliasrc"

#source ~/.github/zsh-autosuggestions/zsh-autosuggestions.zsh

source ~/.zsh/cmd-not-found-insults.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# Load zsh-syntax-highlighting; should be last.
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
#source /home/dafoor/.github/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#
