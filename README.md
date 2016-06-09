# Autopass

A rofi frontend for pass

## Features

- performs autotype with entries
- allows setting window name property (a regex) to match against window titles
- automatically focuses correct window or asks you to
- allows any amount of additional properties which can be used in autotype
- displays entries that are most likely to match currently focused window first
- uses encrypted cache to store pass entries in a single file for fast startup
- OTP (one-time-password) generation (install the ruby gem `rotp` for this)

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

Optionally you can install one of the following browser extensions for better autotype. These add your current URL to
your title (and window title) which can be matched by the URL entry in your password entry.
- Chrom(e|ium) extension [url-in-title](https://chrome.google.com/webstore/detail/url-in-title/ignpacbgnbnkaiooknalneoeladjnfgb)
- Firefox extension [add-url-to-window-title](https://addons.mozilla.org/en-US/firefox/addon/add-url-to-window-title/) ([Repository](https://github.com/erichgoldman/add-url-to-window-title))

## Usage

- run `autopass`
- Highlight an entry either by fuzzy search or with arrow keys
- Press Enter for autotype
- Press Alt+1 for autotype_1
- Press Alt+2 for autotype_2
- Press Alt+3 for autotype_3
- etc
- Press Alt+p to copy pass to clipboard
- Press Alt+u to copy user to clipboard
- Press Alt+c to copy otp code to clipboard
- Press Alt+t to autotype a tan from the entry
- Press Alt+o to open specified URL in your browser

Copied values are cleared from clipboard after 45 seconds

## Entry syntax

Create entries as usual with `pass insert` etc.
Edit them with `pass edit` and add additional properties in the following syntax

``` yaml
my_super_secret_password
---
user: username
url: https://example.com/login
some_other_property: some value
autotype: [user, ':tab', some_other_property, ':tab', pass, ':tab', ':otp']
autotype_1: [user]
autotype_2: [pass]
autotype_3: user some_other_property :tab pass # this is also ok
window: some site.*- Chromium
otp_secret: my_one_time_password_secret
tan: |
	204194
	294922
	240581
# ...
```

You can write any kind of key value pairs here as long as it's valid yaml.
The keys `autotype`, `autotype_{1-7}`, `window`, `otp_secret` and `tan` have
special meanings. `':tab'` hits - you guessed it - the Tab key, `':enter'` hits
the Enter key, `':otp'` types the current time based one time password.
Make sure you add `otp_secret` to an entry when using `':otp'`.

### Config:

Default config file:

```yaml
---
# you can insert any environment variable inside %{} for it to be replaced by
# the value of that variable. If it needs to be at the beginning of the string
# you have to escape it (e.g. `foo: %{BAR}` will raise an error, `foo: '%{BAR}'`
# will work though)

# prompt: 'Search:'
cache_file: '%{HOME}/.cache/autopass/autopass.cache'
# cache_key: YOUR_KEY_ID
# key_bindings:
#   autotype_tan: Alt+t
#   copy_username: Alt+u
#   copy_password: Alt+p
#   open_browser: Alt+o
#   copy_otp: 'Alt+c'
```

### Defaults:

- `window`: name of the entry (without parent group(s))
- `autotype`: `[user, ':tab', pass]`
- `autotype_1`: `[pass]`
- `autotype_2`: `[user]`
- `autotype_3`: `[':otp']`

You can define global fallbacks for `autotype` and `autotype_{1-7}` in the
config file located in `$XDG_CONFIG_HOME/autopass`. You could override the
default behavior of `autotype_1` and `autotype_2` for example to be reversed:
`autotype_1: [user]`, `autotype_2: [pass]`.

Furthermore you can set keys to use for looking up the custom autotype sequence
`autotype_key: autotype`, username `username_key: user` and password
`password_key: pass` in the config file.

Some users experience problems with alternative autotypes (using the Alt
modifier key). It almost certanly is caused by releasing the Alt key only after
the autotype has already started. Therefor there's now a config option
`alt_delay` which waits the amount in seconds before starting the autotype for
alternative autotypes. The value is 0.5 by default.

### Known Problems

xdotool uses the wrong keyboard layout if it is set in `xorg.conf.d` instead of
using the command `xkbmap`.
