[`dark-mode(1)`](./dark-mode.1)
===============================

Manipulate macOS's dark mode from the command-line. Pure AppleScript, no runtime
libraries or compilation needed.


Installation
------------
Just run `make install` after cloning this repository somewhere:

~~~console
$ git clone https://github.com/Alhadis/Dark-Mode /tmp/dark-mode && cd $_
$ make install && cd -
~~~

Or even just

~~~console
$ cd /usr/local/bin
$ wget https://raw.githubusercontent.com/Alhadis/Dark-Mode/master/dark-mode
$ chmod +x dark-mode
~~~

but that won't give you a spiffy-looking [man page](./dark-mode.1).


Usage
-----
Toggle dark mode:

~~~console
$ dark-mode -t
~~~

Display the current dark mode:

~~~console
$ dark-mode
~~~


Caveats
-------
Have only tested this on Big Sur (macOS 11). Probably works on other versions as
well, but [give me a holler](https://github.com/Alhadis/Dark-Mode/issues/new) if
it doesn't.
