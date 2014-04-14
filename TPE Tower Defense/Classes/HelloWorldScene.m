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
#import <math.h>

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

+(CCScene *) jeffScene
{
	CCScene *scene = [CCScene node];
	HelloWorldScene *layer = [HelloWorldScene node];
	[scene addChild: layer];
	return scene;
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
    
    self.tileMap = [CCTiledMap tiledMapWithFile:@"TileMap.tmx"];
    self.background = [_tileMap layerNamed:@"Background"];
    [self addChild:_tileMap];
    CCTiledMapObjectGroup * objectGroup = [_tileMap objectGroupNamed:@"Objects"];
    NSAssert(objectGroup != nil, @"tile map has no objects object layer");
    NSDictionary * startPoint = [objectGroup objectNamed:_tileMap.properties[@"startPosition"]];
    long x = [startPoint[@"x"] integerValue];
    long y = [startPoint[@"y"] integerValue];
    currentPoint = startPoint;
    towersGroup = [_tileMap objectGroupNamed:@"Towers"];
    NSAssert(towersGroup != nil, @"tile map has no objects Towers layer");
    
    // access audio object
    OALSimpleAudio * bgmusic = [OALSimpleAudio sharedInstance];
    // play background sound
    [bgmusic playBg:@"LevelMusic.mp3" loop:TRUE];
    
    [self createBackButton];
    [self createMoneyLabel];
    [self createWavesLabel];
    [self createScoreLabel];
    [self createTowerButtons];
    
    // Sprite de Jeff corriendo
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"jeff.plist"];
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"jeff.png"];
    [self addChild:spriteSheet];
    NSMutableArray *walkAnimFrames = [NSMutableArray array];
    //
    // Cómo saber el size del .plist
    for (int i=1; i<=3; i++) {
        [walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"jeff-right-%d.png",i]]];
    }
    _walkAnim = [CCAnimation animationWithSpriteFrames:walkAnimFrames delay:0.1f];
    self.jeff = [CCSprite spriteWithImageNamed:@"jeff-right-1.png"];
    self.jeff.position = ccp(x,y);
    self.walkAction = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:_walkAnim]];
    [self.jeff runAction:self.walkAction];
    [spriteSheet addChild:self.jeff];
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
    
//    [self removeChild:_player];
//    NSString * aux  = [NSString stringWithFormat:@"jeff-%@-1.png",currentPoint[@"direction"]];
//    _player = [CCSprite spriteWithImageNamed:(aux)];
    
    NSMutableArray *walkAnimFrames = [NSMutableArray array];
    for (int i=1; i<=3; i++) {
        [walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"jeff-%@-%d.png",currentPoint[@"direction"],i]]];
    }
    
    _walkAnim = [CCAnimation animationWithSpriteFrames:walkAnimFrames delay:0.1f];
    [self.jeff stopAction:self.walkAction];
    self.walkAction = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:_walkAnim]];
    [self.jeff runAction:self.walkAction];
    _jeff.position = ccp(x,y);
    
    if([currentPoint[@"next"] isEqual: @"p0"]) {
        // access audio object
        OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
        // play sound effect
        [audio playEffect:@"pickup.caf"];
        [self increaseWavesCount:1];
        [self changeScore:-10000];
    }
    
//    while(![currentPoint[@"next"] isEqual: @"p0"]) {
//        CGPoint destinyLocation = ccp([currentPoint[@"x"] integerValue],[currentPoint[@"y"] integerValue]);
//        CGPoint moveDifference = ccpSub(destinyLocation, _jeff.position);
//        CGSize winSize = [[CCDirector sharedDirector] viewSize];
//        float jeffSpeed = winSize.width / 10.0f;
//        float distanceToMove = ccpLength(moveDifference);
//        float moveDuration = distanceToMove / jeffSpeed;
//        
////        [self.sequenceAction actionWithArray:nil]
//        
//        [_jeff stopAction:_moveAction];
//        _moveAction = [CCActionMoveTo actionWithDuration:moveDuration position:destinyLocation];
//        [_jeff runAction:_moveAction ];
////        _waitAction = [CCActionDelay actionWithDuration:moveDuration];
////        [_jeff runAction:_waitAction ];
//        
////        while (_jeff.position.x != destinyLocation.x || _jeff.position.y != destinyLocation.y) {
////            // espero
////        }
//        
//        NSDictionary *nextPoint = [objectGroup objectNamed:currentPoint[@"next"]];
//        long x = [nextPoint[@"x"] integerValue];
//        long y = [nextPoint[@"y"] integerValue];
//        currentPoint = nextPoint;
//    }
    
//    _player.position = ccp(x,y);
//    [self addChild:_player];

    // Obtengo la ubicación en coordenadas de la matriz del tile (int,int)
    
//    CGPoint location = [touch locationInView: [touch view]];
//    location = [[CCDirector sharedDirector] convertToGL: location];
//    CGPoint mappos = [_tileMap convertToNodeSpace:location];
//    mappos.x = (int)(mappos.x / _tileMap.tileSize.height);
//    mappos.y = (int)(mappos.y / _tileMap.tileSize.width);
//    CCLOG(@"X: %f Y: %f\n",mappos.x,mappos.y);
    
//    CGPoint currentTouchPoint = [touch locationInView:[touch view]];
//    CCLOG(@"Posición: X: %f Y: %fn",currentTouchPoint.x,currentTouchPoint.y);
    
    // Recorro todas los lugares posibles donde se puede colocar una torre
//    int ctpx = currentTouchPoint.x - fmod(currentTouchPoint.x,28);
//    int ctpy = currentTouchPoint.y - fmod(currentTouchPoint.y,30);
    
//    NSMutableArray * towerDics = towersGroup.objects;
//    for (NSDictionary * towerDic in towerDics) {
//        int tdx = [towerDic[@"x"] integerValue];
//        int tdy = [towerDic[@"y"] integerValue];
//        if(ctpx > tdx && ctpx < tdx + 28 && ctpy > tdy && ctpy < tdy + 30) {
//            CCLOG(@"CTP: %d, %d  TD: %d, %d\n",ctpx,ctpy,tdx,tdy);
//            break;
//        }
//    }
    
    // TODO Coloco una torre en la posición indicada, pero centrada en la cuadrícula.
    
//    [self ccTouchEnded:touch withEvent:event];
}

//-(CGPoint) tileCoordForPosition: (CGPoint) position
//{
//    int x = (int)(position.x / _tileMap.tileSize.width);
//    int y = ((_tileMap.mapSize.height * _tileMap.tileSize.height) - position.y) / _tileMap.tileSize.height;
//    return ccp(x, y);
//}

//
//- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
//{
//    // Jeff se mueve a donde se haya hecho un touch.
//    CGPoint touchLocation = [self convertToNodeSpace:touch.locationInWorld];
//    CGPoint moveDifference = ccpSub(touchLocation, self.jeff.position);
//    CGSize winSize = [[CCDirector sharedDirector] viewSize];
//    float jeffSpeed = winSize.width / 10.0f;
//    float distanceToMove = ccpLength(moveDifference);
//    float moveDuration = distanceToMove / jeffSpeed;
//    [self.jeff stopAction:self.moveAction];
//    self.moveAction = [CCActionMoveTo actionWithDuration:moveDuration position:touchLocation];
//    [self.jeff runAction:self.moveAction];
//}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onBackClicked:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:1.0f]];
}

// -----------------------------------------------------------------------

-(void)createScoreLabel
{
    score = 100000;
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

-(void)createMoneyLabel
{
    CCSprite * moneyBg = [CCSprite spriteWithImageNamed:@"money_bg.png"];
    moneyBg.positionType = CCPositionTypeNormalized;
    moneyBg.position = ccp(0.95f, 0.80f);
    [self addChild:moneyBg];
    money = 100;
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

@end