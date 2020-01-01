# OpenGL texture demo
Language: [D](http://www.dlang.org)  
API: [OpenGL](http://www.opengl.org)

Written as a learning excercise to focus on how to load and use textures in opengl. Put in source control as a reference for how to do it when I forget. 

It is not intended to be good or idiomatic D code (for example it doesn't clean up it's resources and there a a lot of *global* variables. It is intended to be a simpe example only.)

Loads a texture and displays it on a quad using opengl 3.3

## Build and run information
    $ dub build
    $ img.exe