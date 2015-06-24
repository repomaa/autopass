# Autopass

A rofi frontend for pass

## Features

- performs autotype with entries
- allows setting window name property (a regex) to match against window titles
- automatically focuses correct window or asks you to
- allows any amount of additional properties which can be used in autotype
- displays entries that are most likely to match currently focused window first
- uses encrypted cache to store pass entries in a single file for fast startup

## Installation

### ArchLinux

Get autopass-git with your favorite aur helper

### Other systems

Copy autopass from this repo somewhere in your path.

#### Dependencies:

- [pass](https://github.com/zx2c4/password-store)
- [rofi](https://github.com/DaveDavenport/rofi)
- [xdotool](http://www.semicomplete.com/projects/xdotool/)
- [libnotify](https://developer.gnome.org/libnotify)
- [xwininfo](http://www.xfree86.org/4.2.0/xwininfo.1.html)
- [xclip](http://sourceforge.net/projects/xclip/')

## Usage

- run `autopass`
- Highlight an entry either by fuzzy search or with arrow keys
- Press return for autotype
- Press Alt+1 for autotype-1
- Press Alt+2 for autotype-2
- etc
- Press Alt+p to copy pass to clipboard
- Press Alt+u to copy user to clipboard

Copied values are cleared from clipboard after 45 seconds

## Entry syntax

Create entries as usual with `pass insert` etc.
Edit them with `pass edit` and add additional properties in the following syntax

``` yaml
my_super_secret_password
---
user: username
some_other_property: some value
autotype:
	- user
	- some_other_property
	- pass
autotype-1:
	- pass
autotype-2:
	- user
window: some site.*- Chromium
```

You can write any kind of key value pairs here as long as it's valid yaml.
Only and `autotype`, `autotype-{1-7}`, `window` have special meanings.

By default the name of the entry (without parent group(s)) is used for `window`,
`['user', 'pass']` for `autotype` and `['pass']` for `autotype-1`, `['user']` for `autotype-2`
