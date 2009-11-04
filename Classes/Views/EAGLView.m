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

#define ROTATION_ANGLE_STEP 5.0
#define USE_DEPTH_BUFFER 1
#define DEGREES_TO_RADIANS(__ANGLE) ((__ANGLE) / 180.0 * M_PI)

@interface EAGLView ()
- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;
@end

// This code comes from
// http://forums.macrumors.com/archive/index.php/t-508042.html
static CGFloat distanceBetweenPoints(CGPoint firstPoint, CGPoint secondPoint) 
{
    CGFloat distance;
    
    //Square difference in x
    CGFloat xDifferenceSquared = pow(firstPoint.x - secondPoint.x, 2);
    // NSLog(@"xDifferenceSquared: %f", xDifferenceSquared);
    
    // Square difference in y
    CGFloat yDifferenceSquared = pow(firstPoint.y - secondPoint.y, 2);
    // NSLog(@"yDifferenceSquared: %f", yDifferenceSquared);
    
    // Add and take Square root
    distance = sqrt(xDifferenceSquared + yDifferenceSquared);
    return distance;
}

@implementation EAGLView

#pragma mark -
#pragma mark Static methods

+ (Class)layerClass 
{
    return [CAEAGLLayer class];
}

#pragma mark -
#pragma mark Init and dealloc

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

        rotationAngles[0] = 0.0;
        rotationAngles[1] = 0.0;
        rotationAngles[2] = 0.0;
        
        drawMode = GL_POINTS;
        zTransform = -80.0;
        
        self.multipleTouchEnabled = YES;
        
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
#pragma mark IBAction methods

- (IBAction)toggleLinesAndPoints:(id)sender
{
    if (toggleButton.on)
    {
        drawMode = GL_LINE_STRIP;
    }
    else 
    {
        drawMode = GL_POINTS;
    }
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
    glTranslatef(0.0, 0.0, zTransform);
    glRotatef(rotationAngles[0], 1.0, 0.0, 0.0);
    glRotatef(rotationAngles[1], 0.0, 1.0, 0.0);
    glRotatef(rotationAngles[2], 0.0, 0.0, 1.0);
    glMatrixMode(GL_MODELVIEW);

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    if (drawMode == GL_POINTS)
    {
        glEnable(GL_POINT_SMOOTH);
    }
    else 
    {
        glEnable(GL_LINE_STRIP);
    }

    glPointSize(1.0);
    glVertexPointer(3, GL_FLOAT, 0, points);
    glEnableClientState(GL_VERTEX_ARRAY);
    glDrawArrays(drawMode, 0, points_count);
    
	glLoadIdentity();
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    NSArray *allTouches = [touches allObjects];
    NSInteger touchesCount = [allTouches count];
    
    if (touchesCount > 0)
    {
        UITouch *t = [allTouches objectAtIndex:0];
        startTouchPosition = [t locationInView:t.view];
    }
    
    if (touchesCount > 1)
    {
        UITouch *t = [allTouches objectAtIndex:1];
        startTouchPosition2 = [t locationInView:t.view];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray *allTouches = [touches allObjects];
    NSInteger touchesCount = [allTouches count];

    if (touchesCount == 1)
    {
        UITouch *t = [allTouches objectAtIndex:0];
        CGPoint endTouchPosition = [t locationInView:t.view];

        if (startTouchPosition.y < endTouchPosition.y)
        {
            rotationAngles[0] += ROTATION_ANGLE_STEP;
        }
        else if (startTouchPosition.y > endTouchPosition.y)
        {
            rotationAngles[0] -= ROTATION_ANGLE_STEP;
        }
        
        if (startTouchPosition.x < endTouchPosition.x)
        {
            rotationAngles[1] += ROTATION_ANGLE_STEP;
        }
        else if (startTouchPosition.x > endTouchPosition.x)
        {
            rotationAngles[1] -= ROTATION_ANGLE_STEP;
        }

        startTouchPosition = endTouchPosition;
    }
    
    if (touchesCount == 2)
    {
        UITouch *t1 = [allTouches objectAtIndex:0];
        CGPoint endTouchPosition = [t1 locationInView:t1.view];

        UITouch *t2 = [allTouches objectAtIndex:1];
        CGPoint endTouchPosition2 = [t2 locationInView:t2.view];

        CGFloat oldDistance = distanceBetweenPoints(startTouchPosition, startTouchPosition2);
        CGFloat newDistance = distanceBetweenPoints(endTouchPosition, endTouchPosition2);
        
        if (oldDistance < newDistance)
        {
            zTransform += 10.0;
        }
        else 
        {
            zTransform -= 10.0;
        }
        
        startTouchPosition = endTouchPosition;
        startTouchPosition2 = endTouchPosition2;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
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
    [context renderbufferStorage:GL_RENDERBUFFER_OES 
                    fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, 
                                 GL_COLOR_ATTACHMENT0_OES, 
                                 GL_RENDERBUFFER_OES, 
                                 viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, 
                                    GL_RENDERBUFFER_WIDTH_OES, 
                                    &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, 
                                    GL_RENDERBUFFER_HEIGHT_OES, 
                                    &backingHeight);
    
    if (USE_DEPTH_BUFFER) 
    {
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, 
                                 GL_DEPTH_COMPONENT16_OES, 
                                 backingWidth, 
                                 backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, 
                                     GL_DEPTH_ATTACHMENT_OES, 
                                     GL_RENDERBUFFER_OES, 
                                     depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) 
    {
        NSLog(@"failed to make complete framebuffer object %x", 
              glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
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
    glFrustumf(-size, 
               size, 
               -size / (rect.size.width / rect.size.height), 
               size / (rect.size.width / rect.size.height), 
               zNear, 
               zFar);
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
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval 
                                                           target:self 
                                                         selector:@selector(drawView) 
                                                         userInfo:nil 
                                                          repeats:YES];
}

- (void)stopAnimation 
{
    animationTimer = nil;
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
