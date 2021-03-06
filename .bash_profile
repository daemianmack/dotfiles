# ~/.bash_profile: executed by bash(1) for login shells.
# see /usr/share/doc/bash/examples/startup-files for examples

#  If we have keychain, start it and point it to the private keys that we'd like it to cache.
if [ -f /usr/local/bin/keychain ]; then
    /usr/local/bin/keychain ~/.ssh/id_?sa
    source ~/.keychain/$HOSTNAME-sh > /dev/null
else
    echo ""
    echo "keychain not yet installed!"
    echo ""
fi

# Accommodate MacPorts' use of ~/.profile
case `uname` in
  Darwin)
    if [ -f ~/.profile ]; then
        source ~/.profile
    fi
    ;;
esac

# include my ~/bin in my $PATH
if [ -d ~/bin ] ; then
    PATH="~/bin:${PATH}"
fi

# Include /opt/local/bin in my $PATH if it exists
if [ -d /opt/local/bin ] ; then
    PATH="${PATH}:/opt/local/bin"
fi

# include .bashrc if it exists
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# include a localized .bashrc if it exists
if [ -f ~/.bashrc.local ]; then
    source ~/.bashrc.local
fi


if [ -f ~/.bash_completes ]; then
    source ~/.bash_completes
fi

# Linux
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Darwin
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

PATH="/usr/local/bin:${PATH}"

eval "$(rbenv init -)"
