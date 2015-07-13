/**
 * FreeDink game-specific code

 * Copyright (C) 1997, 1998, 1999, 2002, 2003  Seth A. Robinson
 * Copyright (C) 2003, 2004, 2005, 2007, 2008  Sylvain Beucler

 * This file is part of GNU FreeDink

 * GNU FreeDink is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 3 of the
 * License, or (at your option) any later version.

 * GNU FreeDink is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see
 * <http://www.gnu.org/licenses/>.
 */

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include "freedink.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/* for time(): */
#include <time.h>

#include "gettext.h"
#define _(String) gettext (String)

#include "fastfile.h"

#include "gfx.h"
#include "gfx_utils.h"
#include "gfx_fonts.h"
#include "gfx_sprites.h"
#include "gfx_tiles.h"
#include "gfx_fade.h"
#include "bgm.h"
#include "sfx.h"
#include "update_frame.h"
#include "init.h"
#include "io_util.h"
#include "paths.h"
#include "input.h"
#include "log.h"

#include "game_engine.h"
#include "dinkvar.h"
#include "dinkc_console.h"

void move(int u, int amount, char kind,  char kindy);
void draw_box(rect box, int color);
void run_through_tag_list_push(int h);
int check_if_move_is_legal(int u);
void change_dir_to_diag( int *dir);
int hurt_thing(int h, int damage, int special);


int but_timer = 0;

int fps_show = 0;
int fps_average;

int drawthistime = /*true*/1;
int x = 640;
int y = 480;
rect                rc;
int winoffset = 25;
int winoffsetx = 5;

int cx;
int cy;
int speed;


/* Fills 'struct seth_joy sjoy' with the current keyboard and/or
   joystick state */
void check_joystick(void)
{
  /* Clean-up */
  /* Buttons */
  {
    int e2;
    for (e2=1; e2 <=10; e2++) 
      sjoy.joybit[e2] = 0;
  }
  
  /* Arrows*/
  sjoy.right = 0;
  sjoy.left = 0;
  sjoy.up = 0;
  sjoy.down = 0;

  /* ? */
  sjoy.rightd = 0;
  sjoy.leftd = 0;
  sjoy.upd = 0;
  sjoy.downd = 0;
	
  if (joystick)
    {
      Sint16 x_pos, y_pos;
      int i;
      for (i = 0; i < 10; i++)
	if (SDL_JoystickGetButton(jinfo, i))
	  /* TODO: play.button ranges from 1 to 6, not 0 to 9
	     (cf. Dink's ESCAPE.C) */
	  sjoy.joybit[play.button[i+1]] = 1;

	x_pos = SDL_JoystickGetAxis(jinfo, 0);
	y_pos = SDL_JoystickGetAxis(jinfo, 1);
	/* Using thresold=10% (original game) is just enough to get
	   rid of the noise. Let's use 30% instead, otherwise Dink
	   will go diags too easily. */
	{
	  Sint16 threshold = 32767 * 30/100;
	  if (x_pos < -threshold) sjoy.left  = 1;
	  if (x_pos > +threshold) sjoy.right = 1;
	  if (y_pos < -threshold) sjoy.up    = 1;
	  if (y_pos > +threshold) sjoy.down  = 1;
	}
    }
  
  /* Only accept keyboard input when console is not active. */
  if (console_active == 0)
    {
      if (GetKeyboard(SDLK_LCTRL) || GetKeyboard(SDLK_RCTRL)) sjoy.joybit[1] = 1;
      if (GetKeyboard(SDLK_SPACE)) sjoy.joybit[2] = 1;
      if (GetKeyboard(SDLK_LSHIFT) || GetKeyboard(SDLK_RSHIFT)) sjoy.joybit[3] = 1;
      if (GetKeyboard(SDLK_RETURN)) sjoy.joybit[4] = 1;
      if (GetKeyboard(SDLK_ESCAPE)) sjoy.joybit[5] = 1;
      if (GetKeyboard('6')) sjoy.joybit[6] = 1;
      if (GetKeyboard('m')) sjoy.joybit[6] = 1;
      if (GetKeyboard('7')) sjoy.joybit[7] = 1;
    }
  
  {
    int x5;
    int x;

    for (x5 = 1; x5 <=10; x5++)
      sjoy.button[x5] = 0;
	
    for (x = 1; x <= 10; x++)
      {
	if (sjoy.joybit[x])
	  {
	    if (sjoy.letgo[x] == 1)
	      {
		sjoy.button[x] = 1;
		sjoy.letgo[x] = 0;
	      }
	  }
      }
  }
  
  /* Only accept keyboard input when console is not active. */
  if (console_active == 0)
    {
      if (GetKeyboard(SDLK_RIGHT)) sjoy.right = 1;
      if (GetKeyboard(SDLK_LEFT)) sjoy.left = 1;
      if (GetKeyboard(SDLK_DOWN)) sjoy.down = 1;
      if (GetKeyboard(SDLK_UP)) sjoy.up = 1;
    }
  
  {
    int x2;
    for (x2 = 1; x2 <= 10; x2++) 
      if (sjoy.joybit[x2])
	sjoy.letgo[x2] = 0;
      else
	sjoy.letgo[x2] = 1;
  }
  
  if (sjoy.right && sjoy.rightold == 1)
    {
      sjoy.rightd = /*true*/1;
      sjoy.rightold = /*false*/0;
    }
  
  if (sjoy.right)
    sjoy.rightold = /*false*/0;
  else
    sjoy.rightold = /*true*/1;
	
  if (sjoy.left && sjoy.leftold == 1)
    {
      sjoy.leftd = /*true*/1;
      sjoy.leftold = /*false*/0;
    }
	
  if (sjoy.left)
    sjoy.leftold = /*false*/0;
  else
    sjoy.leftold = /*true*/1;
  
  if (sjoy.up && sjoy.upold == 1)
    {
      sjoy.upd = /*true*/1;
      sjoy.upold = /*false*/0;
    }
  
  if (sjoy.up)
    sjoy.upold = /*false*/0;
  else
    sjoy.upold = /*true*/1;
	
  if (sjoy.down && sjoy.downold == 1)
    {
      sjoy.downd = /*true*/1;
      sjoy.downold = /*false*/0;
    }
	
  if (sjoy.down)
    sjoy.downold = /*false*/0;
  else
    sjoy.downold = /*true*/1;
  
  
  if (wait4b.active)
    {
      //check for dirs
      
      if (sjoy.rightd) wait4b.button = 16;
      if (sjoy.leftd) wait4b.button = 14;
      if (sjoy.upd) wait4b.button = 18;
      if (sjoy.downd) wait4b.button = 12;
      
      sjoy.rightd = /*false*/0;
      sjoy.downd = /*false*/0;
      sjoy.upd = /*false*/0;
      sjoy.leftd = /*false*/0;
      
      //check buttons
      {
	int ll;
	for (ll=1; ll <= 10; ll++)
	  {
	    if (sjoy.button[ll])
	      {
		//button was pressed
	      wait4b.button = ll;
	      }
	    sjoy.button[ll] = /*false*/0;
	  }
      }
      
      if (wait4b.button != 0)
	{
	  *presult = wait4b.button;
	  wait4b.active = /*false*/0;
	  run_script(wait4b.script);
	}
    }
}


/* Get sprite #h, grab its text and display it */
void text_draw(int h)
{
	
	char crap[200];
	char *cr;
	rect rcRect;
	int color = 0;
	
	if (spr[h].damage == -1)
	{
		sprintf(crap, "%s", spr[h].text);
		cr = &crap[0];
		color = 14;
		while( cr[0] == '`') 
		{
			//color code at top
			if (cr[1] == '#') color = 13;
			if (cr[1] == '1') color = 1;
			if (cr[1] == '2') color = 2;
			if (cr[1] == '3') color = 3;
			if (cr[1] == '5') color = 5;
			if (cr[1] == '6') color = 6;
			if (cr[1] == '7') color = 7;
			if (cr[1] == '8') color = 8;
			if (cr[1] == '9') color = 9;
			if (cr[1] == '0') color = 10;
			if (cr[1] == '$') color = 14;
			if (cr[1] == '%') color = 15;
			
			if (dversion >= 108)
			  {
			    //support for additional colors
			    if (cr[1] == '@')
			      color = 12;
			    if (cr[1] == '!')
			      color = 11;
			  }

			if (cr[1] == '4') color = 4;
			cr = &cr[2];
		}
		
		//Msg("Final is %s.",cr);
		if (spr[h].owner == 1000)
		{
			rect_set(&rcRect,spr[h].x,spr[h].y,spr[h].x+620,spr[h].y+400);
		} else
		{
			
			rect_set(&rcRect,spr[h].x,spr[h].y,spr[h].x+150,spr[h].y+150);
			
			if (spr[h].x+150 > 620)
				rect_offset(&rcRect, ((spr[h].x+150)-620) - (((spr[h].x+150)-620) * 2), 0);
			
			
			
		}
		
	} else
	{
		
		
		sprintf(crap, "%d", spr[h].damage);
		cr = &crap[0];
		if (spr[h].brain_parm == 5000)
			color = 14;
		
		
		if (spr[h].y < 0) spr[h].y = 0;
		rect_set(&rcRect,spr[h].x,spr[h].y,spr[h].x+50 ,spr[h].y+50);
		
		
	}       


	/* During a fadedown/fadeup, use white text to mimic v1.07 */
	if (truecolor_fade_brightness < 256)
	  color = 15;
	
	
/* 	SetTextColor(hdc,RGB(8,14,21)); */
	// FONTS
	FONTS_SetTextColor(8, 14, 21);
	   if (spr[h].owner == 1200)
	   {
	     printf("1200 says %s\n", cr);
		   //this text has no sprite, and doesn't want to be centered.
/* 		   DrawText(hdc,cr,strlen(cr),&rcRect,DT_WORDBREAK); */
		   // FONTS
	     print_text_wrap(cr, &rcRect, 0, 0, FONT_DIALOG);
		   
		   rect_offset(&rcRect,-2,0);
/* 		   DrawText(hdc,cr,strlen(cr),&rcRect,DT_WORDBREAK); */
		   // FONTS
		   print_text_wrap(cr, &rcRect, 0, 0, FONT_DIALOG);
		   
		   rect_offset(&rcRect,1,1);
/* 		   DrawText(hdc,cr,strlen(cr),&rcRect,DT_WORDBREAK); */
		   // FONTS
		   print_text_wrap(cr, &rcRect, 0, 0, FONT_DIALOG);

		   rect_offset(&rcRect,0,-2);
/* 		   DrawText(hdc,cr,strlen(cr),&rcRect,DT_WORDBREAK); */
		   // FONTS
		   print_text_wrap(cr, &rcRect, 0, 0, FONT_DIALOG);
	   }
	   else
	   {
		   
/* 		   DrawText(hdc,cr,strlen(cr),&rcRect,DT_CENTER | DT_WORDBREAK); */
		   // FONTS
	     print_text_wrap(cr, &rcRect, 1, 0, FONT_DIALOG);

		   rect_offset(&rcRect,-2,0);
/* 		   DrawText(hdc,cr,strlen(cr),&rcRect,DT_CENTER | DT_WORDBREAK); */
		   // FONTS
		   print_text_wrap(cr, &rcRect, 1, 0, FONT_DIALOG);
		   
		   rect_offset(&rcRect,1,1);
/* 		   DrawText(hdc,cr,strlen(cr),&rcRect,DT_CENTER | DT_WORDBREAK); */
		   // FONTS
		   print_text_wrap(cr, &rcRect, 1, 0, FONT_DIALOG);

		   rect_offset(&rcRect,0,-2);
/* 		   DrawText(hdc,cr,strlen(cr),&rcRect,DT_CENTER | DT_WORDBREAK); */
		   // FONTS
		   print_text_wrap(cr, &rcRect, 1, 0, FONT_DIALOG);
	   }
	   
	   rect_offset(&rcRect,0,1);
	   
	   // FONTS:
	   // support for custom colors
	   if (color >= 1 && color <= 15)
	     FONTS_SetTextColorIndex(color);
	   else
	     FONTS_SetTextColor(255, 255, 255);

	   if (spr[h].owner == 1200)
	     {
/* 	       DrawText(hdc,cr,strlen(cr),&rcRect,DT_WORDBREAK); */
	       // FONTS
	       print_text_wrap(cr, &rcRect, 0, 0, FONT_DIALOG);
	     }
	   else
	     {
/* 	       DrawText(hdc,cr,strlen(cr),&rcRect,DT_CENTER | DT_WORDBREAK); */
	       // FONTS
	       print_text_wrap(cr, &rcRect, 1, 0, FONT_DIALOG);
	     }
}


void get_last_sprite(void)
{
  int i;
  for (i = MAX_SPRITES_AT_ONCE - 1; i > 2; i--)
    {
      if (spr[i].active)
	{
	  last_sprite_created = i;
	  //   Msg("last sprite created is %d.", i);
	  return;
	}
    }
}


// ********* CHECK TO SEE IF THIS CORD IS ON A HARD SPOT *********
/*bool*/int not_in_this_base(int seq, int base)
{
	
	int realbase = (seq / 10) * 10;
	
	
	if (realbase != base)
	{
		
		
		return(/*true*/1); 
	}
	else
	{
		return(/*false*/0);
	}
}

/*bool*/int in_this_base(int seq, int base)
{
	
	int realbase = (seq / 10) * 10;
	if (realbase == base)
	{
		
		//	Msg("TRUE - Ok, realbase is %d, compared to the base, which is %d.", realbase, base);
		return(/*true*/1); 
	}
	else
	{
		//	Msg("FALSE - Ok, realbase is %d, compared to the base, which is %d.", realbase, base);
		
		return(/*false*/0);
	}
}


void automove (int j)
{
	
	char kindx,kindy;
	int speedx = 0;
	int speedy = 0;
	
	
	
	
	if (spr[j].mx != 0)
	{ 
		if (spr[j].mx < 0)
			kindx = '-'; else kindx = '+';
		if (kindx == '-') speedx = (spr[j].mx - (spr[j].mx * 2)); else
			speedx = spr[j].mx;
	} else kindx = '0';
	
	if (spr[j].my != 0)
	{ 
		if (spr[j].my < 0)
			kindy = '-'; else kindy = '+';
		if (kindy == '-') speedy = (spr[j].my - (spr[j].my * 2)); else
			speedy = spr[j].my;
		
	} else kindy = '0';
	
	int speed = speedx;
	if (speedy > speedx) speed = speedy;
	if (speed > 0)
		move(j,speed,kindx,kindy);
	//move(j, 1, '+','+'); 
	
}


int autoreverse(int j)
{
	//Msg("reversing die %d",spr[j].dir);
	int r = ((rand() % 2)+1);	
	if ( (spr[j].dir == 1) || (spr[j].dir == 2) ) 
	{
		if (r == 1)
			return(8);
		if (r == 2)
			return(6);
		
	}
	
	if ( (spr[j].dir == 3) || (spr[j].dir == 6) ) 
	{
		if (r == 1)
			return(2);
		if (r == 2)
			
			return(4);
		
	}
	
    if ( (spr[j].dir == 9) || (spr[j].dir == 8) ) 
	{
		if (r == 1)
			return(2);
		if (r == 2)
			
			return(6);
		
		
	}
	
    if ( (spr[j].dir == 7) || (spr[j].dir == 4) ) 
	{
		if (r == 1)
			return(8);
		if (r == 2)
			return(6);
		
	}
	
	return(0);
}


int autoreverse_diag(int j)
{
	if (spr[j].dir == 0) spr[j].dir = 7;
	int r = ((rand() % 2)+1);	
	
	if ( (spr[j].dir == 1) || (spr[j].dir == 3) ) 
	{
		
		if (r == 1)
			return(9);
		if (r == 2)
			return(7);
	}
	
	if ( (spr[j].dir == 3) || (spr[j].dir == 6) ) 
	{
		if (r == 1)
			return(7);
		if (r == 2)
			return(1);
		
	}
	
    if ( (spr[j].dir == 9) || (spr[j].dir == 8) ) 
	{
		if (r == 1)
			return(1);
		if (r == 2)
			return(7);
	}
	
    if ( (spr[j].dir == 7) || (spr[j].dir == 4) ) 
	{
		if (r == 1)
			return(3);
		if (r == 2)
			return(9);
		
	}
	
	Msg("Auto Reverse Diag was sent a dir %d sprite, base %d walk.",spr[j].dir, spr[j].base_walk);
	return(0);
}

void draw_damage(int h)
{
	
	int crap2 = add_sprite(spr[h].x,spr[h].y,8,0,0);
	
	spr[crap2].y -= k[seq[spr[h].pseq].frame[spr[h].pframe]].yoffset;
	spr[crap2].x -= k[seq[spr[h].pseq].frame[spr[h].pframe]].xoffset;
	spr[crap2].y -= k[seq[spr[h].pseq].frame[spr[h].pframe]].box.bottom / 3;
	spr[crap2].x += k[seq[spr[h].pseq].frame[spr[h].pframe]].box.right / 5;
	
	spr[crap2].speed = 1;
	spr[crap2].hard = 1;
	spr[crap2].brain_parm = h;  
	spr[crap2].my = -1;
	spr[crap2].kill = 1000;
	spr[crap2].dir = 8;
	spr[crap2].damage = spr[h].damage;
	
}


void add_kill_sprite(int h)
{
	if ( (spr[h].dir > 9) || (spr[h].dir < 1) )
	{
		Msg("Error:  Changing sprites dir from %d (!?) to 3.", spr[h].dir);
		spr[h].dir = 3;
		
	}
	
	
	int dir = spr[h].dir;
	int base = spr[h].base_die;
	
	//Msg("Base die is %d", base);
	if (base == -1) 
	{
		
	  if (seq[spr[h].base_walk+5].is_active)
		{
			add_exp(spr[h].exp, h);
			
			int crap2 = add_sprite(spr[h].x,spr[h].y,5,spr[h].base_walk +5,1);
			spr[crap2].speed = 0;
			spr[crap2].seq = spr[h].base_walk + 5;   
			// set corpse size to the original sprite size
			spr[crap2].size = spr[h].size;
			return;
		} else
		{
			dir = 0;
			base = 164;
			
		}
	}
	
	
	
	if (!seq[base+dir].is_active)
	{  
		
		if (dir == 1) dir = 9;
		else if (dir == 3) dir = 7;			
		else if (dir == 7) dir = 3;			
		else if (dir == 9) dir = 1;			
		
		else if (dir == 4) dir = 6;			
		else if (dir == 6) dir = 4;			
		else if (dir == 8) dir = 2;			
		else if (dir == 2) dir = 8;			
		
		
	}
	if (!seq[base+dir].is_active)
		
	{
		Msg("Can't make a death sprite for dir %d!", base+dir);
	}
	
	
	
	int crap2 = add_sprite(spr[h].x,spr[h].y,5,base +dir,1);
	spr[crap2].speed = 0;
	spr[crap2].base_walk = 0;
	spr[crap2].seq = base + dir;
	
	if (base == 164) spr[crap2].brain = 7;
	
	spr[crap2].size = spr[h].size;
	
	add_exp(spr[h].exp, h);
	
}


void done_moving(int h)
{
	
	spr[h].move_active = /*false*/0;
	
	spr[h].move_nohard = /*false*/0;
	
	if (spr[h].move_script > 0)
	{
		//	Msg("mover running script %d..", spr[h].move_script);
		run_script(spr[h].move_script);
	}
	
	
	
}

int get_distance_and_dir_smooth(int h, int h1, int *dir)
{
  unsigned int x_diff = abs(spr[h].x - spr[h1].x);
  unsigned int y_diff = abs(spr[h].y - spr[h1].y);

  if (spr[h].x < spr[h1].x)
    {
      if (spr[h].y < spr[h1].y)
	{
	  // 6, 3, 2
	  if (y_diff * 4 < x_diff)
	    *dir = 6;
	  else if (x_diff * 4 < y_diff)
	    *dir = 2;
	  else
	    *dir = 3;
	}
      else if (spr[h].y > spr[h1].y)
	{
	  // 4, 9, 8
	  if (y_diff * 4 < x_diff)
	    *dir = 6;
	  else if (x_diff * 4 < y_diff)
	    *dir = 8;
	  else
	    *dir = 9;
	}
      else
	{
	  *dir = 6;
	}
    }
  else if (spr[h].x > spr[h1].x)
    {
      if (spr[h].y < spr[h1].y)
	{
	  // 4, 1, 2
	  if (y_diff * 4 < x_diff)
	    *dir = 4;
	  else if (x_diff * 4 < y_diff)
	    *dir = 2;
	  else
	    *dir = 1;
	}
      else if (spr[h].y > spr[h1].y)
	{
	  // 4, 7, 8
	  if (y_diff * 4 < x_diff)
	    *dir = 4;
	  else if (x_diff * 4 < y_diff)
	    *dir = 8;
	  else
	    *dir = 7;
	}
      else
	{
	  *dir = 4;
	}
    }
  else
    {
      if (spr[h].y < spr[h1].y)
	*dir = 2;
      else if (spr[h].y > spr[h1].y)
	*dir = 8;
    }

  return (x_diff > y_diff) ? x_diff : y_diff;
}
int get_distance_and_dir_nosmooth(int h, int h1, int *dir)
{
  int distancex = 5000;
  int distancey = 5000;
  /* Arbitrarily set to 6 to avoid uninitialized values; don't set to
     5, because *dir is added to e.g. base_attack to get the right
     sequence - with 5, you get the dead/corpse sequence instead of an
     attack sequence.. */
  int dirx = 6;
  int diry = 6;

  if ((spr[h].x > spr[h1].x) && ((spr[h].x - spr[h1].x) < distancex))
    {
      distancex = spr[h].x - spr[h1].x;
      dirx = 4;
    }
  if ((spr[h].x < spr[h1].x) && ((spr[h1].x - spr[h].x) < distancex))
    {
      distancex = spr[h1].x - spr[h].x;
      dirx = 6;
    }

  if ((spr[h].y > spr[h1].y) && ((spr[h].y - spr[h1].y) < distancey))
    {
      distancey = spr[h].y - spr[h1].y;
      diry = 8;
    }
  if ((spr[h].y < spr[h1].y) && ((spr[h1].y - spr[h].y) < distancey))
    {
      distancey = spr[h1].y - spr[h].y;
      diry = 2;
    }

  if (distancex > distancey)
    {
      *dir = dirx;
      return distancex;
    }
  else
    {
      *dir = diry;
      return distancey;
    }
}
int get_distance_and_dir(int h, int h1, int *dir)
{
  if (smooth_follow == 1)
    return get_distance_and_dir_smooth(h, h1, dir);
  else
    return get_distance_and_dir_nosmooth(h, h1, dir);
}

void process_follow(int h)
{
	int hx, hy;
	
	if (spr[h].follow > 299)
	{
		Msg("ERROR:  Sprite %d cannot 'follow' sprite %d??",h,spr[h].follow);
		return;
	}
	
	if (spr[spr[h].follow].active == /*false*/0)
	{
		Msg("Killing follow");
		spr[h].follow = 0;
		return;
	}
	
	hx = spr[spr[h].follow].x;
	hy = spr[spr[h].follow].y;
	
	int dir;
	int distance = get_distance_and_dir(h, spr[h].follow, &dir);
	
	if (distance < 40) return;
	
	changedir(dir,h,spr[h].base_walk);
	automove(h);
	
	
}


void process_target(int h)
{
	int hx, hy;
	
	if (spr[h].target > 299)
	{
		Msg("ERROR:  Sprite %d cannot 'target' sprite %d??",h,spr[h].follow);
		return;
	}
	
	if (spr[spr[h].target].active == /*false*/0)
	{
		Msg("Killing target");
		spr[h].target = 0;
		return;
	}
	
	hx = spr[spr[h].target].x;
	hy = spr[spr[h].target].y;
	
	int dir;
	int distance = get_distance_and_dir(h, spr[h].target, &dir);
	
	if (distance < spr[h].distance) return;
	
	changedir(dir,h,spr[h].base_walk);
	
	automove(h);
	
	
}


/*bool*/int check_for_kill_script(int i)
{
	
	
	if (spr[i].script > 0)
	{
		//if (  (spr[i].brain == 0) | (spr[i].brain == 5) | (spr[i].brain == 6) | (spr[i].brain == 7))
		
		if (locate(spr[i].script, "DIE")) run_script(spr[i].script);
		
		return(/*true*/1);	
	}
	
	return(/*false*/0);
}

/*bool*/int check_for_duck_script(int i)
{
	
	
	if (spr[i].script > 0)
	{
		//if (  (spr[i].brain == 0) | (spr[i].brain == 5) | (spr[i].brain == 6) | (spr[i].brain == 7))
		
		if (locate(spr[i].script, "DUCKDIE")) run_script(spr[i].script);
		
		return(/*true*/1);	
	}
	
	return(/*false*/0);
}



void process_move(int h)
{
	
	//	Msg("Proccesing sprite %d, dir %d (script is %d)", h, spr[h].dir, spr[h].move_script);
	
	
	
	if ((spr[h].move_dir == 4) | (spr[h].move_dir == 1) | (spr[h].move_dir == 7) )
	{
		if (spr[h].x <= spr[h].move_num)
		{
			//done moving
			done_moving(h);
			return;
		}
		changedir(spr[h].move_dir,h,spr[h].base_walk);		
		automove(h);	
	}
	
	if ( (spr[h].move_dir == 6) | (spr[h].move_dir == 9) | (spr[h].move_dir == 3))
	{
		if (spr[h].x >= spr[h].move_num)
		{
			//done moving
			done_moving(h);
			return;
		}
		changedir(spr[h].move_dir,h,spr[h].base_walk);		
		automove(h);	
	}
	
	
	if (spr[h].move_dir == 2)
	{
		if (spr[h].y >= spr[h].move_num)
		{
			//done moving
			done_moving(h);
			return;
		}
		changedir(spr[h].move_dir,h,spr[h].base_walk);		
		automove(h);	
	}
	
	
	if (spr[h].move_dir == 8)
	{
		if (spr[h].y <= spr[h].move_num)
		{
			//done moving
			done_moving(h);
			return;
		}
		changedir(spr[h].move_dir,h,spr[h].base_walk);		
		automove(h);	
	}
	
	
}

void duck_brain(int h)
{
	int hold;
	
	
	if (   (spr[h].damage > 0) && (in_this_base(spr[h].pseq, 110)  ) )
	{
		
		check_for_duck_script(h);
		
		//hit a dead duck
		int crap2 = add_sprite(spr[h].x,spr[h].y,7,164,1);
		spr[crap2].speed = 0;
		spr[crap2].base_walk = 0;
		spr[crap2].seq = 164;
		draw_damage(h);
		spr[h].damage = 0;
		add_exp(spr[h].exp, h);
		
		kill_sprite_all(h);
		
		return;
	}
	
	
	if (   (spr[h].damage > 0) && (in_this_base(spr[h].pseq, spr[h].base_walk)  ) )
	{
		//SoundPlayEffect( 1,3000, 800 );  
		draw_damage(h);
		add_exp(spr[h].exp, h);
		spr[h].damage = 0;
		
		//lets kill the duck here, ha.
		check_for_kill_script(h);
		spr[h].follow = 0;
		int crap = add_sprite(spr[h].x,spr[h].y,5,1,1);
		spr[crap].speed = 0;
		spr[crap].base_walk = 0;
		spr[crap].size = spr[h].size;						
		spr[crap].speed =  ((rand() % 3)+1);
		
		
		spr[h].base_walk = 110;
		spr[h].speed = 1;
		spr[h].timer = 0;
		spr[h].wait = 0;
		spr[h].frame = 0;
		
		if (spr[h].dir == 0) spr[h].dir = 1;
		if (spr[h].dir == 4) spr[h].dir = 7;
		if (spr[h].dir == 6) spr[h].dir = 3;
		
		changedir(spr[h].dir,h,spr[h].base_walk);
		spr[crap].dir = spr[h].dir;
		spr[crap].base_walk = 120;
		changedir(spr[crap].dir,crap,spr[crap].base_walk);
		
		
		automove(h);
		return;
	}
	
	
	if (spr[h].move_active)
	{
		process_move(h);
		return;
	}
	
	if (spr[h].freeze)
	{
		return;
	}
	
	
	if (spr[h].follow > 0)
	{
		process_follow(h);
		return;
	}
	
	
	
	if (spr[h].base_walk == 110)
	{
		if ( (rand() % 100)+1 == 1)
			random_blood(spr[h].x, spr[h].y-18, h);
		goto walk;
	}
	
	
	
	
	
	if (spr[h].seq == 0 ) 
	{
		
		if (((rand() % 12)+1) == 1 )
		{  
			hold = ((rand() % 9)+1);
			
			if ((hold != 2) && (hold != 8) && (hold != 5))
			{
				
				//Msg("random dir change started.. %d", hold);
				changedir(hold,h,spr[h].base_walk);
				
			}
			else
			{
				int junk = spr[h].size;
				
				if (junk >=  100)
					junk = 18000 - (junk * 50);
				
				if (junk < 100)
					junk = 16000 + (junk * 100);
				
				SoundPlayEffect( 1,junk, 800,h ,0);
				spr[h].mx = 0;
				spr[h].my = 0;
				spr[h].wait = thisTickCount + (rand() % 300)+200;
				
			}
			return;		
		} 
		
		if ((spr[h].mx != 0) || (spr[h].my != 0))
			
		{
			spr[h].seq = spr[h].seq_orig;
			
		}
		
	}
	
	
walk:
	if (spr[h].y > playy)
		
	{
		changedir(9,h,spr[h].base_walk);
	}         
	
	
	
	if (spr[h].x > playx-30)
		
	{
		changedir(7,h,spr[h].base_walk);
	}         
	
	if (spr[h].y < 10)
	{
		changedir(1,h,spr[h].base_walk);
	}         
	
	if (spr[h].x < 30) 
	{
		changedir(3,h,spr[h].base_walk);
	}         
	
	//   Msg("Duck dir is %d, seq is %d.", spr[h].dir, spr[h].seq);	
	automove(h);
	
	if (check_if_move_is_legal(h) != 0)
		
	{
		if (spr[h].dir != 0)
			changedir(autoreverse_diag(h),h,spr[h].base_walk);
	}
	
}
// end duck_brain

void change_dir_to_diag( int *dir)
{
	
	if (*dir == 8) *dir = 7;
	if (*dir == 4) *dir = 1;
	if (*dir == 2) *dir = 3;
	if (*dir == 6) *dir = 9;
	
}



void pill_brain(int h)
{
	int hold;
	
	if  (spr[h].damage > 0)
	{
		//got hit
		//SoundPlayEffect( 1,3000, 800 );  
		if (spr[h].hitpoints > 0)
		{
			draw_damage(h);
			if (spr[h].damage > spr[h].hitpoints) spr[h].damage = spr[h].hitpoints;
			spr[h].hitpoints -= spr[h].damage;
			
			if (spr[h].hitpoints < 1)
			{
				//they killed it
				check_for_kill_script(h);
				
				if (spr[h].brain == 9)
				{
					if (spr[h].dir == 0) spr[h].dir = 3;
					change_dir_to_diag(&spr[h].dir);
					add_kill_sprite(h);
					spr[h].active = /*false*/0;
				}
				return;
				
			}
		}
		spr[h].damage = 0;
		
	}
	
	if (spr[h].move_active) 
	{
		process_move(h);
		return;
	}
	
	
	
	
	if (spr[h].freeze) return;
	
	if (spr[h].follow > 0)
	{
		process_follow(h);
		
	}
	
	
	if (spr[h].target != 0) 
	{
		
		if (in_this_base(spr[h].seq, spr[h].base_attack))
		{
			//still attacking
			return;
		}
		
		
		
		
		
		int dir;
		if (spr[h].distance == 0) spr[h].distance = 5;
		int distance = get_distance_and_dir(h, spr[h].target, &dir);
		
		if (distance < spr[h].distance) if (spr[h].attack_wait < thisTickCount)
		{
			//	Msg("base attack is %d.",spr[h].base_attack);
			if (spr[h].base_attack != -1)
			{
			  //Msg("attacking with %d..", spr[h].base_attack+dir);

			  /* Enforce lateral (not diagonal) attack,
			     even in smooth_follow mode */
			  int attackdir = 6; // arbitrary initialized default
			  get_distance_and_dir_nosmooth(h, spr[h].target, &attackdir);
			  spr[h].dir = attackdir;
				
				spr[h].seq = spr[h].base_attack+spr[h].dir;
				spr[h].frame = 0;
				
				if (spr[h].script != 0)
				  {
				    if (locate(spr[h].script, "ATTACK"))
				      run_script(spr[h].script);
				    else
				      spr[h].move_wait = thisTickCount + ((rand() % 300)+10);
				  }
				return;
					
			}
			
		}
		
		
		
		if (spr[h].move_wait  < thisTickCount)
		{
			process_target(h);
			spr[h].move_wait = thisTickCount + 200;
			
		}
		else
		{
		/*	automove(h);
		
		  if (check_if_move_is_legal(h) != 0)
		  {
		  
			}
			*/
			
			goto walk_normal;
		}
		
		return;
	}
	
	
	
walk_normal:
	
	if (spr[h].base_walk != -1)
	{
		if ( spr[h].seq == 0) goto recal;
	}
	
	if (( spr[h].seq == 0) && (spr[h].move_wait < thisTickCount))
	{
recal:
	if (((rand() % 12)+1) == 1 )
	{  
		hold = ((rand() % 9)+1);
		if (  (hold != 4) &&   (hold != 6) &&  (hold != 2) && (hold != 8) && (hold != 5))
		{
			changedir(hold,h,spr[h].base_walk);
			spr[h].move_wait = thisTickCount +((rand() % 2000)+200);
			
		}
		
	} else
	{
		//keep going the same way
		if (in_this_base(spr[h].seq_orig, spr[h].base_attack)) goto recal;
		spr[h].seq = spr[h].seq_orig;
		if (spr[h].seq_orig == 0) goto recal;
	}
	
	}
	
    
	
	if (spr[h].y > (playy - 15))
		
	{
		changedir(9,h,spr[h].base_walk);
	}         
	
	if (spr[h].x > (playx - 15))
		
	{
		changedir(1,h,spr[h].base_walk);
	}         
	
	if (spr[h].y < 18)
	{
		changedir(1,h,spr[h].base_walk);
	}         
	
	if (spr[h].x < 18) 
	{
		changedir(3,h,spr[h].base_walk);
	}         
	
	automove(h);
	
	if (check_if_move_is_legal(h) != 0)
	{
		spr[h].move_wait = thisTickCount + 400;
		changedir(autoreverse_diag(h),h,spr[h].base_walk);
	}
	
	
	//				changedir(hold,h,spr[h].base_walk);
	
	
}

void find_action(int h)
{
	
	spr[h].action = (rand() % 2)+1;
	
	
	if (spr[h].action == 1)
	{
		//sit and think
		spr[h].move_wait = thisTickCount +((rand() % 3000)+400);
		if (spr[h].base_walk != -1)
		{
			int dir = (rand() % 4)+1;  
			
			spr[h].pframe = 1;
			if (dir == 1)  spr[h].pseq = spr[h].base_walk+1;
			if (dir == 2)  spr[h].pseq = spr[h].base_walk+3;
			if (dir == 3)  spr[h].pseq = spr[h].base_walk+7;
			if (dir == 4)  spr[h].pseq = spr[h].base_walk+9;
		}
		
		return;
	}
	
	if (spr[h].action == 2)
	{
		//move
		spr[h].move_wait = thisTickCount +((rand() % 3000)+500);
		int dir = (rand() % 4)+1;  
		spr[h].pframe = 1;
		if (dir == 1)  changedir(1,h,spr[h].base_walk);
		if (dir == 2)  changedir(3,h,spr[h].base_walk);
		if (dir == 3)  changedir(7,h,spr[h].base_walk);
		if (dir == 4)  changedir(9,h,spr[h].base_walk);
		return;
	}
	
	
	Msg("Internal error:  Brain 16, unknown action.");
}


void people_brain(int h)
{
	if  (spr[h].damage > 0)
	{
		//got hit
		//SoundPlayEffect( 1,3000, 800 );  
		if (spr[h].hitpoints > 0)
		{
			draw_damage(h);
			if (spr[h].damage > spr[h].hitpoints) spr[h].damage = spr[h].hitpoints;
			spr[h].hitpoints -= spr[h].damage;
			
			if (spr[h].hitpoints < 1)
			{
				//they killed it
				check_for_kill_script(h);
				
				if (spr[h].brain == 16)
				{
					if (spr[h].dir == 0) spr[h].dir = 3;
					spr[h].brain = 0;
					change_dir_to_diag(&spr[h].dir);
					add_kill_sprite(h);
					spr[h].active = /*false*/0;
				}
				return;
				
			}
		}
		spr[h].damage = 0;
		
	}
	
	if (spr[h].move_active) 
	{
		process_move(h);
		return;
	}
	
	
	
	
	if (spr[h].freeze) return;
	
	if (spr[h].follow > 0)
	{
		process_follow(h);
		return;
	}
	
	
	if ((spr[h].move_wait < thisTickCount) && (spr[h].seq == 0))
	{
		
		spr[h].action = 0;
	}
	
	
	
	if (spr[h].action == 0) find_action(h);
	
	
	if (spr[h].action != 2) 
	{
		spr[h].seq = 0;
		return;
		
	}
	if (spr[h].seq_orig != 0)
		if (spr[h].seq == 0) spr[h].seq = spr[h].seq_orig;
		
		
		if (spr[h].y > playy)
			
		{
			
			if ( ((rand() % 2)+1) == 1)
				changedir(9,h,spr[h].base_walk);
			else changedir(7,h,spr[h].base_walk);
			
			
		}         
		
		if (spr[h].x > playx)
			
		{
			if ( ((rand() % 2)+1) == 1)
				changedir(1,h,spr[h].base_walk);
			else changedir(7,h,spr[h].base_walk);
			
		}         
		
		if (spr[h].y < 20)
		{
			if ( ((rand() % 2)+1) == 1)
				changedir(1,h,spr[h].base_walk);
			else changedir(3,h,spr[h].base_walk);
		}         
		
		if (spr[h].x < 30) 
		{
			if ( ((rand() % 2)+1) == 1)
				changedir(3,h,spr[h].base_walk);
			else changedir(9,h,spr[h].base_walk);
		}         
		
		automove(h);
		
		if (check_if_move_is_legal(h) != 0)
		{
			if ((rand() % 3) == 2)
			{
				changedir(autoreverse_diag(h),h,spr[h].base_walk);
				
			} else
			{
				spr[h].move_wait = 0;
				spr[h].pframe = 1;
				spr[h].seq = 0;
			}
		}
		
		
		//				changedir(hold,h,spr[h].base_walk);
		
		
}


void no_brain(int h)
{
	if (spr[h].move_active) 
	{
		process_move(h);
		return;
	}
	
	if (spr[h].freeze) return;
	
	if (spr[h].follow > 0)
	{
		process_follow(h);
		return;
	}
	
}


void shadow_brain(int h)
{
	if (spr[spr[h].brain_parm].active == /*false*/0)
	{
		spr[h].active = /*false*/0;
		return;
	}
	
	spr[h].x = spr[spr[h].brain_parm].x;
	spr[h].y = spr[spr[h].brain_parm].y;
	spr[h].size = spr[spr[h].brain_parm].size;
	
	if (spr[h].seq == 0) if (spr[h].seq_orig != 0) spr[h].seq = spr[h].seq_orig;
	
}



void dragon_brain(int h)
{
	int hold;
	
	
	if  (spr[h].damage > 0)
	{
		//got hit
		//SoundPlayEffect( 1,3000, 800 );  
		if (spr[h].hitpoints > 0)
		{
			draw_damage(h);
			if (spr[h].damage > spr[h].hitpoints) spr[h].damage = spr[h].hitpoints;
			spr[h].hitpoints -= spr[h].damage;
			
			if (spr[h].hitpoints < 1)
			{
				//they killed it
				
				check_for_kill_script(h);
				if (spr[h].brain == 10)
				{
					add_kill_sprite(h);
					spr[h].active = /*false*/0;
					
				}
				
				return;
				
			}
		}
		spr[h].damage = 0;
	}
	
	
	if (spr[h].move_active) 
	{
		process_move(h);
		return;
	}
	
	
	if (spr[h].freeze) return;
	
	
	if (spr[h].follow > 0)
	{
		process_follow(h);
		return;
	}
	
	if (spr[h].target != 0)
		if (spr[h].attack_wait < thisTickCount)
		{
			if (spr[h].script != 0) 
			{
				
				if (locate(spr[h].script, "ATTACK")) run_script(spr[h].script);
			}	
		}
		
		
		
		if (spr[h].seq == 0)
		{
recal:
		if (((rand() % 12)+1) == 1 )
		{  
			hold = ((rand() % 9)+1);
			if (  (hold != 1) &&   (hold != 3) &&  (hold != 7) && (hold != 9) && (hold != 5))
			{
				changedir(hold,h,spr[h].base_walk);
				
			}
			
		} else
		{
			//keep going the same way
			spr[h].seq = spr[h].seq_orig;
			if (spr[h].seq_orig == 0) goto recal;
		}
		
		}
		
		
		if (spr[h].y > playy)
			
		{
			changedir(8,h,spr[h].base_walk);
		}         
		
		if (spr[h].x > x)
		{
			changedir(4,h,spr[h].base_walk);
		}         
		
		if (spr[h].y < 0)
		{
			changedir(2,h,spr[h].base_walk);
		}         
		
		if (spr[h].x < 0) 
		{
			changedir(6,h,spr[h].base_walk);
		}         
		
		automove(h);
		
		if (check_if_move_is_legal(h) != 0)
			
		{
			
			int mydir = autoreverse(h);
			
			//	Msg("Real dir now is %d, autoresver changed to %d.",spr[h].dir, mydir);
			
			changedir(mydir,h,spr[h].base_walk);
			
			Msg("real dir changed to %d",spr[h].dir);
		}
		
}




void pig_brain(int h)
{
	int hold;
	
	if (spr[h].move_active) 
	{
		process_move(h);
		return;
	}
	
	if (   (spr[h].damage > 0) )
	{
		//SoundPlayEffect( 1,3000, 800 );  
		draw_damage(h);
		spr[h].hitpoints -= spr[h].damage;
		spr[h].damage = 0;
		if (spr[h].hitpoints < 1)
		{
			add_exp(spr[h].exp, h);
			spr[h].damage = 0;
			//lets kill the duck here, ha.
			check_for_kill_script(h);
			spr[h].speed = 0;
            spr[h].base_walk = -1;
			spr[h].seq = 164;
			spr[h].brain = 7;    
		}
		
		return;
	}
	
	
	if (spr[h].freeze) return;
	
	
	
	if (spr[h].seq == 0 ) 
	{
		
		if (((rand() % 12)+1) == 1 )
		{  
			hold = ((rand() % 9)+1);
			
			if (  (hold != 4) &&   (hold != 6) &&  (hold != 2) && (hold != 8) && (hold != 5))
			{
				changedir(hold,h,spr[h].base_walk);
				
			}
			else
			{
				int junk = spr[h].size;
				
				if (junk >=  100)
					junk = 18000 - (junk * 50);
				
				if (junk < 100)
					junk = 16000 + (junk * 100);
				
				
				hold = ((rand() % 4)+1);
				
				if (!playing(spr[h].last_sound)) spr[h].last_sound = 0;
				
				if (spr[h].last_sound == 0)
				{
					
					
					if (hold == 1) 
						spr[h].last_sound = SoundPlayEffect( 2,junk, 800 ,h,0);
					if (hold == 2) 
						spr[h].last_sound = SoundPlayEffect( 3,junk, 800,h ,0);
					if (hold == 3) 
						spr[h].last_sound = SoundPlayEffect( 4,junk, 800 ,h,0);
					if (hold == 4) 
						spr[h].last_sound = SoundPlayEffect( 5,junk, 800,h,0 );
					
				}
				
				spr[h].mx = 0;
				spr[h].my = 0;
				spr[h].wait = thisTickCount + (rand() % 300)+200;
				
			}
			
		} 
		else
		{
			
			if ((spr[h].mx != 0) || (spr[h].my != 0))
				
			{
				spr[h].seq = spr[h].seq_orig;
				
			}                                                                                                                                                                                                                                                                                                                          
			
		}
	}
	
	
	if (spr[h].y > (playy-k[getpic(h)].box.bottom / 4))
	{
		changedir(9,h,spr[h].base_walk);
	}         
	
	if (spr[h].x > (x-k[getpic(h)].box.right-10))
	{
		changedir(1,h,spr[h].base_walk);
	}         
	
	if (spr[h].y < 10)
	{
		changedir(1,h,spr[h].base_walk);
	}         
	
	if (spr[h].x < 10) 
	{
		changedir(3,h,spr[h].base_walk);
	}         
	
	automove(h);
	
	if (check_if_move_is_legal(h) != 0)
		
	{
		changedir(autoreverse_diag(h),h,spr[h].base_walk);
	}
	
}
// end duck_brain



/**
 * Check if the sprite can pass or should be blocked
 *
 * Returns 0 = can pass, <>0 = should be blocked
 */
int check_if_move_is_legal(int u)
{
  if ((dversion >= 108) /* move_nohard is active for all movements, not just active moves */
      || (/* dversion == 107 && */ spr[u].move_active))
    if (spr[u].move_nohard == 1)
      return(0);

  if (u == 1 && in_this_base(spr[u].seq, dink_base_push))
    return(0);
	
  int hardness = 0;
	if (spr[u].moveman > 0)
	{
	  int i;
	  for (i = 1; i <= spr[u].moveman; i++)
	    {
	      hardness = get_hard(spr[u].lpx[i]-20, spr[u].lpy[i]);
	      if (hardness == 2 && spr[u].flying) 
		{
		  spr[u].moveman = 0;
		  if (dversion >= 108)
		    return 0;
		  else
		    return 2;
		}
	      if (hardness > 0)
		{
		  spr[u].x = spr[u].lpx[i-1];
		  spr[u].y = spr[u].lpy[i-1];
		  spr[u].moveman = 0;			
		  
		  if (push_active)
		    {
		      if (u == 1 && hardness != 2 && play.push_active == /*false*/0)
			{
			  if ((spr[u].dir == 2) | (spr[u].dir == 4) | (spr[u].dir == 6) | (spr[u].dir == 8))
			    {
			      //he  (dink)  is definatly pushing on something
			      play.push_active = /*true*/1;
			      play.push_dir = spr[u].dir;
			      play.push_timer = thisTickCount;
			    }
			}
		      else
			{
			  if (play.push_dir != spr[1].dir) play.push_active = /*false*/0;
			}
		    }
		  return(hardness);
		}
	    }
	}
	
	if (u == 1)  play.push_active = /*false*/0;
	return(0);
}


void move(int u, int amount, char kind,  char kindy)
{
	int mx = 0;
	int my = 0;	
	int i;
	/*bool*/int clearx;
	/*bool*/int cleary;
	clearx = /*false*/0;
	cleary = /*false*/0;
	
	for (i = 1; i <= amount; i++)
	{
		spr[u].moveman++;
		if (mx >= spr[u].mx) clearx = /*true*/1;
		if (my >= spr[u].my) clearx = /*true*/1;
		
		if ((clearx) && (cleary))
		{
			mx = 0;
			my = 0;
			clearx = /*false*/0;
			cleary = /*false*/0;
			
		}
		
		
		if (kind == '+')
		{
			if (mx < spr[u].mx)
				spr[u].x++;
			mx++;
			
		}
		if (kind == '-')
		{
			
			
			if (mx < (spr[u].mx - (spr[u].mx * 2)))
				spr[u].x--;
			mx++;
		}
		
		if (kindy == '+')
		{
			
			if (my < spr[u].my)
				spr[u].y++;
			my++;
		}
		if (kindy == '-')
		{
			
			if (my < (spr[u].my - (spr[u].my * 2)))
				spr[u].y--;
			my++;
		}
		
		spr[u].lpx[spr[u].moveman] = spr[u].x;
        spr[u].lpy[spr[u].moveman] = spr[u].y;
	}
	
	
}



void bounce_brain(int h)
{
	if (spr[h].y > (playy-k[getpic(h)].box.bottom))
	{
		spr[h].my -= (spr[h].my * 2);
	}         
	
	if (spr[h].x > (x-k[getpic(h)].box.right))
	{
		spr[h].mx -= (spr[h].mx * 2);
	}         
	
	if (spr[h].y < 0)
	{
		spr[h].my -= (spr[h].my * 2);
	}         
	
	
	if (spr[h].x < 0) 
	{
		spr[h].mx -= (spr[h].mx * 2);
	}         
	
	
	spr[h].x += spr[h].mx;
	spr[h].y += spr[h].my;
	
	
}
//end bounce brain		

void grab_trick(int trick)
{
  /* Capture the current game zone from the backbuffer */
  SDL_Rect src, dst;
  src.x = playl;
  src.y = 0;
  src.w = 620 - playl;
  src.h = 400;
  dst.x = dst.y = 0;
  SDL_BlitSurface(GFX_lpDDSBack, &src, GFX_lpDDSTrick, &dst);
  
  move_screen = trick;			
  trig_man = /*true*/1;
  
  move_counter = 0;
}






void did_player_cross_screen(/*bool*/int real, int h)
{
  if (walk_off_screen == 1)
    return;
	

  //DO MATH TO SEE IF THEY HAVE CROSSED THE SCREEN, IF SO LOAD NEW ONE
	
  if ((spr[h].x) < playl) 
    {
      if ((*pmap-1) >= 1 && map.loc[*pmap-1] > 0 && screenlock == 0)
	{
	  //move one map to the left
	  if (real)
	    return;
	  
	  update_screen_time();
	  grab_trick(4);
	  *pmap -= 1;
	  load_map(map.loc[*pmap]);
	  if (map.indoor[*pmap] == 0)
	    play.last_map = *pmap;
	  
	  spr[h].x = 619;
	  spr[h].y = spr[h].lpy[0];
	  draw_map_game();
	  *pmap=34;
	}
      else
	{
	  spr[h].x = playl;
	}
    }
  
  else if (spr[h].x > 619)
    {
      if ((*pmap+1) <= 24*32 && map.loc[*pmap+1] > 0 && screenlock == 0)
	{
	  //move one map to the right
	  if (real)
	    return;
	  
	  update_screen_time();
	  grab_trick(6);
	  *pmap += 1;
	  load_map(map.loc[*pmap]);
	  if (map.indoor[*pmap] == 0)
	    play.last_map = *pmap;
	  
	  spr[h].x = playl;
	  spr[h].y = spr[h].lpy[0];
	  draw_map_game();
	  *pmap=34;
	}
      else
	{
	  spr[h].x = 619;
	}
    }
  
  else if (spr[h].y < 0)
    {
      if ((*pmap-32) >= 1 && map.loc[*pmap-32] > 0 && screenlock == 0)
	{
	  //move one map up
	  if (real)
	    return;

	  update_screen_time();
	  grab_trick(8);
	  *pmap -= 32;
	  load_map(map.loc[*pmap]);
	  if (map.indoor[*pmap] == 0)
	    play.last_map = *pmap;
	  
	  spr[h].x = spr[h].lpx[0];
	  spr[h].y = 399;
	  draw_map_game();
	  *pmap=34;
	}
      else
	{
	  spr[h].y = 0;
	}
    }
  
  
  else if (spr[h].y > 399)
    {
      if ((*pmap+32) <= 24*32 && map.loc[*pmap+32] > 0 && screenlock == 0)
	{
	  //move one map down
	  if (real)
	    return;
	  
	  update_screen_time();
	  grab_trick(2);
	  *pmap += 32;
	  load_map(map.loc[*pmap]);
	  if (map.indoor[*pmap] == 0)
	    play.last_map = *pmap;
	  
	  spr[h].y = 0;
	  spr[h].x = spr[h].lpx[0];
	  draw_map_game();
	  *pmap=34;
	}
      else
	{
	  spr[h].y = 399;
	}
    }
}


/*bool*/int run_through_tag_list_talk(int h)
{
	rect box;
	int amount, amounty;
	int i;

	for (i = 1; i <= last_sprite_created; i++)
	{
		
		if (spr[i].active) if (i != h) if (spr[i].brain != 8)
		{
			
			
			rect_copy(&box, &k[getpic(i)].hardbox);
			rect_offset(&box, spr[i].x, spr[i].y);
			
			rect_inflate(&box, 10,10);
			
			amount = 50;		
			amounty = 35;
			if (spr[h].dir == 6)
			{
				box.left -= amount;
			}
			
			if (spr[h].dir == 4)
			{
				box.right += amount;
			}
			
			
			if (spr[h].dir == 2)
			{
				box.top -= amounty;
			}
			
			if (spr[h].dir == 8)
			{
				box.bottom += amounty;
			}
			
			//		draw_box(box, 33);
			
			if (inside_box(spr[h].x, spr[h].y, box))
			{	
				//Msg("Talking to sprite %d", i);
				if (spr[i].script > 0)
				{
					//if (  (spr[i].brain == 0) | (spr[i].brain == 5) | (spr[i].brain == 6) | (spr[i].brain == 7))
					//Msg("trying to find TALK in script %d", spr[i].script);
					if (locate(spr[i].script, "TALK")) 
					{
						kill_returning_stuff(spr[i].script);
						
						run_script(spr[i].script);
						return(/*true*/1);	
					}
					
					
				}
				
			}
			
			
		}
		
		
	}
	
	
	return(/*false*/0);
}





void make_missile(int x1, int y1, int dir, int speed, int seq, int frame, int strength)
{
	int crap = add_sprite(x1,y1,11,seq,frame);
	spr[crap].speed = speed;
	spr[crap].seq = seq;
	spr[crap].timer = 0;
	spr[crap].strength = strength;
	spr[crap].flying = /*true*/1;
	changedir(dir, crap, 430);
	
}




void missile_brain(int h, /*bool*/int repeat)
{
  rect box;
  int j;
  automove(h);
  
  *pmissle_source = h;
  int hard = check_if_move_is_legal(h);
  if (repeat && spr[h].seq == 0)
    spr[h].seq = spr[h].seq_orig;
  spr[1].hitpoints = *plife; 
  
  if (hard > 0 && hard != 2) 
    {      
      //lets check to see if they hit a sprites hardness
      if (hard > 100)
	{
	  int ii;
	  for (ii = 1; ii < last_sprite_created; ii++)
	    {
	      if (spr[ii].sp_index == hard-100)
		{
		  if (spr[ii].script > 0)
		    {
		      *pmissile_target = 1;
		      *penemy_sprite = 1;
		      
		      if (locate(spr[ii].script, "HIT"))
			{
			  kill_returning_stuff(spr[ii].script);
			  run_script(spr[ii].script);
			}
		    }
		  
		  if (spr[h].script > 0)
		    {
		      *pmissile_target = ii;
		      *penemy_sprite = 1;
		      if (locate(spr[h].script, "DAMAGE")) 
			{
			  kill_returning_stuff(spr[h].script);
			  run_script(spr[h].script);
			}
		    }
		  else
		    {
		      if (spr[h].attack_hit_sound == 0)
			SoundPlayEffect( 9,22050, 0 ,0,0);
		      else
			SoundPlayEffect( spr[h].attack_hit_sound,spr[h].attack_hit_sound_speed, 0 ,0,0);
		      
		      spr[h].active = 0;
		    }
		  
		  //run missile end	
		  return;
		}
	    }
	}
      //run missile end	
      
      if (spr[h].script > 0)
	{
	  *pmissile_target = 0;
	  if (locate(spr[h].script, "DAMAGE"))
	    run_script(spr[h].script);
	}
      else
	{
	  if (spr[h].attack_hit_sound == 0)
	    SoundPlayEffect(9, 22050, 0, 0, 0);
	  else
	    SoundPlayEffect(spr[h].attack_hit_sound,spr[h].attack_hit_sound_speed, 0, 0, 0);
	  
	  spr[h].active = 0;
	  return;
	}
    }
  
  if (spr[h].x > 1000) spr[h].active = /*false*/0;
  if (spr[h].y > 700) spr[h].active = /*false*/0;
  if (spr[h].y < -500) spr[h].active = /*false*/0;
  if (spr[h].x < -500) spr[h].active = /*false*/0;
  
  //did we hit anything that can die?
  
  for (j = 1; j <= last_sprite_created; j++)
    {
      if (spr[j].active && h != j && spr[j].nohit != 1 && spr[j].notouch == /*false*/0)
	if (spr[h].brain_parm != j && spr[h].brain_parm2!= j)
	  //if (spr[j].brain != 15) if (spr[j].brain != 11)
	  {
	    rect_copy(&box, &k[getpic(j)].hardbox);
	    rect_offset(&box, spr[j].x, spr[j].y);
	    
	    if (spr[h].range != 0)
	      rect_inflate(&box, spr[h].range,spr[h].range);
	    
	    if (debug_mode) draw_box(box, 33);
	    
	    if (inside_box(spr[h].x, spr[h].y, box))
	      {
		spr[j].notouch = /*true*/1;
		spr[j].notouch_timer = thisTickCount+100;
		spr[j].target = 1;
		*penemy_sprite = 1;
		//change later to reflect REAL target
		if (spr[h].script > 0)
		  {
		    *pmissile_target = j;
		    if (locate(spr[h].script, "DAMAGE"))
		      run_script(spr[h].script);
		  }
		else
		  {
		    if (spr[h].attack_hit_sound == 0)
		      SoundPlayEffect(9, 22050, 0, 0, 0);
		    else
		      SoundPlayEffect(spr[h].attack_hit_sound,spr[h].attack_hit_sound_speed, 0, 0,0);
		  }
		
		if (spr[j].hitpoints > 0 && spr[h].strength != 0)
		  {
		    int hit = 0;
		    if (spr[h].strength == 1)
		      hit = spr[h].strength - spr[j].defense;
		    else
		      hit = (spr[h].strength / 2)
			+ ((rand() % (spr[h].strength / 2)) + 1)
			- spr[j].defense;
		    
		    if (hit < 0)
		      hit = 0;
		    spr[j].damage += hit;
		    if (hit > 0)
		      random_blood(spr[j].x, spr[j].y-40, j);
		    spr[j].last_hit = 1;
		    //Msg("Damage done is %d..", spr[j].damage);
		  }
		
		if (spr[j].script > 0)
		  {
		    //CHANGED did = h
		    *pmissile_target = 1;
		    
		    if (locate(spr[j].script, "HIT"))
		      {
			kill_returning_stuff(spr[j].script);
			run_script(spr[j].script);
		      }
		  }
	      }
	    //run missile end	
	    
	  }
    }
}


void missile_brain_expire(int h)
{
	missile_brain(h, /*false*/0);
	if (spr[h].seq == 0) spr[h].active = 0;
	
}

void run_through_mouse_list(int h, /*bool*/int special)
{
  rect box;
  int i;

	for (i = 1; i <= last_sprite_created; i++)
	{
		
		if (spr[i].active) if (i != h) if
			((spr[i].touch_damage != 0) )
		{
			
			if (spr[i].touch_damage != -1) if (spr[h].notouch) return;
			rect_copy(&box, &k[getpic(i)].hardbox);
			rect_offset(&box, spr[i].x, spr[i].y);
			
			
			if (inside_box(spr[h].x, spr[h].y, box))
			{	
				
				if ((spr[i].touch_damage == -1) && (spr[i].script != 0))
				{
					Msg("running %d's script..",spr[i].script);
					if (locate(spr[i].script, "CLICK")) run_script(spr[i].script);
				} 
				else
				{
					if (spr[i].touch_damage == -1)
					{
						Msg("Sprites touch damage is set to -1 but there is no script set!");
					} else
					{
						//lets hurt the guy
					}
					
				}
				
				if (special) return;	
				
			}
			
			
		}
		
	}
	
	if (special) 		SoundPlayEffect(19, 22050, 0, 0,0);
	
}




void mouse_brain(int h)
{
	
	if (spr[h].move_active) 
	{
		process_move(h);
		return;
	}
	
	
	int diag = 0;
	
	if (sjoy.right) diag++;
	if (sjoy.left) diag++;
	if (sjoy.down) diag++;
	if (sjoy.up) diag++;
	
	
    //*********************************PROCESS MOVEMENT							
	
	if (diag == 1)
	{
								
								if (sjoy.right)
								{
									move(h,spr[h].speed,'+','0');
									changedir(6,h,spr[h].base_walk);
								}
								
								
								if (sjoy.left) 
								{
									move(h,spr[h].speed,'-','0');
									changedir(4,h,spr[h].base_walk);
								}
								
								
								if (sjoy.down)
								{
									move(h,spr[h].speed,'0','+');
									changedir(2,h,spr[h].base_walk);
								}
								
								
								if (sjoy.up) 
								{
									move(h,spr[h].speed,'0','-');
									changedir(8,h,spr[h].base_walk);
								}
								
	}
	// ***************** DIAGONAL!!!!
	
	if (diag > 1)
	{
								
								if ( (sjoy.up) && (sjoy.left) ) 
								{
									changedir(7,h,spr[h].base_walk);
									move(h,spr[h].speed - (spr[h].speed / 3),'-','-');
									
								}
								
								if ( (sjoy.down) && (sjoy.left))
								{
									changedir(1,h,spr[h].base_walk);
									move(h,spr[h].speed - (spr[h].speed / 3),'-','+');
									
								}
								
								if ( (sjoy.down) && (sjoy.right))
								{
									changedir(3,h,spr[h].base_walk);
									move(h,spr[h].speed - (spr[h].speed / 3),'+','+');
								}
								
								
								if ( (sjoy.up) && (sjoy.right))
								{
									changedir(9,h,spr[h].base_walk);
									move(h,spr[h].speed - (spr[h].speed / 3),'+','-');
								}
								
	}
	
	
	
	
	if ( (sjoy.button[1] == /*TRUE*/1) | (mouse1) )
	{
		
		Msg("running through mouse list..");
		run_through_mouse_list(h, /*true*/1);
		sjoy.button[1] = /*false*/0;
							 mouse1 = /*false*/0;
							 
	}
	
}

void process_bow( int h)
{
	int timetowait = 100;
	
	
	if (bow.wait < thisTickCount)
	{
		if (sjoy.right) spr[h].dir = 6;
		if (sjoy.left) spr[h].dir = 4;
		if (sjoy.up) spr[h].dir = 8;
		if (sjoy.down) spr[h].dir = 2;
	}
	
	
	
	if (sjoy.right) if (sjoy.up) 
	{
		spr[h].dir = 9;
		bow.wait = thisTickCount + timetowait;
	}
	if (sjoy.left) if (sjoy.up) 
	{
		spr[h].dir = 7;
		bow.wait = thisTickCount + timetowait;
	}
	if (sjoy.right) if (sjoy.down) 
	{
		spr[h].dir = 3;
		bow.wait = thisTickCount + timetowait;
		
	}
	if (sjoy.left) if (sjoy.down) 
	{
		spr[h].dir = 1;
		bow.wait = thisTickCount + timetowait;
		
	}
	spr[h].pseq = 100+spr[h].dir;
	
	
	if (bow.pull_wait < thisTickCount)
	{
		bow.pull_wait = thisTickCount + 10;
		if (bow.hitme) bow.time += 7;
		
		
		//	bowsound->SetFrequency(22050+(bow.time*10));
		
		if (bow.time > 500) bow.time = 500;
		spr[h].pframe = (bow.time / 100)+1;
	}
	
	
	if (sjoy.letgo[1])
	{
		bow.active = /*false*/0;
		bow.last_power = bow.time;
		run_script(bow.script);
		//     bowsound->Stop();
		return;
	}
	
}



/**
 * Player
 */
void human_brain(int h)
{
  int diag, x5;
  int crap;
  /*BOOL*/int bad;
  
  if (mode == 0)
    goto b1end;
  
  if (spr[h].move_active)
    {
      process_move(h);
      return;
    }
	
  if (spr[h].damage > 0)
    {
      draw_damage(h);
      
      *plife -= spr[h].damage;
      
      spr[h].damage = 0;
      if (*plife < 0)
	*plife = 0;
		
      int hurt = (rand() % 2)+1;
		
      if (hurt == 1)
	SoundPlayEffect(15, 25050, 2000, 0,0);
      if (hurt == 2)
	SoundPlayEffect(16, 25050, 2000, 0,0);
		
      //draw blood
    }
  
  if (play.push_active)
    {
      if (play.push_dir == 2 && !sjoy.down) 
	{
	  spr[h].nocontrol = /*false*/0;
	  play.push_active = /*false*/0;
	}
      
      if (play.push_dir == 4 && !sjoy.left) 
	{
	  spr[h].nocontrol = /*false*/0;
	  play.push_active = /*false*/0;
	}
      if (play.push_dir == 6 && !sjoy.right) 
	{
	  spr[h].nocontrol = /*false*/0;
	  play.push_active = /*false*/0;
	}
      
      if (play.push_dir == 8 && !sjoy.up) 
	{
	  spr[h].nocontrol = /*false*/0;
	  play.push_active = /*false*/0;
	}
    }
  
  if (spr[h].nocontrol)
    return;
	
  if (talk.active)
    goto freeze;
	
  if (spr[h].freeze)
    {
      //they are frozen
      if (sjoy.button[2] == 1)
	{
	  //they hit the talk button while frozen, lets hurry up the process
	  int jj;
	  for (jj = 1; jj <= last_sprite_created; jj++)
	    {
	      // Msg("Checking %d, brain %d, script %d, my freeze is %d",jj, spr[jj].brain, spr[jj].script, spr[h].freeze);
	      if (spr[jj].brain == 8 && spr[jj].script == play.last_talk)
		{
		  //this sprite owns its freeze
		  spr[jj].kill_timer = 1;
		  //force the message to be over
		}
	    }
	}
      goto freeze;
    }


  //******************************  KEYS THAT CAN BE PRESSED AT ANY TIME **************
  
  if (bow.active)
    {
      //bow is active!!
      process_bow(h);
      return;
    }

  if (play.push_active && thisTickCount > play.push_timer + 600)
    {
      spr[h].seq = dink_base_push + spr[h].dir;
      spr[h].frame = 1;
      spr[h].nocontrol = /*true*/1;
      //play.push_active = /*false*/0;
      run_through_tag_list_push(h);
      
      return;
    }
  
  if ((sjoy.button[2] == 1))
    {
      if (!run_through_tag_list_talk(h))
	{
	  int did_dnotalk = 0;
	  if (dversion >= 108)
	    {
	      // addition of 'not talking to anything' script
	      int sc = load_script ("dnotalk", 0, /*false*/0);
	      if (sc != 0 && locate (sc, "MAIN"))
		{
		  run_script (sc);
		  did_dnotalk = 1;
		}
	    }

	  if (did_dnotalk == 0)
	    {
	      kill_text_owned_by(h);	
	      int randy = (rand() % 6)+1;
	      if (randy == 1) say_text(_("`$I don't see anything here."), h, 0);
	      if (randy == 2) say_text(_("`$Huh?"), h, 0);
	      if (randy == 3) say_text(_("`$I'm fairly sure I can't talk to or use that."), h, 0);
	      if (randy == 4) say_text(_("`$What?"), h, 0);
	      if (randy == 5) say_text(_("`$I'm bored."), h, 0);
	      if (randy == 6) say_text(_("`$Not much happening here."), h, 0);
	    }
	}
    }
	
  if ((sjoy.button[1] == 1) && (weapon_script != 0))
    {
      if (spr[h].base_hit > 0)
	{
	  if (locate(weapon_script, "USE"))
	    run_script(weapon_script);
	  goto b1end;
	}
    }
  
  //added AGAIN 10-19-99
  //Let's check keys for getting hit
  if (thisTickCount > but_timer && console_active == 0)
    {
      for (x5=29; x5<256; x5++)
	{ 
	  if (x5 == SDLK_SPACE) continue;
	  if (x5 == '6') continue;
	  if (x5 == '7') continue;
	  if (x5 == SDLK_LEFT) continue;
	  if (x5 == SDLK_UP) continue;
	  if (x5 == SDLK_RIGHT) continue;
	  if (x5 == SDLK_DOWN) continue;
	  if (x5 == 'm') continue;
	  /* Conflicts with remapped 'a'-'z' SDL
	     keycodes: */
	  if (x5 >= 'A' && x5 <= 'Z') continue;
	  
	  char msg[30];
	  if (GetKeyboard(x5))
	    {
	      int keycode = x5;
	      /* Get the same keycodes than the original Dink engines
		 for letters, that is, uppercase ascii rather than
		 lowercase ascii */
	      if (x5 >= 'a' && x5 <= 'z')
		keycode = x5 - ('a' - 'A');
	      
	      sprintf(msg, "key-%d", keycode);
	      but_timer = thisTickCount+200;
	      
	      int mycrap = load_script(msg, 1, /*false*/0);
	      if (locate(mycrap, "MAIN")) 
		{
		  run_script(mycrap);
		  goto b1end;
		}
	    }
	}
    }
  
  int i;
  int last_key = 6;
  if (dversion >= 108)
    last_key = 10;
  for (i = 6; i <= last_key; i++)
    {
      // button6.c, button7.c, ..., button10.c
      if (sjoy.button[i] == 1)
	{
	  char script_filename[6+2+1];
	  sprintf(script_filename, "button%d", i);
	  int mycrap = load_script(script_filename, 1, /*false*/0);
	  if (locate(mycrap, "MAIN"))
	    run_script(mycrap);
	  goto b1end;
	}
    }
  
  if (magic_script != 0 && sjoy.joybit[3])
    goto shootm;

  if (sjoy.button[3] == 1)
    {
      if (magic_script == 0)
	{
	  if (dversion >= 108)
	    {
	      // addition of 'no magic' script
	      int sc = load_script ("dnomagic", 0, /*false*/0);
	      if (sc != 0 && locate (sc, "MAIN"))
		{
		  run_script (sc);
		  goto b1end;
		}
	    }

	  int randy = (rand() % 6)+1;
	  kill_text_owned_by(h);	
	  if (randy == 1) say_text(_("`$I don't know any magic."), h, 0);
	  if (randy == 2) say_text(_("`$I'm no wizard!"), h, 0);
	  if (randy == 3) say_text(_("`$I need to learn magic before trying this."), h, 0);
	  if (randy == 4) say_text(_("`$I'm gesturing wildly to no avail!"), h, 0);
	  if (randy == 5) say_text(_("`$Nothing happened."), h, 0);
	  if (randy == 6) say_text(_("`$Hocus pocus!"), h, 0);
	  goto b1end;
	}
		
      //player pressed 1
      //lets magiced something
shootm:	
      if (*pmagic_level >= *pmagic_cost)
	{
	  if (locate(magic_script, "USE"))
	    run_script(magic_script);
	  goto b1end;	
	} 
    }
  
  if (sjoy.button[4])
    {
      if (dversion >= 108)
	{
	  // addition of 'enter key/inventory' script
	  int sc = load_script ("button4", 0, /*false*/0);
	  if (sc != 0 && locate (sc, "MAIN"))
	    {
	      run_script (sc);
	      return;
	    }
	}
      
      item_screen = /*true*/1;
      SoundPlayEffect(18, 22050,0,0,0);
      return;
    }
  
  if (sjoy.button[5] == 1)
    {
      if (!showb.active && !bow.active && !talk.active)
	{
	  int sc = load_script("escape", 1000, /*false*/0);
	  if (sc != 0 && locate(sc, "MAIN"))
	    run_script(sc);
	  return;
	}
    }
  
  if (console_active == 0)
    {
      if (GetKeyboard('b'))
	ResumeMidi();
      if (GetKeyboard('n'))
	PauseMidi();
    }
  
  if (spr[h].skip > 0
      && spr[h].skip <= spr[h].skiptimer)
    {
      spr[h].skiptimer = 0;
      goto b1end;
    }
  
  
  diag = 0;
  if (sjoy.right) diag++;
  if (sjoy.left) diag++;
  if (sjoy.down) diag++;
  if (sjoy.up) diag++;

  
  //*********************************PROCESS MOVEMENT
  
  if (diag == 1)
    {
      if (sjoy.right)
	{
	  move(h,spr[h].speed,'+','0');
	  changedir(6,h,spr[h].base_walk);
	}
      
      if (sjoy.left) 
	{
	  move(h,spr[h].speed,'-','0');
	  changedir(4,h,spr[h].base_walk);
	}
      
      if (sjoy.down)
	{
	  move(h,spr[h].speed,'0','+');
	  changedir(2,h,spr[h].base_walk);
	}
      
      if (sjoy.up) 
	{
	  move(h,spr[h].speed,'0','-');
	  changedir(8,h,spr[h].base_walk);
	}
    }
  
  // ***************** DIAGONAL!!!!
  if (diag > 1 && diag < 3)
    {
      if (sjoy.up && sjoy.left)
	{
	  changedir(7,h,spr[h].base_walk);
	  move(h,spr[h].speed - (spr[h].speed / 3),'-','-');
	}
      
      if (sjoy.down && sjoy.left)
	{
	  changedir(1,h,spr[h].base_walk);
	  move(h,spr[h].speed - (spr[h].speed / 3),'-','+');
	}
      
      if (sjoy.down && sjoy.right)
	{
	  changedir(3,h,spr[h].base_walk);
	  move(h,spr[h].speed - (spr[h].speed / 3),'+','+');
	}
      
      if (sjoy.up && sjoy.right)
	{
	  changedir(9,h,spr[h].base_walk);
	  move(h,spr[h].speed - (spr[h].speed / 3),'+','-');
	}		
    }
  	
  bad = 0;
  if (sjoy.right) bad = 1;
  if (sjoy.left) bad = 1;
  if (sjoy.up) bad = 1;
  if (sjoy.down) bad = 1;
  
  if (bad)
    {
      if (spr[h].idle)
	{
	  spr[h].frame = 1;
	  spr[h].idle = /*FALSE*/0;
	}
      goto badboy;
    }
		
  if (not_in_this_base(spr[h].seq, spr[h].base_idle)) //unccoment to allow walk anim to end before idle anim to start
    {
    freeze:
      if (spr[h].dir == 1) spr[h].dir = 2;
      if (spr[h].dir == 3) spr[h].dir = 2;
      if (spr[h].dir == 7) spr[h].dir = 8;
      if (spr[h].dir == 9) spr[h].dir = 8;
      
      if (spr[h].base_idle != 0)
	changedir(spr[h].dir,h,spr[h].base_idle);
      spr[h].idle = /*TRUE*/1;   
    }
  
 badboy: 
 b1end:
  
  if (spr[h].dir == 2 || spr[h].dir == 4 || spr[h].dir == 6 || spr[h].dir == 8)
    goto smoothend;

  crap = check_if_move_is_legal(h);
  if (crap != 0)
    {
      if (pam.sprite[crap-100].prop != 0)
	flub_mode = crap;
		  
      //hit something, can we move around it?
		  
      if (spr[h].seq == spr[h].base_walk + 4
	  || spr[h].seq == spr[h].base_walk + 6)
	{
	  int hardm = get_hard_play(h, spr[h].x, spr[h].y-1);
	  if (hardm == 0)
	    spr[h].y -= 1;
	}

      if (spr[h].seq == spr[h].base_walk + 8
	  || spr[h].seq == spr[h].base_walk + 2)
	{
	  int hardm = get_hard_play(h, spr[h].x-1, spr[h].y);
	  if (hardm == 0)
	    spr[h].x -= 1;
	}


      if (spr[h].seq == spr[h].base_walk + 9)
	{
	  int hardm = get_hard_play(h, spr[h].x+1, spr[h].y);
	  if (hardm == 0)
	    {  
	      spr[h].x += 1;
	      
	    }
	  else
	    {
	      int hardm = get_hard_play(h, spr[h].x+1, spr[h].y+1);
	      if (hardm == 0)
		{  
		  spr[h].x += 1;
		  spr[h].y += 1;
		}
	      else
		{
		  int hardm = get_hard_play(h, spr[h].x+1, spr[h].y+2);
		  if (hardm == 0)
		    {  
		      spr[h].x += 1;
		      spr[h].y += 2;
		    }
		  else
		    {
		      int hardm = get_hard_play(h, spr[h].x, spr[h].y-1);
		      if (hardm == 0)
			{  
			  spr[h].y -= 1;
			  
			}
		      else
			{
			  int hardm = get_hard_play(h, spr[h].x-1, spr[h].y-1);
			  if (hardm == 0)
			    {  
			      spr[h].x -= 1;
			      spr[h].y -= 1;
			    }  
			}
		    }
		}
	    }
	}
      
      if (spr[h].seq == spr[h].base_walk + 7)
	{
	  int hardm = get_hard_play(h, spr[h].x-1, spr[h].y);
	  if (hardm == 0)
	    {  
	      spr[h].x -= 1;
	    }
	  else
	    {
	      int hardm = get_hard_play(h, spr[h].x-1, spr[h].y+1);
	      if (hardm == 0)
		{  
		  spr[h].x -= 1;
		  spr[h].y += 1;
		}
	      else
		{
		  int hardm = get_hard_play(h, spr[h].x-1, spr[h].y+2);
		  if (hardm == 0)
		    {  
		      spr[h].x -= 1;
		      spr[h].y += 2;
		    }
		  else
		    {
		      int hardm = get_hard_play(h, spr[h].x, spr[h].y-1);
		      if (hardm == 0)
			{  				
			  spr[h].y -= 1;
			}
		      else
			{
			  int hardm = get_hard_play(h, spr[h].x+1, spr[h].y-1);
			  if (hardm == 0)
			    {  				
			      spr[h].x += 1;
			      spr[h].y -= 1;
			    }
			}
		    }
		}
	    }
	}
      
      if (spr[h].seq == spr[h].base_walk + 1)
	{
	  int hardm = get_hard_play(h, spr[h].x-1, spr[h].y);
	  if (hardm == 0)
	    {  
	      spr[h].x -= 1;
	    }
	  else
	    {
	      int hardm = get_hard_play(h, spr[h].x-1, spr[h].y-1);
	      if (hardm == 0)
		{  
		  spr[h].x -= 1;
		  spr[h].y -= 1;
		}
	      else
		{
		  int hardm = get_hard_play(h, spr[h].x-1, spr[h].y-2);
		  if (hardm == 0)
		    {  
		      spr[h].x -= 1;
		      spr[h].y -= 2;
		    }
		  else
		    {
		      int hardm = get_hard_play(h, spr[h].x, spr[h].y+1);
		      if (hardm == 0)
			{  
			  spr[h].y += 1;
			}
		      else
			{
			  int hardm = get_hard_play(h, spr[h].x+1, spr[h].y+1);
			  if (hardm == 0)
			    {  
			      spr[h].x += 1;
			      spr[h].y += 1;
			    } 
			}
		    }
		}
	    }
	}
		  
      if (spr[h].seq == spr[h].base_walk + 3)
	{
	  int hardm = get_hard_play(h, spr[h].x+1, spr[h].y);
	  if (hardm == 0)
	    {  
	      spr[h].x += 1;
	    }
	  else
	    {
	      int hardm = get_hard_play(h, spr[h].x+1, spr[h].y-1);
	      if (hardm == 0)
		{  
		  spr[h].x += 1;
		  spr[h].y -= 1;
		}
	      else
		{
		  int hardm = get_hard_play(h, spr[h].x+1, spr[h].y-2);
		  if (hardm == 0)
		    {  
		      spr[h].x += 1;
		      spr[h].y -= 2;
		    }
		  else
		    {
		      int hardm = get_hard_play(h, spr[h].x, spr[h].y+1);
		      if (hardm == 0)
			{  
			  spr[h].y += 1;
			}
		      else
			{
			  int hardm = get_hard_play(h, spr[h].x-1, spr[h].y+1);
			  if (hardm == 0)
			    {  
			      spr[h].x -= 1;
			      spr[h].y += 1;
			    }
			}
		    }
		}
	    }
	}
    }

 smoothend:
  ;
}


/*bool*/int transition()
{
  SDL_Rect src, dst;
  
  //we need to do our fancy screen transition
  int dumb = fps_final * 2;
  
  if (0) //DEBUG
    {
      // Make the transition last ~5 seconds
      if (move_screen == 4 || move_screen == 6)
	dumb = 600 / (fps_final * 5);
      else if (move_screen == 8 || move_screen == 2)
	dumb = 400 / (fps_final * 5);
    }
  
  move_counter += dumb;
  
  
  if (move_screen == 4)
    {
      if (move_counter > 598)
	move_counter = 598;
      
      src.x = 0;
      src.y = 0;
      src.w = 600 - move_counter;
      src.h = 400;
      dst.x = 20 + move_counter;
      dst.y = 0;
      SDL_BlitSurface(GFX_lpDDSTrick, &src, GFX_lpDDSBack, &dst);
      
      src.x = 600 - move_counter;
      src.y = 0;
      src.w = move_counter;
      src.h = 400;
      dst.x = 20;
      dst.y = 0;
      SDL_BlitSurface(GFX_lpDDSTrick2, &src, GFX_lpDDSBack, &dst);
      
      if (move_counter >= 595)
	{
	  total_trigger = /*false*/0;
	  move_screen = 0;
	  move_counter = 0;
	  trig_man = 0;
	  //draw_map();
	  return /*false*/0;
	}
      
      return /*true*/1;
    }

  
  if (move_screen == 6)
    {
      if (move_counter > 598)
	move_counter = 598;
      
      src.x = move_counter;
      src.y = 0;
      src.w = 600 - move_counter;
      src.h = 400;
      dst.x = 20;
      dst.y = 0;
      SDL_BlitSurface(GFX_lpDDSTrick, &src, GFX_lpDDSBack, &dst);
		
      src.x = 0;
      src.y = 0;
      src.w = move_counter;
      src.h = 400;
      dst.x = 620 - move_counter;
      dst.y = 0;
      SDL_BlitSurface(GFX_lpDDSTrick2, &src, GFX_lpDDSBack, &dst);
      
      if (move_counter >= 595)
	{
	  total_trigger = /*false*/0;
	  move_screen = 0;
	  move_counter = 0;
	  trig_man = 0;
	  //draw_map();
	  return /*false*/0;
	}
      
      return /*true*/1;
    }
  

  if (move_screen == 8)
    {
      if (move_counter > 398)
	move_counter = 398;
      
      src.x = 0;
      src.y = 0;
      src.w = 600;
      src.h = 400 - move_counter;
      dst.x = 20;
      dst.y = move_counter;
      SDL_BlitSurface(GFX_lpDDSTrick, &src, GFX_lpDDSBack, &dst);
      
      src.x = 0;
      src.y = 400 - move_counter;
      src.w = 600;
      src.h = move_counter;
      dst.x = 20;
      dst.y = 0;
      SDL_BlitSurface(GFX_lpDDSTrick2, &src, GFX_lpDDSBack, &dst);
      
      if (move_counter >= 398)
	{
	  total_trigger = /*false*/0;
	  move_screen = 0;
	  move_counter = 0;
	  trig_man = 0;
	  //draw_map();
	  return /*false*/0;
	}
      
      return /*true*/1;
    }
  

  if (move_screen == 2)
    {
      if (move_counter > 398)
	move_counter = 398;
      
      src.x = 0;
      src.y = move_counter;
      src.w = 600;
      src.h = 400 - move_counter;
      dst.x = 20;
      dst.y = 0;
      SDL_BlitSurface(GFX_lpDDSTrick, &src, GFX_lpDDSBack, &dst);
      
      src.x = 0;
      src.y = 0;
      src.w = 600;
      src.h = move_counter;
      dst.x = 20;
      dst.y = 400 - move_counter;
      SDL_BlitSurface(GFX_lpDDSTrick2, &src, GFX_lpDDSBack, &dst);
      
      if (move_counter >= 398)
	{
	  total_trigger = /*false*/0;
	  move_screen = 0;
	  move_counter = 0;
	  trig_man = 0;
	  //draw_map();
	  return /*false*/0;
	}
      
      return /*true*/1;
    }
  
  return /*false*/0;
}

	
	int find_sprite(int block)
	{
	  int k;
		for (k = 1; k <= last_sprite_created; k++)
		{
			if (spr[k].sp_index == block)
			{
				return(k);
			}
			
		}
		
		return(0);
		
	}
	
	int special_block(int block, int h)
	{
		
		if (pam.sprite[block].prop == 1)
		{
			//they touched a warp		
			
			if (pam.sprite[block].sound == 0)
				SoundPlayEffect( 7,12000, 0 , 0,0); else
				SoundPlayEffect( pam.sprite[block].sound,22050, 0 , 0,0);
			
			if (pam.sprite[block].parm_seq != 0)
			{
				//we'll also play an animation here
				
				int sprite = find_sprite(block);
				if (sprite > 0)
				{
					spr[sprite].seq = pam.sprite[block].parm_seq;
					process_warp = block;
				}
				return(1);
			}
			process_warp = block;	
			/*spr[1].x = pam.sprite[block].warp_x;
			spr[1].y = pam.sprite[block].warp_y;
			*pmap = pam.sprite[block].warp_map;	
			
			  load_map(map.loc[pam.sprite[block].warp_map]);
			  draw_map();
			*/
			return(1); //redraw screen with fade
		}
		return(0);
	}
	
/* fade_down() - fade to black */
void CyclePalette()
{
  if (!truecolor)
    {
      SDL_Color palette[256];
      int kk;

      memcpy(palette, cur_screen_palette, sizeof(palette));

      for (kk = 1; kk < 256; kk++) /* skipping index 0 because it's
				      already (and always) black ;) */
	{
	  if (dversion >= 108)
	    {
	      /* Use time-based rather than absolute increments;
		 avoids incomplete fades on slow computers */
	      /* dt / 2 == dt * 256 / 512 == complete fade in 512ms */
	      int lValue = (thisTickCount - lastTickCount) / 2;
	      if (palette[kk].b != 0)
		{
		  if (palette[kk].b > lValue)
		    palette[kk].b -= lValue;
		  else
		    palette[kk].b = 0;
		}
	      if (palette[kk].g != 0)
		{
		  if (palette[kk].g > lValue)
		    palette[kk].g -= lValue;
		  else
		    palette[kk].g = 0;
		}
	      if (palette[kk].r != 0)
		{
		  if (palette[kk].r > lValue)
		    palette[kk].r -= lValue;
		  else
		    palette[kk].r = 0;
		}
	    }
	  else
	    {
	      if (palette[kk].b != 0)
		{
		  if (palette[kk].b > 10)
		    palette[kk].b -= 10;
		  else
		    palette[kk].b--;
		}
	      if (palette[kk].g != 0)
		{
		  if (palette[kk].g > 10)
		    palette[kk].g -= 10;
		  else
		    palette[kk].g--;
		}
	      if (palette[kk].r != 0)
		{
		  if (palette[kk].r > 10)
		    palette[kk].r -= 10;
		  else
		    palette[kk].r--;
		}
	    }
	}
  
      change_screen_palette(palette);
    }
  else
    {
      /* truecolor */
      if (truecolor_fade_lasttick == -1)
	{
	  truecolor_fade_lasttick = SDL_GetTicks();
	  //truecolor_fade_brightness -= 256*.3;
	}
      else
	{
	  int delta = SDL_GetTicks() - truecolor_fade_lasttick;
	  /* Complete fade in 400ms */
	  truecolor_fade_lasttick = SDL_GetTicks();
	  truecolor_fade_brightness -= delta * 256 / 400.0;
	}
      if (truecolor_fade_brightness <= 0)
	truecolor_fade_brightness = 0;
      
    }

  if (process_downcycle) 
    {
      if (thisTickCount > cycle_clock)
	{
	  process_downcycle = /*false*/0;
	  truecolor_fade_lasttick = -1;
				
	  if (cycle_script != 0)
	    {
	      int junk = cycle_script;
	      cycle_script = 0;	
	      run_script(junk);
	    }
	}
    }
}
	
/* fade_up() */	
void up_cycle(void)
{
  int donethistime = 1;

  if (!truecolor)
    {
      SDL_Color palette[256];
      int kk;

      memcpy(palette, cur_screen_palette, sizeof(palette));

      for (kk = 1; kk < 256; kk++)
	{
	  int tmp = -1;

	  tmp = palette[kk].b; // 'int' to avoid 'char' overflow
	  if (tmp != GFX_real_pal[kk].b)
	    {
	      donethistime = 0;
	      if (tmp > 246)
		tmp++;
	      else
		tmp += 10;
	    }
	  if (tmp > GFX_real_pal[kk].b)
	    tmp = GFX_real_pal[kk].b;
	  palette[kk].b = tmp;
      
	  tmp = palette[kk].g; // 'int' to avoid 'char' overflow
	  if (tmp != GFX_real_pal[kk].g)
	    {
	      donethistime = 0;
	      if (tmp > 246)
		tmp++;
	      else
		tmp += 10;
	    }
	  if (tmp > GFX_real_pal[kk].g)
	    tmp = GFX_real_pal[kk].g;
	  palette[kk].g = tmp;
      
	  tmp = palette[kk].r; // 'int' to avoid 'char' overflow
	  if (tmp != GFX_real_pal[kk].r)
	    {
	      donethistime = 0;
	      if (tmp > 246)
		tmp++;
	      else
		tmp += 10;
	    }
	  if (tmp > GFX_real_pal[kk].r)
	    tmp = GFX_real_pal[kk].r;
	  palette[kk].r = tmp;
	}
  
      change_screen_palette(palette);
    }
  else
    {
      /* truecolor */
      donethistime = 0;
      if (truecolor_fade_lasttick == -1)
	{
	  truecolor_fade_lasttick = SDL_GetTicks();
	  //truecolor_fade_brightness += 256*.3;
	}
      else
	{
	  int delta = SDL_GetTicks() - truecolor_fade_lasttick;
	  /* Complete fade in 400ms */
	  truecolor_fade_lasttick = SDL_GetTicks();
	  truecolor_fade_brightness += delta * 256 / 400.0;
	}
      if (truecolor_fade_brightness >= 256)
	{
	  truecolor_fade_brightness = 256;
	  donethistime = 1;
	}
    }
		
  if (process_upcycle)
    if (donethistime == 1)
      {
	process_upcycle = 0;
	truecolor_fade_lasttick = -1;
	
	if (cycle_script != 0)
	  {
	    int junk = cycle_script;
	    cycle_script = 0;	
	    run_script(junk);
	  }
      }
}


void draw_box(rect box, int color)
{
/*   DDBLTFX     ddbltfx; */
  
/*   ddbltfx.dwSize = sizeof(ddbltfx); */
/*   ddbltfx.dwFillColor = color; */
  
/*   ddrval = lpDDSBack->Blt(&box ,NULL, NULL, DDBLT_COLORFILL| DDBLT_WAIT, &ddbltfx); */
  // GFX
  {
    SDL_Rect dst;
    dst.x = box.left; dst.y = box.top;
    dst.w = box.right - box.left;
    dst.h = box.bottom - box.top;
    SDL_FillRect(GFX_lpDDSBack, &dst,
		 SDL_MapRGB(GFX_lpDDSBack->format,
			    cur_screen_palette[color].r,
			    cur_screen_palette[color].g,
			    cur_screen_palette[color].b));
  }
}
	
	
	
void flip_it(void)
{
  /* We work directly on either lpDDSBack (no lpDDSPrimary as in
     the original game): the double buffer (Back) is directly
     managed by SDL; SDL_Flip is used to refresh the physical
     screen. */
  if (!truecolor && trigger_palette_change)
    {
      // Apply the logical palette to the physical screen. This
      // may trigger a Flip (so don't do that until Back is
      // ready), but not necessarily (so do a Flip anyway).
      SDL_SetPalette(GFX_lpDDSBack, SDL_PHYSPAL,
		     cur_screen_palette, 0, 256);
      trigger_palette_change = 0;
    }
  if (truecolor_fade_brightness < 256)
    {
      gfx_fade_apply(truecolor_fade_brightness);
    }

  SDL_Flip(GFX_lpDDSBack);
}


/**
 * Check which sprites are affected by an attack from 'h', the
 * attacker.
 */
	void run_through_tag_list(int h, int strength)
	{
		rect box;
		int amount, amounty;
		int i;

		for (i = 1; i <= last_sprite_created; i++)
		{
			if (spr[i].active) if (i != h) if
				(! ( (spr[i].nohit == 1) && (spr[i].script == 0)) )
			{
				
				rect_copy(&box, &k[getpic(i)].hardbox);
				rect_offset(&box, spr[i].x, spr[i].y);
				
				//InflateRect(&box, 10,10);
				
				box.right += 5;
				box.left -= 5;
				box.top -= 5;
				box.bottom += 10;
				if (spr[h].range == 0)		
					amount = 28; else amount = spr[h].range;
				
				if (spr[h].range == 0)		
					
					amounty = 36; else amounty = (spr[h].range + (spr[h].range / 6));
				
				int range_amount = spr[h].range / 8;
				
				if (spr[h].dir == 6)
				{
					box.top -= 10;
					box.bottom += 10;
					if (spr[h].range != 0) box.top -= range_amount;
					if (spr[h].range != 0) box.bottom += range_amount;
					
					
					box.left -= amount;
				}
				
				if (spr[h].dir == 4)
				{
					box.right += amount;
					
					box.top -= 10;
					box.bottom += 10;
					if (spr[h].range != 0) box.top -= range_amount;
					if (spr[h].range != 0) box.bottom += range_amount;
					
				}
				
				
				if (spr[h].dir == 2)
				{
					box.right += 10;
					box.left -= 10;
					box.top -= amounty;
					
					if (spr[h].range != 0) box.right += range_amount;
					if (spr[h].range != 0) box.left -= range_amount;
					
				}
				
				if (spr[h].dir == 8)
				{
					box.right += 10;
					box.left -= 10;
					box.bottom += amounty;
					
					if (spr[h].range != 0) box.right += range_amount;
					if (spr[h].range != 0) box.right -= range_amount;
					
				}
				
				if (debug_mode) draw_box(box, 33);
				
				if (inside_box(spr[h].x, spr[h].y, box))
				{	
					// addition for fixing missle_source problems
					if (dversion >= 108)
					  *pmissle_source = h;

					if (spr[i].nohit == 1)
					{
						if (spr[i].script > 0)
						{
							//if (  (spr[i].brain == 0) | (spr[i].brain == 5) | (spr[i].brain == 6) | (spr[i].brain == 7))
							*penemy_sprite = h;
							
							if (  (spr[i].base_attack != -1) || (spr[i].touch_damage > 0))
								spr[i].target = h;   
							
							if (locate(spr[i].script, "HIT"))
							{
								kill_returning_stuff(spr[i].script);
								run_script(spr[i].script);
							}
							
							
						}
						
						
					} else
					{
						//hit this personb/thing
						if (spr[h].attack_hit_sound == 0)
						{
							SoundPlayEffect( 9,22050, 0 ,0,0);
						} else
						{
							SoundPlayEffect( spr[h].attack_hit_sound,spr[h].attack_hit_sound_speed, 0 ,0,0);
						}
						if (  (spr[i].base_attack != -1) || (spr[i].touch_damage > 0))
							spr[i].target = h;   
						if (spr[h].strength == 0)
						{
							
						} else
						{
							if (  (spr[i].hitpoints > 0) || (i == 1) )
							{
								
								spr[i].last_hit = h; 
								if ( hurt_thing(i, (spr[h].strength / 2) + ((rand() % ((spr[h].strength+1) / 2))+1), 0) > 0)
									random_blood(spr[i].x, spr[i].y-40, i);
							}
							
						}
						if (spr[i].script > 0)
						{
							//if (  (spr[i].brain == 0) | (spr[i].brain == 5) | (spr[i].brain == 6) | (spr[i].brain == 7))
							spr[i].last_hit = h;    
							*penemy_sprite = h;
							if (  (spr[i].base_attack != -1) || (spr[i].touch_damage > 0))
								spr[i].target = h;   
							
							if (locate(spr[i].script, "HIT"))
							{
								kill_returning_stuff(spr[i].script);
								run_script(spr[i].script);
							}
							
						}
						
					}
					
				}
				
		}
		
	}
	
}



void run_through_tag_list_push(int h)
{
	rect box;
	int i;

	for (i = 1; i <= last_sprite_created; i++)
	{
		if (spr[i].active) if (i != h) if
			((spr[i].script != 0) )
		{
			
			rect_copy(&box, &k[getpic(i)].hardbox);
			rect_offset(&box, spr[i].x, spr[i].y);
			
			//InflateRect(&box, 10,10);
			
			box.right += 2;
			box.left -= 2;
			box.top -= 2;
			box.bottom += 2;
			//draw_box(box, 33);
			
			if (inside_box(spr[h].x, spr[h].y, box))
			{	
				if (locate(spr[i].script, "PUSH")) run_script(spr[i].script);
			}
			
		}
		
	}
	
}




void run_through_touch_damage_list(int h)
{
	rect box;
	int i;

	for (i = 1; i <= last_sprite_created; i++)
	{
		if (spr[i].active) if (i != h) if
			((spr[i].touch_damage != 0) )
		{
			
			if (spr[i].touch_damage != -1) if (spr[h].notouch) return;
			rect_copy(&box, &k[getpic(i)].hardbox);
			rect_offset(&box, spr[i].x, spr[i].y);
			
			//InflateRect(&box, 10,10);
			
			box.right += 2;
			box.left -= 2;
			box.top -= 2;
			box.bottom += 2;
			if (debug_mode)		
				draw_box(box, 33);
			
			
			if (inside_box(spr[h].x, spr[h].y, box))
			{	
				
				if ((spr[i].touch_damage == -1) && (spr[i].script != 0))
				{
					if (locate(spr[i].script, "TOUCH")) run_script(spr[i].script);
				} else
				{
					if (spr[i].touch_damage == -1)
					{
						Msg("Sprites touch damage is set to -1 but there is no script set!");
					} else
					{
						//lets hurt the guy
						
						spr[h].notouch = /*true*/1;
						spr[h].notouch_timer = thisTickCount+400;
						spr[h].last_hit = i;
						if (spr[i].script != 0)
							if (locate(spr[i].script, "TOUCH")) run_script(spr[i].script);
							if (hurt_thing(h, spr[i].touch_damage, 0) > 0)
								random_blood(spr[h].x, spr[h].y-40, h);
							
							
					}
					
				}
				
				
				
			}
			
			
		}
		
	}
	
}




void process_warp_man(void)
{
  int sprite = find_sprite(process_warp);
  
  if (spr[sprite].seq == 0)
    {
      process_count++;
      CyclePalette();
      /* Wait 5 CyclePalette before blanking the screen and
	 warp. Truecolor more: the fade algorithm is a bit different
	 and requires a few more cycles to get the same effect; unlike
	 v1.08, we don't wait for a full fadedown, which is long and
	 can be not very smooth on old computers. */
      if ((!truecolor && process_count > 5)
	  || (truecolor && truecolor_fade_brightness <= 180))
	{
	  SDL_FillRect(GFX_lpDDSBack, NULL,
		       SDL_MapRGB(GFX_lpDDSBack->format, 0, 0, 0));
	  flip_it();
	  
	  process_count = 0;
	  int block = process_warp;
	  update_screen_time();
	  spr[1].x = pam.sprite[block].warp_x;
	  spr[1].y = pam.sprite[block].warp_y;
	  *pmap = pam.sprite[block].warp_map;	

	  // update map indicator
	  if (map.indoor[pam.sprite[block].warp_map] == 0)
	    play.last_map = pam.sprite[block].warp_map;
	  
	  load_map(map.loc[pam.sprite[block].warp_map]);
	  draw_map_game();
	  *pmap=34;	  
	  process_upcycle = 1;
	  process_warp = 0;
	}
    }
  else
    {
      process_count = 0;		
    }
}

void one_time_brain(int h)
{
	
	//goes once then draws last frame to background
	
	if (spr[h].move_active) 
	{
		process_move(h);
		return;
	}
	
	if (spr[h].follow > 0)
	{
		process_follow(h);
	}
	
	
	if (spr[h].seq == 0)
	{
	  draw_sprite_game(GFX_lpDDSTwo, h);
		spr[h].active = /*false*/0;			
		return;
	}
	
	changedir(spr[h].dir,h,-1);
	automove(h);
	
}

void one_time_brain_for_real(int h)
{
	
	if (spr[h].move_active) 
	{
		process_move(h);
	}
	
	
	if (spr[h].follow > 0)
	{
		process_follow(h);
	}
	
	
	if (spr[h].seq == 0)
	{
		
		spr[h].active = /*false*/0;			
		return;
	}
	if (spr[h].dir > 0)
	{
		changedir(spr[h].dir,h,-1);
		automove(h);
	}
}


void scale_brain(int h)
{
	
	if (spr[h].size == spr[h].brain_parm)
	{
		spr[h].active = /*false*/0;
		
		
		return;
	}
	
	int num = 5 * (base_timing / 4);
	
	
	
	if (spr[h].size > spr[h].brain_parm)
	{
		if (spr[h].size - num < spr[h].brain_parm) num = spr[h].size - spr[h].brain_parm;
		spr[h].size -= num;
	}
	
	if (spr[h].size < spr[h].brain_parm) 
	{
		if (spr[h].size + num > spr[h].brain_parm) num = spr[h].brain_parm - spr[h].size;   
		spr[h].size += num;
	}
	if (spr[h].move_active) 
	{
		process_move(h);
		return;
	}
	
	
	
	if (spr[h].dir > 0)
	{
		changedir(spr[h].dir,h,-1);
		automove(h);
	}
	
	
}



void repeat_brain(int h)
{
	
	if (spr[h].move_active) 
	{
		process_move(h);
		//		return;
	}
	
	
	if (spr[h].seq_orig == 0) if (spr[h].sp_index != 0) 
	{
		spr[h].seq_orig = pam.sprite[spr[h].sp_index].seq;
		spr[h].frame = pam.sprite[spr[h].sp_index].frame;
		spr[h].wait = 0;
		
		//pam.sprite[spr[h].sp_index].frame;
		
	}
	   
	   if (spr[h].seq == 0) spr[h].seq = spr[h].seq_orig;
	   
}


void text_brain(int h)
{
	
	
	
	if (  (spr[h].damage == -1) && (spr[h].owner != 1000))
	{
		
		if (spr[spr[h].owner].active == /*false*/0)
		{
			//msg("Killing text brain %d, because owner %d is dead.",h, spr[h].owner);
			spr[h].active = /*false*/0;
			return;
		}
		
		//give this text the cords from it's owner sprite
		spr[h].x = spr[spr[h].owner].x - spr[h].strength;
		
		
		spr[h].y = spr[spr[h].owner].y - spr[h].defense;
		
		if (spr[h].x < 1) spr[h].x = 1;
		
		if (spr[h].y < 1) spr[h].y = 1;
		
		
	} else
	{
		//Msg("automoving %d.. ", h);
		
		if (spr[h].move_active) 
		{
			process_move(h);
			return;
		}
		
		
		automove(h);
	}
	
}


void process_talk()
{
  int px = 48, py = 44;
  
  int sx = 184;
  int sy = 94, sy_hold, sy_ho;
/*   int spacing = 12; */
  int curxl = 126;
  int curxr = 462;
  int curyr = 200;
  int curyl = 200;
  
  int y_last = 0, y_hold = 0, y_ho; 
/*   HDC         hdc; */
  rect rcRect;
  int i;
  int x_depth = 335;
  if (talk.newy != -5000)
    sy = talk.newy;
  
  sy_hold = sy;
  sy_ho = sy;
  
  check_seq_status(30);
  
  int fake_page;
/*  again: */
/*   ddrval = lpDDSBack->BltFast( px, py, k[seq[30].frame[2]].k, */
/* 			       &k[seq[30].frame[2]].box  , DDBLTFAST_SRCCOLORKEY  ); */
/*   if (ddrval == DDERR_WASSTILLDRAWING) goto again; */
  // GFX
  {
    SDL_Rect dst;
    dst.x = px; dst.y = py;
    SDL_BlitSurface(GFX_k[seq[30].frame[2]].k, NULL, GFX_lpDDSBack, &dst);
  }
  
/*  again2:	 */
/*   ddrval = lpDDSBack->BltFast( px+169, py+42, k[seq[30].frame[3]].k, */
/* 			       &k[seq[30].frame[3]].box  , DDBLTFAST_SRCCOLORKEY  ); */
/*   if (ddrval == DDERR_WASSTILLDRAWING) goto again2; */
  // GFX
  {
    SDL_Rect dst;
    dst.x = px + 169; dst.y = py + 42;
    SDL_BlitSurface(GFX_k[seq[30].frame[3]].k, NULL, GFX_lpDDSBack, &dst);
  }
  
/*  again3: */
/*   ddrval = lpDDSBack->BltFast( px+169+180, py+1, k[seq[30].frame[4]].k, */
/* 			       &k[seq[30].frame[4]].box  , DDBLTFAST_SRCCOLORKEY  ); */
/*   if (ddrval == DDERR_WASSTILLDRAWING) goto again3; */
  // GFX
  {
    SDL_Rect dst;
    dst.x = px+169+180; dst.y = py+1;
    if (SDL_BlitSurface(GFX_k[seq[30].frame[4]].k, NULL, GFX_lpDDSBack, &dst) < 0)
      fprintf(stderr, "Could not draw sprite %d: %s\n", seq[30].frame[4], SDL_GetError());
  }
  
  
  int talk_hold = talk.cur;
  if (sjoy.rightd) talk.cur++;
  if (sjoy.downd) talk.cur++;
  if (sjoy.upd) talk.cur--;
  if (sjoy.leftd) talk.cur--;
  
  if (play.mouse > 20)
    {
      talk.cur++;
      play.mouse = 0;
    }
  
  if (play.mouse < -20)
    {
      talk.cur--;
      play.mouse = 0;
    }
  
  
  if (talk_hold != talk.cur)
    {
      if (talk.cur >= talk.cur_view)
	if (talk.cur <= talk.cur_view_end) 
	  SoundPlayEffect(11, 22050,0,0,0);
    }
  
/*   if (lpDDSBack->GetDC(&hdc) == DD_OK) */
/*     {       */
      
/*       SelectObject (hdc, hfont_small); */
      // FONTS
      //FONTS_SetFont(FONTS_hfont_small);
/*       SetBkMode(hdc, TRANSPARENT);  */
      
      
      
      /* Print dialog title, if any */
      if (strlen(talk.buffer) > 0)
	{
	  rect_set(&rcRect, sx, 94, 463, 400);
	  /* if using an explicit "set_y" after "choice_start()": */
	  if (talk.newy != -5000)
	    rcRect.bottom = talk.newy + 15;
	  
/* 	  SetTextColor(hdc,RGB(8,14,21)); */
	  // FONTS
	  FONTS_SetTextColor(8, 14, 21);
/* 	  DrawText(hdc,talk.buffer,strlen(talk.buffer),&rcRect,DT_VCENTER | DT_CENTER | DT_WORDBREAK); */
	  // FONTS
	  //printf("(%dx%d)x(%dx%d)\n", rcRect.left, rcRect.top, rcRect.right, rcRect.bottom);
	  print_text_wrap(talk.buffer, &rcRect, 1, 0, FONT_DIALOG);


	   /* Same of in text_draw, except for #1 and default */
	   // FONTS:
	   // support for custom colors
	   if (talk.color >= 1 && talk.color <= 15)
	     FONTS_SetTextColorIndex(talk.color);
	   else
	     {
	       if (dversion >= 108)
		 FONTS_SetTextColor(255, 255, 255);
	       else
		 FONTS_SetTextColor(255, 255, 2);
	    }

	  rect_offset(&rcRect, 1, 1);
/* 	  DrawText(hdc,talk.buffer,strlen(talk.buffer),&rcRect,DT_VCENTER | DT_CENTER | DT_WORDBREAK);	 */
	  // FONTS
	  print_text_wrap(talk.buffer, &rcRect, 1, 0, FONT_DIALOG);

/* 	  SetTextColor(hdc,RGB(8,14,21)); */
	  // FONTS
	  FONTS_SetTextColor(8, 14, 21);
	}
      
      
		
      
      //tabulate distance needed by text, LORDII experience helped here
      //recal: 
      for (i = talk.cur_view; i < talk.last; i++)
	{
	  rect_set(&rcRect,sx,y_hold,463,x_depth+100);
/* 	  y_hold = DrawText(hdc,talk.line[i],lstrlen(talk.line[i]),&rcRect,DT_CALCRECT | DT_CENTER | DT_WORDBREAK); */
	  // FONTS
	  /* Don't print, only check the height in pixel: */
	  y_hold = print_text_wrap(talk.line[i], &rcRect, 1, 1, FONT_DIALOG);
	  sy_hold += y_hold;
	  
	  //Msg("Sy_hold = %d (%d)", sy_hold,i);
	  
	  if (sy_hold > x_depth) 
	    {
	      
	      talk.cur_view_end = i-1;
	      //Msg("Sy is over, sp cur_view is %d ", talk.cur_view_end);
	      goto death;
	    }
	}
      
      talk.cur_view_end = i;
      
      if (talk.cur_view == 1 && talk.cur_view_end == talk.last)
	{
	  //Msg("Small enough to fit on one screen, lets center it!");
	  sy += ( (x_depth - sy_hold) / 2) - 20;
	}
    death:
      if (talk.cur > talk.last) 
	{
	  SoundPlayEffect(11, 22050,0,0,0);
	  
	  talk.cur = 1;
	  
	}
      if (talk.cur < 1) 
	{
	  SoundPlayEffect(11, 22050,0,0,0);
	  
	  talk.cur = talk.last;
	}
      
      
      //if (talk.cur_view_end != talk.last)
      {
	//Msg("Talkcur is %d, talk cur view is %d", talk.cur, talk.cur_view);
	//total options too large for page, lets scroll
	
	
	if (talk.cur > talk.cur_view_end) 
	  {
	    //     Msg("advancing page:  talkcur is %d, changing cur_view to same", talk.cur, talk.cur_view);
	    talk.cur_view = talk.cur;
	    talk.page ++;
	    
	    // Msg("Page advanced to %d. (cur_end is %d, cur is %d)", talk.page,talk.cur_view_end, talk.cur);
	    goto fin;
	  }
	
	
	
	if (talk.cur < talk.cur_view) 
	  {
	    //	Msg("Turning back the clock from page %d..", talk.page);
	    
	    talk.cur_view = 1;
	    // talk.cur = 1;
	    
	    talk.page--;
	    Msg("Page backed to %d.", talk.page);
	    fake_page = 1;
	    for (i = 1; i < talk.last; i++)
	      {
		rect_set(&rcRect,sx,sy_ho,463,x_depth);
		
/* 		y_ho = DrawText(hdc,talk.line[i],lstrlen(talk.line[i]),&rcRect,DT_CALCRECT | DT_CENTER | DT_WORDBREAK); */
		// FONTS
		/* Don't print, only check the height in pixel: */
		y_ho = print_text_wrap(talk.line[i], &rcRect, 1, 1, FONT_DIALOG);
		sy_ho += y_ho;	 
		//Msg("adding y_yo %d.. (on %d)", y_ho,i);
		if (sy_ho > x_depth) 
		  {
		    /*if (fake_page == talk.page)
		      {
		      goto fin;
		      }
		    */
		    fake_page++;	  
		    sy_ho = sy+ y_ho;
		    //Msg("Does fake page (%d) match desired page (%d) %d", fake_page, talk.page, i);
		  }
		if (fake_page == talk.page)
		  {
		    talk.cur_view = i;
		    talk.cur_view_end = talk.cur;
		    //Msg("Going to fin with end being %d, and.cur being %d.  View is %d.",
		    //		   talk.cur_view_end, talk.cur, talk.cur_view);
		    goto fin;
		  }
		
		//         Msg("Second: Sy is over, sp cur_view is %d", talk.cur_view_end);
	      }
	    talk.cur_view_end = i;
	  }
      }
      
      //Msg("talk last is %d.  cur_view_end is %d, Cur is %d", talk.last, talk.cur_view_end, talk.cur);
      
      //	 talk.cur_view_end = talk.last;
      
      for ( i = talk.cur_view; i <= talk.cur_view_end; i++)
	{
	  //lets figure out where to draw this line
	  
	  rect_set(&rcRect, sx, sy, 463, x_depth + 100);
/* 	  SetTextColor(hdc,RGB(8,14,21)); */
	  // FONTS
	  FONTS_SetTextColor(8, 14, 21);
/* 	  DrawText(hdc,talk.line[i],lstrlen(talk.line[i]),&rcRect, DT_CENTER | DT_WORDBREAK); */
	  // FONTS
	  print_text_wrap(talk.line[i], &rcRect, 1, 0, FONT_DIALOG);
	  rect_offset(&rcRect, -2, -2);
/* 	  DrawText(hdc,talk.line[i],lstrlen(talk.line[i]),&rcRect,DT_CENTER | DT_WORDBREAK); */
	  // FONTS
	  print_text_wrap(talk.line[i], &rcRect, 1, 0, FONT_DIALOG);

	  rect_offset(&rcRect, 1, 1);
	  if (i == talk.cur)
	    {
	      curyl = sy-4;
	      curyr = sy-4;
	      
/* 	      SetTextColor(hdc,RGB(255,255,255)); */
	      // FONTS
	      FONTS_SetTextColor(255, 255, 255);
	    }
	  else
	    {
/* 	      SetTextColor(hdc,RGB(255,255,2)); */
	      // FONTS
	      FONTS_SetTextColor(255, 255, 2);
	    }
/* 	  y_last = DrawText(hdc,talk.line[i],lstrlen(talk.line[i]),&rcRect,DT_CENTER | DT_WORDBREAK); */
	  // FONTS
	  y_last = print_text_wrap(talk.line[i], &rcRect, 1, 0, FONT_DIALOG);
	  sy += y_last;
	}
      
    fin:
      //	   dum =  GetTextFace(hdc,100,shit) ;
/*       lpDDSBack->ReleaseDC(hdc); */
      
      if (talk.timer < thisTickCount)
	{	
	  talk.curf++;
	  talk.timer = thisTickCount+100;
	}
      
      
      if (talk.curf == 0) talk.curf = 1;
      
      if (talk.curf > 7) talk.curf = 1;
/*     again4: */
/*       ddrval = lpDDSBack->BltFast( curxl, curyl, k[seq[456].frame[talk.curf]].k, */
/* 				   &k[seq[456].frame[talk.curf]].box  , DDBLTFAST_SRCCOLORKEY  ); */
/*       if (ddrval == DDERR_WASSTILLDRAWING) goto again4; */
      // GFX
      {
	SDL_Rect dst;
	dst.x = curxl; dst.y = curyl;
	SDL_BlitSurface(GFX_k[seq[456].frame[talk.curf]].k, NULL, GFX_lpDDSBack, &dst);
      }
      
/*     again5: */
/*       ddrval = lpDDSBack->BltFast( curxr, curyr, k[seq[457].frame[talk.curf]].k, */
/* 				   &k[seq[456].frame[talk.curf]].box  , DDBLTFAST_SRCCOLORKEY  ); */
/*       if (ddrval == DDERR_WASSTILLDRAWING) goto again5; */
      // GFX
      {
	SDL_Rect dst;
	dst.x = curxr; dst.y = curyr;
	SDL_BlitSurface(GFX_k[seq[457].frame[talk.curf]].k, NULL, GFX_lpDDSBack, &dst);
      }
/*   } */
  
  
  if ((sjoy.button[1]) | (mouse1))
    {
      mouse1 = /*false*/0;
      talk.active = /*false*/0;
      *presult = talk.line_return[talk.cur];
      SoundPlayEffect(17, 22050,0,0,0);
      
      if (talk.script != 0) 
	{ 
	  //we need to continue a script
	  run_script(talk.script);
	  
	}
    }
}


void UpdateCursorPosition(int dx, int dy)
{
	
/*
*  Pick up any leftover fuzz from last time.  This is important
*  when scaling down mouse motions.  Otherwise, the user can
*  drag to the right extremely slow for the length of the table
*  and not get anywhere.
	*/
	if (spr[1].active) if (spr[1].brain == 13)
	{
		spr[1].x += dx;
		spr[1].y += dy;
		/* Clip the cursor to our client area */
		
		if (spr[1].x > 640) spr[1].x = 640; /* TODO: -1? */
		if (spr[1].y > 480) spr[1].y = 480; /* TODO: -1? */
		if (spr[1].x < 0) spr[1].x = 0;
		if (spr[1].y < 0) spr[1].y = 0;
	}
	/* Text choice selection (e.g. "Load game" in the title
	   screen) */
	if (mode == 1) 
	{
	  play.mouse += dy;
	  //Msg("play mousey is now %d", play.mouse);
	}

	/* Try to get the mouse (and the focus) within the window,
	   not 100% safe but good enough */
	SDL_WarpMouse(320, 240);
	/* Ignore the mouse event generated by SDL_WarpMouse: */
	SDL_PumpEvents();
	SDL_GetRelativeMouseState(NULL, NULL);
	/* Alternatively, we can do this all the time, even when dx
	   and dy are zero, and the mouse will always return to the
	   application. We'd need to avoid that when the application
	   is backgrounded though, otherwise FreeDink will keep
	   warping the mouse. */
}


void Scrawl_OnMouseInput(void)
{
  SDL_Event event;
  int dx, dy;

  mouse1 = /*false*/0;

  SDL_PumpEvents();
  SDL_GetRelativeMouseState(&dx, &dy);
  /* Only call if there's mouse activity (original game behavior).
     However, we don't process mouse moves through events, because we
     use SDL_WarpMouse and this generates spurious events, which we
     then need to filter out - better simply check if dx and dy are
     not zero. */
  if (dx != 0 || dy != 0)
    UpdateCursorPosition(dx, dy);

  /* Process stacked clicks */
  while (SDL_PeepEvents(&event, 1, SDL_GETEVENT,
			SDL_EVENTMASK(SDL_MOUSEBUTTONDOWN)) > 0)
    {
      SDL_MouseButtonEvent *button_event = (SDL_MouseButtonEvent*)&event;
      if (button_event->button == SDL_BUTTON_LEFT)
	mouse1 = /*true*/1;
    }
  return;

/* 	mouse1 = false; */
	
/* 	BOOL fDone = 0; */
	
/*     while (!fDone) { */
		
/* 		DIDEVICEOBJECTDATA od; */
		
/*         DWORD dwElements = 1; */
		
/*         HRESULT hr = g_pMouse->GetDeviceData( */
/* 			sizeof(DIDEVICEOBJECTDATA), &od, */
/* 			&dwElements, 0); */
		
/*         if (hr == DIERR_INPUTLOST) { */
/* 		/\* */
/* 		*  We had acquisition, but lost it.  Try to reacquire it. */
/* 		* */
/* 		*  WARNING!  DO NOT ATTEMPT TO REACQUIRE IF YOU GET */
/* 		*  DIERR_NOTACQUIRED!  Otherwise, you're extremely likely */
/* 		*  to get caught in an infinite loop:  The acquire will fail, */
/* 		*  and you'll get another DIERR_NOTACQUIRED so you'll */
/* 		*  try to aquire again, and that'll fail, etc. */
/* 			*\/ */
/*             //PostMessage(hwnd, WM_SYNCACQUIRE, 0, 0L); */
/* 			//   break; */
			
/* 			g_pMouse->Acquire(); */
			
/* 		} */
		
/*         /\* Unable to read data or no data available *\/ */
/*         if (FAILED(hr) || dwElements == 0) { */
/* 			// Msg("No mouse data there."); */
/* 			break; */
/*         } */
		
/*         /\* Look at the element to see what happened *\/ */
		
/* /\* Rewritten slightly differently to make it compile with recent versions of g++ *\/ */
/* /\*        switch (od.dwOfs) { */
			
/* 			// DIMOFS_X: Mouse horizontal motion */
/*       case DIMOFS_X: UpdateCursorPosition(od.dwData, 0); break; */
			
			
/* 			// DIMOFS_Y: Mouse vertical motion */
/*       case DIMOFS_Y: UpdateCursorPosition(0, od.dwData); break; */
			
/* 		case DIDFT_BUTTON: if (od.dwData > 0) mouse1 = true; break; */
			
/*         } */
/* *\/ */
/* 		if (od.dwOfs == DIMOFS_X) */
/* 		{ */
/* 			/\* DIMOFS_X: Mouse horizontal motion *\/ */
/* 			UpdateCursorPosition(od.dwData, 0); */
/* 		} */
/* 		else if (od.dwOfs == DIMOFS_Y) */
/* 		{ */
/* 			/\* DIMOFS_Y: Mouse vertical motion *\/ */
/* 			UpdateCursorPosition(0, od.dwData); */
/* 		} */
/* 		else if (od.dwOfs == DIDFT_BUTTON) */
/* 		{ */
/* 			if (od.dwData > 0) mouse1 = true; */
/* 		} */

/*     } */
	
}

void button_brain(int h )
{
	rect box;
	if (spr[h].move_active) 
	{
		process_move(h);
		return;
	}
	
	
	if (spr[h].script == 0) return;
	
	rect_copy(&box, &k[getpic(h)].hardbox);
	rect_offset(&box, spr[h].x, spr[h].y);
	
	if (spr[h].brain_parm == 0)
	{
		if (inside_box(spr[1].x, spr[1].y, box))
		{	
			spr[h].brain_parm = 1;
			
			if (locate(spr[h].script, "BUTTONON")) 
			{
				run_script(spr[h].script);
				
				return;
			}
			
		}
		
	}
	else
	{
		if (!inside_box(spr[1].x, spr[1].y, box))
		{	
			spr[h].brain_parm = 0;
			
			if (locate(spr[h].script, "BUTTONOFF")) 
			{
				
				run_script(spr[h].script);
				return;
			}
			
		}
		
	}
	
	
}

void draw_item(int num, /*bool*/int magic, int mseq, int mframe)
{
	int mx = 20;
	int my = 0;
	int vert = 0;
	if (magic == /*false*/0)
	{
		mx = 260;
		my = 83;
		
		vert = ((num-1) / 4);
		mx += (((num-1) - (vert * 4)) * (18 + 65));
		my += (vert * (20 + 55));
	} else
	{
		mx = 45;
		my = 83;
		
		vert = ((num-1) / 2);
		mx += (((num-1) - (vert * 2)) * (18 + 65));
		my += (vert * (20 + 55));
		
		
	}
	
/* again: */
	
	check_seq_status(mseq);
	
	if (GFX_k[seq[mseq].frame[mframe]].k == NULL) 
	{
		
		if (!magic)
		{
			Msg("Whups, item %d seq %d frame %d not loaded, killed it",
				num, mseq, mframe);
			play.item[num].active = /*false*/0;
		} else
		{
			Msg("Whups, magic %d seq %d frame %d not loaded, killed it",
				num, mseq, mframe);
			play.mitem[num].active = /*false*/0;
			
		}
		
		return;
	}
	
/* 	ddrval = lpDDSBack->BltFast( mx, my, k[seq[mseq].frame[mframe]].k, */
/* 		&k[seq[mseq].frame[mframe]].box, DDBLTFAST_SRCCOLORKEY); */
/* 	if( ddrval == DDERR_WASSTILLDRAWING ) goto again; */
	// GFX
	{
	  SDL_Rect dst;
	  dst.x = mx; dst.y = my;
	  SDL_BlitSurface(GFX_k[seq[mseq].frame[mframe]].k, NULL, GFX_lpDDSBack, &dst);
	}
}

/* Draw screen when browsing the inventory */
void process_item( void )
{
/*     RECT                rcRect; */
/*     rcRect.left = 0; */
/*     rcRect.top = 0; */
/*     /\* x and y are the size of the screen *\/ */
/*     rcRect.right = x; */
/*     rcRect.bottom = y; */
	int hor, virt;
	
	
	
/* 	while( 1 ) */
/* 	{ */
/* 		ddrval = lpDDSBack->BltFast( 0, 0, lpDDSTwo, */
/* 			&rcRect, DDBLTFAST_NOCOLORKEY); */
		// GFX
		SDL_BlitSurface(GFX_lpDDSTwo, NULL, GFX_lpDDSBack, NULL);

/* 		if( ddrval == DD_OK ) */
/* 		{ */
/* 			break; */
/* 		} */
/* 		if( ddrval == DDERR_SURFACELOST ) */
/* 		{ */
/* 			ddrval = restoreAll(); */
/* 			break; */
/* 		} */
/* 		if( ddrval != DDERR_WASSTILLDRAWING ) */
/* 		{ */
/* 			dderror(ddrval); */
/* 			return; */
/* 		} */
/* 	} */
	
	
	check_seq_status(423);
	//lets blit the main screen over it
/* again:	 */
/* 	ddrval = lpDDSBack->BltFast( 20, 0, k[seq[423].frame[1]].k, */
/* 		&k[seq[423].frame[1]].box, DDBLTFAST_SRCCOLORKEY); */
/* 	if( ddrval == DDERR_WASSTILLDRAWING ) */
/* 	  goto again; */
	// GFX
	{
	  SDL_Rect dst = {20, 0};
	  SDL_BlitSurface(GFX_k[seq[423].frame[1]].k, NULL, GFX_lpDDSBack, &dst);
	}

	//draw all currently owned items; magic
	int i;
	for (i = 1; i < 9; i++)
	  if (play.mitem[i].active)
	    draw_item(i, /*true*/1, play.mitem[i].seq, play.mitem[i].frame);
	
	//draw all currently owned items; normal
	for (i = 1; i < 17; i++)
	  if (play.item[i].active)
	    draw_item(i, /*false*/0, play.item[i].seq, play.item[i].frame);
	
	//draw selection box around armed weapon
	if (*pcur_weapon != 0) if (play.item[*pcur_weapon].active)
		draw_item(*pcur_weapon, /*false*/0, 423, 4);
	
	
	//draw selection box around armed magic
	if (*pcur_magic != 0) if (play.item[*pcur_magic].active)
		draw_item(*pcur_magic, /*true*/1, 423, 5);
	
	
	//draw the selector around it, alternating from 2 to 3
	if (play.curitem < 1) play.curitem = 1;
	
	
	if (thisTickCount > item_timer)
	{
		if (item_pic == 2) item_pic = 3; else item_pic = 2;
		item_timer = thisTickCount + 400;
		
	}
	draw_item(play.curitem, play.item_magic, 423, item_pic);
	
	
	
	
	if (!play.item_magic)
	{
		hor = (play.curitem - (((play.curitem-1) / 4) * 4));
		virt = ((play.curitem-1) / 4);
		
		
		
		//choosing weapon/item
		
		if (sjoy.button[1])
		{
			if (play.item[play.curitem].active)
			{
				//arm weapon
				SoundPlayEffect(18, 42050,0,0,0);        
				if (*pcur_weapon != 0)
				{
					//disarm old weapon
					if (locate(weapon_script, "DISARM")) run_script(weapon_script);
				}
				//load weapons script
				*pcur_weapon = play.curitem;
				weapon_script = load_script(play.item[*pcur_weapon].name, 1000, /*false*/0);
				if (locate(weapon_script, "ARM")) run_script(weapon_script);
				if (locate(weapon_script, "ARMMOVIE")) run_script(weapon_script);
				
				draw_status_all();
			} else
			{
				//can't arm nothing, play sound
			}
		} else
			if (sjoy.rightd) 
			{
				if (hor < 4) play.curitem++;
				SoundPlayEffect(11, 22050,0,0,0);	
			} else
				if (sjoy.leftd) 
				{
					if (hor > 1)
					{
						play.curitem--; 
						SoundPlayEffect(11, 22050,0,0,0);	
						
					}
					else
					{
						SoundPlayEffect(11, 22050,0,0,0);	
						
						play.item_magic = /*true*/1;
						play.curitem = (virt * 2) + 2;
						//switch to magic mode
					}
				} else
					
					
					if (sjoy.downd)
					{
						if (virt < 3)
						{
							play.curitem += 4;
							SoundPlayEffect(11, 22050,0,0,0);	
							
						}
					} else
						
						if (sjoy.upd)
						{
							if (virt > 0)
							{
								play.curitem -= 4;
								SoundPlayEffect(11, 22050,0,0,0);	
								
							}
						}
						
						
	} else
		
	{
		hor = (play.curitem - (((play.curitem-1) / 2) * 2));
		virt = ((play.curitem-1) / 2);
		
		if (sjoy.button[1])
		{
			if (play.mitem[play.curitem].active)
			{
				//arm magic
				SoundPlayEffect(18, 42050,0,0,0);  
				if (*pcur_magic != 0)
				{
					//disarm old weapon
					if (locate(magic_script, "DISARM")) run_script(magic_script);
				}
				//load magics script
				*pcur_magic = play.curitem;
				magic_script = load_script(play.mitem[*pcur_magic].name, 1000, /*false*/0);
				if (locate(magic_script, "ARM")) run_script(magic_script);
				if (locate(magic_script, "ARMMOVIE")) run_script(magic_script);
				draw_status_all();
			} else
			{
				//can't arm nothing, play sound
			}
		}
		
		if (sjoy.rightd) 
		{
			if (hor < 2)
			{
				play.curitem++;
				SoundPlayEffect(11, 22050,0,0,0);	
				
			}
			else
			{ 
				play.item_magic = /*false*/0;
				play.curitem = (virt * 4) +1;
				SoundPlayEffect(11, 22050,0,0,0);	
				
			}
		} else
			if (sjoy.leftd) 
			{
				if (hor > 1)
				{
					play.curitem--;
					SoundPlayEffect(11, 22050,0,0,0);	
					
				}
				else
				{
				}
			} else
				
				
				if (sjoy.downd)
				{
					if (virt < 3)
					{
						play.curitem += 2;
						SoundPlayEffect(11, 22050,0,0,0);	
						
					}
				} else
					
					if (sjoy.upd)
					{
						if (virt > 0) 
						{
							play.curitem -= 2;
							SoundPlayEffect(11, 22050,0,0,0);	
							
						}
					}
					
	}
	if (talk.active) process_talk();
	
	//a special process callbacks for just stuff that was created in this mode? 
	// process_callbacks_special();
	flip_it(); 
	
	if (sjoy.button[4])
	{
		SoundPlayEffect(17, 22050,0,0,0);
		
		item_screen = /*false*/0;
	}
	
	
}


void process_show_bmp( void )
{
/*   RECT rcRect; */
/*   SetRect(&rcRect, 0,0,x, y); */
  
  // We could disable this Blit (work is already done in show_bmp())
  // but we want to display the shiny mark on the map below. Besides,
  // after show_bmp(), other parts of the code drew sprites on
  // lpDDSBack, so we need to regenerate it anyway.
/*  again: */
/*   ddrval = lpDDSBack->BltFast(0, 0, lpDDSTrick, */
/* 			      &rcRect, DDBLTFAST_NOCOLORKEY); */
/*   if( ddrval == DDERR_WASSTILLDRAWING ) goto again; */
  // GFX
  SDL_BlitSurface(GFX_lpDDSTrick, NULL, GFX_lpDDSBack, NULL);
  
  if (showb.showdot)
    {
      //let's display a nice dot to mark where they are on the map
      int x = play.last_map - 1;
      int mseq = 165;
      
      showb.picframe++;
      if (showb.picframe > seq[mseq].len) showb.picframe = 1;
      int mframe = showb.picframe;
      
/*       lpDDSBack->BltFast( ((x) * 20 - ((x / 32) * 640))-20, (x / 32) * 20, k[seq[mseq].frame[mframe]].k, */
/* 			  &k[seq[mseq].frame[mframe]].box, DDBLTFAST_SRCCOLORKEY| DDBLTFAST_WAIT ); */
      // GFX
      {
	SDL_Rect dst;
	// convert map# to a (x,y) position on a FreeDinkEdit minimap
	dst.x = (x % 32) * 20;
	dst.y = (x / 32) * 20;
	SDL_BlitSurface(GFX_k[seq[mseq].frame[mframe]].k, NULL, GFX_lpDDSBack, &dst);
      }
    }
  
  
  if ((sjoy.button[1])
      || (sjoy.button[2])
      || (sjoy.button[3])
      || (sjoy.button[4])
      || (sjoy.button[5])
      || (sjoy.button[6]))
    {
      showb.active = /*false*/0;
      if (showb.script != 0)
	run_script(showb.script);
      showb.stime = thisTickCount+2000;
      but_timer = thisTickCount + 200;
      
      int sprite = say_text_xy("", 1, 440, 0);								
      spr[sprite].noclip = 1;
      
      
      // Return to canonical game palette
/*       if(lpDDPal->SetEntries(0,0,256,real_pal) !=DD_OK) */
/* 	{ */
/* 	  Msg("error with setting entries"); */
/* 	  return; */
/* 	} */
      // GFX
      change_screen_palette(GFX_real_pal);
      // The main flip_it() will be called, skip it - lpDDSBack is
      // not matching the palette anymore, it needs to be redrawn
      // first.
      abort_this_flip = /*true*/1;
    }
}

void drawscreenlock( void )
{
/*   HRESULT     ddrval; */
  
/*  loop: */
  //draw the screenlock icon
/*   ddrval = lpDDSBack->BltFast(0, 0, k[seq[423].frame[9]].k, */
/* 			      &k[seq[423].frame[9]].box  , DDBLTFAST_NOCOLORKEY  ); */
/*   if (ddrval == DDERR_WASSTILLDRAWING ) goto loop; */
  //if (ddrval != DD_OK) dderror(ddrval);
  // GFX
  gfx_blit_nocolorkey(GFX_k[seq[423].frame[9]].k, NULL, GFX_lpDDSBack, NULL);
  
/*  loop2: */
  //draw the screenlock icon
/*   ddrval = lpDDSBack->BltFast(620, 0, k[seq[423].frame[10]].k, */
/* 			      &k[seq[423].frame[10]].box  , DDBLTFAST_NOCOLORKEY  ); */
/*   if (ddrval == DDERR_WASSTILLDRAWING ) goto loop2; */
  // if (ddrval != DD_OK) dderror(ddrval);
  // GFX
  {
    SDL_Rect dst = {620, 0};
    gfx_blit_nocolorkey(GFX_k[seq[423].frame[10]].k, NULL, GFX_lpDDSBack, &dst);
  }
}


/**
 * doInit - do work required for every instance of the application:
 *                create the window, initialize data
 */
static int doInit(int argc, char *argv[])
{
  char *fullpath = NULL;
  
  /* New initialization */
  if (init(argc, argv) == 0)
    exit(1);

  /* Load the tiles from the BMPs */
  tiles_load_default();

  srand((unsigned)time(NULL));
  
  char *base_bmp = "Tiles/Splash.bmp";
  fullpath = paths_dmodfile(base_bmp);
  if (!exist(fullpath))
    {
      free(fullpath);
      fullpath = paths_fallbackfile(base_bmp);
    }
  SDL_Surface* splash = load_bmp(fullpath);
  free(fullpath);
  if (splash == NULL)
    {
      fprintf(stderr, "Cannot load base graphics splash.bmp\n");
    }
  else
    {
      SDL_BlitSurface(splash, NULL, GFX_lpDDSTwo, NULL);
      SDL_FreeSurface(splash);
    }
  
  /* Copy splash screen to the screen during loading time */
  SDL_BlitSurface(GFX_lpDDSTwo, NULL, GFX_lpDDSBack, NULL);
  
  flip_it();

  if (cd_inserted)
    PlayCD(7);
	
  //dinks normal walk
  Msg("Loading batch...");
  load_batch();
  Msg(" done!");
  
  Msg("Loading hard...");
  load_hard();
  Msg(" done!");


  //Activate dink, but don't really turn him on
  //spr[1].active = TRUE;
  spr[1].timer = 33;
	

  // ** SETUP **
  last_sprite_created = 1;
	
  mode = 0;
    
  load_info();

  //lets run our init script
  int script = load_script("main", 0, /*true*/1);
  locate(script, "main");
  run_script(script);

  //lets attach our vars to the scripts
  attach();
	
  return 1;
} /* doInit */


/**
 * Initialization, message loop
 */
int main(int argc, char* argv[])
{
  int last_console_active = 0;

  doInit(argc, argv);
  
  /* Notify other apps that FreeDink is playing */
  log_path(/*true*/1);

  /* Windows event loop */
  while(!g_b_kill_app)
    {
      SDL_Event event;
      SDL_PumpEvents();
      
      /* Check for unprocessed clicks */
      if (SDL_PeepEvents(&event, 1, SDL_GETEVENT,
			 SDL_EVENTMASK(SDL_QUIT)) > 0)
	finiObjects();

      /* Fullscreen <-> window */
      /* Note: as of 2008-08-07, only works under X11 */
      if ((SDL_GetModState()&KMOD_ALT) && GetKeyboard(SDLK_RETURN))
	SDL_WM_ToggleFullScreen(GFX_lpDDSBack);

      /* TODO: maybe check for application active/background state and
	 pause the game accordingly - but this may be an annoying
	 behavior. */
      if (g_b_kill_app == /*false*/0)
	updateFrame();

      if (console_active == 0 || last_console_active == 0)
	/* Get rid of keyboard events, otherwise they'll pile-up. Also
	   purge them just when console is turned on. We poll the
	   keyboard state directly in the rest of the game, so no
	   keystroke will be lost. */
	while (SDL_PeepEvents(&event, 1, SDL_GETEVENT,
			      SDL_EVENTMASK(SDL_KEYDOWN)) > 0);

      if (console_active == 1)
	{
	  SDL_KeyboardEvent kev;
	  if (SDL_PeepEvents((SDL_Event*)&kev, 1, SDL_GETEVENT,
			     SDL_EVENTMASK(SDL_KEYDOWN)) > 0)
	    dinkc_console_process_key(kev);
	}

      last_console_active = console_active;
    }

  return 0;
}
