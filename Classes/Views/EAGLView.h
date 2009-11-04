//
//  EAGLView.h
//  Lorenz
//
//  Created by Adrian Kosmaczewski on 03/11/09.
//  Copyright akosma software 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

typedef enum __MOVMENT_TYPE 
{
    MTNone = 0,
    MTWalkForward,
    MTWAlkBackward,
    MTTurnLeft,
    MTTurnRight
} MovementType;

@interface EAGLView : UIView 
{
@private
    GLint backingWidth;
    GLint backingHeight;
    
    EAGLContext *context;
    
    GLuint viewRenderbuffer, viewFramebuffer;
    
    GLuint depthRenderbuffer;
    
    NSTimer *animationTimer;
    NSTimeInterval animationInterval;

    // Where we are viewing from
    GLfloat eye[3];
    // Where we are looking towards
    GLfloat center[3];

    MovementType currentMovement;
}

@property NSTimeInterval animationInterval;

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView;

- (void)setupView;
- (void)checkGLError:(BOOL)visibleCheck;
- (void)handleTouches;

@end
