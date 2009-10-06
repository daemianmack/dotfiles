# ~/.bash_profile: executed by bash(1) for login shells.
# see /usr/share/doc/bash/examples/startup-files for examples

#on this next line, we start keychain and point it to the private keys that
#we'd like it to cache
/usr/bin/keychain ~/.ssh/id_rsa
source ~/.keychain/$HOSTNAME-sh > /dev/null

# Accommodate MacPorts' use of ~/.profile
case `uname` in
  Darwin)
    if [ -f ~/.profile ]; then
        source ~/.profile
    fi
    ;;
esac

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
if [ -f /opt/local/etc/bash_completion ]; then
    . /opt/local/etc/bash_completion
fi


# include my ~/bin in my $PATH
if [ -d ~/bin ] ; then
    PATH="~/bin:${PATH}"
fi

