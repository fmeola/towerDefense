#import "AboutScene.h"
#import "IntroScene.h"

@implementation AboutScene

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (AboutScene *)scene
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
    CCSprite * image = [CCSprite spriteWithImageNamed:@"splash_screen.png"];
    image.positionType = CCPositionTypeNormalized;
    image.position = ccp(0.5f, 0.8f);
    [self addChild:image];
    
    CCLabelTTF * label = [CCLabelTTF labelWithString:@"Acerca De" fontName:@"Helvetica-Bold" fontSize:30.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    label.position = ccp(0.5f, 0.80f);
    [self addChild:label];
    
    CCButton * helloWorldButton = [CCButton buttonWithTitle:@"[ Volver ]" fontName:@"Helvetica-Bold" fontSize:24.0f];
    helloWorldButton.positionType = CCPositionTypeNormalized;
    helloWorldButton.position = ccp(0.5f, 0.15f);
    [helloWorldButton setTarget:self selector:@selector(onSpinningClicked:)];
    [self addChild:helloWorldButton];
    
    // access audio object
    OALSimpleAudio * bgmusic = [OALSimpleAudio sharedInstance];
    // play background sound
    [bgmusic playBg:@"DayBreak.mp3" loop:TRUE];
    
    // done
	return self;
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onSpinningClicked:(id)sender
{
    // start spinning scene with transition
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionCrossFadeWithDuration:1.0f]];
}

// -----------------------------------------------------------------------

@end
