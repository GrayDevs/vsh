# VSH Server (BASH)

This project aims to create an archive server.

It allows you to launch and query the archive server via a
new shell command, named vsh, which works in different modes.

## What is an archive ?

An archive is a file used to represent the tree structure of a directory and the contents of all files in this tree.
An archive consists of two parts:
1) 'header', describes the file tree.
2) 'body', represents the contents of the different files.
(@see test archive)

## Getting started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. 

### Prerequisites

What things you need to install the software and how to install them ?

For debian-based OS or Windows 10 WSL
(@see https://docs.microsoft.com/en-us/windows/wsl/install-win10)
```
sudo apt-get install netcat
sudo apt-get install cryptcat
```
### Installing
```
git clone https://github.com/GrayDevs/vsh.git
```

## Demo

```
Work in progress
```

### Common Error

When running vsh, you may have this error :
```
'\r': command not found - .bashrc / .bash_profile
```
Indeed, if you modified the files on windows, the newline characters is by default set to \r\n which give you this error.
To solve this issue, you juste need to set the newline sequence to LF (and not CRLF).

## Built With

* [VSCode](https://code.visualstudio.com/) - Best text editor
* [SublimeText](http://www.sublimetext.com/) - classical text editor
* [Vim](https://github.com/vim/vim) - stubborn people text editor

## Authors

* **name** - *Initial work* - [nickname](github link)
* **name2** - *Initial work* - [nickname2](github link)
* **name3** - *archive generator* - [nickname3](github link)
See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under <no_license> yet

