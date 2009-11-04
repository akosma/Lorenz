//
//  LorenzAppDelegate.m
//  Lorenz
//
//  Created by Adrian on 11/3/09.
//  Copyright akosma software 2009. All rights reserved.
//

#import "LorenzAppDelegate.h"
#import "EAGLView.h"

@implementation LorenzAppDelegate

- (void) applicationDidFinishLaunching:(UIApplication *)application
{
	[_glView startAnimation];
}

- (void) applicationWillResignActive:(UIApplication *)application
{
	[_glView stopAnimation];
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
	[_glView startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[_glView stopAnimation];
}

- (void) dealloc
{
	[_window release];
	[_glView release];
	
	[super dealloc];
}

@end
