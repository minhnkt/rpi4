

# OpenWrt builds for the rpi-4

see: https://forum.openwrt.org/t/rpi4-community-build/69998 to request packages, provide feedback etc.


## Credits

### Credit and source courtesy of the OpenWrt team, contributors and the great folks on the forum.


<sup>github https://github.com for a solid and open platform</sup><br>
<sup>pi-foundation for a mostly open platform - committers do good things</sup><br>
<sup>Special thanks: vgaetera jeff jow slh trendy and lleachii for guru skillsharing and support... </sup><br>
<sup>@PaulFertser, @dibdot, @trendy, @moodyblue, @neil1, @jayanta525, @poodad, @syntaxterror, @bigfat, @gpuyy, @krazeh, @jcejohnson, @cesarvog, @malikshi, @stargeizer, @mint, @johnd2, @BenjaminBeichler, @cricalix, @toasterdev, @masaq, @synapse, @Phase1, @SubZero and @geerlingguy for contributions to the build</sup><br>
<sup>@dangowrt, @noltari, @oskari.rauta, @nbd, @bkpepe, @mhei mainline code</sup><br>
<sup>@lynx, @moeller0, @dlakelan + others sqm-autorate (lte/3g/variable-bw-links)</sup><br>
<sup>@hnyman build system insight and official repo fixing</sup><br>
<sup>@bobafetthotmail nicmove/macmatch</sup><br>
<sup>@stangri vpn-pbr and other apps</sup><br>
<sup>[@damianperera github_action_sidebuilds](https://github.com/damianperera/openwrt-rpi)</sup><br>
<sup>[@jerrykuku luci-theme-argon](https://github.com/jerrykuku/luci-theme-argon)</sup><br>
<sup>login-sysinfo.sh: Cezary Jackiewicz</sup><br>
<sup>argonone code: @DarkElvenAngel</sup><br>
<sup>@bkpepe, @neheb github mentoring</sup><br>
<sup>[Van Tech Corner](https://www.youtube.com/channel/UCczXrZ5r1nCMACiaipGqbtw)</sup><br>
<sup>[MaroonMed](https://www.maroonmed.com/berry-on-a-bush-router-on-a-stick-raspberry-pi-4-inter-vlan-openwrt-router/)</sup><br>
<sup>qm-dscp-logic: hisham2630(ultimate-sqm-settings-layer-cake-dscp-marks) (and others) @ldir @dlakelan</sup><br>
<sup>@dairyman and the rooter peoples</sup><br>
<sup>plenty-of-others: if i have learnt or borrowed something from you thankyou...</sup><br>



## img-specs:
- ext4 300M-boot 900M-rootfs (no squashfs) (NOTE: ROOTFSEXPAND=1 on first upgrade)
- opkg-alt-repo (base|core|luci) 100% non-modified
- over 223 additional drivers and packages


## github-guides
- guides [wulfy23/rpi4/misc/README.md](https://github.com/wulfy23/rpi4/blob/master/misc/README.md)

	- [i am new, hardware, flashing, initial setup](https://github.com/wulfy23/rpi4/blob/master/misc/guides/abc123.md)
	- [updatecheck bar or flavour](https://github.com/wulfy23/rpi4/blob/master/misc/guides/updatecheck.md)
	- [ini-editing](https://github.com/wulfy23/rpi4/blob/master/misc/guides/updatecheck.md#ini-editing)
	- [i have large data](https://github.com/wulfy23/rpi4/blob/master/misc/guides/i_have_large_data.md)
	- [i need something added](https://github.com/wulfy23/rpi4/blob/master/misc/guides/i_need_something_added.md)
	- [o' shit](https://github.com/wulfy23/rpi4/blob/master/misc/guides/fsck.md)
	- [i'm paranoid](https://github.com/wulfy23/rpi4/blob/master/misc/guides/im_paranoid.md)
	- [using vlans](https://github.com/wulfy23/rpi4/blob/master/HARDWARE.md#using-vlans)
	- [dd-backups](https://github.com/wulfy23/rpi4/blob/master/misc/guides/dd-backups.md)
	- [factory-tricks](https://github.com/wulfy23/rpi4/blob/master/misc/guides/factory-tricks.md)


# extra-overview

## features
- automatic re-install of packages post-upgrade (or not)
- luci updatecheck notice with one-click flash
- expansion of partition to whole sdcard on sysupgrade
- webui full-ish text editor (off past r18315)
- youtube-download webui (wip requires external storage) (off past r18315)
- webui browser ssh terminal (wip)
- smb/sshfs mount helper
- optimised / patched rpi-eeprom-update
- nano colors, 'man' command
- login sysinfo and sh/bash profile blingification
- easy user setup variables via wrt.ini (lanip, ntp-server, etc.) with luci editing
- usbboot-support/auto-fsck (wip->multiboot/partresize/live-mode)
- usb persisent nic naming (optional)

## scripts
- rpi-sysup-online.sh automated upgrade
- package restore (sysupgrade -R)
- rpi4-official-opkg.sh for security and bugfixes from master
- luci updates notifications (points to master not build :( )
- rpi-throttlewatch.sh ( test thermal/scaling )
- rollback.sh|opK install <pkg|file>|wrtsnapback (betas)
- fake 'man' command
- some 'locate' command setup+tweaks
- semi-discontinued use topbar: rpi-sysup-clean-backup.sh wip (dump generic backups)


## opt-in/out
- persistent logs / statistics / nlbwmon / upgrade-data
- sqmdscp console/other priority @> rpi4.qos
- lucisshon, wifiadminboot
- fwcustom geoip-db, rfc1918

## utilities
- speedtest-ookla(git-dl'd)
- qemu(git-manual-dl wip needs a tester)
- base64, tac, stat, blkid, etc. etc.


## packages
- bash (w-temperature@ps1)
- wget curl unzip htop lsof losetup strace vim-fuller
- openvpn + kmod-tun + wireguard + mwan3 + vpn-pbr
- banip + adblock
- many many more... if you call in the next 15mins, you will recieve a free toaster!




