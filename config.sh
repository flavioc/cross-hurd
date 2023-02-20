# Change your host GCC here.
export HOST_MACHINE=x86_64-linux-gnu

# Change how many CPUs you want to use.
export PROCS=$(nproc)

# Set this to your ccache path if using ccache.
export CCACHE_DIRECTORY="/usr/lib/ccache"

# The kind of hurd system to build. The options are:
# minimal: enough to run a shell.
# full: everything.
export BUILD_TYPE=minimal

# GNU Hurd target.
if [ -z "$CPU" ]; then
	export CPU=i686
fi
