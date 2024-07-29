# dotfiles
My dotfiles

## Steps to use

* Install gnu stow (Ubuntu: `sudo apt install stow`)
* Clone this repo and enter the directory
* Make sure that none of the config directories are present in your home directory (~)
* Run the command:
    `stow -vt ~ */`
* Run `ls -l ~/.config` to verify that symlinks are created properly
* Enjoy!
