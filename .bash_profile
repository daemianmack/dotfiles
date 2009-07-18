# ~/.bash_profile: executed by bash(1) for login shells.
# see /usr/share/doc/bash/examples/startup-files for examples

# u+rw for files, u+rwx for directories you own. go-rwx for your files and directories. 
umask 077

#on this next line, we start keychain and point it to the private keys that
#we'd like it to cache
/usr/bin/keychain ~/.ssh/id_rsa
source ~/.keychain/$HOSTNAME-sh > /dev/null

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

# include my ~/bin in my $PATH
if [ -d ~/bin ] ; then
    PATH="~/bin:${PATH}"
fi

