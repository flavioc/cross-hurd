/* Default values for weak variables
   Copyright (C) 1996 Free Software Foundation, Inc.
   Written by Thomas Bushnell, n/BSG.

   This file is part of the GNU Hurd.

   The GNU Hurd is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License as
   published by the Free Software Foundation; either version 2, or (at
   your option) any later version.

   The GNU Hurd is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111, USA. */


#include "priv.h"

char *diskfs_extra_version __attribute__ ((weak)) = "";
int diskfs_shortcut_symlink __attribute__ ((weak)) = 0;
int diskfs_shortcut_chrdev __attribute__ ((weak)) = 0;
int diskfs_shortcut_blkdev __attribute__ ((weak)) = 0;
int diskfs_shortcut_fifo __attribute__ ((weak)) = 0;
int diskfs_shortcut_ifsock __attribute__ ((weak)) = 0;
error_t (*diskfs_create_symlink_hook)(struct node *np, const char *target)
  __attribute__ ((weak));
error_t (*diskfs_read_symlink_hook)(struct node *np, char *target)
  __attribute__ ((weak));
