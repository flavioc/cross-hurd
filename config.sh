# Change your host GCC here.
export HOST_MACHINE=x86_64-linux-gnu

# Change how many CPUs you want to use.
export PROCS=$(nproc)

# Set this to your ccache path if using ccache.
export CCACHE_DIRECTORY="/usr/lib/ccache"

# GNU Hurd target.
export CPU=i686
