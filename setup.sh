#!/bin/sh

echo 'Setting up .bashrc'
ln -fs $(realpath .bashrc) ~/.bashrc 

echo 'Setting up .bash_profile'
ln -fs $(realpath .bash_profile) ~/.bash_profile 

echo 'Setting up .gitconfig'
ln -fs $(realpath .gitconfig) ~/.gitconfig 

echo 'Setting up .git_prompt_colors'
ln -fs $(realpath .gitconfig) ~/.gitconfig 

echo 'Setting up vim'
ln -fs $(realpath .vim) ~/.vim 
ln -fs $(realpath .vim/.vimrc) ~/.vimrc

echo 'Done.'

echo 'You may want to install homebrew, bash-git-prompt, and install vim plugins'
