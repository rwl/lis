gcc -fPIC -std=c99 -I/usr/lib/dart/include -I../../native/dlis/include -DDART_SHARED_LIB -c lis_extension.c

gcc -shared -Wl,-soname,liblis_extension.so -o liblis_extension.so lis_extension.o
