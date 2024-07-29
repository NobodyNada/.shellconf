function rando
    set url (string match -rg '^https?://([a-z0-9_.-]+)/customizer/([a-z0-9-]+)$' "$argv[1]"); or return 1
    set host $url[1]
    set seed $url[2]
    
    set patch ()

    ips-patch (
        curl "https://$host/customWebService" -X POST --data-raw (string join '&' \
            logic=random itemsounds=off spinjumprestart=off rando_speed=off\
			elevators_speed=off fast_doors=off Infinite_Space_Jump=off\
			refill_before_save=off better_reserves=off widescreen=off\
			AimAnyButton=off max_ammo_display=off supermetroid_msu1=off base=off\
			colorsRandomization=off suitsPalettes=off beamsPalettes=off\
			tilesPalettes=off enemiesPalettes=off bossesPalettes=off grayscale=off\
			globalShift=off customSpriteEnable=off customItemsEnable=off\
			noSpinAttack=off customShipEnable=off remove_itemsounds=off\
			remove_elevators_speed=off remove_fast_doors=off\
			remove_Infinite_Space_Jump=off remove_rando_speed=off\
			remove_spinjumprestart=off gamepadMapping=off lava_acid_physics=off\
			hell=off hard_mode=off color_blind=off disable_screen_shake=off\
			noflashing=off disable_minimap_colors=off customSprite=samus\
			customShip=Red-M0nk3ySMShip1 hellrun_rate=100 etanks=0 minDegree=-15\
			maxDegree=15 invert=on no_blue_door_palette=off music="Don't+touch"\
			seedKey=$seed) \
                | jq -r '.ips' \
                | base64 -d \
                | psub \
        ) < ~/code/sm/ntsc.sfc \
        | command ssh root@mister.home 'cat > /media/fat/games/SNES/rando.sfc'
end

