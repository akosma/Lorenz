//
//  LorenzView.m
//  Lorenz
//
//  Created by Adrian on 11/6/09.
//  Copyright (c) 2009, __MyCompanyName__. All rights reserved.
//

#import "LorenzView.h"
#import "BasicOpenGLView.h"

@implementation LorenzView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) 
    {
        NSRect newFrame = frame;
        newFrame.origin.x = 0.0;
        newFrame.origin.y = 0.0;
        lorenz = [[BasicOpenGLView alloc] initWithFrame:newFrame];

        [self setAutoresizesSubviews:NO];
        [self addSubview:lorenz];
        [lorenz prepareOpenGL];
        [self setAnimationTimeInterval:1/60.0];
        [lorenz awakeFromNib];
        [[self window] makeFirstResponder:self];
        [self startAnimation];

        [NSBundle loadNibNamed:@"ConfigureSheet" owner:self];
    }
    return self;
}

- (void)dealloc
{
    [lorenz release];
    [super dealloc];
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

- (void)animateOneFrame
{
    [lorenz animationTimer:nil];
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow *)configureSheet
{
    return configSheet;
}

- (IBAction)close:(id)sender
{
    [NSApp endSheet:configSheet];
}

- (IBAction)changeColor:(id)sender
{
    if (sender == foregroundColorWell)
    {
        lorenz.foregroundColor = [sender color];
    }
    else if (sender == backgroundColorWell)
    {
        lorenz.backgroundColor = [sender color];
    }
    [self setNeedsDisplay:YES];
}

@end
