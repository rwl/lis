./reconfigure.sh

#emconfigure ./configure --prefix=${PWD}/lis/lib/web/dlis CFLAGS=-I/home/rwl/tmp/emscripten/SuperLU_4.3/SRC\ -L/home/rwl/tmp/emscripten/SuperLU_4.3/lib/libsuperlu_4.3.a
#emmake make clean all install
#
#emconfigure ./configure --prefix=${PWD}/lis/lib/web/zlis --enable-complex CFLAGS=-I/home/rwl/tmp/emscripten/SuperLU_4.3/SRC
#emmake make clean all install
#
#cd lis
#emmake make clean all
#cd ..


./configure --prefix=${PWD}/lis/lib/native/dlis --enable-shared
make clean all install

#./configure --prefix=${PWD}/lis/lib/native/zlis --enable-shared --enable-complex
#make clean all install
