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
    NSString * wavesString;
    CCLabelTTF * wavesLabel;
    int waveCount;
    NSString * moneyString;
    CCLabelTTF * moneyLabel;
    int money;
    NSString * scoreString;
    CCLabelTTF * scoreLabel;
    int score;
    NSMutableSet * placedTowers;
    BOOL buybutton1selected;
    BOOL buybutton2selected;
    CGPoint startPosition;
    int maxHP;
    NSMutableSet * currentEnemies;
    NSDictionary * startPoint;
    int count;
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
    _tileMap = [CCTiledMap tiledMapWithFile:@"TileMap.tmx"];
    _background = [_tileMap layerNamed:@"Background"];
    [self addChild:_tileMap];
    objectGroup = [_tileMap objectGroupNamed:@"Path"];
    NSAssert(objectGroup != nil, @"tile map has no Path object layer");
    startPoint = [objectGroup objectNamed:_tileMap.properties[@"startPosition"]];
    startPosition = ccp([startPoint[@"x"] integerValue],[startPoint[@"y"] integerValue]);
    towersGroup = [_tileMap objectGroupNamed:@"Towers"];
    NSAssert(towersGroup != nil, @"tile map has no objects Towers layer");
    // Música de fondo
    OALSimpleAudio * bgmusic = [OALSimpleAudio sharedInstance];
    [bgmusic playBg:@"LevelMusic.mp3" loop:TRUE];
    buybutton1selected = NO;
    buybutton2selected = NO;
    maxHP = 1000;
    count = 1;
    placedTowers = [NSMutableSet setWithCapacity:100];
    currentEnemies = [NSMutableSet setWithCapacity:100];
    [self createBackButton];
    [self createMoneyLabelWithInitialMoney:100];
    [self createWavesLabel];
    [self createScoreLabelWithInitialScore:100000];
    [self createTowerButtons];
    [self initSpriteSheetWithCharacterName:@"jeff"];
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
    [self schedule:@selector(createCharacter:) interval:2.0f];
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
    CCButton * button = (CCButton *)[self getChildByName:@"tower1buybutton" recursively:NO];
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
    CCButton * button = (CCButton *)[self getChildByName:@"tower2buybutton" recursively:NO];
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

- (void)initSpriteSheetWithCharacterName:(NSString *)characterName
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist",characterName]];
    CCSpriteBatchNode * spriteSheet;
    spriteSheet = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@.png",characterName]];
    [self addChild:spriteSheet z:10 name:@"spriteSheet"];
}

- (void)createCharacterSprite:(NSString *)characterName withPosition:(CGPoint)point
{
    NSMutableArray * walkAnimFrames = [NSMutableArray array];
    for (int i=1; i<=SPRITE_SIZE; i++) {
        [walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"%@-%@-%d.png",characterName,startPoint[@"direction"],i]]];
    }
    CCAnimation * walkAnim;
    walkAnim = [CCAnimation animationWithSpriteFrames:walkAnimFrames delay:0.1f];
    CCSprite * newCharacter;
    newCharacter = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"%@-%@-1.png",characterName,startPoint[@"direction"]]];
    newCharacter.position = point;
    CCAction * walkAction;
    walkAction = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:walkAnim]];
    walkAction.tag = @"walk";
    [newCharacter runAction:walkAction];
    [[self getChildByName:@"spriteSheet" recursively:NO] addChild:newCharacter z:2 name:[NSString stringWithFormat:@"nc%d",count]];
    NSMutableDictionary * characterMutableDictionary = [NSMutableDictionary dictionary];
    [characterMutableDictionary setObject:newCharacter forKey:@"characterSprite"];
    [characterMutableDictionary setObject:startPoint forKey:@"characterPoint"];
    [characterMutableDictionary setObject:@"jeff" forKey:@"characterName"];
    [characterMutableDictionary setObject:[NSString stringWithFormat:@"%d",maxHP] forKey:@"characterHP"];
    [characterMutableDictionary setObject:[NSString stringWithFormat:@"%d",count] forKey:@"id"];
    [currentEnemies addObject:characterMutableDictionary];
    count++;
}

- (void)updateCharacterSprite:(NSMutableDictionary *)character
{
    CCSprite * s = character[@"characterSprite"];
    NSMutableArray * walkAnimFrames = [NSMutableArray array];
    for (int i=1; i<=SPRITE_SIZE; i++) {
        [walkAnimFrames addObject: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
        [NSString stringWithFormat:@"%@-%@-%d.png",character[@"characterName"],character[@"characterPoint"][@"direction"],i]]];
    }
    CCAnimation * walkAnim;
    walkAnim = [CCAnimation animationWithSpriteFrames:walkAnimFrames delay:0.1f];
    [s stopAction:[s getActionByTag:@"walk"]];
    CCAction * walkAction;
    walkAction = [CCActionRepeatForever actionWithAction:[CCActionAnimate actionWithAnimation:walkAnim]];
    walkAction.tag = @"walk";
    [s runAction:walkAction];
}

- (void)moveCharacter:(CCTime)dt
{
    for (NSMutableDictionary * d in currentEnemies) {
        NSDictionary * nextPoint = [objectGroup objectNamed:d[@"characterPoint"][@"next"]];
        [d setObject:nextPoint forKey:@"characterPoint"];
        [self updateCharacterSprite:d];
        CCSprite * s = d[@"characterSprite"];
        if([d[@"characterPoint"][@"next"] isEqual: @"p0"]) {
            [self playAudioEffectNamed:@"pickup.caf"];
            [self increaseWavesCount:1];
            [self changeScore:-10000];
            [s stopAction:[s getActionByTag:@"walk"]];
            [[self getChildByName:@"spriteSheet" recursively:NO] removeChildByName:[NSString stringWithFormat:@"nc%@",d[@"id"]] cleanup:YES];
            [d setObject:[NSString stringWithFormat:@"0"] forKey:@"characterHP"];
        } else {
            CGPoint destinyLocation = ccp([d[@"characterPoint"][@"x"] floatValue],[d[@"characterPoint"][@"y"] floatValue]);
            _moveAction = [CCActionMoveTo actionWithDuration:dt position:destinyLocation];
            [s runAction: _moveAction];
        }
    }
}

- (BOOL)checkCircleCollision:(CGPoint)center1 ofRadius:(float)radius1 withCircleCentered:(CGPoint)center2 ofRadius:(float)radius2 {
    float distance = sqrt(pow((center2.x-center1.x), 2) + pow((center2.y-center1.y), 2));
    return distance < (radius1 + radius2);
}

- (void)characterIsNearATower
{
    NSMutableSet * toRemove = [NSMutableSet setWithCapacity:100];
    for (NSMutableDictionary * d in currentEnemies) {
        for (NSDictionary * t in placedTowers) {
            Tower * currentTower = [t valueForKey:@"towerInstance"];
            CCSprite * s = d[@"characterSprite"];
            if([self checkCircleCollision:s.position ofRadius:[s contentSize].width/4  withCircleCentered:ccp([t[@"x"] floatValue],[t[@"y"] floatValue]) ofRadius:[currentTower getAttackRange]]) {
                long auxHP = [d[@"characterHP"] integerValue];
                auxHP -= [currentTower getDamage];
                [self playAudioEffectNamed:@"move.caf"];
                [d setObject:[NSString stringWithFormat:@"%ld",auxHP] forKey:@"characterHP"];
                if(auxHP <= 0) {
                    [[self getChildByName:@"spriteSheet" recursively:NO] removeChildByName:[NSString stringWithFormat:@"nc%@",d[@"id"]] cleanup:YES];
                    [toRemove addObject:d];
                }
            }
        }
    }
    for (NSMutableDictionary * d in toRemove) {
        [currentEnemies removeObject:d];
    }
}

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
    [towerBase setValue:tower forKey:@"towerInstance"];
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
                CCButton * button = (CCButton *)[self getChildByName:@"tower1buybutton" recursively:NO];
                [self playAudioEffectNamed:@"hit.caf"];
                buybutton1selected = NO;
                button.selected = NO;
            } else if (buybutton2selected && [self canBuyTower: [MissileTower alloc]]) {
                [self addTower:tb inPosition:ccp(towerX,towerY) withType: [MissileTower alloc]];
                CCButton * button = (CCButton *)[self getChildByName:@"tower2buybutton" recursively:NO];
                [self playAudioEffectNamed:@"hit.caf"];
                buybutton2selected = NO;
                button.selected = NO;
            }
        }
    }
}

- (void)drawHealthBar
{
    for(int i = 1; i < count; i++) {
        NSString * baseBarString = [NSString stringWithFormat:@"baseBar%@",[NSString stringWithFormat:@"%d",i]];
        if ([self getChildByName:baseBarString recursively:NO] != nil){
            [self removeChildByName:baseBarString cleanup:YES];
        }
        NSString * healthBarString = [NSString stringWithFormat:@"healthBar%@",[NSString stringWithFormat:@"%d",i]];
        if ([self getChildByName:healthBarString recursively:NO] != nil){
            [self removeChildByName:healthBarString cleanup:YES];
        }
    }
    for (NSMutableDictionary * d in currentEnemies) {
        CCSprite * s = d[@"characterSprite"];
        long auxHP = [d[@"characterHP"] integerValue];
        if(auxHP > 0) {
            CCNodeColor * baseBar = [CCNodeColor nodeWithColor:[CCColor redColor] width:10 height:2];
            baseBar.position = ccp(s.position.x-5,s.position.y + 25);
            NSString * baseBarString = [NSString stringWithFormat:@"baseBar%@",d[@"id"]];
            [self addChild:baseBar z:3 name:baseBarString];
            CCNodeColor * healthBar = [CCNodeColor nodeWithColor:[CCColor greenColor] width:auxHP/100 height:2];
            healthBar.position = ccp(s.position.x-5,s.position.y + 25);
            NSString * healthBarString = [NSString stringWithFormat:@"healthBar%@",d[@"id"]];
            [self addChild:healthBar z:3 name:healthBarString];
        }
    }
}

- (void)update:(CCTime)delta
{
    [self characterIsNearATower];
    [self drawHealthBar];
}

- (void)createCharacter:(CCTime)dt
{
    if(count <= 10) {
        [self createCharacterSprite:@"jeff" withPosition:startPosition];
    }
}

@end