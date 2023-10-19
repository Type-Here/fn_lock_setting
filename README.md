# FN Key Default Set
##Change Default Behaviour of FN Key

### Intro

Function Keys in recent devices has multiple working modes, usually:
- Function Key Only;
- Fn + Function Key.

This code lets the user choose the default mode at startup.
By default, several Linux Distros leave th Fn Lock ON (most cases, it can be manually disabled pressing Fn + Esc).
Disabling this setting, leaves the Special Function do its work without pressing Fn (Fn + F2 -> Is F2 Key instead).

In Apple Keyboard (and several other devices that Linux identify as hid_apple (kernel module)), things are a bit different:

| Value | Fn Mode      | Infos                                                    |  
|-------|--------------|----------------------------------------------------------|
| 0     | Disabled     | F2 and Fn+F2 will trigger F2 Key  (special key disabled) | 
| 1     | Fn Key Last  | F2 -> Special Function;  Fn+F2 -> Is Normal F2.          |
| 2     | Fn Key First | Fn + F2 -> Special Function;  F2 -> Is Normal F2.        |   

Source: [Here]:(https://www.hashbangcode.com/article/turning-or-fn-mode-ubuntu-linux).

For this devices the script sets 0 with '-d' parameter while lets the user choose between 1 and 2 with the '-e' flag.

### Parameters

"-h | --help : see this help"
"-d | --disable : disable fn_lock (permanent)"
"-e | --enable : enable fn_lock (permanent)"
"-t | --temp : temporary disable fn_lock"

### Supported Devices

- Apple Keyboard -- Not Tested personally, but working in original source 
- Keychron Keyboards and others identified as hid_apple (from source)
- Asus Devices working with asus_wmi module
- (Others soon to come.. Submit your Code/Infos!)

### Thanks
Fix the Asus dysfunctional FN key on Linux. 2023-10-13;
Original from Mint Forum: https://forums.linuxmint.com/viewtopic.php?t=368164

-----

Mod by type-here
