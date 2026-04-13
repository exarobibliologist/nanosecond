![](https://i.imgur.com/OKroi5L.png)<br>![](https://i.imgur.com/k67VjAZ.png)<br>![](https://i.imgur.com/bMVIk0p.png)

# THIS IS INTENDED TO BE ***ONLY*** FOR DEBIAN!!

# To run these scripts AS-IS you must have:
- **Debian Stable installation on your computer.**
- **A keyboard, a monitor, and the sheer force of will to use them.**
- **Ability to read and comprehend instructions**
- **A deep appreciation for terminal aesthetics and curses-based menus.**
- **Like rollercoasters**
- **Have a sense of humor**
- **A willingness to experiment and learn new things**

# To tweak these scripts for another Debian Linux distro, you must have:
- **Expert level Debian knowledge.**
- **Expert BASH scripting knowledge.**
- **Moderate Python scripting knowledge.**
- **Moderate LS and PS1 scripting knowledge. While this part of the script is the easiest to modify and tweak, many scripts are extensively layered to produce the unique TTY look I like.**
- **A tested, verified, and physically disconnected backup drive. Seriously!**
- **Enjoy the smell of crashing and burning**

# To tweak these scripts to another non-Debian Linux OS, you must have:
- **God-Level Linux knowledge, especially with apt and apt_preferences. (If those two systems do not exist on the Linux OS you choose, you MUST be God to rewrite and untangle all of this)**
- **Expert-Level BASH scripting knowledge, especially when figuring out if your terminal outputs PS1 and BASH color codes correctly or not.**
- **Like driving tractor trailers without breaks downhill on icy roads**
- **Be willing to keep going after any/all accidents occur, and pretend the flames are just a new desktop feature.**
- **As always, if you break things, you get to keep both halves.**

# THIS IS INTENDED TO BE ***ONLY*** FOR DEBIAN!!

### If you want something like this on Ubuntu, Mint, Fedora, or Arch, you are welcome to write your own, but if you use this script AS-IS on another OS, there is a 99.99999% chance you will destroy your system without ever knowing what went wrong.

## These scripts are not designed for beginning Debian users.
- **I recommend you experience Debian AS-IS *before* trying to tweak the crap out of it.**
- **Walk *before* you run.**
- **Run *before* you attempt to permanently hybridize your package manager.**

#### These scripts will *permanently hybridize* your Debian setup.

###### It will convert a Debian Stable install into a hybrid rolling Debian setup that is incredibly versatile, without sacrificing stability.
###### You will get a modified sources.list that includes extra sources (for testing, unstable, and experimental).
###### Version names are used to allow rolling release upgrades and updates.
###### APT Preferences will be heavily modified to control the extra sources so things stay stable while giving you extra access to packages far beyond stable.

####If you are uncomfortable with learning new things, and want to stick with the standard methods of using/customizing Linux, this repo IS NOT for you.
Walk away now!</b>

# but.........
### if you are still here......
##### and want to continue...

### To install these scripts, follow the directions below.</b>

You will need `git` installed beforehand, in order to fetch and use all the files.

`sudo apt install git`

Open a Terminal and type
`cd`
`mkdir ~/GIT/`
`cd ~/GIT`
`git clone https://github.com/exarobibliologist/nanosecond`

Then navigate into the created folder like so:
`cd ~/GIT/nanosecond`

make the install script executable

`chmod +x installbash`

then install:

`bash installbash`

The installer will not overwrite your .bashrc, but will copy a single line to end of your .bashrc to source the modified bashrc file I have included in the nanosecond repo.

After that is complete, close your Terminal and reopen.
You should see a unique Terminal prompt.

Then type:

`installstuff`

and follow the menu prompts to install other programs your system can use.

![](https://i.imgur.com/8ADPFLl.png)
