dnl Process this file with autoconf to produce a configure script.
dnl
dnl   Copyright (C) 2009, 2010 Peter Breitenlohner <tex-live@tug.org>
dnl
dnl   This file is free software; the copyright holder
dnl   gives unlimited permission to copy and/or distribute it,
dnl   with or without modifications, as long as this notice is preserved.
dnl
AC_INIT([TeX Live], [2010-04-15], [tex-k@tug.org])
AC_PREREQ([2.65])
AC_CONFIG_SRCDIR([m4/kpse-pkgs.m4])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([m4])

dnl ## ------------------------------------------- ##
dnl ## Setup of the TeX Live (TL) infrastructure   ##
dnl ##    done in ./, libs/, utils/, and texk/     ##
dnl ## ------------------------------------------- ##
dnl
dnl 1. Define four lists of TeXk programs, utility programs,
dnl    and (generic or TeX specific) libraries in the TL tree.
dnl    These list are defined in m4/kpse-pkgs.m4.
dnl
dnl 2. For each program Prog in the list of
dnl      utility programs:
dnl        sinclude utils/Prog/ac/withenable.ac
dnl      TeXk programs:
dnl        sinclude texk/Prog/ac/withenable.ac
dnl    These fragments usually provide the configure options
dnl      --disable-Prog or --enable-Prog
dnl    If Prog is to be built, then set need_SubLib=yes
dnl      for each TL library SubLib required by Prog (if any)
dnl
dnl 3. For each library Lib in the list of
dnl      generic TL libraries:
dnl        sinclude libs/Lib/ac/withenable.ac
dnl      TeX specific TL libraries:
dnl        sinclude texk/Lib/ac/withenable.ac
dnl    These fragments usually provide the configure options
dnl      --with-system-Lib, --with-Lib-includes=DIR, and --with-Lib-libdir=DIR
dnl    For each TL library SubLib required by Lib (if any):
dnl      disallow with_system_Lib=yes and with_system_SubLib=no
dnl      if $need_Lib=yes then set need_SubLib=yes 
dnl
KPSE_SETUP([])

dnl Common code for all programs using libkpathsea.
KPSE_COMMON([TeX Live top-level], [dist-xz])
KPSE_CANONICAL_HOST

AC_PROG_MKDIR_P

AC_PATH_XTRA

AC_PROG_CXX

AC_PROG_LN_S
AC_ARG_WITH([ln-s],
            AS_HELP_STRING([--without-ln-s],
                           [do build even if `ln -s' does not work]))[]dnl
if test "x$LN_S" != "xln -s" && test "x$with_ln_s" != xno; then
  AC_MSG_ERROR([You could use `--without-ln-s' to build without working `ln -s'])
fi

if test "x$mandir" = 'x${datarootdir}/man'; then
  mandir='${prefix}/texmf/doc/man'
  ac_configure_args="$ac_configure_args '--mandir=$mandir'"  
fi

if test "x$infodir" = 'x${datarootdir}/info'; then
  infodir='${prefix}/texmf/doc/info'
  ac_configure_args="$ac_configure_args '--infodir=$infodir'"  
fi

dnl Although quite unusual, it is possible to build Web2C (TeX & Co)
dnl using installed (system) kpathsea headers and library.
dnl In that case we need the location of <kpathsea/paths.h>.
if test "x$enable_web2c" = xyes && test "x$with_system_kpathsea" = xyes; then
  if test "x$with_kpathsea_includes" = x; then
    list="/usr/include /usr/local/include"
  else
    list=$with_kpathsea_includes
  fi
  found=no
  for ac_dir in $list; do
    if test -r "$ac_dir/kpathsea/paths.h"; then
      found=yes
      break
    fi
  done
  if test "x$found" = xno; then
    AC_MSG_NOTICE([You requested to build `web2c' using an installed `kpathsea' version,])
    AC_MSG_NOTICE([    which requires to locate the <kpathsea/paths.h> header file.])
    AC_MSG_ERROR([Sorry, not found under any of: $list *****])
  fi
fi

AC_MSG_CHECKING([for TeX specific libraries to build])
TEXLIBS=
DIST_TEXLIBS=
KPSE_FOR_PKGS([texlibs], [
if test -x $srcdir/texk/Kpse_Pkg/configure; then
  if test "x$with_system_[]Kpse_pkg" != xyes && \
     test "x$need_[]Kpse_pkg" = xyes; then
    TEXLIBS="texk/Kpse_Pkg $TEXLIBS"    
  fi
dnl Cause 'make dist' to recurse into all texlibs dirs
  DIST_TEXLIBS="texk/Kpse_Pkg $DIST_TEXLIBS"
dnl Cause 'configure -hr' and 'autoreconf' to recurse into all texlibs dirs
  if false; then
    AC_CONFIG_SUBDIRS([texk/]Kpse_Pkg)
  fi
fi
])
AC_SUBST([TEXLIBS])
AC_SUBST([DIST_TEXLIBS])
AC_MSG_RESULT([$TEXLIBS])

dnl We check that all required system libraries are usable, and may
dnl reduce frustration if anything is wrong by doing this first.
dnl A native TeX Live build must not use any system libraries.
KPSE_SAVE_FLAGS
syslib_status=yes
syslib_used=no
KPSE_ALL_SYSTEM_FLAGS
KPSE_LT_HACK
KPSE_FOR_PKGS([sys_texk], [m4_sinclude([texk/]Kpse_Pkg[/ac/]Kpse_Pkg[.ac])])[]dnl
KPSE_FOR_PKGS([sys_libs], [m4_sinclude([libs/]Kpse_Pkg[/ac/]Kpse_Pkg[.ac])])[]dnl
if test "x$syslib_status" = xno; then
  AC_MSG_ERROR([some requested system libraries failed])
fi
if test "x$syslib_used:$enable_native_texlive_build" = xyes:yes; then
  AC_MSG_ERROR([you can not use system libraries for a native TeX Live build])
fi
KPSE_RESTORE_FLAGS

dnl AM_CONDITIONAL([build_kpathsea],
dnl                [test "x$need_kpathsea" = xyes && test "x$with_system_kpathsea" != xyes])

AM_CONDITIONAL([cross_compiling], [test "x$cross_compiling" = xyes])

AC_CONFIG_SUBDIRS([auxdir/auxsub libs utils texk])

AC_CONFIG_FILES([Makefile])

AC_OUTPUT

dnl Most probably we need GNU make.
if test -z "`${MAKE-make} -v 2>/dev/null | grep GNU`"; then
  if test "x$enable_native_texlive_build" = xno; then
    AC_MSG_WARN([Building TeX Live may require GNU make])
  else
    AC_MSG_ERROR([Building TeX Live requires GNU make])
  fi
fi

AS_IF([test "x$cross_compiling" = xyes],
      [msg_compiling="cross-compiling on $build_alias for $host_alias"],
      [msg_compiling="compiling for $kpse_build_alias"])
kpse_bld=`pwd`
kpse_src=`cd "$srcdir" && pwd`
msg_compiling="$msg_compiling
      in $kpse_bld"
test "x$srcdir" = x. || msg_compiling="$msg_compiling
      from sources in $kpse_src"
AC_MSG_RESULT([
** Configuration summary for $PACKAGE_STRING:

   $msg_compiling])
case $kpse_src$kpse_bld in
  *' '*) AC_MSG_ERROR([Absolute source and/or build path with embedded spaces]);;
esac
AC_MSG_RESULT([
   prefix:                       $prefix
   enable_native_texlive_build:  $enable_native_texlive_build
   enable_shared:                $enable_shared
   enable_multiplatform:         $enable_multiplatform
   enable_cxx_runtime_hack:      $enable_cxx_runtime_hack
   enable_libtool_hack:          $enable_libtool_hack
   enable_compiler_warnings:     $enable_compiler_warnings

** Next run `make' to configure and build each library and program.
])
