//
//  IntroScene.m
//  TPE Tower Defense
//
//  Created by Franco Román Meola on 10/04/14.
//  Copyright Franco Román Meola 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "IntroScene.h"
#import "HelloWorldScene.h"

// -----------------------------------------------------------------------
#pragma mark - IntroScene
// -----------------------------------------------------------------------

@implementation IntroScene

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (IntroScene *)scene
{
	return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Create a colored background (Dark Grey)
//    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]];
//    [self addChild:background];
    
    // Imagen de la Splash-Screen
    CCSprite * image = [CCSprite spriteWithImageNamed:@"splash-background.jpg"];
    image.positionType = CCPositionTypeNormalized;
    image.position = ccp(0.5f, 0.5f);
    [self addChild:image];
    
    // Hello world
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Tower Defense" fontName:@"Helvetica-Bold" fontSize:60.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    label.position = ccp(0.5f, 0.5f); // Middle of screen
    [self addChild:label];
    
    // Helloworld scene button
    CCButton *helloWorldButton = [CCButton buttonWithTitle:@"[ Jugar ]" fontName:@"Helvetica-Bold" fontSize:24.0f];
    helloWorldButton.positionType = CCPositionTypeNormalized;
    helloWorldButton.position = ccp(0.5f, 0.35f);
    [helloWorldButton setTarget:self selector:@selector(onSpinningClicked:)];
    [self addChild:helloWorldButton];

    // access audio object
    OALSimpleAudio * bgmusic = [OALSimpleAudio sharedInstance];
    // play background sound
    [bgmusic playBg:@"IntroMusic.mp3" loop:TRUE];
    
    // done
	return self;
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onSpinningClicked:(id)sender
{
    // start spinning scene with transition
    [[CCDirector sharedDirector] replaceScene:[HelloWorldScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
}

// -----------------------------------------------------------------------
@end
