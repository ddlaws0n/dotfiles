# Shell behavior and history.

# History
export HISTFILE="${XDG_STATE_HOME}/zsh/history"
export HISTSIZE=50000
export SAVEHIST=50000
mkdir -p "$(dirname "$HISTFILE")"  # Create dir if needed

setopt APPEND_HISTORY SHARE_HISTORY INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS HIST_VERIFY

# Completion cache directory
export COMPLETION_CACHE_DIR="${XDG_CACHE_HOME}/zsh/completions"
mkdir -p "$COMPLETION_CACHE_DIR"

# Shell options
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS NO_BEEP INTERACTIVE_COMMENTS PROMPT_SUBST
setopt ALWAYS_TO_END AUTO_MENU COMPLETE_IN_WORD

# Other
export DISABLE_UNTRACKED_FILES_DIRTY=true
export LS_COLORS="di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30"

# Base keybindings (extended by plugins)
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^K' kill-line
bindkey '^U' backward-kill-line
bindkey '^W' backward-kill-word
bindkey '^Y' yank
