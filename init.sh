#!/bin/bash
#先安装vitrulbox,vscode
#xcode-select --install

HOME_DIR=$(pwd)

## install brew
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
brew update


cd ~/Downloads
brew install mycli tldr thefuck htop jq wget 

# install zsh
brew install zsh
cd ~/.oh-my-zsh/themes
git clone https://github.com/dracula/zsh.git
mv zsh/dracula.zsh-theme .
rm -rf 
sed -i "" 's/ZSH_THEME="robbyrussell"/ZSH_THEME="dracula"/' ~/.zshrc



# upgrade vim
cd $HOME_DIR
brew install mercurial
brew install vim
sudo mv /usr/bin/vim /usr/bin/vim72
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim




# install maven
wget https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.zip
mkdir ~/Documents/JAVA
cp apache-maven-3.5.3-bin.zip ~/Documents/JAVA
unzip ~/Documents/JAVA/apache-maven-3.5.3-bin.zip


# install cowsay
brew install cowsay fortune lolcat

source ~/.bash_profile


brew install docker docker-machine
docker-machine create --driver=virtualbox default





