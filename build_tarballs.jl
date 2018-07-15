# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

# Collection of sources required to build BKMaxflow
sources = [
    "http://vision.csd.uwo.ca/code/maxflow-v3.01.zip" =>
    "b30891ba393a5fbc9d7d0ec808f502bdfca801f289a5cb79b673ac35c413b06e",

    "https://github.com/Gnimuc/bkmaxflow-c.git" =>
    "3a789aa7ff167e2286a9c8fdeaec184031813019",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
mv bkmaxflow-c/* .
cat > maxflow.patch << 'END'
--- maxflow.cpp
+++ maxflow.cpp
@@ -681,4 +681,4 @@

-#include "instances.inc"
+// #include "instances.inc"
END

patch --ignore-whitespace < maxflow.patch

mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain ..
make -j${nproc}
make install

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = BinaryBuilder.supported_platforms()

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libbkmaxflow", :libbkmaxflow)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, "BKMaxflow", v"3.0.1", sources, script, platforms, products, dependencies)
