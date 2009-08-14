# If not running interactively, don't do anything:
[ -z "$PS1" ] && return

export LC_CTYPE=en_US
export HISTCONTROL=ignoredups
export HISTSIZE=10000
shopt -s histappend # Don't overwrite the older history file on exit -- append to it.
shopt -s checkwinsize # Avoids crappy linewrapping overwrite.
export EDITOR=emacs
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
	cd $*;
	ls -al $LS_OPTIONS;
}

alias ..='za ..'

alias d='ls -Lla|grep ^d'
alias e='emacsclient'
alias f='find . | grep -v ".git"'
alias i='ipython2.6'
alias pd='pushd'
alias mega='du -ah|grep '[0-9]M' '
alias ff='find . -name $1'
alias g='grep --color=auto --exclude=*gif --exclude=*svn*'

alias fm='fetchmail -d 1200'
alias fh='fetchmail' # This will HUP an existing fetchmail daemon and grab new mail.

alias bt='btdownloadcurses.py --max_uploads 1 --max_upload_rate 5'
alias cp='cp -i'
alias h='history'
alias j='jobs -l'
alias mv='mv -i'
alias p='ps auxw'
alias rm='rm -i'
alias s='kill -STOP %?procmail.log; fh; ruby -I /home/vasudeva/sup/lib /home/vasudeva/sup/bin/sup; fh; bg %?procmail.log;'
alias tail='tail -n 100'
alias vi='vim -X'

alias tc='/opt/local/bin/yasql corp/corp@testdb'


function tree()
{
    echo -e "\033[1;33m"

    (cd ${1-.} ; pwd)
    find ${1-.} -print | sort -f | sed     \
        \
        -e "s,^${1-.},,"                   \
        -e "/^$/d"                         \
        -e "s,[^/]*/\([^/]*\)$,\ |-->\1,"  \
        -e "s,[^/]*/, |   ,g"

    echo -e "\033[0m"
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




# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"



if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi


# MySQL prompt:
# mysql:(dmack@localhost)  (tracking_db)
export MYSQL_PS1="\n\n\nmysql:(\u@\h)\t(\d)\n"
# BASH prompt: 
# (dmack@ming)       (~/dotfiles)        (12:57:38)
export PS1="\n\n\[\033[0;32m\](\[\033[0;37m\]\u@\h\[\033[0;32m\])       (\[\033[0;32m\]\w\[\033[0;32m\])        (\[\033[0;32m\]\t\[\033[0;32m\]) \[\033[0m\]\n";

export PYTHONPATH=$PYTHONPATH:$HOME/src/git
export ORACLE_HOME=/opt/oracle
export TNS_ADMIN=$ORACLE_HOME
# Darwin
export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:$ORACLE_HOME
# Linux
export LD_LIBRARY_PATH=$ORACLE_HOME

