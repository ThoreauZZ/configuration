# java
JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_161.jdk/Contents/Home
export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar 
export PATH=$PATH:$JAVA_HOME/bin 

# maven
export M2_HOME=/Users/zhaozhou/Documents/JAVA/apache-maven-3.5.3
export PATH=$PATH:$M2_HOME/bin

# git 
alias ll='ls -la'
alias gst='git status'
alias ga='git add .'
cowsay `fortune` |lolcat

