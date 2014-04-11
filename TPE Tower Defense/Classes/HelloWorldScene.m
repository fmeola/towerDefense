//
//  HelloWorldScene.m
//  TPE Tower Defense
//
//  Created by Franco Román Meola on 10/04/14.
//  Copyright Franco Román Meola 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "HelloWorldScene.h"
#import "IntroScene.h"

// -----------------------------------------------------------------------
#pragma mark - HelloWorldScene
// -----------------------------------------------------------------------

@implementation HelloWorldScene
{
    NSDictionary * currentPoint;
    CCSprite *_sprite;
    NSString * wavesString;
    CCLabelTTF * wavesLabel;
    int waveCount;
    CCTiledMapObjectGroup * towersGroup;
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (HelloWorldScene *)scene
{
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    
    // Create a colored background (Dark Grey)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]];
    [self addChild:background];
    
    self.tileMap = [CCTiledMap tiledMapWithFile:@"TileMap.tmx"];
    self.background = [_tileMap layerNamed:@"Background"];
    
    [self addChild:_tileMap];
    
    CCTiledMapObjectGroup *objectGroup = [_tileMap objectGroupNamed:@"Objects"];
    NSAssert(objectGroup != nil, @"tile map has no objects object layer");
    
    NSDictionary *startPoint = [objectGroup objectNamed:_tileMap.properties[@"startPosition"]];
    long x = [startPoint[@"x"] integerValue];
    long y = [startPoint[@"y"] integerValue];
    
    currentPoint = startPoint;
    
    _player = [CCSprite spriteWithImageNamed:@"soldier_blue_right.png"];
    _player.position = ccp(x,y);
    
    [self addChild:_player];
    
    [self loadTowerPositions];
    
    // access audio object
    OALSimpleAudio * bgmusic = [OALSimpleAudio sharedInstance];
    // play background sound
    [bgmusic playBg:@"TileMap.caf" loop:TRUE];
    
    // Create a back button
    CCButton *backButton = [CCButton buttonWithTitle:@"[ Volver ]" fontName:@"Helvetica-Bold" fontSize:16.0f];
    backButton.color = [CCColor blackColor];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(0.85f, 0.95f); // Top Right of screen
    [backButton setTarget:self selector:@selector(onBackClicked:)];
    [self addChild:backButton];
    
    // Mostrar las oleadas
    waveCount = 1;
    wavesString = [NSString stringWithFormat:@"Oleada #%d",waveCount];
    wavesLabel = [CCLabelTTF labelWithString: wavesString fontName:@"Helvetica-Bold" fontSize:25.0f];
    wavesLabel.positionType = CCPositionTypeNormalized;
    wavesLabel.color = [CCColor blackColor];
    wavesLabel.position = ccp(0.85f, 0.85f); // Middle of screen
    [self addChild:wavesLabel];
    
    // done
	return self;
}

// -----------------------------------------------------------------------

- (void)dealloc
{
    // clean up code goes here
}

// -----------------------------------------------------------------------
#pragma mark - Enter & Exit
// -----------------------------------------------------------------------

- (void)onEnter
{
    // always call super onEnter first
    [super onEnter];
    
    // In pre-v3, touch enable and scheduleUpdate was called here
    // In v3, touch is enabled by setting userInterActionEnabled for the individual nodes
    // Per frame update is automatically enabled, if update is overridden
    
}

// -----------------------------------------------------------------------

- (void)onExit
{
    // always call super onExit last
    [super onExit];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    // El sprite salta a la posición final
    CCTiledMapObjectGroup *objectGroup = [_tileMap objectGroupNamed:@"Objects"];
    NSAssert(objectGroup != nil, @"tile map has no objects object layer");
    
    NSDictionary *nextPoint = [objectGroup objectNamed:currentPoint[@"next"]];
 
    long x = [nextPoint[@"x"] integerValue];
    long y = [nextPoint[@"y"] integerValue];
    
    currentPoint = nextPoint;
    
    [self removeChild:_player];

    if([currentPoint[@"direction"] isEqual: @"right"]) {
        _player = [CCSprite spriteWithImageNamed:@"soldier_blue_right.png"];
    } else if([currentPoint[@"direction"] isEqual: @"left"]) {
        _player = [CCSprite spriteWithImageNamed:@"soldier_blue_left.png"];
    } else if ([currentPoint[@"direction"] isEqual: @"up"]) {
        _player = [CCSprite spriteWithImageNamed:@"soldier_blue_up.png"];
    } else {
        _player = [CCSprite spriteWithImageNamed:@"soldier_blue_down.png"];
    }
    
    if([currentPoint[@"next"] isEqual: @"p0"]) {
        // access audio object
        OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
        // play sound effect
        [audio playEffect:@"pickup.caf"];
        
        waveCount++;
        [self removeChild:wavesLabel];
        wavesString = [NSString stringWithFormat:@"Oleada #%d",waveCount];
        wavesLabel = [CCLabelTTF labelWithString: wavesString fontName:@"Helvetica-Bold" fontSize:25.0f];
        wavesLabel.positionType = CCPositionTypeNormalized;
        wavesLabel.color = [CCColor blackColor];
        wavesLabel.position = ccp(0.85f, 0.85f); // Middle of screen
        [self addChild:wavesLabel];
    }
    
    _player.position = ccp(x,y);
    [self addChild:_player];
}

-(void)setPlayerPosition:(CGPoint)position {
	_player.position = position;
}

-(void)loadTowerPositions
{
    towersGroup = [_tileMap objectGroupNamed:@"Towers"];
    NSAssert(towersGroup != nil, @"tile map has no objects object layer");
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onBackClicked:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:1.0f]];
}

// -----------------------------------------------------------------------

@end