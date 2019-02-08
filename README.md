nanosecond
==========
This is a collection of my BASH scripts, and time saving scripts.

<h2>THIS IS ONLY FOR DEBIAN!!</h2>

<b>This will overwrite your sources.list with a modified version that includes extra sources (for testing, unstable, and experimental).</b>
<b>This will add a preferences file to /etc/apt/preferences.d/ to control and limit the extra sources.</b>

To run these scripts you will need Moderate to Expert level Debian Linux understanding. If you are uncomfortable with this type of Debian setup, DO NOT CONTINUE!

To install these scripts, follow the directions below. You will need git installed beforehand, in order to fetch and use all the files.

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
