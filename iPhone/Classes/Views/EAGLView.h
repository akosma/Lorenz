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

@interface EAGLView : UIView 
{
@private
    IBOutlet UISwitch *toggleButton;
    
    GLint backingWidth;
    GLint backingHeight;
    
    EAGLContext *context;
    
    GLuint viewRenderbuffer, viewFramebuffer;
    
    GLuint depthRenderbuffer;
    
    NSTimer *animationTimer;
    NSTimeInterval animationInterval;

    GLfloat rotationAngles[3];
    GLfloat zTransform;
    CGPoint startTouchPosition;
    CGPoint startTouchPosition2;
    
    GLenum drawMode;
}

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView;

- (void)setupView;
- (void)checkGLError:(BOOL)visibleCheck;

- (IBAction)toggleLinesAndPoints:(id)sender;

@end
