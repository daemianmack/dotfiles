
# If not running interactively, don't do anything:
[ -z "$PS1" ] && return

# export LANG=C
# export LC_ALL=C
export HISTCONTROL=ignoredups
export HISTSIZE=10000
shopt -s histappend # Don't overwrite the older history file on exit -- append to it.
shopt -s checkwinsize # Avoids crappy linewrapping overwrite.
export EDITOR='emacsclient -n -a emacs'
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
alias ls.='ls $LS_OPTIONS -alhF|less'     # ls with dotfiles and less
alias lss='ls $LS_OPTIONS -Srlh'	  # sort by: Size reversed...
alias lst='ls $LS_OPTIONS -altrhF'	  #          Time...
alias lsx='ls $LS_OPTIONS -alh|sort'	  #          chmod...
alias lsd='ls $LS_OPTIONS -lhF|grep /'	  # Just:    Dirs...         
alias lsf='ls $LS_OPTIONS -lhF|grep -v /' #          Files...

function za() {
	\cd $*;
        if [[ $? -eq 0 ]]; then
	    ls -al $LS_OPTIONS;
        fi
}

alias cd='za'
alias ..='za ..'
alias pu='pushd'
alias po='popd'
alias -- -='cd -'

alias d='ls -Lla|grep ^d'
alias e='emacsclient'              # Standalone client.
alias f='find . | grep -v ".git"'
alias mega='du -ah|grep '[0-9]M' '
alias ff='find . -name "$@"'
alias g='grep --color=auto --exclude=*gif --exclude=*svn*'

alias fm='fetchmail -d 1200'
alias fh='fetchmail' # This will HUP an existing fetchmail daemon and grab new mail.

alias cp='cp -i'
alias h='history'
alias j='jobs -l'
alias mv='mv -i'
alias p='ps auxw'
alias rm='rm -i'
alias tail='tail -n 100'
alias vi='vim -X'

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
alias gc-="git checkout -"  # Checkout last-checked-out branch.


alias be="bundle exec"
alias bes="bundle exec s -p"

alias rmount="truecrypt --mount --protect-hidden=no --keyfiles= ~/relevance.tc ~/relevance"
alias rumount="truecrypt --dismount ~/relevance.tc"

function ec() {
    /usr/bin/env emacsclient -c -a "" $@
}

function gdd() {
    # Diff a SHA against its parent.
    sha=${1:-HEAD} # Default if not passed.
    git diff ${sha}^ ${sha}
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



function parse_git_branch {
    git_status="$1"
    branch_pattern="^# On branch ([^${IFS}]*)"
    if [[ "$git_status" =~ ${branch_pattern} ]]; then
        branch=${BASH_REMATCH[1]}
        echo "${branch}"
    fi
}

function parse_git_symbol {
    git_status="$1"
    branch_pattern="^# On branch ([^${IFS}]*)"
    remote_pattern="# Your branch is (.*)"
    diverge_pattern="# Your branch and (.*) have diverged"
    if [[ ! ${git_status} =~ "working directory clean" ]]; then
        state="${FRED}⚡" # Red text should be annoying.
    fi
    # add an else if or two here if you want to get more specific
    if [[ ${git_status} =~ ${remote_pattern} ]]; then
        if [[ ${BASH_REMATCH[1]} == "ahead" ]]; then
            remote="${FYELLOW}↑"
        else
            remote="${FYELLOW}↓"
        fi
    fi
    if [[ ${git_status} =~ ${diverge_pattern} ]]; then
        remote="${FYELLOW}↕"
    fi
    if [[ ${git_status} =~ ${branch_pattern} ]]; then
        branch=${BASH_REMATCH[1]}
        echo "${remote}${state}"
    fi
}

function fancy_prompt() {
    function prompt_func() {
        # BASH prompt:
        # (dmack@ming:~/dotfiles)      [(git-branch) if git repo]         (12:57:38)
        # [git-symbol if git repo] [cursor]

        git rev-parse --git-dir &> /dev/null
        git_status="$(git status 2> /dev/null)"
        branch='($(parse_git_branch "$git_status"))       '
        branch="${branch}"
        symbol=$(parse_git_symbol "$git_status")

        PS1="\n\n$FGREEN($FWHITE\u@\h$FGREEN:\w)$RS       " # <newline> <newline> (username@hostname) <faketab>
        PS1=$PS1"$HC$FBLUE$branch$RS"                       # git-branch token if in a git repo
        PS1=$PS1"$FGREEN(\t)$RS"                            # time
        PS1=$PS1"\n$symbol$RS "                             # git-symbol token if in a git repo
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
        PS1="\n\n\[\e[1;34;40m\]$branch\[\e[0m\]:\[\e[32;40m\]\w>\[\e[0m\]$symbol$RS "
    }

    PROMPT_COMMAND=prompt_func
}

fancy_prompt

# Share history across sessions in real-time.
# Flush history on each command issued and re-source history file.
PROMPT_COMMAND="$PROMPT_COMMAND; history -a; history -n"
if [ -f /usr/local/bin/brew ]; then
  if [ -f `brew --prefix`/etc/autojump ]; then
      echo "Setting autojump"
    . `brew --prefix`/etc/autojump
  fi
fi

export PYTHONPATH=$PYTHONPATH:$HOME/src/git

# virtualenv stuff...
export WORKON_HOME=$HOME/.virtualenvs
if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
    source /usr/local/bin/virtualenvwrapper.sh
fi
