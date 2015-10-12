./reconfigure.sh

emconfigure ./configure --prefix=${PWD}/lis/lib/dlis
emmake make clean all install

emconfigure ./configure --prefix=${PWD}/lis/lib/zlis --enable-complex
emmake make clean all install

cd lis
emmake make clean all
cd ..

