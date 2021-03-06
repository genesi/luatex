% pdfobj.w

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
static const char _svn_version[] =
    "$Id: pdfobj.w 3571 2010-04-02 13:50:45Z taco $"
    "$URL: http://foundry.supelec.fr/svn/luatex/tags/beta-0.60.1/source/texk/web2c/luatexdir/pdf/pdfobj.w $";

#include "ptexlib.h"

@ @c
#include "lua/luatex-api.h"

int pdf_last_obj;

@ write a raw PDF object 

@c
void pdf_write_obj(PDF pdf, int k)
{
    lstring data;
    const_lstring st;
    size_t i, li;               /* index into |data.s| */
    int saved_compress_level = pdf->compress_level;
    int os_level = 1;           /* gives compressed objects for \.{\\pdfobjcompresslevel} $>$ 0 */
    int l = 0;                  /* possibly a lua registry reference */
    int ll = 0;
    data.s = NULL;
    if (obj_obj_pdfcompresslevel(pdf, k) > -1)  /* -1 = "unset" */
        pdf->compress_level = obj_obj_pdfcompresslevel(pdf, k);
    if (obj_obj_pdfoslevel(pdf, k) > -1)        /* -1 = "unset" */
        os_level = obj_obj_pdfoslevel(pdf, k);
    if (obj_obj_is_stream(pdf, k)) {
        pdf_begin_dict(pdf, k, 0);
        l = obj_obj_stream_attr(pdf, k);
        if (l != LUA_NOREF) {
            lua_rawgeti(Luas, LUA_REGISTRYINDEX, l);
            assert(lua_isstring(Luas, -1));
            st.s = lua_tolstring(Luas, -1, &li);
            st.l = li;
            for (i = 0; i < st.l; i++)
                pdf_out(pdf, st.s[i]);
            if (st.s[st.l - 1] != '\n')
                pdf_out(pdf, '\n');
            luaL_unref(Luas, LUA_REGISTRYINDEX, l);
            obj_obj_stream_attr(pdf, k) = LUA_NOREF;
        }
        pdf_begin_stream(pdf);
    } else
        pdf_begin_obj(pdf, k, os_level);
    l = obj_obj_data(pdf, k);
    lua_rawgeti(Luas, LUA_REGISTRYINDEX, l);
    assert(lua_isstring(Luas, -1));
    st.s = lua_tolstring(Luas, -1, &li);
    st.l = li;
    if (obj_obj_is_file(pdf, k)) {
        boolean res = false;    /* callback status value */
        const char *fnam = NULL;        /* callback found filename */
        int callback_id;
        /* st.s is also |\0|-terminated, even as lstring */
        fnam = luatex_find_file(st.s, find_data_file_callback);
        callback_id = callback_defined(read_data_file_callback);
        if (fnam && callback_id > 0) {
            boolean file_opened = false;
            res = run_callback(callback_id, "S->bSd", fnam,
                               &file_opened, &data.s, &ll);
            data.l = (size_t) ll;
            if (!file_opened)
                pdf_error("ext5", "cannot open file for embedding");
        } else {
            byte_file f;        /* the data file's FILE* */
            if (!fnam)
                fnam = st.s;
            if (!luatex_open_input
                (&f, fnam, kpse_tex_format, FOPEN_RBIN_MODE, true))
                pdf_error("ext5", "cannot open file for embedding");
            res = read_data_file(f, &data.s, &ll);
            data.l = (size_t) ll;
            close_file(f);
        }
        if (data.l == 0L)
            pdf_error("ext5", "empty file for embedding");
        if (!res)
            pdf_error("ext5", "error reading file for embedding");
        tprint("<<");
        tprint(st.s);
        for (i = 0; i < data.l; i++)
            pdf_out(pdf, data.s[i]);
        if (!obj_obj_is_stream(pdf, k) && data.s[data.l - 1] != '\n')
            pdf_out(pdf, '\n');
        xfree(data.s);
        tprint(">>");
    } else {
        for (i = 0; i < st.l; i++)
            pdf_out(pdf, st.s[i]);
        if (!obj_obj_is_stream(pdf, k) && st.s[st.l - 1] != '\n')
            pdf_out(pdf, '\n');
    }
    if (obj_obj_is_stream(pdf, k))
        pdf_end_stream(pdf);
    else
        pdf_end_obj(pdf);
    luaL_unref(Luas, LUA_REGISTRYINDEX, l);
    obj_obj_data(pdf, k) = LUA_NOREF;
    pdf->compress_level = saved_compress_level;
}

@ @c
void init_obj_obj(PDF pdf, int k)
{
    obj_obj_stream_attr(pdf, k) = LUA_NOREF;
    obj_obj_data(pdf, k) = LUA_NOREF;
    unset_obj_obj_is_stream(pdf, k);
    unset_obj_obj_is_file(pdf, k);
    obj_obj_pdfcompresslevel(pdf, k) = -1;      /* unset */
    obj_obj_pdfoslevel(pdf, k) = -1;    /* unset */
}

@ The \.{\\pdfobj} primitive is used to create a ``raw'' object in the PDF
   output file. The object contents will be hold in memory and will be written
   out only when the object is referenced by \.{\\pdfrefobj}. When \.{\\pdfobj}
   is used with \.{\\immediate}, the object contents will be written out
   immediately. Objects referenced in the current page are appended into
   |pdf_obj_list|. 

@c
void scan_obj(PDF pdf)
{
    int k;
    lstring *st = NULL;
    if (scan_keyword("reserveobjnum")) {
        /* Scan an optional space */
        get_x_token();
        if (cur_cmd != spacer_cmd)
            back_input();
        incr(pdf->obj_count);
        pdf_create_obj(pdf, obj_type_obj, pdf->sys_obj_ptr + 1);
        k = pdf->sys_obj_ptr;
    } else {
        if (scan_keyword("useobjnum")) {
            scan_int();
            k = cur_val;
            check_obj_exists(pdf, obj_type_obj, k);
            if (is_obj_scheduled(pdf, k) || obj_data_ptr(pdf, k) != 0)
                luaL_error(Luas, "object in use");
        } else {
            incr(pdf->obj_count);
            pdf_create_obj(pdf, obj_type_obj, pdf->sys_obj_ptr + 1);
            k = pdf->sys_obj_ptr;
        }
        obj_data_ptr(pdf, k) = pdf_get_mem(pdf, pdfmem_obj_size);
        init_obj_obj(pdf, k);
        if (scan_keyword("uncompressed")) {
            obj_obj_pdfcompresslevel(pdf, k) = 0;       /* \pdfcompresslevel = 0 */
            obj_obj_pdfoslevel(pdf, k) = 0;
        }
        if (scan_keyword("stream")) {
            set_obj_obj_is_stream(pdf, k);
            if (scan_keyword("attr")) {
                scan_pdf_ext_toks();
                st = tokenlist_to_lstring(def_ref, true);
                flush_list(def_ref);
                lua_pushlstring(Luas, (char *) st->s, st->l);
                obj_obj_stream_attr(pdf, k) = luaL_ref(Luas, LUA_REGISTRYINDEX);
                free_lstring(st);
                st = NULL;
            }
        }
        if (scan_keyword("file"))
            set_obj_obj_is_file(pdf, k);
        scan_pdf_ext_toks();
        st = tokenlist_to_lstring(def_ref, true);
        flush_list(def_ref);
        lua_pushlstring(Luas, (char *) st->s, st->l);
        obj_obj_data(pdf, k) = luaL_ref(Luas, LUA_REGISTRYINDEX);
        free_lstring(st);
        st = NULL;
    }
    pdf_last_obj = k;
}

@ @c
#define tail          cur_list.tail_field

void scan_refobj(PDF pdf)
{
    scan_int();
    check_obj_exists(pdf, obj_type_obj, cur_val);
    new_whatsit(pdf_refobj_node);
    pdf_obj_objnum(tail) = cur_val;
}

@ @c
void pdf_ref_obj(PDF pdf, halfword p)
{
    if (!is_obj_scheduled(pdf, pdf_obj_objnum(p)))
        addto_page_resources(pdf, obj_type_obj, pdf_obj_objnum(p));
}
