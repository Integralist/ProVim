# Some of the Zsh awesomeness seen below was originally found here...
# http://zanshin.net/2013/02/02/zsh-configuration-from-the-ground-up/

# Variables {{{
dropbox="$HOME/Dropbox"
syncfolder="$HOME/Box Sync" # sourcing a file breaks with backslashes
# }}}

# Exports {{{
export GITHUB_USER="integralist"
export DROPBOX=$dropbox # Export the path so it can be used elsewhere (such as in our .vimrc file)
export DEV_CERT_PATH="$syncfolder/Work/BBC/Certificates"
export DEV_CERT_PEM="$DEV_CERT_PATH/Certificate.pem"
export DEV_CERT_P12="$DEV_CERT_PATH/Certificate.p12"
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin # Reorder PATH so local bin is first
export PATH="/usr/local/share/npm/bin:$PATH" # Fixes issue where updating NPM causes wrong bin path to be picked up
export NETWORK_LOCATION="$(/usr/sbin/scselect 2>&1 | egrep '^ \* ' | sed 's:.*(\(.*\)):\1:')"
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;32'
export MANPAGER="less -X" # Don’t clear the screen after quitting a manual page
export EDITOR="vim"
export TERM="screen-256color"
export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad
export LS_COLORS=Gxfxcxdxbxegedabagacad
# }}}

# Network {{{
if [ $NETWORK_LOCATION = 'BBC On Network'  ]; then
    export http_proxy='http://www-cache.reith.bbc.co.uk:80'
    export https_proxy='http://www-cache.reith.bbc.co.uk:80'
    export ftp_proxy='ftp-gw.reith.bbc.co.uk:21'
    export socks_proxy='socks-gw.reith.bbc.co.uk:1085'

    export HTTP_PROXY='http://www-cache.reith.bbc.co.uk:80'
    export HTTPS_PROXY='http://www-cache.reith.bbc.co.uk:80'
    export FTP_PROXY='ftp-gw.reith.bbc.co.uk:21'
    export SOCKS_PROXY='socks-gw.reith.bbc.co.uk:1085'
else
    unset http_proxy
    unset https_proxy
    unset ftp_proxy
    unset socks_proxy

    unset HTTP_PROXY
    unset HTTPS_PROXY
    unset FTP_PROXY
    unset SOCKS_PROXY
fi;
# }}}

# Ruby {{{
# Determine Ruby version
function get_ruby_version() {
  ruby -v | awk '{print $1 " " $2}'
}

# Sets up chruby and allows us to use .ruby-version files to switch ruby versions
source /usr/local/opt/chruby/share/chruby/chruby.sh
source /usr/local/opt/chruby/share/chruby/auto.sh

# Makes installing versions of Ruby slightly easier
function ri() {
  ruby-install -i ~/.rubies/ ruby $1
}

# Handle installing of Ruby Gems using Gemsets
# Create a `.gemset` file alongside your Gemfile
# The content of `.gemset` is your project name.
# Will install Gems to `~/.gem/gemsets/ruby/{version}/{identifier}/gems`
function chruby_gemset() {
  # Save existing environment setup
  if [ -z "$DEFAULT_GEM_HOME" ]; then
    export DEFAULT_GEM_HOME=$GEM_HOME
  fi

  if [ -z "$DEFAULT_GEM_PATH" ]; then
    export DEFAULT_GEM_PATH=$GEM_PATH
  fi

  if [ -z "$DEFAULT_PATH" ]; then
    export DEFAULT_PATH=$PATH
  fi
  chruby_gemset=$1

  ruby_bin="`command -v unbundled_ruby || command -v ruby`"

eval `$ruby_bin - <<EOF
require 'rubygems'
puts "ruby_engine=#{defined?(RUBY_ENGINE) ? RUBY_ENGINE : 'ruby'}"
puts "ruby_vers=#{RUBY_VERSION}"
puts "gem_path=\"#{Gem.path.join(':')}\""
EOF`

  gem_dir="$HOME/.gem/gemsets/$ruby_engine/$ruby_vers/$chruby_gemset"

  export PATH="$gem_dir/bin:$PATH"
  export GEM_HOME="$gem_dir"
  export GEM_PATH="$gem_dir"
}

function reset_chruby_gemset() {
  export PATH=$DEFAULT_PATH
  export GEM_HOME=$DEFAULT_GEM_HOME
  export GEM_PATH=$DEFAULT_GEM_PATH
}

function chruby_gemset_auto() {
  local dir="$PWD"
  local gemset

  until [[ -z "$dir" ]]; do
    if { read -r gemset <"$dir/.gemset"; } 2>/dev/null; then
      chruby_gemset "$gemset"
      return $?
    fi
    if { read -r gemset <"$dir/.ruby-gemset"; } 2>/dev/null; then
      chruby_gemset "$gemset"
      return $?
    fi

    dir="${dir%/*}"
  done

  if [[ -z "$gemset" ]]; then
    if [ -z "$DEFAULT_GEM_PATH" ]; then
    else
      reset_chruby_gemset
      unset DEFAULT_GEM_PATH
      unset DEFAULT_GEM_HOME
      unset DEFAULT_PATH
    fi
  fi
}

if [[ -n "$ZSH_VERSION" ]]; then
  if [[ ! "$preexec_functions" == *chruby_gemset_auto* ]]; then
    preexec_functions+=("chruby_gemset_auto")
  fi
fi
# }}}

# Tmux {{{
# Makes creating a new tmux session (with a specific name) easier
function tmuxopen() {
  tmux attach -t $1
}

# Makes creating a new tmux session (with a specific name) easier
function tmuxnew() {
  tmux new -s $1
}

# Makes deleting a tmux session easier
function tmuxkill() {
  tmux kill-session -t $1
}
# }}}

# Alias' {{{
alias r="source ~/.zshrc"
alias tmuxsrc="tmux source-file ~/.tmux.conf"
alias vi="vim"
alias st="cd tabloid/webapp/static"
alias rubyv="ls ~/.rubies/"
alias grunt="grunt --verbose --stack"
alias tmuxkillall="tmux ls | cut -d : -f 1 | xargs -I {} tmux kill-session -t {}" # tmux kill all sessions
alias lib="cd '$syncfolder/Library'"
alias shell="cd $dropbox/Fresh\ Install/Shell"
alias site="cd '$syncfolder/Library/Github/integralist/Website'"
alias vs="vagrant suspend"
alias vu="vagrant up"
alias vd="vagrant destroy"
alias vr="vagrant box remove responsive virtualbox"
alias vst="vagrant status"
alias vsh="vagrant ssh"
alias gemu="for i in `gem list --no-versions`; do gem uninstall -aIx $i; done"
alias phplint='find ./ -name \*.php | xargs -n 1 php -l'
alias currentwifi='networksetup -getairportnetwork en0'
alias ip='dig +short myip.opendns.com @resolver1.opendns.com'
alias localip='ipconfig getifaddr en0'
alias ips="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'" # command works, but not when aliased?
alias ct="ctags -R --exclude=.git --exclude=node_modules"
alias phpsh="psysh"
alias dotfiles="ls -a | grep '^\.' | grep --invert-match '\.DS_Store\|\.$'"
alias cukes="ulimit -n 1024; cucumber"
# }}}

# Website Deployment {{{
# Using CabinJS to create my blog, but it only works with GitHub pages
# So rather than write a Rake task or a Node/Grunt task and have to remember the File system APIs
# I've decided to use standard unix commands to achieve the same thing.
# Yes it's a lot more long winded but it works and took me a lot less time to write.
#
# we move into our website directory
# we create a log.txt file
# we send to stdout the latest commit message
# we cut out just the message (ignoring the commit hash)
# we pipe the stdout to xargs where we then write it into the log.txt
# we move into our website release folder
# we copy the content of the `dist` folder into our website release folder
# we `git add` and `git add -A`
# we send to stdout the content of our log.txt (which is the commit message)
# we then pipe that commit message over to xargs which runs `git commit` using it
# finally we `git push origin master`
alias deploysite="cd '$syncfolder/Library/Github/integralist/Website' && \
                  touch log.txt && \
                  git log --oneline -n 1 | \
                  cut -d ' ' -f 2- | \
                  xargs -I {} echo {} > log.txt && \
                  cd ../integralist.github.com && \
                  cp -r ../Website/dist/* ./ && \
                  git add . && git add -A && \
                  cat ../Website/log.txt | \
                  xargs -I {} git commit -m {} && \
                  git push origin master"
# }}}

# Miscellaneous {{{
function set_ruby() {
  touch .ruby-version && echo $1 >> .ruby-version
}

function gem_add_owner() {
  # gem help owner
  gem owner $1 -a $2
}

function restart_finder() {
  killall Finder
}

function show_hidden_files() {
  defaults write com.apple.finder AppleShowAllFiles TRUE
  restart_finder
}

function hide_hidden_files() {
  defaults write com.apple.finder AppleShowAllFiles FALSE
  restart_finder
}

# find shorthand
# find ./ -name '*.js'
function f() {
  find . -name "$1"
}

# Create a new directory and enter it
function md() {
  mkdir -p "$@" && cd "$@"
}

# Start an HTTP server from a directory, optionally specifying the port
function server() {
  local port="${1:-8000}"
  open "http://localhost:${port}/"
  # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
  # And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
  python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port"
}

function phpserver() {
  php -S localhost:8888
}

function rubyserver() {
  ruby -run -e httpd . -p 5000
}

# get gzipped size
function gz() {
  echo "orig size    (bytes): "
  cat "$1" | wc -c
  echo "gzipped size (bytes): "
  gzip -c "$1" | wc -c
}

# Vagrant fixes issue with Chef not completing
if `test -t 0`; then
   mesg n
fi

# Open path in the terminal which matches current directory within the the forefront Finder window.
function cdf() {
  if [ "`osascript -e 'tell application "System Events" to "Finder" is in (get name of processes)'`" = "true" ]; then
    if [ "`osascript -e 'tell application "Finder" to get collapsed of front window' 2>/dev/null`" != "false" ]; then
      if [ "`osascript -e 'tell application "System Events" to "TotalFinderCrashWatcher" is in (get name of processes)'`" = "true" ];then
        open .
        osascript -e 'tell application "System Events" to tell process "Finder" to keystroke "w" using {command down}' -e 'tell application "System Events" to tell process "Finder" to keystroke "h" using {command down}'
      else
        finderState=`osascript -e 'tell application "System Events" to set visible of application process "Finder" to true' -e 'tell application "Finder" to set collapsed of front window to true' 2>/dev/null`
      fi
    fi

    finder=`osascript -e 'tell application "Finder" to set curName to (POSIX path of (target of front window as alias))' 2>/dev/null`

    if [ -z "$finder" ]; then
      echo "Failed to find \"Finder\""
    else
      echo "$finder"
      cd "$finder"
    fi

  else
    echo "\"Finder\" is not running"
  fi
}

# Convert movie file to animated gif
gif-ify() {
  if [[ -n "$1" && -n "$2" ]]; then
    ffmpeg -i $1 -pix_fmt rgb24 temp.gif
    convert -layers Optimize temp.gif $2
    rm temp.gif
  else
    echo "proper usage: gif-ify <input_movie.mov> <output_file.gif>. You DO need to include extensions."
  fi
}
# }}}

# Auto Completion {{{
autoload -U compinit && compinit
zmodload -i zsh/complist

# man zshcontrib
zstyle ':vcs_info:*' actionformats '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
zstyle ':vcs_info:*' enable git #svn cvs

# Enable completion caching, use rehash to clear
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zsh/cache/$HOST

# Fallback to built in ls colors
zstyle ':completion:*' list-colors ''

# Make the list prompt friendly
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'

# Make the selection prompt friendly when there are a lot of choices
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'

# Add simple colors to kill
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

# list of completers to use
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate

zstyle ':completion:*' menu select=1 _complete _ignored _approximate

# insert all expansions for expand completer
# zstyle ':completion:*:expand:*' tag-order all-expansions

# match uppercase from lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# formatting and messages
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''

# ignore completion functions (until the _ignored completer)
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:scp:*' tag-order files users 'hosts:-host hosts:-domain:domain hosts:-ipaddr"IP\ Address *'
zstyle ':completion:*:scp:*' group-order files all-files users hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' tag-order users 'hosts:-host hosts:-domain:domain hosts:-ipaddr"IP\ Address *'
zstyle ':completion:*:ssh:*' group-order hosts-domain hosts-host users hosts-ipaddr
zstyle '*' single-ignored show
# }}}

# Key Bindings {{{
# Make the delete key (or Fn + Delete on the Mac) work instead of outputting a ~
bindkey '^?' backward-delete-char
bindkey "^[[3~" delete-char
bindkey "^[3;5~" delete-char
bindkey "\e[3~" delete-char

# Make the `beginning/end` of line and `bck-i-search` commands work within tmux
bindkey '^R' history-incremental-search-backward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
# }}}

# Colours {{{
autoload colors; colors

# The variables are wrapped in \%\{\%\}. This should be the case for every
# variable that does not contain space.
for COLOR in RED GREEN YELLOW BLUE MAGENTA CYAN BLACK WHITE; do
  eval PR_$COLOR='%{$fg_no_bold[${(L)COLOR}]%}'
  eval PR_BOLD_$COLOR='%{$fg_bold[${(L)COLOR}]%}'
done

eval RESET='$reset_color'
export PR_RED PR_GREEN PR_YELLOW PR_BLUE PR_WHITE PR_BLACK
export PR_BOLD_RED PR_BOLD_GREEN PR_BOLD_YELLOW PR_BOLD_BLUE
export PR_BOLD_WHITE PR_BOLD_BLACK

# Clear LSCOLORS
unset LSCOLORS
# }}}

# Set Options {{{
# ===== Basics
setopt no_beep # don't beep on error
setopt interactive_comments # Allow comments even in interactive shells (especially for Muness)

# ===== Changing Directories
setopt auto_cd # If you type foo, and it isn't a command, and it is a directory in your cdpath, go there
setopt cdablevarS # if argument to cd is the name of a parameter whose value is a valid directory, it will become the current directory
setopt pushd_ignore_dups # don't push multiple copies of the same directory onto the directory stack

# ===== Expansion and Globbing
setopt extended_glob # treat #, ~, and ^ as part of patterns for filename generation

# ===== History
setopt append_history # Allow multiple terminal sessions to all append to one zsh command history
setopt extended_history # save timestamp of command and duration
setopt inc_append_history # Add comamnds as they are typed, don't wait until shell exit
setopt hist_expire_dups_first # when trimming history, lose oldest duplicates first
setopt hist_ignore_dups # Do not write events to history that are duplicates of previous events
setopt hist_ignore_space # remove command line from history list when first character on the line is a space
setopt hist_find_no_dups # When searching history don't display results already cycled through twice
setopt hist_reduce_blanks # Remove extra blanks from each command line being added to history
setopt hist_verify # don't execute, just expand history
setopt share_history # imports new commands and appends typed commands to history

# ===== Completion
setopt always_to_end # When completing from the middle of a word, move the cursor to the end of the word
setopt auto_menu # show completion menu on successive tab press. needs unsetop menu_complete to work
setopt auto_name_dirs # any parameter that is set to the absolute name of a directory immediately becomes a name for that directory
setopt complete_in_word # Allow completion from within a word/phrase

unsetopt menu_complete # do not autoselect the first completion entry

# ===== Correction
setopt correct # spelling correction for commands
setopt correctall # spelling correction for arguments

# ===== Prompt
setopt prompt_subst # Enable parameter expansion, command substitution, and arithmetic expansion in the prompt
setopt transient_rprompt # only show the rprompt on the current prompt

# ===== Scripts and Functions
setopt multios # perform implicit tees or cats when multiple redirections are attempted
# }}}

# Prompt {{{
function virtualenv_info {
  [ $VIRTUAL_ENV ] && echo '('`basename $VIRTUAL_ENV`') '
}

function prompt_char {
  git branch >/dev/null 2>/dev/null && echo '±' && return
  hg root >/dev/null 2>/dev/null && echo '☿' && return
  echo '○'
}

function box_name {
  [ -f ~/.box-name ] && cat ~/.box-name || hostname -s
}

# http://blog.joshdick.net/2012/12/30/my_git_prompt_for_zsh.html
# copied from https://gist.github.com/4415470
# Adapted from code found at <https://gist.github.com/1712320>.

#setopt promptsubst
autoload -U colors && colors # Enable colors in prompt

# Modify the colors and symbols in these variables as desired.
GIT_PROMPT_SYMBOL="%{$fg[blue]%}±"
GIT_PROMPT_PREFIX="%{$fg[green]%} [%{$reset_color%}"
GIT_PROMPT_SUFFIX="%{$fg[green]%}]%{$reset_color%}"
GIT_PROMPT_AHEAD="%{$fg[red]%}ANUM%{$reset_color%}"
GIT_PROMPT_BEHIND="%{$fg[cyan]%}BNUM%{$reset_color%}"
GIT_PROMPT_MERGING="%{$fg_bold[magenta]%}⚡︎%{$reset_color%}"
GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}u%{$reset_color%}"
GIT_PROMPT_MODIFIED="%{$fg_bold[yellow]%}m%{$reset_color%}"
GIT_PROMPT_STAGED="%{$fg_bold[green]%}s%{$reset_color%}"

# Show Git branch/tag, or name-rev if on detached head
function parse_git_branch() {
  (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}

# Show different symbols as appropriate for various Git repository states
function parse_git_state() {
  # Compose this value via multiple conditional appends.
  local GIT_STATE=""

  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
  fi

  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
  fi

  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MERGING
  fi

  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_UNTRACKED
  fi

  if ! git diff --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MODIFIED
  fi

  if ! git diff --cached --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_STAGED
  fi

  if [[ -n $GIT_STATE ]]; then
    echo "$GIT_PROMPT_PREFIX$GIT_STATE$GIT_PROMPT_SUFFIX"
  fi
}

# If inside a Git repository, print its branch and state
function git_prompt_string() {
  local git_where="$(parse_git_branch)"
  [ -n "$git_where" ] && echo "on %{$fg[blue]%}${git_where#(refs/heads/|tags/)}$(parse_git_state)"
}

function current_pwd {
  echo $(pwd | sed -e "s,^$HOME,~,")
}

# Original prompt with User name and Computer name included...
# PROMPT='
# ${PR_GREEN}%n%{$reset_color%} %{$FG[239]%}at%{$reset_color%} ${PR_BOLD_BLUE}$(box_name)%{$reset_color%} %{$FG[239]%}in%{$reset_color%} ${PR_BOLD_YELLOW}$(current_pwd)%{$reset_color%} $(git_prompt_string)
# $(prompt_char) '

PROMPT='
${PR_GREEN}M.%{$reset_color%} ${PR_BOLD_YELLOW}$(current_pwd)%{$reset_color%} $(git_prompt_string)
$(prompt_char) '

export SPROMPT="Correct $fg[red]%R$reset_color to $fg[green]%r$reset_color [(y)es (n)o (a)bort (e)dit]? "

# directory="$PWD"
# version=

# until [[ -z "$directory" ]]; do
#     echo "hai: " $directory
#     if { read -r version <"$directory/.ruby-version"; } 2>/dev/null || [[ -n "$version" ]]; then
#       echo "hai"
#     fi
# done

RPROMPT='${PR_GREEN}$(virtualenv_info)%{$reset_color%} ${PR_RED}$(get_ruby_version)%{$reset_color%}'
# }}}

# History {{{
HISTSIZE=10000
SAVEHIST=9000
HISTFILE=~/.zsh_history
# }}}

# Zsh Hooks {{{
function precmd {
  # vcs_info
  # Put the string "hostname::/full/directory/path" in the title bar:
  echo -ne "\e]2;$PWD\a"

  # Put the parentdir/currentdir in the tab
  echo -ne "\e]1;$PWD:h:t/$PWD:t\a"
}

function set_running_app {
  printf "\e]1; $PWD:t:$(history $HISTCMD | cut -b7- ) \a"
}

function preexec {
  set_running_app
}

function postexec {
  set_running_app
}
# }}}

# Zsh Sourced {{{
# brew install zsh-syntax-highlighting
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# }}}
