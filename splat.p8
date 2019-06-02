pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--setup

splats={}
t_flow = 28
player={}
trans={}
debug=false
level=1
next_level=1
init_lvl=false
fin={}

function _init()
 
	
	trans.x = 0
	trans.y = -128
	trans.vis= false
	trans.t_s = 0
	trans.init = false
	
	player.x = 48
	player.y = 48
	player.m = false
	player.x_m = 48
	player.y_m = 48
	player.t_s = 0
	player.e = 3
	fin.x = 0
	fin.y = 0
	fin.a = 10
	
	load_lvls()
	init_lvl(level)
	
end

function _update()

	if (time() % 1 == 0.1) then
		flow()
		distribute_flow()
	end
	
	player_movement()
	check_fin()
	
end


function _draw()

	set_splats()
	
	
	draw_bg()
	draw_fin()
	draw_player()
	draw_ui()
	draw_trans()
	
	
	draw_debug()
	
end

function draw_bg()
	rectfill(0,0,128,128,0)
	map(0, 0, 0, 0)
end

function draw_ui()

	spr(38,8,112)
	spr(39,16,112)
	spr(40,24,112)
	
	spr(54,8,120)
	spr(55,16,120)
	spr(56,24,120)
	
	print("➡️ ".. level,
		12,118,1)
	print("➡️ ".. level,
		12,117,7)

end

function draw_fin()
	spr(fin.a, fin.x,fin.y)
	
	if ((time() * 16) % 1 == 0) then
		fin.a+=1
	end
	
	if fin.a > 13 then
		fin.a = 10
	end
end

function check_fin()

	if player.x == fin.x and
		player.y == fin.y then
			start_trans()
	end
end

function draw_trans()

	if trans.vis == true then
		
		local timer=(time()-trans.t_s )
			/1%1
			
			if timer > 0.95 then
				trans.vis = false
				trans.t_s = 0
			end
			
			if timer > 0.5 and
				trans.init == false then
				
				init_lvl(level)
				trans.init = true
				
			end
			
			trans.y = lerp(-136,
			128,smooth_step(timer))
			
			build_trans()
	end
	
end

function build_trans()
	rectfill(0,trans.y,
				128,trans.y+128,8)
				
	for i=0,128,8 do
		spr(59,i,trans.y-8)
		spr(59,i,trans.y+128,
			1,1,false,true)
	end
end

function start_trans()
	if trans.vis == false then
		trans.vis = true
		trans.t_s = time()
		trans.init = false
	end
end

function set_splats()
	for i=1,#splats do
		splat(splats[i])
	end
end


function splat(sp)

	local spr_ind = 
		splat_spr(sp.x,sp.y)
	
	local t_x = 
		((sp.x - (sp.x % 8)) / 8)
	local t_y = 
		((sp.y - (sp.y % 8)) / 8)
	
	mset(t_x,t_y,spr_ind)
	
end

function splat_spr(x,y)

	local spr_ind
	local top = false
	local bot = false
	local left = false
	local right = false

	if is_splat(x,y+8)==true then
		bot = true
	end
	if is_splat(x,y-8)==true then
		top = true
	end
	if is_splat(x-8,y)==true then
		left = true
	end
	if is_splat(x+8,y)==true then
		right = true
	end
	
	local w_top = false
	local w_bot = false
	local w_left = false
	local w_right = false
	
	if is_wall(x,y+8)==true then
		w_bot = true
	end
	if is_wall(x,y-8)==true then
		w_top = true
	end
	if is_wall(x-8,y)==true then
		w_left = true
	end
	if is_wall(x+8,y)==true then
		w_right = true
	end
	
	
	
	if top == true 
		and bot == true 
		and left == true 
		and right == true then
		
		spr_ind = 4
	elseif left==true 
		and right==true
		and bot==true then
		
		spr_ind=3
	elseif top==true 
		and bot==true
		and left==true then
		
		spr_ind=19
	elseif left==true 
		and right==true
		and top==true then
		
		spr_ind=35
	elseif top==true 
		and bot==true
		and right==true then
		
		spr_ind=51
	elseif left==true
		and bot == true then
		
		spr_ind = 2
		
	elseif right==true
		and bot==true then
		
		spr_ind = 18
	elseif top==true 
		and right==true then
		
		spr_ind = 34
	elseif top==true
		and left==true then
		
		spr_ind =50
	elseif top==true
		and bot==true then
		
		spr_ind =20
	elseif left==true
		and right==true then
		
		spr_ind =36
		
	elseif w_top==true
		and w_right==true
		and w_left==true
		and bot==true then
		
		spr_ind =52
		
	elseif w_right==true
		and w_top==true
		and w_bot==true
		and left==true then
		
		spr_ind =16
		
	elseif w_bot==true
		and w_left==true
		and w_right==true
		and top==true then
		
		spr_ind =32
		
	elseif w_left==true
		and w_top==true
		and w_bot==true
		and right==true then
		
		spr_ind =48
		
	elseif bot==true then
		spr_ind=1
	elseif left==true then
		spr_ind=17
	elseif top==true then
		spr_ind=33
	elseif right==true then
		spr_ind=49
	else
		spr_ind = 6
	end
	
	
	return spr_ind
	
end

function is_splat(x,y)

	local t_x = 
		((x - (x % 8)) / 8)
	local t_y = 
		((y - (y % 8)) / 8)
		
		
	s_s = {1,2,3,4,5,6,18,34,
		17,33,49,50,3,19,35,51,20,36,
		52,16,32,48}
		
		
	for i=1,#s_s do
		if mget(t_x,t_y) == s_s[i] 
			then
			return true
		end
	end
	return false
 
end


function is_wall(x,y)

	local t_x = 
		((x - (x % 8)) / 8)
	local t_y = 
		((y - (y % 8)) / 8)

 if mget(t_x,t_y) ==7 or
 	mget(t_x,t_y) == 8 or
 	mget(t_x,t_y) == 23 then
 	return true
 else
 	return false
 end
 
end

function add_splat(x,y,si,c,f)

	if is_splat(x,y)==false then
	
 	local s = {}
 	s.x=x
 	s.y=y
 	s.s=si
 	s.c=c
 	s.f=f
 	
 	splats[#splats+1] = s
 	splat(s)
 	t_flow-=1
	end
	
	
	
end

function get_splat(x,y)

	local s = "null"
	
	for i=1,#splats do
	
			local spl = splats[i]
			
			if spl.x == x
				and spl.y == y then
				
				s = spl
				
		 end
	end
	
	return s

end


-->8
--flow
function flow()

	for i=1,#splats do
	
		local spl = splats[i]
		
		if t_flow > 0 then
		
  	if is_wall(spl.x,spl.y+8)
  	==false then
  		add_splat(spl.x,spl.y+spl.s,
					spl.s,spl.c,spl.f-1)
  	end
  	if is_wall(spl.x,spl.y-8)
  	==false then
  		add_splat(spl.x,spl.y-spl.s,
					spl.s,spl.c,spl.f-1)
  	end
  	if is_wall(spl.x-8,spl.y)
  	==false then
  		add_splat(spl.x-spl.s,spl.y,
					spl.s,spl.c,spl.f-1)
  	end
  	if is_wall(spl.x+8,spl.y)
  	==false then
  		add_splat(spl.x+spl.s,spl.y,
					spl.s,spl.c,spl.f-1)
  	end
				
				spl.f = spl.f - 1
				
		end
	end

end


function distribute_flow()

	local ed_spl 
		= get_edge_splats()
		
	local flow = drain_flow()
	
	local new_f 
		= flr(flow / #ed_spl)
	
	for i=1,#ed_spl do
		local spl = ed_spl[i]
		spl.f=new_f
	end
	
end



function get_edge_splats()

	local ed_spl = {}

	for i=1,#splats do
	
		local spl = splats[i]
		local w_no = 
			count_walls(spl.x,spl.y)
		local s_no = 
			count_splats(spl.x,spl.y)
			
		if w_no + s_no != 4 then
			ed_spl[#ed_spl+1] = spl
		end
	end
	
	return ed_spl

end

function drain_flow()

	local f=0
	
	for i=1,#splats do
		local spl=splats[i]
		
		if spl.f>0 then
			f += spl.f
		end
		
		spl.f = 0
		
	end
	
	return f

end



function count_walls(x,y)

	local w = 0
	
	if is_wall(x,y+8)==true then
 	w = w + 1
 end
 if is_wall(x,y-8)==true then
 	w = w + 1	
 end
 if is_wall(x+8,y)==true then
 	w = w + 1
 end
 if is_wall(x-8,y)==true then
 	w = w + 1	
 end
 
 return w

end

function count_splats(x,y)

	local s = 0
	
	if is_splat(x,y+8)==true then
 	s += 1
 end
 if is_splat(x,y-8)==true then
 	s += 1	
 end
 if is_splat(x+8,y)==true then
 	s += 1
 end
 if is_splat(x-8,y)==true then
 	s += 1	
 end
 
 return s

end




function get_sur_splats(x,y)

	local l_splats = {}
	local i = 1
	local t_s = get_splat(x,y-8)
	local b_s = get_splat(x,y+8)
	local l_s = get_splat(x-8,y)
	local r_s = get_splat(x+8,y)
	
	if t_s !="null" then
		l_splats[i] = t_s
		i = i + 1
	end
	
	if b_s !="null" then
		l_splats[i] = b_s
		i = i + 1
	end
	
	if l_s !="null" then
		l_splats[i] = l_s
		i = i + 1
	end
	
	if r_s !="null" then
		l_splats[i] = r_s
		i = i + 1
	end
	
	return l_splats
	
end

function get_splat(x,y)

	for i=1,#splats do
	 local spl = splats[i]
	
		if spl.x == x and
			spl.y == y then
			
			return spl
			
		end
	end
	
	return "null"

end
-->8
--player
function draw_player()
	spr(25, player.x,player.y)
end

function player_movement()

	if player.x == player.x_m
			or player.y == player.y_m 
			then
 	if btnp(0) and
 		player.m == false then
 		try_move(player.x-8,player.y)
 	end
 	if btnp(1) and
 		player.m == false then
 		try_move(player.x+8,player.y)
 	end
 	if btnp(2) and
 		player.m == false then
 		try_move(player.x,player.y-8)
 	end
 	if btnp(3) and
 		player.m == false then
 		try_move(player.x,player.y+8)
 	end
	end

	if player.x != player.x_m
			or player.y != player.y_m 
			then
			
			player.m = true
		
		local timer=(time()-player.t_s )
			/0.2%1
			
			if timer==1then
				return
			end
		
		player.x = lerp(player.x,
			player.x_m,ease_out(timer))
			
		player.y = lerp(player.y,
			player.y_m,ease_out(timer))
	else
		player.m = false
	end

end

function try_move(x,y)

	if is_wall(x,y)==false then
		player.x_m=x
		player.y_m=y
		player.m=true
		sfx(0)
		player.t_s=time()
		return true
	else
			break_wall(x,y)
		return false
	end
	

end

function break_wall(x,y)
	if player.e <= 0 then
		return
	end
	
	local b_x = 
		((x - (x % 8)) / 8)
	local b_y = 
		((y - (y % 8)) / 8)
		
	if (mget(b_x,b_y) == 7) then
		sfx(1)
		mset(b_x,b_y,23)
	elseif 
		(mget(b_x,b_y) 	== 8) then
	else 
		sfx(1)
		player.e -= 1
		mset(b_x,b_y,0)
	end
	
end

function lerp(a,b,t)

	if b<a then
		return flr(a + (b-a)*t)
	else 
		return ceil(a + (b-a)*t)
	end
end

function ease_out(t)
	return 1-(1-t)^2
end

function smooth_step(t)
	return (t^2)*(1-t) +
		(1-(1-t)^2)*t;
end
-->8
--debug
function draw_debug()
	if debug==true then
		print(player.x .. " " ..
		player.y,16,16,10)
		print(fin.x .. " " ..
		fin.y,16,24,10)

		
	end
end
-->8
--particle fx
-->8
--level creation

levels={}

function load_lvls()

	levels[1] = lvl_1()

end


function lvl_1()

	local lvl = {}
	local r_p = {}
	local r_d = {}
	
	box_lvl(r_p)
	
	add_ob(1,2,r_d)
	add_ob(2,2,r_d)
	add_ob(2,1,r_d)
	
	add_ob(1,10,r_d)
	add_ob(2,10,r_d)
	add_ob(3,10,r_d)
	add_ob(1,11,r_d)
	add_ob(2,11,r_d)
	add_ob(1,12,r_d)
	add_ob(2,12,r_d)
	add_ob(1,13,r_d)
	add_ob(2,13,r_d)
	add_ob(3,13,r_d)
	add_ob(4,13,r_d)
	add_ob(5,13,r_d)
	
	add_ob(4,10,r_d)
	add_ob(5,10,r_d)
	add_ob(3,11,r_d)
	add_ob(5,11,r_d)
	add_ob(3,12,r_d)
	add_ob(4,12,r_d)
	add_ob(5,12,r_d)
	
	
	
	
	local function setup()
		
		player.x=4*8
		player.x_m=4*8
		player.y=11*8
		player.y_m=11*8
		fin.x=12*8
		fin.y=3*8
		add_splat(8,8,8,8,4)
		--add_splat(72,64,8,8,4)

	end
		
	lvl.r_p = r_p
	lvl.r_d = r_d
	lvl.s = setup
	
	return lvl

end

function lvl_2()

	

end





function add_ob(x,y,lst)
	local ob = {}
	ob.x = x
	ob.y = y
	lst[#lst+1] = ob
end


function box_lvl(lst)

	for i=0,14 do
		add_ob(0,i,lst)
	end
	
	for i=0,15 do
		add_ob(i,0,lst)
	end
	
	for i=0,15 do
		add_ob(i,14,lst)
	end
	
		for i=0,15 do
		add_ob(i,15,lst)
	end
	
	for i=0,14 do
		add_ob(15,i,lst)
	end

end


function init_lvl(lvl)
		
	local r_p = levels[lvl].r_p
	local r_d = levels[lvl].r_d
	
	clear_map()
	
	splats={}
	
	init_st_obs(8,r_p)
	init_st_obs(7,r_d)
	
	levels[lvl].s()
	player.e = 3

end

function clear_map()

	for x=0,15 do
  for y=0,15 do
   mset(x, y, 0)
		end	
	end
end

function init_st_obs(ind,obs)

	for i=1,#obs do
		
		mset(obs[i].x,obs[i].y,ind)
		
	end
	
end

function init_splats(spls)


end




__gfx__
00000000000000000000000000000000888888880000000000888800011111101111111100000000900000009000000090000000900000000000000000000000
000000000000000088888000888888888888888800000000088888801dddddd61dddddd600000000600bb00060bb00006bb00b006b00bb000000000000000000
000000000000000088888800888888888888888800000000888888881dddddd61dddddd6000000006bbbbb006bbbbb006bbbbb006bbbbb000000000000000000
000000000000000088888880888888888888888800000000888888881dddddd61dddddd6000000006bbbbb006bbbbb006bbbbb006bbbbb000000000000000000
000000000088880088888880888888888888888800000000888888881dddddd61dddddd6000000006bb33b006b33bb00633bb30063bb33000000000000000000
000000000888888088888880888888888888888800000000888888881dddddd61dddddd600000000633003006300330060033000603300000000000000000000
000000000888888088888880888888888888888800000000088888801dddddd61dddddd600000000600000006000000060000000600000000000000000000000
00000000088888808888888088888888888888880000000000888800066666601666666600000000500000005000000050000000500000000000000000000000
000000000000000000000000888888800888888000000000000000000dd101d000000000000000000a0000000000000000000000000000000000000000000000
888888008880000000088888888888800888888000000000000000001ddd0dd6000000000cc00cc0000000a00000000000000000000000000000000000000000
8888888088880000008888888888888008888880000000000000000001d1ddd5000000000ceccec0009900000099000000000000000000000000000000000000
888888808888000008888888888888800888888000000000000000001d11dd1000000000001c1c0000aa990000aa990000000000000000000000000000000000
88888880888800000888888888888880088888800000000000000000ddd111d50000000000c1cc0000aaaa9000aaaa9000000000000000000000000000000000
88888880888800000888888888888880088888800000000000000000dddd1dd60000000000cccc00a0aaaaa000aaaaa000000000000000000000000000000000
88888800888000000888888888888880088888800000000000000000ddd1ddd60000000000ccccc0000000000000000000000000000000000000000000000000
000000000000000008888888888888800888888000000000000000000650566000000000000ccc0c00000a000000000000000000000000000000000000000000
08888880088888800888888888888888000000000000000011111111111111111111111100000000000000000000000000000000000000000000000000000000
0888888008888880088888888888888888888888000000001dddddddddddddddddddddd600000000000000000000000000000000000000000000000000000000
0888888008888880088888888888888888888888000000001dddddddddddddddddddddd600000000000000000000000000000000000000000000000000000000
0888888000888800088888888888888888888888000000001dddddddddddddddddddddd600000000000000000000000000000000000000000000000000000000
0888888000000000088888888888888888888888000000001dddddddddddddddddddddd600000000000000000000000000000000000000000000000000000000
0888888000000000008888888888888888888888000000001dddddddddddddddddddddd600000000000000000000000000000000000000000000000000000000
0088880000000000000888888888888888888888000000001dddddddddddddddddddddd600000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000001dddddddddddddddddddddd600000000000000000000000000000000000000000000000000000000
0000000000000000888888800888888800000000000000001dddddddddddddddddddddd600000000000000000000000000000000000000000000000000000000
0088888800000888888888800888888800888800000000001dddddddddddddddddddddd600000000000000000000000000000000000000000000000000000000
0888888800008888888888800888888808888880000000001dddddddddddddddddddddd600000000000000000808080800000000000000000000000000000000
0888888800008888888888800888888808888880000000001dddddddddddddddddddddd600000000000000008080808000000000000000000000000000000000
0888888800008888888888800888888808888880000000001dddddddddddddddddddddd600000000000000000808080800000000000000000000000000000000
0888888800008888888888000888888808888880000000001dddddddddddddddddddddd600000000000000008080808000088000000000000000000000000000
0088888800000888888880000888888808888880000000001dddddddddddddddddddddd600000000000000000888088880888808000000000000000000000000
00000000000000000000000008888888088888800000000016666666666666666666666600000000000000008888888888888888000000000000000000000000
00000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000008750087500975009750097500a7500b7500c7500e7500410005100031000310003100051000010017000190001b0001c0001d0001e0001e0001e0001e0001e000040000400003000030000200002000
0001000010650126501365011750127501375014750147501475017750127500f6500d6500a6500e6501165000600006000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 43424344

