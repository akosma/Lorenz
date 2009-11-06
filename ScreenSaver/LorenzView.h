//
//  LorenzView.h
//  Lorenz
//
//  Created by Adrian on 11/6/09.
//  Copyright (c) 2009, __MyCompanyName__. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>

@class BasicOpenGLView;

@interface LorenzView : ScreenSaverView 
{
@private
    BasicOpenGLView *lorenz;
    IBOutlet NSPanel *configSheet;
    IBOutlet NSColorWell *foregroundColorWell;
    IBOutlet NSColorWell *backgroundColorWell;
}

- (IBAction)changeColor:(id)sender;
- (IBAction)close:(id)sender;

@end
