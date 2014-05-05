#import "HelloWorldScene.h"
#import "IntroScene.h"
#import "CCAnimation.h"
#import "Tower.h"
#import "MissileTower.h"

// -----------------------------------------------------------------------
#pragma mark - HelloWorldScene
// -----------------------------------------------------------------------

@implementation HelloWorldScene
{
    CCTiledMapObjectGroup * objectGroup;
    CCTiledMapObjectGroup * towersGroup;
    NSDictionary * currentPoint;
    NSString * wavesString;
    CCLabelTTF * wavesLabel;
    int waveCount;
    NSString * moneyString;
    CCLabelTTF * moneyLabel;
    int money;
    NSString * scoreString;
    CCLabelTTF * scoreLabel;
    int score;
    CCSpriteBatchNode * spriteSheet;
    NSString * currrentCharacterName;
    NSMutableSet * placedTowers;
    BOOL buybutton1selected;
    BOOL buybutton2selected;
    CGPoint startPosition;
    CCPhysicsNode *_physicsWorld;
    int currentHP;
    int maxHP;
}

@synthesize towers;

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
    
    _physicsWorld = [CCPhysicsNode node];
    _physicsWorld.gravity = ccp(0,0);
    _physicsWorld.debugDraw = NO;
    _physicsWorld.collisionDelegate = self;
    [self addChild:_physicsWorld];

    _tileMap = [CCTiledMap tiledMapWithFile:@"TileMap.tmx"];
    _background = [_tileMap layerNamed:@"Background"];
    [self addChild:_tileMap];
    objectGroup = [_tileMap objectGroupNamed:@"Path"];
    NSAssert(objectGroup != nil, @"tile map has no Path object layer");
    NSDictionary * startPoint = [objectGroup objectNamed:_tileMap.properties[@"startPosition"]];
    startPosition = ccp([startPoint[@"x"] integerValue],[startPoint[@"y"] integerValue]);
    currentPoint = startPoint;
    towersGroup = [_tileMap objectGroupNamed:@"Towers"];
    NSAssert(towersGroup != nil, @"tile map has no objects Towers layer");
    // Música de fondo
    OALSimpleAudio * bgmusic = [OALSimpleAudio sharedInstance];
    [bgmusic playBg:@"LevelMusic.mp3" loop:TRUE];
    buybutton1selected = NO;
    buybutton2selected = NO;
    currrentCharacterName = @"jeff";
    [self createBackButton];
    [self createMoneyLabelWithInitialMoney:100];
    [self createWavesLabel];
    [self createScoreLabelWithInitialScore:100000];
    [self createTowerButtons];
    [self createCharacterSprite:currrentCharacterName withPosition:startPosition];
    placedTowers = [NSMutableSet setWithCapacity:100];
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
    [self schedule:@selector(moveCharacter:) interval:1.0f];
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

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if([self anyBuyButtonIsSelected])
        [self tryAddTower:touch];
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onBackClicked:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene] withTransition:[CCTransition transitionCrossFadeWithDuration:1.0f]];
}

- (void)onBuy1Clicked:(id)sender
{
    [self playAudioEffectNamed:@"move.caf"];
    CCButton * button = (CCButton *)[self getChildByName:@"tower1buybutton" recursively:YES];
    if(buybutton1selected) {
        buybutton1selected = NO;
        button.selected = NO;
    }
    else {
        buybutton1selected = YES;
        button.selected = YES;
    }
}

- (void)onBuy2Clicked:(id)sender
{
    [self playAudioEffectNamed:@"move.caf"];
    CCButton * button = (CCButton *)[self getChildByName:@"tower2buybutton" recursively:YES];
    if(buybutton2selected) {
        buybutton2selected = NO;
        button.selected = NO;
    }
    else {
        buybutton2selected = YES;
        button.selected = YES;
    }
}

// -----------------------------------------------------------------------

- (void)createScoreLabelWithInitialScore:(int)initial
{
    score = initial;
    [self defaultScoreLabel];
    [self addChild:scoreLabel];
}

- (void)changeScore:(int)diff
{
    score += diff;
    [self removeChild:scoreLabel];
    [self defaultScoreLabel];
    [self addChild:scoreLabel];
}

- (void)defaultScoreLabel
{
    scoreString = [NSString stringWithFormat:@"Puntaje: %d",score];
    scoreLabel = [CCLabelTTF labelWithString: scoreString fontName:@"Helvetica" fontSize:16.0f];
    scoreLabel.positionType = CCPositionTypeNormalized;
    scoreLabel.color = [CCColor blackColor];
    scoreLabel.position = ccp(0.50f, 0.05f);
}

- (void)createWavesLabel
{
    CCSprite * waveBg = [CCSprite spriteWithImageNamed:@"wave_bg.png"];
    waveBg.positionType = CCPositionTypeNormalized;
    waveBg.position = ccp(0.95f, 0.92f);
    [self addChild:waveBg z:5];
    waveCount = 1;
    [self defaultWavesLabel];
    [self addChild:wavesLabel z:6];
}

- (void)increaseWavesCount:(int)diff
{
    waveCount += diff;
    [self removeChild:wavesLabel];
    [self defaultWavesLabel];
    [self addChild:wavesLabel z:6];
}

- (void)defaultWavesLabel
{
    wavesString = [NSString stringWithFormat:@"%d / N",waveCount];
    wavesLabel = [CCLabelTTF labelWithString: wavesString fontName:@"Helvetica-Bold" fontSize:16.0f];
    wavesLabel.positionType = CCPositionTypeNormalized;
    wavesLabel.color = [CCColor whiteColor];
    wavesLabel.position = ccp(0.95f, 0.91f);
}

- (void)createMoneyLabelWithInitialMoney:(int)initial
{
    CCSprite * moneyBg = [CCSprite spriteWithImageNamed:@"money_bg.png"];
    moneyBg.positionType = CCPositionTypeNormalized;
    moneyBg.position = ccp(0.95f, 0.80f);
    [self addChild:moneyBg z:5];
    money = initial;
    [self defaultMoneyLabel];
    [self addChild:moneyLabel z:6];
}

- (void)changeMoney:(int)diff
{
    money += diff;
    [self removeChild:moneyLabel];
    [self defaultMoneyLabel];
    [self addChild:moneyLabel z:6];
}

- (void)defaultMoneyLabel
{
    moneyString = [NSString stringWithFormat:@"$ %d",money];
    moneyLabel = [CCLabelTTF labelWithString: moneyString fontName:@"Helvetica-Bold" fontSize:16.0f];
    moneyLabel.positionType = CCPositionTypeNormalized;
    moneyLabel.color = [CCColor whiteColor];
    moneyLabel.position = ccp(0.95f, 0.79f);
}

- (void)createTowerButtons
{
    [self createTower1Button];
    [self createTower2Button];
}

- (void)createTower1Button
{
    CCButton * tower1buybutton = [CCButton buttonWithTitle:@""
                                               spriteFrame:[CCSpriteFrame frameWithImageNamed:@"icon-tower-1-enabled.png"]
                                    highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"icon-tower-1-disabled.png"]
                                       disabledSpriteFrame:nil];
    tower1buybutton.positionType = CCPositionTypeNormalized;
    tower1buybutton.position = ccp(0.83f, 0.10f);
    [tower1buybutton setTarget:self selector:@selector(onBuy1Clicked:)];
    [self addChild:tower1buybutton z:5 name:@"tower1buybutton"];
    CCLabelTTF * tower1price = [CCLabelTTF labelWithString:@"$10" fontName:@"Helvetica-Bold" fontSize:11.0f];
    tower1price.positionType = CCPositionTypeNormalized;
    tower1price.color = [CCColor blackColor];
    tower1price.position = [self getTowerPriceLabelPositionWithTowerButtonInPosition: tower1buybutton.position];
    [self addChild:tower1price z:6];
}

- (void)createTower2Button
{
    CCButton * tower2buybutton = [CCButton buttonWithTitle:@""
                                               spriteFrame:[CCSpriteFrame frameWithImageNamed:@"icon-tower-2-enabled.png"]
                                    highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"icon-tower-2-disabled.png"]
                                       disabledSpriteFrame:nil];
    tower2buybutton.positionType = CCPositionTypeNormalized;
    tower2buybutton.position = ccp(0.93f, 0.10f);
    [tower2buybutton setTarget:self selector:@selector(onBuy2Clicked:)];
    [self addChild:tower2buybutton z:5 name:@"tower2buybutton"];
    CCLabelTTF * tower2price = [CCLabelTTF labelWithString:@"$20" fontName:@"Helvetica-Bold" fontSize:11.0f];
    tower2price.positionType = CCPositionTypeNormalized;
    tower2price.color = [CCColor blackColor];
    tower2price.position = [self getTowerPriceLabelPositionWithTowerButtonInPosition: tower2buybutton.position];
    [self addChild:tower2price z:6];
}

- (CGPoint)getTowerPriceLabelPositionWithTowerButtonInPosition:(CGPoint) point
{
    return ccp(point.x+0.015,point.y-0.061);
}

- (void)createBackButton
{
    CCButton * backButton = [CCButton buttonWithTitle:@"[ Volver ]" fontName:@"Helvetica-Bold" fontSize:16.0f];
    backButton.color = [CCColor blackColor];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(0.10f, 0.95f);
    [backButton setTarget:self selector:@selector(onBackClicked:)];
    [self addChild:backButton];
}

- (void)playAudioEffectNamed:(NSString *)name
{
    OALSimpleAudio * audio = [OALSimpleAudio sharedInstance];
    [audio playEffect:name];
}

- (void)createCharacterSprite:(NSString *)characterName withPosition:(CGPoint)point
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist",characterName]];
    spriteSheet = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@.png",characterName]];
    [self addChild:spriteSheet];
    NSMutableArray * walkAnimFrames = [NSMutableArray array];
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
//    [_physicsWorld addChild:_character];
    [spriteSheet addChild:_character];
}

- (void)updateCharacerSprite:(NSString *)characterName
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
}

- (void)moveCharacter:(CCTime)dt
{
    NSDictionary * nextPoint = [objectGroup objectNamed:currentPoint[@"next"]];
    currentPoint = nextPoint;
    [self updateCharacerSprite:currrentCharacterName];
    if([currentPoint[@"next"] isEqual: @"p0"]) {
        [self playAudioEffectNamed:@"pickup.caf"];
        [self increaseWavesCount:1];
        [self changeScore:-10000];
        [_character stopAction:_walkAction];
        [spriteSheet removeChild:_character cleanup: YES];
        currrentCharacterName = @"trainjeff";
        [self createCharacterSprite:currrentCharacterName withPosition:startPosition];
    } else {
        CGPoint destinyLocation = ccp([currentPoint[@"x"] floatValue],[currentPoint[@"y"] floatValue]);
        _moveAction = [CCActionMoveTo actionWithDuration:dt position:destinyLocation];
        [_character runAction: _moveAction];
    }
}

- (void)characterIsNearATower
{
    for (NSDictionary * t in placedTowers) {
        float diff = ccpDistance(_character.position, ccp([t[@"x"] floatValue],[t[@"y"] floatValue]));
        if(diff < 70 + [_character contentSize].width/2) {
            CCLOG(@"Dentro del rango de una torre");
        }
    }
}

/*
 * Devuelve la posición de la Matriz Tile. Ejemplo:(3,5)
 */
- (CGPoint)tileFromPosition:(CGPoint)position
{
    NSInteger x = (NSInteger)(position.x / _tileMap.tileSize.width);
    NSInteger y = (NSInteger)(((_tileMap.mapSize.height * _tileMap.tileSize.width) - position.y) / _tileMap.tileSize.width);
    return ccp(x, y);
}

- (BOOL)spaceIsEmpty:(NSDictionary *)towerPlace
{
    for (NSDictionary * d in placedTowers) {
        if(d == towerPlace){
            return NO;
        }
    }
    return YES;
}

- (BOOL)canBuyTower:(Tower*)tower
{
    if(money - [tower getPrice] >= 0) {
        [self changeMoney:-[tower getPrice]];
        return YES;
    }
    return NO;
}

- (void)addTower:(NSDictionary *)towerBase inPosition:(CGPoint)position withType:(Tower *)type
{
    Tower * tower = [type.class nodeWithTheGame:self location:position];
    [towers addObject:tower];
    [placedTowers addObject:towerBase];
}

- (BOOL)anyBuyButtonIsSelected
{
    return buybutton1selected || buybutton2selected;
}

- (void)tryAddTower:(UITouch *)touch
{
    CGPoint location = [touch locationInView: [touch view]];
    NSInteger x = [self tileFromPosition:location].x * _tileMap.tileSize.width;
    NSInteger y = [self tileFromPosition:location].y * _tileMap.tileSize.height;
    NSLog(@"x:%ld, y:%ld",(long)x,(long)y);
    for(NSDictionary * tb in [towersGroup objects]) {
        NSInteger towerX = [tb[@"x"] intValue];
        NSInteger towerY = [tb[@"y"] intValue];
        if(x == towerX && y == towerY && [self spaceIsEmpty:tb]) {
            if(buybutton1selected && [self canBuyTower: [Tower alloc]]) {
                [self addTower:tb inPosition:ccp(towerX,towerY) withType:[Tower alloc]];
                CCButton * button = (CCButton *)[self getChildByName:@"tower1buybutton" recursively:YES];
                [self playAudioEffectNamed:@"hit.caf"];
                buybutton1selected = NO;
                button.selected = NO;
            } else if (buybutton2selected && [self canBuyTower: [MissileTower alloc]]) {
                [self addTower:tb inPosition:ccp(towerX,towerY) withType: [MissileTower alloc]];
                CCButton * button = (CCButton *)[self getChildByName:@"tower2buybutton" recursively:YES];
                [self playAudioEffectNamed:@"hit.caf"];
                buybutton2selected = NO;
                button.selected = NO;
            }
        }
    }
}

- (void)drawHealthBar
{
    [self removeChildByName:@"healthbar"];
    CCNodeColor * rectangleNode = [CCNodeColor nodeWithColor:[CCColor greenColor] width:10 height:2];
    rectangleNode.position = ccp(_character.position.x-5,_character.position.y + 25);
    [self addChild:rectangleNode z:3 name:@"healthbar"];
}

- (void)update:(CCTime)delta
{
    [self characterIsNearATower];
    [self drawHealthBar];
}

@end