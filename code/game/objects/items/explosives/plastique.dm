/obj/item/explosive/plastique
	name = "plastic explosives"
	desc = "Used to put holes in specific areas without too much extra hole."
	gender = PLURAL
	icon = 'icons/obj/items/assemblies.dmi'
	icon_state = "plastic-explosive0"
	item_state = "plasticx"
	flags_atom = FPRINT|NOBLUDGEON
	w_class = 2.0
	origin_tech = "syndicate=2"
	var/timer = 10
	var/atom/target = null

/obj/item/explosive/plastique/attack_self(mob/user)
	if(user.mind && user.mind.skills_list && user.mind.skills_list["engineer"] < SKILL_ENGINEER_METAL)
		user << "<span class='warning'>You don't seem to know how to use [src]...</span>"
		return
	var/newtime = input(usr, "Please set the timer.", "Timer", 10) as num
	if(newtime < 10)
		newtime = 10
	if(newtime > 60)
		newtime = 60
	timer = newtime
	user << "Timer set for [timer] seconds."

/obj/item/explosive/plastique/afterattack(atom/target, mob/user, flag)
	if(!flag) r_FAL
	if(user.mind && user.mind.skills_list && user.mind.skills_list["engineer"] < SKILL_ENGINEER_METAL)
		user << "<span class='warning'>You don't seem to know how to use [src]...</span>"
		return
	if(istype(target, /turf/unsimulated) || istype(target, /turf/simulated/shuttle) || istype(target, /obj/structure/ladder) || istype(target,/obj/item))
		r_FAL
	if(istype(target, /obj/effect) || istype(target, /obj/machinery))
		var/obj/O = target
		if(O.unacidable) r_FAL
	if(istype(target, /turf/simulated/wall))
		var/turf/simulated/wall/W = target
		if(W.hull)
			r_FAL
	if(istype(target, /obj/structure/window))
		var/obj/structure/window/W = target
		if(W.not_damageable)
			user << "<span class='warning'>[W] is much too tough for you to do anything to it with [src]</span>." //On purpose to mimic wall message
			r_FAL

	user.visible_message("<span class='warning'>[user] is trying to plant [name] on [target]!</span>",
	"<span class='warning'>You are trying to plant [name] on [target]!</span>")
	bombers += "[key_name(user)] attached C4 to [target.name]."

	if(do_after(user, 50, TRUE, 5, BUSY_ICON_CLOCK) && in_range(user, target))
		user.drop_held_item()
		target = target
		loc = null
		var/location
		if (isturf(target)) location = target
		if (isobj(target)) location = target.loc

		if(ismob(target))
			user.attack_log += "\[[time_stamp()]\] <font color='red'> [user.real_name] successfully planted [name] on [target:real_name] ([target:ckey])</font>"
			message_admins("[key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) planted [src.name] on [key_name(target)](<A HREF='?_src_=holder;adminmoreinfo=\ref[target]'>?</A>) with [timer] second fuse",0,1)
			log_game("[key_name(user)] planted [src.name] on [key_name(target)] with [timer] second fuse")
		else
			message_admins("[key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) planted [src.name] on [target.name] at ([target.x],[target.y],[target.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[target.x];Y=[target.y];Z=[target.z]'>JMP</a>) with [timer] second fuse",0,1)
			log_game("[key_name(user)] planted [src.name] on [target.name] at ([target.x],[target.y],[target.z]) with [timer] second fuse")

		target.overlays += image('icons/obj/items/assemblies.dmi', "plastic-explosive2")
		user.visible_message("<span class='warning'>[user] plants [name] on [target]!</span>",
		"<span class='warning'>You plant [name] on [target]! Timer counting down from [timer].</span>")
		spawn(timer*10)
			if(target)
				explosion(location, -1, -1, 2, 3)
				target.ex_act(1)
				if (isobj(target))
					if (target)
						cdel(target)
						target = null
				if(target && target.loc)
					target.overlays -= image('icons/obj/items/assemblies.dmi', "plastic-explosive2")
				if (src)
					cdel(src)

/obj/item/explosive/plastique/attack(mob/M as mob, mob/user as mob, def_zone)
	return