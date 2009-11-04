//
//  LorenzAppDelegate.h
//  Lorenz
//
//  Created by Adrian on 11/3/09.
//  Copyright akosma software 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAGLView;

@interface LorenzAppDelegate : NSObject <UIApplicationDelegate> 
{
@private
    IBOutlet UIWindow *_window;
    IBOutlet EAGLView *_glView;
}

@end

