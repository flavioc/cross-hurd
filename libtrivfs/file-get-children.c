/* file_get_children

   Copyright (C) 2013 Free Software Foundation, Inc.

   Written by Justus Winter <4winter@informatik.uni-hamburg.de>

   This file is part of the GNU Hurd.

   The GNU Hurd is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   The GNU Hurd is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with the GNU Hurd.  If not, see <http://www.gnu.org/licenses/>.  */

#include "priv.h"
#include "trivfs_fs_S.h"

/* Return any active translators bound to nodes of the receiving
   filesystem.  CHILDREN is an argz vector containing file names
   relative to the root of the receiving translator.  */
error_t
trivfs_S_file_get_children (struct trivfs_protid *cred,
			    mach_port_t reply,
			    mach_msg_type_name_t replyPoly,
			    data_t *children,
			    mach_msg_type_number_t *children_len)
{
  return EOPNOTSUPP;
}
