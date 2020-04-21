
# If not running interactively, don't do anything:
[ -z "$PS1" ] && return

# export LANG=C
# export LC_ALL=C
export HISTCONTROL=ignoreboth
export HISTSIZE=10000
shopt -s histappend # Don't overwrite the older history file on exit -- append to it.
shopt -s checkwinsize # Avoids crappy linewrapping overwrite.
export EDITOR='emacsclient -nw -a emacs'
export LESS=$'-i -W -n  -z-4 -g -M -X -F -R -P%t?f%f \\\n:stdin .?pb%pb\\%:?lbLine %lb:?bbByte %bb:-...'

# From screen misc pages at http://www.math.fu-berlin.de/~guckes/screen/misc.php3
# This should enable arrow keys and end keys and such inside vim inside screen.
export TERMINFO=~/.terminfo



case `uname` in
  Linux)
    export LS_OPTIONS='--color=auto -p'
    eval `dircolors`
    ;;
  Darwin)
    # Enable colors in ls.
    export LS_OPTIONS='-G'
    # Change default color for directories.
    export LSCOLORS='Exfxcxdxbxegedabagacad'
    ;;
esac



alias ls='ls $LS_OPTIONS'
alias l='ls $LS_OPTIONS -lhF'		  # ls without dotfiles
alias ll='ls $LS_OPTIONS -alhF'		  # ls with dotfiles
alias ls.='CLICOLOR_FORCE=true ls $LS_OPTIONS -alhF|less'     # ls with dotfiles and less
alias lss='ls $LS_OPTIONS -Srlh'	  # sort by: Size reversed...
alias lst='ls $LS_OPTIONS -altrhF'	  #          Time...
alias lsx='CLICOLOR_FORCE=true ls $LS_OPTIONS -alh|sort'	  #          chmod...
alias lsd='CLICOLOR_FORCE=true ls $LS_OPTIONS -lhF|grep /'	  # Just:    Dirs...         
alias lsf='CLICOLOR_FORCE=true ls $LS_OPTIONS -lhF|grep -v /' #          Files...

function CD() {
	\cd "$*" > /dev/null;
        if [[ $? -eq 0 ]]
        then
            echo
	    ll
        fi
}

alias cd='CD'
alias ..='CD ..'
alias pu='pushd'
alias po='popd'
alias -- -='cd -'

alias d='ls -Lla|grep ^d'
alias e='emacsclient -c'              # Standalone client.
alias f='find . | grep -v ".git"'
alias mega='du -ah|grep '[0-9]M' '
alias ff='find . -name "$@"'
alias g='grep --color=auto --exclude=*gif --exclude=*svn*'

alias cp='cp -i'
alias h='history'
alias j='jobs -l'
alias mv='mv -i'
alias p='ps auxw'
alias rm='rm -i'
alias tail='tail -n 100'
alias vi='vim -X'
alias r='lein repl'
alias ara='announce_return_after'

# ipython's edit function needs to wait for emacs to return the buffer.
alias ip='export EDITOR="emacsclient -a emacs"; ipython; source ~/.bashrc'

# git!
alias ga='git add -p'
alias gc='git commit -m'
alias gd='git diff'
alias gl='git log'
alias gp='git pull'
alias gs='git status'
alias gba='git branch -a'
alias gg='git grep'
alias gcm='git checkout master'
alias gc-="git checkout -"       # Checkout last-checked-out branch.
# Create aliases to checkout last nth-checked-out branch.
for i in `seq 2 10`;
do
    alias gc-"$i"="git checkout @{-$i}"  
done;

function gcl() {
    # List last n-checked-out branches and alias command to check it out.
    local gcl_output="n QQQ ref-name QQQ checkout QQQ alias\n\n-QQQ ---------QQQ ----------QQQ -----\n"
    
    for i in `seq 1 10`;
    do
        local curr=$(git rev-parse --abbrev-ref @{-$i} 2>/dev/null);
        if [ "" != "$curr" ] && [ "@{-$i}" != "$curr" ];
        then
            gcl_output="$gcl_output\n$i QQQ $curr QQQ git checkout @{-$i} QQQ gc-$i\n";
        fi;
    done
    echo -ne $gcl_output | column -t -s "QQQ"
}

alias be="bundle exec"
alias bes="bundle exec s -p"

alias rmount="truecrypt --mount --protect-hidden=no --keyfiles= ~/relevance.tc ~/relevance"
alias rumount="truecrypt --dismount ~/relevance.tc"

function ec() {
    /usr/bin/env emacsclient -nw -a "" $@
}

function gsp() {
    # Show a patch.
    sha=${1:-HEAD} # Default if not passed.
    git show --patch ${sha}
}

function gsh() {
    # Diff a SHA against its parent.
    sha=${1:-HEAD} # Default if not passed.
    git show ${sha}
}

function gtb() {
    # Checkout tracking branch.
    git checkout -b $1 --track remotes/origin/$1
}

function gps {
    # Do a quick git pull for given directories.
    cd ~/src/git/$@
    git pull
    cd -
}


# frob [NEW_PRIORITY] [PROCESS_NAME]
function frob {
    renice $1 `pidof $2`;
}

function showcolors()
{
    # Display ANSI colours.
    esc="\033["
    echo -e "\t  40\t   41\t   42\t    43\t      44       45\t46\t 47"
    for fore in 30 31 32 33 34 35 36 37; do
        line1="$fore  "
        line2="    "
        for back in 40 41 42 43 44 45 46 47; do
            line1="${line1}${esc}${back};${fore}m Normal  ${esc}0m"
            line2="${line2}${esc}${back};${fore};1m Bold    ${esc}0m"
        done
        echo -e "$line1\n$line2"
    done

    echo ""
    echo "# Example:"
    echo "#"
    echo "# Type a Blinkin TJEENARE in Swedens colours (Yellow on Blue)"
    echo "#"
    echo "#           ESC"
    echo "#            |  CD"
    echo "#            |  | CD2"
    echo "#            |  | | FG"
    echo "#            |  | | |  BG + m"
    echo "#            |  | | |  |         END-CD"
    echo "#            |  | | |  |            |"
    echo "# echo -e az'\033[1;5;33;44mTJEENARE\033[0m'"
    echo "#"
}



# Lend human-readable names to ANSI color-code escape sequences.
RS="\[\033[0m\]"         # reset
HC="\[\033[1m\]"         # hicolor
UL="\[\033[4m\]"         # underline
INV="\[\033[7m\]"        # inverse background and foreground
FBLACK="\[\033[30m\]"    # foreground black
FRED="\[\033[0;31m\]"    # foreground red
FGREEN="\[\033[32m\]"    # foreground green
FYELLOW="\[\033[33m\]"   # foreground yellow
FBLUE="\[\033[34m\]"     # foreground blue
FMAGENTA="\[\033[35m\]"  # foreground magenta
FCYAN="\[\033[36m\]"     # foreground cyan
FWHITE="\[\033[37m\]"    # foreground white
BBLACK="\[\033[40m\]"    # background black
BRED="\[\033[41m\]"      # background red
BGREEN="\[\033[42m\]"    # background green
BYELLOW="\[\033[43m\]"   # background yellow
BBLUE="\[\033[44m\]"     # background blue
BMAGENTA="\[\033[45m\]"  # background magenta
BCYAN="\[\033[46m\]"     # background cyan
BWHITE="\[\033[47m\]"    # background white



# Make less more friendly for non-text input files, see lesspipe(1).
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"
 

# MySQL prompt:
# mysql:(dmack@localhost)  (tracking_db)
export MYSQL_PS1="\n\n\nmysql:(\u@\h)\t(\d)\n"

# Abstract over date facilities, preferring GNU date's millisecond precision.
function get_time {
    # If on Mac...
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # And GNU date is available (via e.g.`brew install coreutils`)...
        if [[ $(type -P "gdate") ]]; then
            # Then we have millisecond precision.
            echo $(gdate +%s%3N)
        else
            # Otherwise, BSD date -- second precision. Paper over this with trailing zeros.
            printf "%d000" $(date +%s)
        fi
    else
        # If not on Mac, assume Linux and GNU date.
        echo $(date +%s%3N)
    fi

}

function timer_start() {
    _USER_COMMAND_STARTED_AT=${_USER_COMMAND_STARTED_AT:-$(get_time)}
}

function timer_stop() {
    local now=$(get_time)
    _USER_COMMAND_ELAPSED_TIME=$(echo "$now - $_USER_COMMAND_STARTED_AT" | bc)
    unset _USER_COMMAND_STARTED_AT
}

function parse_time() {
    local elapsed_ms=$1
    local elapsed_s=$elapsed_ms/1000
    local hours=$(echo "$elapsed_s/3600" | bc)
    local sub_hours=$(echo "$elapsed_s%3600" | bc)
    local minutes=$(echo "$sub_hours/60" | bc)
    local seconds=$(echo "$sub_hours%60" | bc)
    local millis=$(echo "$elapsed_ms%1000" | bc)
    _USER_COMMAND_PARSED_TIME=($hours $minutes $seconds $millis)
}

function parse_git_branch {
    git_status="$1"
    # git 1.5.8 removes the leading # from `git status` output.
    maybe_hash="(# )?"
    branch_pattern="^${maybe_hash}On branch ([^${IFS}]*)"
    if [[ "$git_status" =~ ${branch_pattern} ]]; then
        branch=${BASH_REMATCH[2]}
        echo "${branch}"
    fi
}

function parse_git_symbol {
    git_status="$1"
    maybe_hash="(# )?"
    branch_pattern="^${maybe_hash}On branch ([^${IFS}]*)"
    ahead_pattern="${maybe_hash}Your branch is ahead"
    behind_pattern="${maybe_hash}Your branch is behind"
    diverge_pattern="${maybe_hash}Your branch and (.*) have diverged"
    if [[ ! ${git_status} =~ "working tree clean" ]]; then
        state="${HC}${BRED}${FWHITE} ‼ ${RS}"
    fi
    if [[ ${git_status} =~ ${ahead_pattern} ]]; then
        remote_state="${HC}${BRED}${FWHITE} ↑ ${RS}"
    fi
    if [[ ${git_status} =~ ${behind_pattern} ]]; then
        remote_state="${HC}${BBLUE}${FWHITE} ↓ ${RS}"
    fi
    if [[ ${git_status} =~ ${diverge_pattern} ]]; then
        remote_state="${HC}${BMAGENTA}${FYELLOW} ↕ ${RS}"
    fi
    if [[ ${git_status} =~ ${branch_pattern} ]]; then
        echo "${remote_state}${state}"
    fi
}

function announce_return_after() {
  export ANNOUNCE_RETURN_AFTER=${1:-0};
  echo "ANNOUNCE_RETURN_AFTER=$ANNOUNCE_RETURN_AFTER";
}

function announce_return() {
    if [[ $1 -ge $ANNOUNCE_RETURN_AFTER && $ANNOUNCE_RETURN_AFTER -gt 0 ]]; then
        # Don't announce if user issued Ctrl-C or Ctrl-Z.
        # (Not sure how universal "146" is for SIGSTOP, which also can't be trapped.)
        if [[ $_USER_COMMAND_EXIT_CODE -ne 130 && $_USER_COMMAND_EXIT_CODE -ne 146 ]]; then
            # Make unpleasant sound if exit status warrants.
            if [[ $_USER_COMMAND_EXIT_CODE -eq 1 ]]; then
                afplay -r 5 /System/Library/Sounds/Basso.aiff & disown $!
            else
                afplay -r 5 /System/Library/Sounds/Morse.aiff & disown $!
            fi
        fi
    fi
}

# If the named tmux session I want to attach to doesn't already
# exist, create it, then attach.
ta () {
    if [ "$(tmux list-sessions | grep -E "^$1:")" ];
    then echo "Found existing session. Attaching."
         tmux attach-session -t $1;
    else echo "Creating new session and attaching."
         tmux new-session -s $1;
    fi;
}

function user_command_timer_display_color() {
    local elapsed_seconds=${_USER_COMMAND_PARSED_TIME[2]}
    local color
    if [[ $elapsed_seconds -lt 4 ]]; then
        color=$FBLACK
    else
        if [[ $elapsed_seconds -lt 10 ]]; then
            color=$HC$FYELLOW
        else
            color=$HC$FRED
        fi
    fi
    echo $color
}

function user_command_timer_display_string() {
    local string=""
    if [[ ${_USER_COMMAND_PARSED_TIME[0]} -gt 0 ]]; then
        string+="${_USER_COMMAND_PARSED_TIME[0]}h"
    fi
    if [[ ${_USER_COMMAND_PARSED_TIME[1]} -gt 0 ]]; then
        string+="${_USER_COMMAND_PARSED_TIME[1]}m"
    fi
    if [[ ${_USER_COMMAND_PARSED_TIME[2]} -gt 0 ]]; then
        string+="${_USER_COMMAND_PARSED_TIME[2]}"
    fi
    string+=$(printf ".%03ds" ${_USER_COMMAND_PARSED_TIME[3]})
    echo $string
}

function user_command_ret_val_display_string() {
    if [[ $_USER_COMMAND_EXIT_CODE -gt 0 ]]; then
        echo "${FBLACK}/${BRED}${HC}${INV}$_USER_COMMAND_EXIT_CODE${RS}"
    fi
}

function fancy_prompt() {
    function prompt_func() {
        # BASH prompt:
        # (dmack@ming:~/dotfiles)      [(git-branch) if git repo]         (12:57:38/[elapsed-time-of-previous-command])
        # [git-symbol if git repo] [cursor]

        timer_stop
        parse_time $_USER_COMMAND_ELAPSED_TIME

        git rev-parse --git-dir &> /dev/null
        git_status="$(git status 2> /dev/null)"
        branch=$(parse_git_branch "$git_status")
        if [[ -n "$branch" ]]; then
          branch="(${branch})       "
        fi
        symbol=$(parse_git_symbol "$git_status")

        PS1="\n\n$FGREEN($FWHITE\u@\h$FGREEN:\w)$RS       " # <newline> <newline> (username@hostname) <faketab>
        PS1+="$HC$FBLUE$branch$RS"                      # git-branch token if in a git repo
        
        PS1+="$FGREEN(\t"
        PS1+="$(user_command_ret_val_display_string)"
        PS1+="${FBLACK}/$(user_command_timer_display_color)"
        PS1+="$(user_command_timer_display_string)$FGREEN)$RS      " # time <faketab>
        PS1+="\n$symbol" # git-symbol token if in a git repo

        announce_return ${_USER_COMMAND_PARSED_TIME[2]}
    }
    PROMPT_COMMAND=prompt_func
}

function simple_prompt() {
    function prompt_func() {
        # BASH prompt:
        # [git-branch if git repo]:~/dotfiles[git-symbol if git repo] [cursor]
        git rev-parse --git-dir &> /dev/null
        git_status="$(git status 2> /dev/null)"
        branch=$(parse_git_branch "$git_status")
        branch="${branch}"
        symbol=$(parse_git_symbol "$git_status")
        PS1="\n\n\[\e[1;34;40m\]${branch:0:15}\[\e[0m\]:\[\e[32;40m\]\W>\[\e[0m\]$symbol$RS "
    }

    PROMPT_COMMAND=prompt_func
}

fancy_prompt

trap timer_start DEBUG

pre_prompt () {
    # First, preserve for downstream fns the return value of the
    # command the user has issued so that intermediate prompt-driven
    # fns don't clobber it with their own return codes.
    _USER_COMMAND_EXIT_CODE=$?
    # Flush history to file on each command issued, so resulting history
    # file contains all commands from all sessions.
    history -a
}

PROMPT_COMMAND="pre_prompt; $PROMPT_COMMAND"

if [ -f /usr/local/bin/brew ]; then
  if [ -f `brew --prefix`/etc/autojump ]; then
      echo "Setting autojump"
    . `brew --prefix`/etc/autojump
  fi
fi

bind "set show-all-if-ambiguous on"

ara 1


# brew install awscli
# ==> Downloading https://homebrew.bintray.com/bottles/awscli-1.10.32.el_capitan.bottle.tar.gz
# ######################################################################## 100.0%
# ==> Pouring awscli-1.10.32.el_capitan.bottle.tar.gz
# ==> Caveats
# The "examples" directory has been installed to:
#   /usr/local/share/awscli/examples

# Add the following to ~/.bashrc to enable bash completion:
#   complete -C aws_completer aws

# Add the following to ~/.zshrc to enable zsh completion:
#   source /usr/local/share/zsh/site-functions/_aws

# Before using awscli, you need to tell it about your AWS credentials.
# The easiest way to do this is to run:
#   aws configure

# More information:
#   https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html

# zsh completion has been installed to:
#   /usr/local/share/zsh/site-functions
# ==> Summary
# 🍺  /usr/local/Cellar/awscli/1.10.32: 2,703 files, 19.7M

complete -C aws_completer aws

function li() {
    if [ -z ${1+x} ]; then
        lein install;
    else
        \cd $1
        lein install
        \cd -
    fi
}

eval "$(direnv hook bash)"

function last_docker_container(){
    docker ps -l | head -n 2 | \tail -n 1 | awk {'print $1'}
}

alias ldc="last_docker_container"


alias di="docker images"
alias dp="docker ps"     # List running containers.
alias dpa="docker ps -a" # List all containers.

function rm_last_container(){
    local last_c=$(last_docker_container)
    docker stop "$last_c"
    docker rm "$last_c"
    echo "Container deleted."
}

alias rlc="rm_last_container"

function log_last_container(){
    local last_c=$(last_docker_container)
    docker logs "$last_c"
}

alias llc="log_last_container"

alias fk="fkill -v"

function docnames(){
    echo
    docker ps --format "table {{.ID}}	{{.Status}}	{{.Names}}"
    }

function docstop(){
    local name="dct_$1_1"
    local cid=$(docker ps -q --filter "name=$name")
    docker stop "$cid"
    docnames
}

function docstart(){
    local name="dct_$1_1"
    local cid=$(docker ps -a -q --filter "name=$name")
    docker start "$cid"
    docnames
}


function jj {
    jet --from json --pretty --keywordize $1
}


export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh

