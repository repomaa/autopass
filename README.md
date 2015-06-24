# Autopass

A rofi frontend for pass

## Features

- performs autotype with entries
- allows setting window name property (a regex) to match against window titles
- automatically focuses correct window or asks you to
- allows any amount of additional properties which can be used in autotype
- displays entries that are most likely to match currently focused window first
- uses encrypted cache to store pass entries in a single file for fast startup

## Usage

`autopass`

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
window: some site.*- Chromium
```

You can write any kind of key value pairs here as long as it's valid yaml.
Only and `autotype`, `window` have special meanings.

By default the name of the entry (without parent group(s)) is used for `window`
and `['user', 'pass']` for `autotype`.
