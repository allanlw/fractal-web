This repo contains a dockerfile and some glue code to run some ancient code I wrote 
to do fractal image "compression" in a web browser.

The dockerfile contains good examples of using optimized emscripten, and builds and 
optimizes:

- zlib
- libpng
- libjpeg
- libgd

Which were transitively build dependencies of my project. Note that I do not use the 
native emscripten ports interface, so this might be useful for someone attempting to 
do the same thing and build some libraries out of tree.

I highly recommend building on docker so that your builds are at least somewhat 
reproducable. If you don't, you will have a LOT of pain while you try and debug the 
right way to get everything to compile and link. If you do it from the start too 
then you will not have to jump through hoops to change dependency build 
optimizations/flags, or any other similar nonsense.
