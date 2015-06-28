/**
 * Draw background from tiles

 * Copyright (C) 2007  Sylvain Beucler

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

#ifndef _GFX_TILES_H
#define _GFX_TILES_H

/* #include <ddraw.h> */
#include "SDL.h"

#define NB_TILE_SCREENS 511

/* extern LPDIRECTDRAWSURFACE tiles[]; */
/* extern RECT tilerect[]; */
extern SDL_Surface *GFX_tiles[];

extern void tiles_load_default(void);
extern void tiles_load_slot(char* relpath, int slot);
extern void tiles_unload_all(void);
extern void draw_map_game(void);
extern void draw_map_game_background(void);
extern void process_animated_tiles(void);

#endif
