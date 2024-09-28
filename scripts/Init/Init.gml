function Init()
{
	oceangen = false;
	
	spr1 = undefined;
	spr2 = undefined;
	
	zoom = 3;
	anim = true;
	showimage = true;
	showtext = true;
	
	offx = 0;
	offy = 0;
	
	file1 = "";
	file2 = "";
	
	framecount = 0;
	
	col0 = c_black
	col1 = make_color_rgb(0, 51, 0);
	col2 = make_color_rgb(0, 102, 153);
	col3 = make_color_rgb(51, 204, 204);
	
	cols = [col0, col1, col2, col3];
	
	if !oceangen Run();
}

function Run()
{
	zoom = 3;
	anim = true;
	showimage = true;
	showtext = true;
	
	offx = 0;
	offy = 0;
	
	file1 = "";
	file2 = "";
	
	framecount = 0;
	
	var filename = get_open_filename("PNG files|*.png","");
	if filename != "" file1 = filename;
	if file1 == "" exit;
	
	var filename = get_open_filename("PNG files|*.png","");
	if filename != "" file2 = filename;
	if file2 == "" exit;
	
	if spr1 != undefined sprite_delete(spr1);
	if spr2 != undefined sprite_delete(spr2);
	
	spr1 = sprite_add(file1, 1, 1, 0, 0, 0);
	spr2 = sprite_add(file2, 1, 1, 0, 0, 0);
	
	wid1 = sprite_get_width(spr1);
	hei1 = sprite_get_height(spr1);
	wid2 = sprite_get_width(spr2);
	hei2 = sprite_get_height(spr2);
	wid  = max(wid1, wid2);
	hei  = max(hei1, hei2);
	
	// figure out auto max zoom
	maxwid = 3 * 256; // available screen area
	maxhei = 3 * 240;
	
	zoom = min(floor(maxwid / wid), floor(maxhei / hei));
	zoom = max(1, zoom);
	
	surf1 = surface_create(wid, hei);
	surf2 = surface_create(wid, hei);
	surfmagenta  = surface_create(wid, hei);
	surflime  = surface_create(wid, hei);
	
	surface_set_target(surf1); draw_sprite(spr1, 0, 0, 0); surface_reset_target();
	surface_set_target(surf2); draw_sprite(spr2, 0, 0, 0); surface_reset_target();
	
	buffersize = wid * hei * 4; // px * px * rgba
	
	buff1 = buffer_create(buffersize, buffer_u8, 1);
	buff2 = buffer_create(buffersize, buffer_u8, 1);
	buffmagenta  = buffer_create(buffersize, buffer_u8, 1);
	bufflime  = buffer_create(buffersize, buffer_u8, 1);
	
	buffer_get_surface(buff1, surf1, 0);
	buffer_get_surface(buff2, surf2, 0);
	
	buffer_fill(buffmagenta, 0, buffer_u8, 0, buffersize); // set all black and no alpha
	buffer_fill(bufflime, 0, buffer_u8, 0, buffersize); // set all black and no alpha
	
	for (var b = 0; b < buffersize; b+=4)
	{
		if buffer_peek(buff1, b + 0, buffer_u8) != buffer_peek(buff2, b + 0, buffer_u8)
		or buffer_peek(buff1, b + 1, buffer_u8) != buffer_peek(buff2, b + 1, buffer_u8)
		or buffer_peek(buff1, b + 2, buffer_u8) != buffer_peek(buff2, b + 2, buffer_u8)
		or buffer_peek(buff1, b + 3, buffer_u8) != buffer_peek(buff2, b + 3, buffer_u8)
		{
			// magenta
			buffer_poke(buffmagenta, b + 0, buffer_u8, 255); // 
			buffer_poke(buffmagenta, b + 1, buffer_u8, 0); // 
			buffer_poke(buffmagenta, b + 2, buffer_u8, 255); // 
			buffer_poke(buffmagenta, b + 3, buffer_u8, 255); // set alpha 1
			
			// lime
			buffer_poke(bufflime, b + 0, buffer_u8, 0); // 
			buffer_poke(bufflime, b + 1, buffer_u8, 255); // 
			buffer_poke(bufflime, b + 2, buffer_u8, 0); // 
			buffer_poke(bufflime, b + 3, buffer_u8, 255); // set alpha 1
		}
	}
	
	buffer_set_surface(buffmagenta, surfmagenta, 0);
	buffer_set_surface(bufflime, surflime, 0);
	sprmagenta = sprite_create_from_surface(surfmagenta, 0, 0, wid, hei, 0, 0, 0, 0);
	sprlime = sprite_create_from_surface(surflime, 0, 0, wid, hei, 0, 0, 0, 0);
	
	surface_free(surf1);
	surface_free(surf2);
	surface_free(surfmagenta);
	surface_free(surflime);
	
	buffer_delete(buff1);
	buffer_delete(buff2);
	buffer_delete(buffmagenta);
	buffer_delete(bufflime);
	
	/*{
		// this is to get all files in the folder
		path = filename_path(filename);
		var mask = path + "*.png";
		mask = string_replace_all(mask, "\\", "/");
		var file_name = file_find_first(mask, fa_none);
		
		while (file_name != "")
		{
			array_push(files, file_name);
			totalimages++;
			file_name = file_find_next();
		}
		
		file_find_close();
	}*/
}

function Main()
{
	framecount++;
	
		 if (keyboard_check_pressed(ord("A")) or mouse_wheel_up())
		 zoom++;
	else if (keyboard_check_pressed(ord("Z")) or mouse_wheel_down()) zoom--;
	else if keyboard_check_pressed(vk_shift) showimage = !showimage;
	else if mouse_check_button_pressed(mb_left) { showimage++; if showimage > 2 showimage = 1; }
	else if (keyboard_check_pressed(vk_space)
	or mouse_check_button_pressed(mb_right)) anim = !anim;
	else if keyboard_check_pressed(vk_escape) showtext = !showtext;
	
	var spd = 10;
		 if keyboard_check(vk_right) offx += spd;
	else if keyboard_check(vk_left) offx -= spd;
		 if keyboard_check(vk_up) offy -= spd;
	else if keyboard_check(vk_down) offy += spd;
	if zoom < 1 zoom = 1;
	
	if keyboard_check_pressed(ord("O")) 
	{
		Run();
	}
	else if keyboard_check_pressed(ord("S"))
	{
		var filename = get_save_filename("*.png", filename_change_ext(file1, "") + " difference.png");
		if filename != ""
			sprite_save(sprmagenta, 0, filename);
	}
	//else if keyboard_check_pressed(vk_escape) game_end();
}

function OceanGenDraw()
{
	var R = 714;
	var D = 340;
	var segcount, segwid, weight, spacing, xx, colpick, maxcol, col, deviation;
	var segwiddefault = 2;
	var segcountdefault = (D / segwiddefault) * 20;
	deviation = 0.5;
	maxcol = array_length(cols) - 1;
	draw_set_color(col0);
	draw_rectangle(0,0,R,D,false);
	for(var yy = 0; yy < D; yy++)
	{
		ratio = yy / D;
		ratio = ratio * ratio;
		col = maxcol * ratio;
		col += random_range(-deviation, deviation);
		col = min(col, maxcol - 1);
		col++;
		draw_set_color(cols[col]);
		draw_line(0,yy,R,yy);
		
		if yy mod 2
		{
			ratio = 1 - (yy / D);
			weight = random_range(0, ratio);
			segcount = segcountdefault * weight;
			for (var s = 0; s < segcount; s++)
			{
				weight = random_range(1- ratio, 1);
				segwid = segwiddefault * weight * 2;
				spacing = R / segcount;
				xx = spacing * s;
			
				ratio = yy / D;
				ratio = ratio * ratio;
				col = maxcol * ratio;
				col += random_range(-deviation, deviation);
				col = min(col, maxcol - 1);
				col++;
				draw_set_color(cols[col]);
				draw_line_width(xx, yy, xx + segwid, yy, 3 * weight);
			}
		}
	}
}

function Draw()
{
	
	
	
	var m = 10;
	
	if file1 != ""
	and file2 != ""
	{
			 if showimage == 1 draw_sprite_ext(spr1, 0, m + offx, m + offy, zoom, zoom, 0, c_white, 1);
		else if showimage == 2 draw_sprite_ext(spr2, 0, m + offx, m + offy, zoom, zoom, 0, c_white, 1);
		if anim
		{
			if floor(framecount / 5) mod 2 draw_sprite_ext(sprmagenta, 0, m + offx, m + offy, zoom, zoom, 0, c_white, 1);
			else draw_sprite_ext(sprlime, 0, m + offx, m + offy, zoom, zoom, 0, c_white, 1);
		}
		
		var str = @"O: Load other images
		S: Save difference image
		A / Mouse Wheel Up: Zoom in
		Z / Mouse Wheel Down: Zoom out
		Space / Right Mouse Button: toggle animation
		Shift: toggle viewing images
		Left Mouse: toggle which image to draw
		Esc: toggle show text
		Arrows: pan
		
		Zoom: ";
		
		var strwid = string_width(str);
		
		str += string(zoom) + "#";
		if anim str += "Animation: On#";
		else str += "Animation: Off#";
			 if showimage == 0 str += "Image: Off#";
		else if showimage == 1 str += "Image: " + filename_name(file1) + "#";
		else if showimage == 2 str += "Image: " + filename_name(file2) + "#";
		str += "H Offset: " + string(offx) + "#";
		str += "V Offset: " + string(offy) + "#";
		str = string_hash_to_newline(str);
	}
	else
	{
		var str = @"Please load two images.
		O: Load images";
		
		var strwid = string_width(str);
	}
	
	if showtext
	{
		m = 20;
		
		// text outline
		xx = [-3,-2,-1,0,1,2,3];
		yy = [-3,-2,-1,0,1,2,3];
		draw_set_color(c_black);
		for (var yyy = 0; yyy < 7; yyy++)
		for (var xxx = 0; xxx < 7; xxx++)
			draw_text(room_width - strwid - m + xx[xxx], m + yy[yyy], str);
		
		draw_set_color(c_white);
		draw_text(room_width - strwid - m, m, str);
	
		str = @"PS.: Only 8-bit PNGs are supported, so if the
		image looks distorted, that could be the cause";
		strwid = string_width(str);
		draw_text(room_width - strwid - m, room_height - string_height(str) - m, str);
	}
}