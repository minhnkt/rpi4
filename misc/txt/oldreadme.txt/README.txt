

    ##################################  OpenWrt builds for the rpi-4
    
    see: https://forum.openwrt.org/t/rpi4-community-build/69998
         to request packages, provide feedback etc.

    ################################################################



    Credit and source courtesy of the OpenWrt team, contributors and
    the great folks on the forum.
	

    github https://github.com for a solid and open platform
    pi-foundation for a mostly open platform


    Special thanks: vgaetera jeff jow slh trendy and lleachii for
                    guru skillsharing and support... 

                    @dibdot, @trendy, @moodyblue, @neil1, @jayanta525,
                    @poodad, @syntaxterror, @bigfat, @gpuyy, @krazeh
                    @jcejohnson, @cesarvog, @malikshi, @stargeizer,
                    @mint, @johnd2, @BenjaminBeichler, @toasterdev
                    and @geerlingguy for contributions to the build

                    @dangowrt, @noltari, @oskari.rauta, @mhei mainline code                   
                    @hnyman build system insight and official repo fixing
                    @bobafetthotmail
                    @stangri vpn-pbr and other apps
                    @damianperera https://github.com/damianperera/openwrt-rpi


    luci-theme-argon: https://github.com/jerrykuku/luci-theme-argon
    login-sysinfo.sh: Cezary Jackiewicz
       argonone code: @DarkElvenAngel
      sqm-dscp-logic: hisham2630 (and others) @ldir @dlakelan
                      forum > ultimate-sqm-settings-layer-cake-dscp-marks
    plenty-of-others: if i have learn't or borrowed something from you
                      thankyou...



    NOTES:         official images @ 21.02.0 soon available
                   first time OpenWrt users recommended to use stable official
                   suppose it wouldn't hurt to whack this on for a quick spin...
                   switch back to an OfficialBuild as soon as you become confused... ;)


    IMG-SPECS:
                  -ext4 300M-boot 900M-rootfs (no squashfs)
                  -opkg-alt-repo (base|core|luci) 100% non-modified
                  -over 223 additional drivers and packages






	WIFI:
            note: technically atm, wifi is not supported by this build and
                  a stand alone auxillary AP is required for production env

                 -make sure 'wpad' is enabled and started...
          
                 further issues: (unless with auto-setup scripts) should be addressed on
                 the general OpenWrt forum... after you do some searching and reading
                 first... use a third party access point ($65AUD/37US) and avoid
                 stress, time wastage, limited performance...

        



    flashing) [see: forum thread top post in link above]

                 -'fac' = factory>(g)unzip>sdcard
                 -'sys' = sysupgrade

        
        -*non-comm-upgrade-only* !!! sysupgrade -p  !!! switch to take new partition sizes !!!
        -*non-comm-upgrade-only* sysupgrade on non-community backup + ensure rc.local has exit 0
        -note: the two options above, aka 'upgrading-to-this-build' are less advised/tested...
               it's preferred if you start fresh factory->sdcard
               ( a config backup etc/config/* restore is ok )


        NOTE: Flashing can take extra time... due to 1G i.e.;

                   Seriously... go hang the washing or something

                         samsungevo-internalsd: 2-3 mins
                    generic-sandisk-internalsd:   7 mins
        
                    (green-act-led on means flashing)
                    (usb key with led helps to see)
                    (20210216~2.7.71+ unitializing blink status)
                    -slow throbbing blink during firstboot setup solid when done(-ish)



    hardware) see HARDWARE for typical setup / recommendations   
              202107note: dfrobot-cm4-carrier initial support added


      quirks)
        
               -some autosetup functionality is dependant on eth1-usb

               -disabled services... desired services might be disabled
         out of the box in order not to bog down people who don't use them.
         enable what you use, and provide feedback if something is bloaty /
         or needed by default. see forum for more info.

              -extroot-overlay[unsupported]... (see lower)

              -~wifi ap/ac issue (reportedx2: mine works fine)

        -add /root/wrt.ini to your /etc/sysupgrade.conf (done automatically)
        -create /etc/packagesremove.txt and add to sysupgrade.conf(adding likely now automatic)



      
      extras
        
        ##################################################################### specialfeatures

        -automatic re-install of packages post-upgrade (or not)
        -luci updatecheck notice with one-click flash
        -expansion of partition to whole sdcard on sysupgrade
        -webui full-ish text editor
        -webui browser ssh terminal (wip)
        -youtube-download webui (wip requires external storage)
        -smb/sshfs mount helper
        -optimised / patched rpi-eeprom-update
        -nano colors, 'man' command
        -login sysinfo and sh/bash profile blingification
        -easy user setup variables via wrt.ini (lanip, ntp-server, etc.) with luci editing


        ##################################################################### scripts

         -rpi-sysup-online.sh automated upgrade
         -package restore (sysupgrade -R)
         -rpi4-official-opkg.sh for security and bugfixes from master
         -luci updates notifications (points to master not build :( )
         -rpi-throttlewatch.sh ( test thermal/scaling )
         -rollback.sh|opK install <pkg|file>|wrtsnapback (betas)
         -semi-discontinued use topbar: rpi-sysup-clean-backup.sh wip (dump generic backups)


        ##################################################################### opt-in/out

         -persistent logs / statistics / nlbwmon / upgrade-data
         -sqmdscp console/other priority @> rpi4.qos
         -lucisshon, wifiadminboot
         -fwcustom geoip-db, rfc1918
         -usbboot-support/auto-fsck (wip->multiboot/partresize/live-mode)


        ##################################################################### utilities

         -speedtest-ookla(git-dl'd)
         -ffmpeg(git-dl'd)
         -base64, tac, stat, blkid, etc. etc.
         -x parted (202107->now_mainline_openwrt-ipk)


    PACKAGES:
        
         -bash (w-temperature@ps1)
         -wget curl unzip htop lsof losetup strace vim-fuller
         -openvpn + kmod-tun + wireguard + mwan3 + vpn-pbr
         -banip + adblock
         -many many more...


        
        ##################################################################### requests
        packages/features

             1: required for firstboot net connectivity (or related functions)?
             2: are they not too big?
             3: can they easily be rendered dormant/intert?
             5: are they common to other users?
             6: if (complex) setup is required can you provide samples/automation?
             7: do they cause any other conflicts with typical device operation
                or other build related logic?

             *Uncommon requests are put to the 3 or 5 build user test ( 20% interest )




        ##################################################################### somefinerdetails 
        -see TODO

         -partuuid(usb-support) means backup restore requires you to check
         or move and replace your current cmdline.txt(distfeeds/customfeeds also)
         post restore...
         UPDATE: if you use the topbar backup it will exclude cmdline.txt so these
                 should restore fine... backups made via traditional methods need
                 cmdline PARTUUID updated or changed to root=/dev/mmcblk0p2
                 prior to reboot on manual restore (or creation)


        -/root in its entirety should not be part of your sysupgrade.conf
         ( community > community ) individual files and directories will
         be ok... efforts are underway to overcome this...


        -using sysupgrade -n has never been tested you'd assume that
         it would leave you with something similar to a factory install
         although i suspect there would be a glitch or two... lucklily...
         zapping a new factory to an sdcard is an equivalent workaround


        -extroot/overlay will/may cause issues for some script logix...
         only use this if you are prepared to report logs / are an
         intermediate user or above... as these make upgrading difficult
         anyway, its recommended you just point service config to a
         usb-mount where applicable this saves the hassle of pkgdata
         on upgrade and is handled (reasonable) transparently
         Can fix extroot-overlay underlying issues if someone capable
         reports the problems, would likely effect, packagerestore
         upgrade, backup etc logix


        -luci_statistics will fail to start if collectd-mod-x is not installed
         and is enabled in /etc/config/luci_statistics > module, as firstboot
         scripts setup these modules... and sysupgrade auto-removes packages
         you have removed... i'd suggest just leaving all modules installed for
         now and possibly cp statistics config file pre/post upgrade if you
         want to disable some default modules...


        -rc.local style scripts should be placed in /etc/custom/startup ...
         see examples there and make sure to add to sysupgrade.conf avoid
         editing rc.local but if there is a real need ask on the support page
         and we'll work something out...


        -sdcard writes... unlike a stock image, this build makes use of sdcard
         storage to keep traffic / statistical data across reboots. if you are
         averse to any disk writes, you can disable this option. given the cost
         of sdcards, the infrequency of reboots, and the utility of persisent
         data ... this is generally a functional win.
         if you wish to store your data somewhere other than the default...
         like an attached usb device... you should also disable this...


        -procps-ng-{ps,df,top?} will likely create issues with some of the custom
         scripts within the build, avoid installing them or discuss on the forum
         tar, gzip
         UPDATE: some of these tools have now been added with a -full suffix...
                 i.e. top-full ps-full for command line usage

        
       _____________________________________

 
