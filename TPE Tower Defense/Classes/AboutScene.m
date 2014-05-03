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
    self = [super init];
    if (!self) return(nil);
    CCSprite * image = [CCSprite spriteWithImageNamed:@"splash_screen.png"];
    image.positionType = CCPositionTypeNormalized;
    image.position = ccp(0.5f, 0.8f);
    [self addChild:image];
    OALSimpleAudio * bgmusic = [OALSimpleAudio sharedInstance];
    [bgmusic playBg:@"DayBreak.mp3" loop:TRUE];
    [self createBackButton];
    [self createTitleLabel];
    [self createAuthorLabel];
    [self createThankLabel];
	return self;
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onSpinningClicked:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionCrossFadeWithDuration:1.0f]];
}

// -----------------------------------------------------------------------

- (void)createBackButton
{
    CCButton * backButton = [CCButton buttonWithTitle:@"[ Volver ]" fontName:@"Helvetica-Bold" fontSize:24.0f];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(0.5f, 0.15f);
    [backButton setTarget:self selector:@selector(onSpinningClicked:)];
    [self addChild:backButton];
}

- (void)createTitleLabel
{
    CCLabelTTF * titleLabel = [CCLabelTTF labelWithString:@"Acerca De" fontName:@"Helvetica-Bold" fontSize:30.0f];
    titleLabel.positionType = CCPositionTypeNormalized;
    titleLabel.color = [CCColor grayColor];
    titleLabel.position = ccp(0.5f, 0.80f);
    [self addChild:titleLabel];
}

- (void)createAuthorLabel
{
    CCLabelTTF * authorLabel = [CCLabelTTF labelWithString:@"Creado por Franco Román Meola" fontName:@"Helvetica-Bold" fontSize:24.0f];
    authorLabel.positionType = CCPositionTypeNormalized;
    authorLabel.color = [CCColor blackColor];
    authorLabel.position = ccp(0.5f, 0.60f);
    [self addChild:authorLabel];
}

- (void)createThankLabel
{
    CCLabelTTF * thankLabel = [CCLabelTTF labelWithString:@"Inspirado en Digital Estate Planning: The Game" fontName:@"Helvetica-Bold" fontSize:22.0f];
    thankLabel.positionType = CCPositionTypeNormalized;
    thankLabel.color = [CCColor whiteColor];
    thankLabel.position = ccp(0.5f, 0.40f);
    [self addChild:thankLabel];
}

@end
