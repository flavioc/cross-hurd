/* 
   Copyright (C) 1994 Free Software Foundation

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License as
   published by the Free Software Foundation; either version 2, or (at
   your option) any later version.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. */

#include "priv.h"
#include "io_S.h"

/* Implement io_async as described in <hurd/io.defs>. */
kern_return_t
diskfs_S_io_async (struct protid *cred,
		   mach_port_t notify,
		   mach_port_t *idport,
		   mach_msg_type_name_t *idport_type)
{
  mach_port_deallocate (mach_task_self (), notify);
  *idport = MACH_PORT_NULL;
  *idport_type = MACH_MSG_TYPE_COPY_SEND;
  return 0;
}

