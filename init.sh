#!/bin/bash
#先安装vitrulbox,vscode
#xcode-select --install

# install brew 
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update


HOME_DIR=$(pwd)

# install zsh and oh-my-zs
brew install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
chsh -s /bin/zsh
cd ~/.oh-my-zsh/themes
git clone https://github.com/dracula/zsh.git
mv zsh/dracula.zsh-theme .
rm -rf zsh
sed -i "" 's/ZSH_THEME="robbyrussell"/ZSH_THEME="dracula"/' ~/.zshrc

# install autojump
brew install autojump
autojump


cd ~/Downloads
brew install mycli tldr thefuck htop jq wget 


# upgrade vim
cd $HOME_DIR
brew install mercurial
brew install vim
sudo mv /usr/bin/vim /usr/bin/vim72
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cp vimrc ~/.vimrc
vim +PluginInstall +qall

# install git
ssh-keygen -t rsa -C "zz.thoreau@gmail.com"
pbcopy < ~/.ssh/id_rsa.pub



# install maven
wget https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.zip
mkdir ~/Documents/JAVA
cp apache-maven-3.5.3-bin.zip ~/Documents/JAVA
unzip ~/Documents/JAVA/apache-maven-3.5.3-bin.zip

# install gradle
wget https://downloads.gradle.org/distributions/gradle-4.6-bin.zip
unzip gradle-4.6-bin.zip

# install cowsay
brew install cowsay fortune lolcat

source ~/.bash_profile


brew install docker docker-machine
docker-machine create --driver=virtualbox default
