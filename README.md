# VSH Server (BASH)

This project aims to create an archive server.

It allows you to launch and query the archive server via a
new shell command, named vsh, which works in different modes.

## What is an archive ?

An archive is a file used to represent the tree structure of a directory and the contents of all files in this tree.
An archive consists in two parts:
1) 'header', describes the file tree.
2) 'body', represents the contents of the different files.
(@see test archive)

#### - Header Exemple
![Header Exemple](IMG_Demo/exemple_header.PNG? "Header Exemple")

## Getting started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. 

### Prerequisites

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

### Server side
#### - Launching the server

  ![launch](IMG_Demo/browse.PNG? "Launching the server")

### Client side
#### - What are the different modes ?

  ![Help](IMG_Demo/testing_help.PNG? "VSH Help")

#### - List and Extract
  
 ![List and Extract](IMG_Demo/list_extract.PNG? "List and Extract")
 ![Extract success](IMG_Demo/success.PNG? "Extract success")
 ![Check Extract](IMG_Demo/tree.PNG? "Check Extract")
 
 #### - Browse
 
 ![Browse](IMG_Demo/browse_rm.PNG? "Browse")
 
 #### - Add / Generate / Init / Delete

**It Exist** ... and **it works** ... (######sometimes) 

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
* **aurelien45** - *Initial work* - [see Aurelien's github](https://github.com/aurelien45)
* **me** - *Initial work* - [see Gray github](https://github.com/GrayDevs/)
* **Zorzi** - *archive generator (recursive function)* - [see z0rzi github](https://github.com/z0rzi/)

See also the list of [contributors](https://github.com/GrayDevs/vsh/contributors) who participated in this project.

## License

This project is licensed under <no_license> yet

