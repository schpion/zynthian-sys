# linuxsampler
set -ex
cd $ZYNTHIAN_SW_DIR

# Download, Build & Install needed libraries: libgig & libscp
svn co https://svn.linuxsampler.org/svn/libgig/trunk libgig
cd libgig
libtoolize --force
aclocal
autoheader
automake --force-missing --add-missing
autoconf 
./configure
make -j 4
make install
make clean
cd ..
svn co https://svn.linuxsampler.org/svn/liblscp/trunk liblscp
cd liblscp
libtoolize --force
aclocal
autoheader
automake --force-missing --add-missing
autoconf 
./configure
make -j 4
make install
make clean
cd ..

# Download, Build &  Install LinuxSampler
svn co https://svn.linuxsampler.org/svn/linuxsampler/trunk linuxsampler
cd linuxsampler
libtoolize --force
aclocal
autoheader
automake --force-missing --add-missing
autoconf
#./configure
#Configure with optimizations from Schpion
./configure --enable-max-voices=21 --enable-max-streams=64 --enable-stream-min-refill=4096 --enable-refill-streams=2 --enable-stream-max-refill=131072 --enable-stream-size=262144 --disable-asm --enable-subfragment-size=64 --enable-eg-min-release-time=0.001 --enable-eg-bottom=0.0025 --enable-max-pitch=2 --enable-preload-samples=65536
cd src/scriptvm
yacc -o parser parser.y
cd ../..
# Apply patch from Steveb
rm -rf rpi_linuxsampler_patch
git clone https://github.com/steveb/rpi_linuxsampler_patch.git
if ! patch -R -p1 --dry-run < rpi_linuxsampler_patch/linuxsampler-arm.patch
then
  patch -p1 < rpi_linuxsampler_patch/linuxsampler-arm.patch
fi
# Build LinuxSampler
make -j 4
make install
mv /usr/local/lib/lv2/linuxsampler.lv2 ${ZYNTHIAN_PLUGINS_DIR}/mod-lv2
make clean
cd ..


