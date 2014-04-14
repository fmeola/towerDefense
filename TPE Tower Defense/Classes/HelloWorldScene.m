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
#import "CCAnimation.h"

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
    
    NSString * moneyString;
    CCLabelTTF * moneyLabel;
    int money;
    
    NSString * scoreString;
    CCLabelTTF * scoreLabel;
    int score;
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
    CCNodeColor * background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]];
    [self addChild:background];
    _tileMap = [CCTiledMap tiledMapWithFile:@"TileMap.tmx"];
    _background = [_tileMap layerNamed:@"Background"];
    [self addChild:_tileMap];
    CCTiledMapObjectGroup * objectGroup = [_tileMap objectGroupNamed:@"Objects"];
    NSAssert(objectGroup != nil, @"tile map has no objects object layer");
    NSDictionary * startPoint = [objectGroup objectNamed:_tileMap.properties[@"startPosition"]];
    long x = [startPoint[@"x"] integerValue];
    long y = [startPoint[@"y"] integerValue];
    currentPoint = startPoint;
    towersGroup = [_tileMap objectGroupNamed:@"Towers"];
    NSAssert(towersGroup != nil, @"tile map has no objects Towers layer");
    // Música de fondo
    OALSimpleAudio * bgmusic = [OALSimpleAudio sharedInstance];
    [bgmusic playBg:@"LevelMusic.mp3" loop:TRUE];
    [self createBackButton];
    [self createMoneyLabelWithInitialMoney:100];
    [self createWavesLabel];
    [self createScoreLabelWithInitialScore:100000];
    [self createTowerButtons];
    [self createCharacterSprite:@"jeff" withPosition:ccp(x,y)];
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

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CCTiledMapObjectGroup *objectGroup = [_tileMap objectGroupNamed:@"Objects"];
    NSAssert(objectGroup != nil, @"tile map has no objects object layer");
    NSDictionary *nextPoint = [objectGroup objectNamed:currentPoint[@"next"]];
    long x = [nextPoint[@"x"] integerValue];
    long y = [nextPoint[@"y"] integerValue];
    currentPoint = nextPoint;
    [self updateCharacerSprite:@"jeff" withPosition:ccp(x,y)];
    // Si llego a la posición final
    if([currentPoint[@"next"] isEqual: @"p0"]) {
        [self playAudioEffectNamed:@"pickup.caf"];
        [self increaseWavesCount:1];
        [self changeScore:-10000];
    }
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onBackClicked:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene] withTransition: [CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:1.0f]];
}

// -----------------------------------------------------------------------

-(void)createScoreLabelWithInitialScore:(int)initial
{
    score = initial;
    [self defaultScoreLabel];
    [self addChild:scoreLabel];
}

-(void)changeScore:(int)diff
{
    score += diff;
    [self removeChild:scoreLabel];
    [self defaultScoreLabel];
    [self addChild:scoreLabel];
}

-(void)defaultScoreLabel
{
    scoreString = [NSString stringWithFormat:@"Puntaje: %d",score];
    scoreLabel = [CCLabelTTF labelWithString: scoreString fontName:@"Helvetica" fontSize:16.0f];
    scoreLabel.positionType = CCPositionTypeNormalized;
    scoreLabel.color = [CCColor blackColor];
    scoreLabel.position = ccp(0.50f, 0.05f);
}

-(void)createWavesLabel
{
    CCSprite * waveBg = [CCSprite spriteWithImageNamed:@"wave_bg.png"];
    waveBg.positionType = CCPositionTypeNormalized;
    waveBg.position = ccp(0.95f, 0.92f);
    [self addChild:waveBg];
    waveCount = 1;
    [self defaultWavesLabel];
    [self addChild:wavesLabel];
}

-(void)increaseWavesCount:(int)diff
{
    waveCount += diff;
    [self removeChild:wavesLabel];
    [self defaultWavesLabel];
    [self addChild:wavesLabel];
}

-(void)defaultWavesLabel
{
    wavesString = [NSString stringWithFormat:@"%d / N",waveCount];
    wavesLabel = [CCLabelTTF labelWithString: wavesString fontName:@"Helvetica-Bold" fontSize:16.0f];
    wavesLabel.positionType = CCPositionTypeNormalized;
    wavesLabel.color = [CCColor whiteColor];
    wavesLabel.position = ccp(0.95f, 0.91f);
}

-(void)createMoneyLabelWithInitialMoney:(int)initial
{
    CCSprite * moneyBg = [CCSprite spriteWithImageNamed:@"money_bg.png"];
    moneyBg.positionType = CCPositionTypeNormalized;
    moneyBg.position = ccp(0.95f, 0.80f);
    [self addChild:moneyBg];
    money = initial;
    [self defaultMoneyLabel];
    [self addChild:moneyLabel];
}

-(void)changeMoney:(int)diff
{
    money += diff;
    [self removeChild:moneyLabel];
    [self defaultMoneyLabel];
    [self addChild:moneyLabel];
}

-(void)defaultMoneyLabel
{
    moneyString = [NSString stringWithFormat:@"$ %d",money];
    moneyLabel = [CCLabelTTF labelWithString: moneyString fontName:@"Helvetica-Bold" fontSize:16.0f];
    moneyLabel.positionType = CCPositionTypeNormalized;
    moneyLabel.color = [CCColor whiteColor];
    moneyLabel.position = ccp(0.95f, 0.79f);
}

-(void)createTowerButtons
{
    [self createTower1Button];
    [self createTower2Button];
}

-(void)createTower1Button
{
    CCSprite * tower1buybutton = [CCSprite spriteWithImageNamed:@"icon-tower-1-enabled.png"];
    tower1buybutton.positionType = CCPositionTypeNormalized;
    tower1buybutton.position = ccp(0.80f, 0.10f);
    [self addChild:tower1buybutton];
}

-(void)createTower2Button
{
    CCSprite * tower2buybutton = [CCSprite spriteWithImageNamed:@"icon-tower-2-disabled.png"];
    tower2buybutton.positionType = CCPositionTypeNormalized;
    tower2buybutton.position = ccp(0.90f, 0.10f);
    [self addChild:tower2buybutton];
}

-(void)createBackButton
{
    CCButton * backButton = [CCButton buttonWithTitle:@"[ Volver ]" fontName:@"Helvetica-Bold" fontSize:16.0f];
    backButton.color = [CCColor blackColor];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(0.10f, 0.95f);
    [backButton setTarget:self selector:@selector(onBackClicked:)];
    [self addChild:backButton];
}

-(void)playAudioEffectNamed:(NSString *)name
{
    OALSimpleAudio * audio = [OALSimpleAudio sharedInstance];
    [audio playEffect:name];
}

-(void)createCharacterSprite:(NSString *)characterName withPosition:(CGPoint)point
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist",characterName]];
    CCSpriteBatchNode * spriteSheet = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@.png",characterName]];
    [self addChild:spriteSheet];
    NSMutableArray * walkAnimFrames = [NSMutableArray array];
    // Cómo saber el size del .plist
    for (int i=1; i<=SPRITE_SIZE; i++) {
        [walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"%@-%@-%d.png",characterName,currentPoint[@"direction"],i]]];
    }
    _walkAnim = [CCAnimation animationWithSpriteFrames:walkAnimFrames delay:0.1f];
    _character = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"%@-%@-1.png",characterName,currentPoint[@"direction"]]];
    _character.position = point;
    _walkAction = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:_walkAnim]];
    [_character runAction:_walkAction];
    [spriteSheet addChild:_character];
}

-(void)updateCharacerSprite:(NSString *)characterName withPosition:(CGPoint)point
{
    NSMutableArray * walkAnimFrames = [NSMutableArray array];
    for (int i=1; i<=SPRITE_SIZE; i++) {
        [walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"%@-%@-%d.png",characterName,currentPoint[@"direction"],i]]];
    }
    _walkAnim = [CCAnimation animationWithSpriteFrames:walkAnimFrames delay:0.1f];
    [_character stopAction:_walkAction];
    _walkAction = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:_walkAnim]];
    [_character runAction:_walkAction];
    _character.position = point;
}

@end