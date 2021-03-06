% luanode.w
% 
% Copyright 2006-2008 Taco Hoekwater <taco@@luatex.org>

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
#include "lua/luatex-api.h"
#include "ptexlib.h"


static const char _svn_version[] =
    "$Id: luanode.w 3583 2010-04-02 17:40:44Z hhenkel $ "
"$URL: http://foundry.supelec.fr/svn/luatex/tags/beta-0.60.1/source/texk/web2c/luatexdir/lua/luanode.w $";

@ @c
static const char *group_code_names[] = {
    "",
    "simple",
    "hbox",
    "adjusted_hbox",
    "vbox",
    "vtop",
    "align",
    "no_align",
    "output",
    "math",
    "disc",
    "insert",
    "vcenter",
    "math_choice",
    "semi_simple",
    "math_shift",
    "math_left",
    "local_box",
    "split_off",
    "split_keep",
    "preamble",
    "align_set",
    "fin_row"
};

const char *pack_type_name[] = { "exactly", "additional" };


@ @c
void lua_node_filter_s(int filterid, const char *extrainfo)
{
    lua_State *L = Luas;
    int s_top = lua_gettop(L);
    int callback_id = callback_defined(filterid);
    if (callback_id <= 0)
        return;
    if (!get_callback(L, callback_id)) {
        lua_settop(L, s_top);
        return;
    }
    lua_pushstring(L, extrainfo);       /* arg 1 */
    if (lua_pcall(L, 1, 0, 0) != 0) {
        fprintf(stdout, "error: %s\n", lua_tostring(L, -1));
        lua_settop(L, s_top);
        error();
        return;
    }
    lua_settop(L, s_top);
    return;
}

@ @c
void
lua_node_filter(int filterid, int xextrainfo, halfword head_node,
                halfword * tail_node)
{
    halfword ret;
    int a;
    lua_State *L = Luas;
    const char *extrainfo = group_code_names[xextrainfo];
    int callback_id = callback_defined(filterid);
    if (head_node == null || vlink(head_node) == null || callback_id <= 0)
        return;
    if (!get_callback(L, callback_id)) {
        lua_pop(L, 2);
        return;
    }
    nodelist_to_lua(L, vlink(head_node));       /* arg 1 */
    lua_pushstring(L, extrainfo);       /* arg 2 */
    if (lua_pcall(L, 2, 1, 0) != 0) {   /* no arg, 1 result */
        fprintf(stdout, "error: %s\n", lua_tostring(L, -1));
        lua_pop(L, 2);
        error();
        return;
    }
    if (lua_isboolean(L, -1)) {
        if (lua_toboolean(L, -1) != 1) {
            flush_node_list(vlink(head_node));
            vlink(head_node) = null;
        }
    } else {
        a = nodelist_from_lua(L);
        vlink(head_node) = a;
    }
    lua_pop(L, 2);              /* result and callback container table */
    if (fix_node_lists)
        fix_node_list(head_node);
    ret = vlink(head_node);
    if (ret != null) {
        while (vlink(ret) != null)
            ret = vlink(ret);
        *tail_node = ret;
    } else {
        *tail_node = head_node;
    }
    return;
}


@ @c
int
lua_linebreak_callback(int is_broken, halfword head_node, halfword * new_head)
{
    int a;
    register halfword *p;
    int ret = 0;                /* failure */
    lua_State *L = Luas;
    int callback_id = callback_defined(linebreak_filter_callback);
    if (head_node == null || vlink(head_node) == null || callback_id <= 0)
        return ret;
    if (!get_callback(L, callback_id)) {
        lua_pop(L, 2);
        return ret;
    }
    nodelist_to_lua(L, vlink(head_node));       /* arg 1 */
    lua_pushboolean(L, is_broken);      /* arg 2 */
    if (lua_pcall(L, 2, 1, 0) != 0) {   /* no arg, 1 result */
        fprintf(stdout, "error: %s\n", lua_tostring(L, -1));
        lua_pop(L, 2);
        error();
        return ret;
    }

    p = lua_touserdata(L, -1);
    if (p != NULL) {
        a = nodelist_from_lua(L);
        vlink(*new_head) = a;
        ret = 1;
    }
    lua_pop(L, 2);              /* result and callback container table */
    return ret;
}



@ @c
halfword
lua_hpack_filter(halfword head_node, scaled size, int pack_type, int extrainfo,
                 int pack_direction)
{
    halfword ret;
    lua_State *L = Luas;
    int callback_id = callback_defined(hpack_filter_callback);
    if (head_node == null || callback_id <= 0)
        return head_node;
    if (!get_callback(L, callback_id)) {
        lua_pop(L, 2);
        return head_node;
    }
    nodelist_to_lua(L, head_node);
    lua_pushstring(L, group_code_names[extrainfo]);
    lua_pushnumber(L, size);
    lua_pushstring(L, pack_type_name[pack_type]);
    if (pack_direction >= 0)
        lua_pushstring(L, string_dir(pack_direction));
    else
        lua_pushnil(L);
    if (lua_pcall(L, 5, 1, 0) != 0) {   /* no arg, 1 result */
        fprintf(stdout, "error: %s\n", lua_tostring(L, -1));
        lua_pop(L, 2);
        error();
        return head_node;
    }
    ret = head_node;
    if (lua_isboolean(L, -1)) {
        if (lua_toboolean(L, -1) != 1) {
            flush_node_list(head_node);
            ret = null;
        }
    } else {
        ret = nodelist_from_lua(L);
    }
    lua_pop(L, 2);              /* result and callback container table */
#if 0
    lua_gc(L,LUA_GCSTEP, LUA_GC_STEP_SIZE);
#endif
    if (fix_node_lists)
        fix_node_list(ret);
    return ret;
}

@ @c
halfword
lua_vpack_filter(halfword head_node, scaled size, int pack_type, scaled maxd,
                 int extrainfo, int pack_direction)
{
    halfword ret;
    int callback_id;
    lua_State *L = Luas;
    if (head_node == null)
        return head_node;
    if (strcmp("output", group_code_names[extrainfo]) == 0) {
        callback_id = callback_defined(pre_output_filter_callback);
    } else {
        callback_id = callback_defined(vpack_filter_callback);
    }
    if (callback_id <= 0) {
        return head_node;
    }
    if (!get_callback(L, callback_id)) {
        lua_pop(L, 2);
        return head_node;
    }
    nodelist_to_lua(L, head_node);
    lua_pushstring(L, group_code_names[extrainfo]);
    lua_pushnumber(L, size);
    lua_pushstring(L, pack_type_name[pack_type]);
    lua_pushnumber(L, maxd);
    if (pack_direction >= 0)
        lua_pushstring(L, string_dir(pack_direction));
    else
        lua_pushnil(L);
    if (lua_pcall(L, 6, 1, 0) != 0) {   /* no arg, 1 result */
        fprintf(stdout, "error: %s\n", lua_tostring(L, -1));
        lua_pop(L, 2);
        error();
        return head_node;
    }
    ret = head_node;
    if (lua_isboolean(L, -1)) {
        if (lua_toboolean(L, -1) != 1) {
            flush_node_list(head_node);
            ret = null;
        }
    } else {
        ret = nodelist_from_lua(L);
    }
    lua_pop(L, 2);              /* result and callback container table */
#if 0
    lua_gc(L,LUA_GCSTEP, LUA_GC_STEP_SIZE);
#endif
    if (fix_node_lists)
        fix_node_list(ret);
    return ret;
}


@ This is a quick hack to fix etex's \.{\\lastnodetype} now that
  there are many more visible node types. TODO: check the
  eTeX manual for the expected return values.
 
@c
int visible_last_node_type(int n)
{
    int i = type(n);
    if (i == whatsit_node && subtype(n) == local_par_node)
        return -1;
    if (i == glyph_node) {
        if (is_ligature(n))
            return 7;           /* old ligature value */
        else
            return 0;           /* old character value */
    }
    if (i <= unset_node) {
        return i + 1;
    } else if (i <= delim_node) {
        return 15;              /* so-called math nodes */
    } else {
        return -1;
    }
}

@ @c
void lua_pdf_literal(PDF pdf, int i)
{
    const char *s = NULL;
    size_t l = 0;
    lua_rawgeti(Luas, LUA_REGISTRYINDEX, i);
    s = lua_tolstring(Luas, -1, &l);
    if (l < max_single_pdf_print) {
        pdf_out_block(pdf, s, l);
    } else {
        while (l--) {
            pdf_out(pdf, *s++);
        }
    }
    pdf_out(pdf, 10);           /* |pdf_print_nl| */
    lua_pop(Luas, 1);
}

@ @c
void copy_pdf_literal(pointer r, pointer p)
{
    pdf_literal_type(r) = pdf_literal_type(p);
    pdf_literal_mode(r) = pdf_literal_mode(p);
    if (pdf_literal_type(p) == normal) {
        pdf_literal_data(r) = pdf_literal_data(p);
        add_token_ref(pdf_literal_data(p));
    } else {
        lua_rawgeti(Luas, LUA_REGISTRYINDEX, pdf_literal_data(p));
        pdf_literal_data(r) = luaL_ref(Luas, LUA_REGISTRYINDEX);
    }
}


@ @c
void free_pdf_literal(pointer p)
{
    if (pdf_literal_type(p) == normal) {
        delete_token_ref(pdf_literal_data(p));
    } else {
        luaL_unref(Luas, LUA_REGISTRYINDEX, pdf_literal_data(p));
    }
}

@ @c
void show_pdf_literal(pointer p)
{
    tprint_esc("pdfliteral");
    switch (pdf_literal_mode(p)) {
    case set_origin:
        break;
    case direct_page:
        tprint(" page");
        break;
    case direct_always:
        tprint(" direct");
        break;
    default:
        confusion("literal2");
        break;
    }
    if (pdf_literal_type(p) == normal) {
        print_mark(pdf_literal_data(p));
    } else {
        lua_rawgeti(Luas, LUA_REGISTRYINDEX, pdf_literal_data(p));
        tprint(lua_tostring(Luas, -1));
        lua_pop(Luas, 1);
    }
}
