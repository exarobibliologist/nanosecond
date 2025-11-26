![](https://i.imgur.com/OKroi5L.png)<br>![](https://i.imgur.com/k67VjAZ.png)<br>![](https://i.imgur.com/bMVIk0p.png)

<b>APT Preferences will also be heavily modified.</b> This will help to control the extra sources so things stay stable while giving you extra access to packages far beyond stable.

To run these scripts you will need:
<blockquote><b>Expert</b> level Debian Linux knowledge. Don't attempt to run these scripts without brains.</blockquote>
<blockquote><b>God-Level</b> knowledge, if attempting to rewrite or modify these scripts for another Linux operating system.</blockquote>
<blockquote><b>Moderate</b> BASH scripting experience.</b> Many scripts are extensively layered to produce the unique look I like in the Terminal interface.</blockquote>
<blockquote><b>Beginner to Moderate</b> Conky scripting experience.</blockquote>
<blockquote><b>Be willing to learn and experiment</b></blockquote>
<blockquote><b>And a sense of humor.</b></blockquote>

<h1>THIS IS ONLY FOR DEBIAN!!<br><br>Additionally, it will work with the Debian package for WSL (Windows Subsystem for Linux) on Windows.</h1>
<h2>This will cause <u>unrecoverable</u> changes to your Debian setup.</h2>

These scripts will <b>permanently hybridize</b> your Debian setup. converting it into a Debian setup that is incredibly versatile, without sacrificing stability.

<b>You will get a modified sources.list that includes extra sources (for testing, unstable, and experimental).</b>
The sources use deb.debian.org so that you will always be on the fastest Debian server.
Generic version names are used to allow rolling release upgrades and updates.

These scripts are not designed for beginning Debian users.
If you are uncomfortable with learning new things, and want to stick with the standard methods of using/customizing Linux, this repo <b>IS NOT</b> for you. <b>Walk away now!</b>

<h1>but...</h1>

<h2>if you're still here...</h2>

<h3>and want to continue...</h3>

<b>To install these scripts, follow the directions below.</b>

You will need <b>git-all</b> installed beforehand, in order to fetch and use all the files.

<blockquote><code>sudo apt-get install git-all</code></blockquote>

Open a Terminal and type
<blockquote><code>cd</code></blockquote>
<blockquote><code>mkdir ~/GIT/</code></blockquote>
<blockquote><code>cd ~/GIT</code></blockquote>
<blockquote><code>git clone https://github.com/exarobibliologist/nanosecond</code></blockquote>

Then navigate into the created folder like so:
<blockquote><code>cd ~/GIT/nanosecond</code></blockquote>

and type:
<blockquote><code>bash installbash</code></blockquote>

The installer will not overwrite your .bashrc, but will copy a single line to end of your .bashrc to source the modified bashrc file I have included in the nanosecond repo.

After that is complete, close your Terminal and reopen.
You should see a unique Terminal prompt.

Then type:

<blockquote><code>installstuff</code></blockquote>

Follow the menu prompts to install other programs your system can use.

![](https://i.imgur.com/8ADPFLl.png)
