#import "IntroScene.h"
#import "HelloWorldScene.h"
#import "AboutScene.h"

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
//    CCNodeColor * background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]];
//    [self addChild:background];
    
    // Imagen de la Splash-Screen
    CCSprite * image = [CCSprite spriteWithImageNamed:@"splash_screen.png"];
    image.positionType = CCPositionTypeNormalized;
    image.position = ccp(0.5f, 0.8f);
    [self addChild:image];
    
    // Community Logo
    CCSprite * cLogo = [CCSprite spriteWithImageNamed:@"community-logo.png"];
    cLogo.positionType = CCPositionTypeNormalized;
    cLogo.position = ccp(0.5f, 0.8f);
    [self addChild:cLogo];
    
    // Game Title
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Greendale\n  Runners" fontName:@"Helvetica-Bold" fontSize:60.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    label.position = ccp(0.5f, 0.45f); // Middle of screen
    [self addChild:label];
    
    // Play Button
    CCButton *helloWorldButton = [CCButton buttonWithTitle:@"[ Jugar ]" fontName:@"Helvetica-Bold" fontSize:24.0f];
    helloWorldButton.positionType = CCPositionTypeNormalized;
    helloWorldButton.position = ccp(0.5f, 0.15f);
    [helloWorldButton setTarget:self selector:@selector(onSpinningClicked:)];
    [self addChild:helloWorldButton];

    [self createAboutButton];
    
    // access audio object
    OALSimpleAudio * bgmusic = [OALSimpleAudio sharedInstance];
    // play background sound
    [bgmusic playBg:@"IntroMusic.mp3" loop:TRUE];
    
    // done
	return self;
}

-(void)createAboutButton
{
    CCButton * backButton = [CCButton buttonWithTitle:@"[ Acerca De ]" fontName:@"Helvetica-Bold" fontSize:16.0f];
    backButton.color = [CCColor blackColor];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(0.10f, 0.95f);
    [backButton setTarget:self selector:@selector(onAboutClicked:)];
    [self addChild:backButton];
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onSpinningClicked:(id)sender
{
    // start spinning scene with transition
    [[CCDirector sharedDirector] replaceScene:[HelloWorldScene scene]
                               withTransition:[CCTransition transitionCrossFadeWithDuration:1.0f]];
}

- (void)onAboutClicked:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[AboutScene scene] withTransition: [CCTransition transitionCrossFadeWithDuration:1.0f]];
}
// -----------------------------------------------------------------------
@end
