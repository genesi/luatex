% memoryword.w
% 
% Copyright 2009-2010 Taco Hoekwater <taco@@luatex.org>

% This file is part of LuaTeX.

% LuaTeX is free software; you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free
% Software Foundation; either version 2 of the License, or (at your
% option) any later version.

% LuaTeX is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
% License for more details.

% You should have received a copy of the GNU General Public License along
% with LuaTeX; if not, see <http://www.gnu.org/licenses/>.

@ @c
#include "ptexlib.h"

static const char _svn_version[] =
    "$Id: memoryword.w 3587 2010-04-03 14:32:25Z taco $"
    "$URL: http://foundry.supelec.fr/svn/luatex/tags/beta-0.60.1/source/texk/web2c/luatexdir/tex/memoryword.w $";


@ When debugging, we may want to print a |memory_word| without knowing
what type it is; so we print it in all modes.

@c
#ifdef DEBUG
void print_word(memory_word w)
{
    /* prints |w| in all ways */
    print_int(w.cint);
    print_char(' ');
    print_scaled(w.cint);
    print_char(' ');
    print_scaled(round(unity * float_cast(w.gr)));
    print_ln();
    print_int(w.hh.lhfield);
    print_char('=');
    print_int(w.hh.b0);
    print_char(':');
    print_int(w.hh.b1);
    print_char(';');
    print_int(w.hh.rh);
    print_char(' ');
    print_int(w.qqqq.b0);
    print_char(':');
    print_int(w.qqqq.b1);
    print_char(':');
    print_int(w.qqqq.b2);
    print_char(':');
    print_int(w.qqqq.b3);
}
#endif
