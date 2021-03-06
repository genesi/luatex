dnl Process this file with autoconf to produce a configure script.
dnl
dnl   Copyright (C) 2009, 2010 Peter Breitenlohner <tex-live@tug.org>
dnl
dnl   This file is free software; the copyright holder
dnl   gives unlimited permission to copy and/or distribute it,
dnl   with or without modifications, as long as this notice is preserved.
dnl --------------------------------------------------------
dnl Keep Kpathsea shared and package library versions the same:
dnl   Only bug fixes:
dnl     kpse_lib_micro += 1;
dnl   Adding new interfaces (backwards compatible)
dnl     kpse_lib_minor += 1;
dnl     kpse_lib_micro = 0;
dnl   Modifying or revoking interfaces (not backwards compatible)
dnl     kpse_lib_major += 1;
dnl     kpse_lib_minor = 0;
dnl     kpse_lib_micro = 0;
dnl
dnl   After a release, set kpse_lib_dev to "dev", to distinguish
dnl   binaries built between releases.

m4_define([kpse_lib_major], [6])[]dnl
m4_define([kpse_lib_minor], [0])[]dnl
m4_define([kpse_lib_micro], [0])[]dnl
m4_define([kpse_lib_devel], [dev])[]dnl empty or "dev"
m4_define([kpse_version], [kpse_lib_major.kpse_lib_minor.kpse_lib_micro[]kpse_lib_devel])[]dnl

AC_INIT([Kpathsea], [kpse_version], [tex-k@tug.org])
AC_PREREQ([2.65])
AC_CONFIG_SRCDIR([pathsearch.c])
AC_CONFIG_AUX_DIR([../../build-aux])
AC_CONFIG_MACRO_DIR([../../m4])

AC_SUBST([KPSEVERSION], [kpse_version])
AC_DEFINE([KPSEVERSION], ["kpathsea version kpse_version"])
AC_SUBST([KPSE_LT_VERSINFO], [m4_eval(kpse_lib_major+kpse_lib_minor):kpse_lib_micro:kpse_lib_minor])

dnl Common code for all programs using libkpathsea.
KPSE_COMMON([kpathsea])
dnl Include additional code for kpathsea.
KPSE_WEB2C_PREPARE
m4_sinclude([ac/web2c.ac])

dnl Generate MAKE_TEX_*_BY_DEFAULT and MAKE_OMEGA_*_BY_DEFAULT defines.
m4_foreach([Kpse_Mktex], [kpse_mktex_opts],
           [m4_ifset([Kpse_Mktex],
                     [KPSE_MKTEX_DEFINE(Kpse_Mktex)])])[]dnl

dnl Replacement functions that may be required on ancient broken system.
AC_CHECK_DECLS([putenv, strstr])
AC_REPLACE_FUNCS([putenv strcasecmp strtol strstr])

if test $ac_cv_func_getcwd = yes; then
# We only need to run this if we have getcwd.
AC_CACHE_CHECK([whether getcwd uses fork or vfork],
               [kb_cv_func_getcwd_forks],
               [AC_RUN_IFELSE([AC_LANG_PROGRAM([[int fork() { exit(1); }
                                                 int vfork() { exit(1); }
                                                 extern char *getcwd();
                                                 char path[100];]],
                                               [[getcwd(path,100);]])],
                              [kb_cv_func_getcwd_forks=no],
                              [kb_cv_func_getcwd_forks=yes],
                              [kb_cv_func_getcwd_forks=no])])
if test $kb_cv_func_getcwd_forks = yes; then
  AC_DEFINE([GETCWD_FORKS], 1,
            [Define to 1 if getcwd is implemented using fork or vfork.
             Let me know if you have to add this by hand because configure
             failed to detect it.])
fi
fi

KPSE_CHECK_WIN32
AM_CONDITIONAL([WIN32], [test "x$kpse_cv_have_win32" != xno])
AM_CONDITIONAL([MINGW32], [test "x$kpse_cv_have_win32" = xmingw32])

dnl Write output here, instead of putting a zillion -D's on the command line.
AC_CONFIG_HEADERS([c-auto.h:c-auto.in],
 [sed -e 's/^#define PACKAGE/#define KPSE_PACKAGE/' \
      -e 's/^#define VERSION/#define KPSE_VERSION/' c-auto.h >c-auto.tmp && mv -f c-auto.tmp c-auto.h])

AH_TOP([/* c-auto.h: defines for kpathsea, as determined by configure.

   Copyright 1994-97, 2008, 2009 Karl Berry.
   Copyright 1997-99, 2002, 2005 Olaf Weber.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public License
   along with this library; if not, see <http://www.gnu.org/licenses/>.  */

/* Guard against double inclusion. */
#ifndef KPATHSEA_C_AUTO_H
#define KPATHSEA_C_AUTO_H

/* kpathsea: the version string. */
#define KPSEVERSION "REPLACE-WITH-KPSEVERSION"])
AH_BOTTOM([#endif /* !KPATHSEA_C_AUTO_H */])

AC_CONFIG_FILES([Makefile doc/Makefile man/Makefile])

AC_OUTPUT
