//
//  EAGLView.m
//  Lorenz
//
//  Created by Adrian Kosmaczewski on 03/11/09.
//  Copyright akosma software 2009. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "EAGLView.h"

#define WALK_SPEED 0.1
#define TURN_SPEED 0.1

#define USE_DEPTH_BUFFER 1
#define DEGREES_TO_RADIANS(__ANGLE) ((__ANGLE) / 180.0 * M_PI)

void gluLookAt(GLfloat eyex, GLfloat eyey, GLfloat eyez, GLfloat centerx,
			   GLfloat centery, GLfloat centerz, GLfloat upx, GLfloat upy,
			   GLfloat upz);

@interface EAGLView ()

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) NSTimer *animationTimer;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

@end


@implementation EAGLView

@synthesize context;
@synthesize animationTimer;
@synthesize animationInterval;

+ (Class)layerClass 
{
    return [CAEAGLLayer class];
}

- (id)initWithCoder:(NSCoder*)coder 
{
    if ((self = [super initWithCoder:coder])) 
    {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], 
                                        kEAGLDrawablePropertyRetainedBacking, 
                                        kEAGLColorFormatRGBA8, 
                                        kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) 
        {
            [self release];
            return nil;
        }
        
        animationInterval = 1.0 / 60.0;
		currentMovement = MTNone;
        
        eye[0] = -35.0;
        eye[1] = -20.5;
        eye[2] = 80.0;
        
        center[0] = -5.0;
        center[1] = 1.5;
        center[2] = -10.0;
        
		[self setupView];
    }
    return self;
}

- (void)dealloc 
{
    
    [self stopAnimation];
    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];  
    [super dealloc];
}

#pragma mark -
#pragma mark Public methods

- (void)drawView 
{
    const GLfloat points[] = 
    {
#import "values.inc"
    };
    
    int points_count = (sizeof points) / (sizeof(GLfloat)) / 3;

    [EAGLContext setCurrentContext:context];    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
    glMatrixMode(GL_MODELVIEW);

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glEnable(GL_POINT_SMOOTH);
    glPointSize(1.0);
    glVertexPointer(3, GL_FLOAT, 0, points);
    glEnableClientState(GL_VERTEX_ARRAY);
    glDrawArrays(GL_POINTS, 0, points_count);
    
	glLoadIdentity();
    [self handleTouches];
    gluLookAt(eye[0], eye[1], eye[2], center[0], center[1], center[2],
              0.0, 1.0, 0.0);
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    UITouch *t = [[touches allObjects] objectAtIndex:0];
    CGPoint touchPos = [t locationInView:t.view];
    
    if (touchPos.y < 160) 
    {
        // We are moving forward
        currentMovement = MTWalkForward;
        
    } 
    else if (touchPos.y > 320) 
    {
        // We are moving backward
        currentMovement = MTWAlkBackward;
        
    } 
    else if (touchPos.x < 160) 
    {
        // Turn left
        currentMovement = MTTurnLeft;
    } 
    else 
    {
        // Turn Right
        currentMovement = MTTurnRight;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    currentMovement = MTNone;
}

- (void)handleTouches 
{
    if (currentMovement == MTNone) 
    {
        // We're going nowhere, nothing to do here
        return;
    }
    
    GLfloat vector[3];
    
    vector[0] = center[0] - eye[0];
    vector[1] = center[1] - eye[1];
    vector[2] = center[2] - eye[2];
    
    switch (currentMovement) 
    {
        case MTWalkForward:
            eye[0] += vector[0] * WALK_SPEED;
            eye[2] += vector[2] * WALK_SPEED;
            center[0] += vector[0] * WALK_SPEED;
            center[2] += vector[2] * WALK_SPEED;
            break;
            
        case MTWAlkBackward:
            eye[0] -= vector[0] * WALK_SPEED;
            eye[2] -= vector[2] * WALK_SPEED;
            center[0] -= vector[0] * WALK_SPEED;
            center[2] -= vector[2] * WALK_SPEED;
            break;
            
        case MTTurnLeft:
            center[0] = eye[0] + cos(-TURN_SPEED)*vector[0] -
            sin(-TURN_SPEED)*vector[2];
            center[2] = eye[2] + sin(-TURN_SPEED)*vector[0] +
            cos(-TURN_SPEED)*vector[2];
            break;
            
        case MTTurnRight:
            center[0] = eye[0] + cos(TURN_SPEED)*vector[0] - sin(TURN_SPEED)*vector[2];
            center[2] = eye[2] + sin(TURN_SPEED)*vector[0] + cos(TURN_SPEED)*vector[2];
            break;
            
        default:
            break;
    }
}

- (void)layoutSubviews 
{
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self drawView];
}


- (BOOL)createFramebuffer 
{
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (USE_DEPTH_BUFFER) 
    {
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) 
    {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}

- (void)setupView 
{
    const GLfloat zNear = 0.1, zFar = 1000.0, fieldOfView = 60.0;
    GLfloat size;
	
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);
	
	// This give us the size of the iPhone display
    CGRect rect = self.bounds;
    glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), zNear, zFar);
    glViewport(0, 0, rect.size.width, rect.size.height);
	
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);	
}

- (void)destroyFramebuffer 
{
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if(depthRenderbuffer) 
    {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}


- (void)startAnimation 
{
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval 
                                                           target:self 
                                                         selector:@selector(drawView) 
                                                         userInfo:nil 
                                                          repeats:YES];
}

- (void)stopAnimation 
{
    self.animationTimer = nil;
}

- (void)setAnimationTimer:(NSTimer *)newTimer 
{
    [animationTimer invalidate];
    animationTimer = newTimer;
}

- (void)setAnimationInterval:(NSTimeInterval)interval 
{
    animationInterval = interval;
    if (animationTimer) 
    {
        [self stopAnimation];
        [self startAnimation];
    }
}

- (void)checkGLError:(BOOL)visibleCheck 
{
    GLenum error = glGetError();
    
    switch (error) 
    {
        case GL_INVALID_ENUM:
            NSLog(@"GL Error: Enum argument is out of range");
            break;
    
        case GL_INVALID_VALUE:
            NSLog(@"GL Error: Numeric value is out of range");
            break;
        
        case GL_INVALID_OPERATION:
            NSLog(@"GL Error: Operation illegal in current state");
            break;
        
        case GL_STACK_OVERFLOW:
            NSLog(@"GL Error: Command would cause a stack overflow");
            break;
        
        case GL_STACK_UNDERFLOW:
            NSLog(@"GL Error: Command would cause a stack underflow");
            break;
        
        case GL_OUT_OF_MEMORY:
            NSLog(@"GL Error: Not enough memory to execute command");
            break;
        
        case GL_NO_ERROR:
            if (visibleCheck) 
            {
                NSLog(@"No GL Error");
            }
            break;

        default:
            NSLog(@"Unknown GL Error");
            break;
    }
}

@end

#pragma mark -
#pragma mark SGI Copyright Functions

static void normalize(float v[3])
{
    float r;
	
    r = sqrt( v[0]*v[0] + v[1]*v[1] + v[2]*v[2] );
    if (r == 0.0) return;
	
    v[0] /= r;
    v[1] /= r;
    v[2] /= r;
}

static void __gluMakeIdentityf(GLfloat m[16])
{
    m[0+4*0] = 1; m[0+4*1] = 0; m[0+4*2] = 0; m[0+4*3] = 0;
    m[1+4*0] = 0; m[1+4*1] = 1; m[1+4*2] = 0; m[1+4*3] = 0;
    m[2+4*0] = 0; m[2+4*1] = 0; m[2+4*2] = 1; m[2+4*3] = 0;
    m[3+4*0] = 0; m[3+4*1] = 0; m[3+4*2] = 0; m[3+4*3] = 1;
}

static void cross(float v1[3], float v2[3], float result[3])
{
    result[0] = v1[1]*v2[2] - v1[2]*v2[1];
    result[1] = v1[2]*v2[0] - v1[0]*v2[2];
    result[2] = v1[0]*v2[1] - v1[1]*v2[0];
}

void gluLookAt(GLfloat eyex, GLfloat eyey, GLfloat eyez, GLfloat centerx,
			   GLfloat centery, GLfloat centerz, GLfloat upx, GLfloat upy,
			   GLfloat upz)
{
    float forward[3], side[3], up[3];
    GLfloat m[4][4];
	
    forward[0] = centerx - eyex;
    forward[1] = centery - eyey;
    forward[2] = centerz - eyez;
	
    up[0] = upx;
    up[1] = upy;
    up[2] = upz;
	
    normalize(forward);
	
    /* Side = forward x up */
    cross(forward, up, side);
    normalize(side);
	
    /* Recompute up as: up = side x forward */
    cross(side, forward, up);
	
    __gluMakeIdentityf(&m[0][0]);
    m[0][0] = side[0];
    m[1][0] = side[1];
    m[2][0] = side[2];
	
    m[0][1] = up[0];
    m[1][1] = up[1];
    m[2][1] = up[2];
	
    m[0][2] = -forward[0];
    m[1][2] = -forward[1];
    m[2][2] = -forward[2];
	
    glMultMatrixf(&m[0][0]);
    glTranslatef(-eyex, -eyey, -eyez);
}

