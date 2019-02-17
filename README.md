nanosecond
==========
This is a collection of my BASH scripts, and time saving scripts.

<h1>THIS IS ONLY FOR DEBIAN!!</h1>

<h2>This will cause <u>unrecoverable</u> changes to your Debian setup.</h2>

<b>This will overwrite your sources.list with a modified version that includes extra sources (for testing, unstable, and experimental).</b> The sources list is formatted in such a 
way that you will always be on the fastest Debian server (I use deb.debian.org to select the fastest server to your location), and it will always be up-to-date even after the version 
names advance..

<b>This will also add a preferences file to /etc/apt/preferences.d/</b> This will help to control and limit the extra sources in the sources.list so things stay stable while giving you 
extra access to packages far beyond stable.

To run these scripts you will need:
<blockquote><b>Moderate to Expert</b> level Debian Linux knowledge. Don't run these scripts without brains.</blockquote>
<blockquote><b>Understand BASH scripting</b> (These scripts run everywhere from beginner to expert. Many scripts are extensively layered to produce the unique look I like in the Terminal 
interface.)</blockquote>
<blockquote><b>Beginner to Moderate Conky</b> understanding</blockquote>
<blockquote><b>And a sense of humor.</b></blockquote>

Many of the hacks written in this repo defy the Debian Wiki. If you believe that everything in the Debian Wiki is absolute and cannot be violated, this repo IS 
NOT for you. Walk away now!

These scripts will produce a FrankenDebian setup that is incredibly stable. If you are uncomfortable with this type of Debian setup, this repo IS NOT for you. Walk away now!

<b>If you're still here and want to continue...</b>

To install these scripts, follow the directions below.

You will need <b>git</b> installed beforehand, in order to fetch and use all the files.

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
