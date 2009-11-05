#import <OpenGL/gl.h>

// call after OpenGL caps are found
void initCapsTexture (GLCaps * displayCaps, CGDisplayCount numDisplays);

// get NSString with caps for this renderer
void drawCaps (GLCaps * displayCaps, CGDisplayCount numDisplays, long renderer, GLfloat width); // view width for drawing location
