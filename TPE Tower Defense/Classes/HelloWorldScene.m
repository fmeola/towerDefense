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
    // TMX
    CCTiledMapObjectGroup * objectGroup;
    CCTiledMapObjectGroup * towersGroup;
    NSDictionary * startPoint;
    // Music
    OALSimpleAudio * bgmusic;
    // Tries Label
    NSString * triesString;
    CCLabelTTF * triesLabel;
    int triesCount;
    // Money Label
    NSString * moneyString;
    CCLabelTTF * moneyLabel;
    int money;
    // Score Label
    NSString * scoreString;
    CCLabelTTF * scoreLabel;
    int score;
    // Enemies
    NSString * currentCharacterName;
    NSMutableSet * currentEnemies;
    // Towers
    NSMutableSet * placedTowers;
    BOOL buybutton1selected;
    BOOL buybutton2selected;
    // Counters
    int count;
    int waveCount;
    int deadCount;
    int totalEnemyCount;
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
    self = [super init];
    if (!self) return(nil);
    self.userInteractionEnabled = YES;
    _tileMap = [CCTiledMap tiledMapWithFile:@"TileMap.tmx"];
    _background = [_tileMap layerNamed:@"Background"];
    [self addChild:_tileMap];
    objectGroup = [_tileMap objectGroupNamed:@"Path"];
    NSAssert(objectGroup != nil, @"tile map has no Path object layer");
    startPoint = [objectGroup objectNamed:_tileMap.properties[@"startPosition"]];
    towersGroup = [_tileMap objectGroupNamed:@"Towers"];
    NSAssert(towersGroup != nil, @"tile map has no objects Towers layer");
    bgmusic = [OALSimpleAudio sharedInstance];
    [bgmusic playBg:@"LevelMusic.mp3" loop:TRUE];
    buybutton1selected = NO;
    buybutton2selected = NO;
    waveCount = 1;
    count = 1;
    deadCount = 0;
    totalEnemyCount = WAVE_ENEMY_COUNT;
    currentCharacterName = @"jeff";
    placedTowers = [NSMutableSet setWithCapacity:10];
    currentEnemies = [NSMutableSet setWithCapacity:10];
    [self createBackButton];
    [self createMoneyLabelWithInitialMoney:50];
    [self createTriesLabel];
    [self createScoreLabelWithInitialScore:0];
    [self createTowerButtons];
    [self initSpriteSheet];
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
    [super onEnter];
    [self schedule:@selector(endCharacter:) interval:1.0f];
    [self schedule:@selector(moveCharacter:) interval:1.0f];
    [self schedule:@selector(createCharacter:) interval:2.0f];
}

// -----------------------------------------------------------------------

- (void)onExit
{
    [super onExit];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if([self anyBuyButtonIsSelected])
        [self tryAddTower:touch];
    else
        [self tryRemoveTower:touch];
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
#pragma mark - HUD
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

- (void)createTriesLabel
{
    CCSprite * triesBg = [CCSprite spriteWithImageNamed:@"wave_bg.png"];
    triesBg.positionType = CCPositionTypeNormalized;
    triesBg.position = ccp(0.95f, 0.92f);
    [self addChild:triesBg z:5];
    triesCount = 0;
    [self defaultTriesLabel];
    [self addChild:triesLabel z:6];
}

- (void)increaseTriesCount:(int)diff
{
    triesCount += diff;
    [self removeChild:triesLabel];
    [self defaultTriesLabel];
    [self addChild:triesLabel z:6];
    if (triesCount == MAX_TRIES_COUNT) {
        [self lostGame];
    }
}

- (void)defaultTriesLabel
{
    triesString = [NSString stringWithFormat:@"%d / %d",triesCount, MAX_TRIES_COUNT];
    triesLabel = [CCLabelTTF labelWithString: triesString fontName:@"Helvetica-Bold" fontSize:16.0f];
    triesLabel.positionType = CCPositionTypeNormalized;
    triesLabel.color = [CCColor whiteColor];
    triesLabel.position = ccp(0.95f, 0.91f);
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

- (CGPoint)tileFromPosition:(CGPoint)position
{
    NSInteger x = (NSInteger)(position.x / _tileMap.tileSize.width);
    NSInteger y = (NSInteger)(((_tileMap.mapSize.height * _tileMap.tileSize.width) - position.y) / _tileMap.tileSize.width);
    return ccp(x, y);
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

- (BOOL)anyBuyButtonIsSelected
{
    return buybutton1selected || buybutton2selected;
}

// -----------------------------------------------------------------------
#pragma mark - Sounds
// -----------------------------------------------------------------------

- (void)playAudioEffectNamed:(NSString *)name
{
    OALSimpleAudio * audio = [OALSimpleAudio sharedInstance];
    [audio playEffect:name];
}

// -----------------------------------------------------------------------
#pragma mark - SpriteSheet
// -----------------------------------------------------------------------

- (void)initSpriteSheet
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%s.plist",SPRITESHEET_NAME]];
    CCSpriteBatchNode * spriteSheet;
    spriteSheet = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%s.png",SPRITESHEET_NAME]];
    [self addChild:spriteSheet z:10 name:@"spriteSheet"];
}

- (void)createCharacterSprite:(NSString *)characterName withPosition:(CGPoint)point
{
    NSMutableArray * walkAnimFrames = [NSMutableArray array];
    for (int i = 1; i <= SPRITE_SIZE; i++) {
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
    [characterMutableDictionary setObject:currentCharacterName forKey:@"characterName"];
    [characterMutableDictionary setObject:[NSString stringWithFormat:@"%d",MAX_HP] forKey:@"characterHP"];
    [characterMutableDictionary setObject:[NSString stringWithFormat:@"%d",count] forKey:@"id"];
    [currentEnemies addObject:characterMutableDictionary];
    count++;
}

- (void)updateCharacterSprite:(NSMutableDictionary *)character
{
    CCSprite * s = character[@"characterSprite"];
    NSMutableArray * walkAnimFrames = [NSMutableArray array];
    for (int i = 1; i <= SPRITE_SIZE; i++) {
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

- (void)drawHealthBar
{
    for(int i = 1; i < WAVE_ENEMY_COUNT + 1; i++) {
        NSString * baseBarString = [NSString stringWithFormat:@"baseBar%@",[NSString stringWithFormat:@"%d",i]];
        if ([self getChildByName:baseBarString recursively:NO] != nil){
            [[self getChildByName:baseBarString recursively:NO] removeFromParentAndCleanup:YES];
        }
        NSString * healthBarString = [NSString stringWithFormat:@"healthBar%@",[NSString stringWithFormat:@"%d",i]];
        if ([self getChildByName:healthBarString recursively:NO] != nil){
            [[self getChildByName:healthBarString recursively:NO] removeFromParentAndCleanup:YES];
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

- (void)createFallingCharacterSprite:(NSString *)characterName withPosition:(CGPoint)point
{
    NSMutableArray * walkAnimFrames = [NSMutableArray array];
    for (int i = 1; i <= SPRITE_SIZE; i++) {
        [walkAnimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"%@-fall-%@-%d.png",characterName,startPoint[@"direction"],i]]];
    }
    CCAnimation * walkAnim;
    walkAnim = [CCAnimation animationWithSpriteFrames:walkAnimFrames delay:0.2f];
    CCSprite * newCharacter;
    newCharacter = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"%@-%@-1.png",characterName,startPoint[@"direction"]]];
    newCharacter.position = point;
    CCAction * fallAction;
    fallAction = [CCActionRepeat actionWithAction:[CCActionAnimate actionWithAnimation:walkAnim] times:1];
    fallAction.tag = @"fall";
    [newCharacter runAction:fallAction];
    [[self getChildByName:@"spriteSheet" recursively:NO] addChild:newCharacter z:2 name:[NSString stringWithFormat:@"fall%d",deadCount]];
    deadCount++;
    [self changeScore:100];
    [self changeMoney:5];
}

// -----------------------------------------------------------------------
#pragma mark - Towers
// -----------------------------------------------------------------------

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

- (void)tryAddTower:(UITouch *)touch
{
    CGPoint location = [touch locationInView: [touch view]];
    NSInteger x = [self tileFromPosition:location].x * _tileMap.tileSize.width;
    NSInteger y = [self tileFromPosition:location].y * _tileMap.tileSize.height;
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

- (void)tryRemoveTower:(UITouch *)touch
{
    CGPoint location = [touch locationInView: [touch view]];
    NSInteger x = [self tileFromPosition:location].x * _tileMap.tileSize.width;
    NSInteger y = [self tileFromPosition:location].y * _tileMap.tileSize.height;
    NSMutableSet * toRemove = [NSMutableSet setWithCapacity:10];
    for (NSDictionary * t in placedTowers) {
        Tower * currentTower = [t valueForKey:@"towerInstance"];
        int tx = currentTower.towerSprite.position.x - 20;
        int ty = currentTower.towerSprite.position.y - 20;
        if(x == tx && y == ty) {
            [toRemove addObject:t];
            [[currentTower towerSprite] removeFromParentAndCleanup:YES];
            [currentTower removeFromParentAndCleanup:YES];
            
        }
    }
    for (NSDictionary * tr in toRemove) {
        [placedTowers removeObject:tr];
    }
}

- (void)addTower:(NSDictionary *)towerBase inPosition:(CGPoint)position withType:(Tower *)type
{
    Tower * tower = [type.class nodeWithTheGame:self location:position];
    [towers addObject:tower];
    [towerBase setValue:tower forKey:@"towerInstance"];
    [placedTowers addObject:towerBase];
}

- (BOOL)checkCircleCollision:(CGPoint)center1 ofRadius:(float)radius1 withCircleCentered:(CGPoint)center2 ofRadius:(float)radius2 {
    float distance = sqrt(pow((center2.x-center1.x), 2) + pow((center2.y-center1.y), 2));
    return distance < (radius1 + radius2);
}

- (void)characterIsNearATower
{
    NSMutableSet * toRemove = [NSMutableSet setWithCapacity:10];
    for (NSMutableDictionary * d in currentEnemies) {
        for (NSDictionary * t in placedTowers) {
            Tower * currentTower = [t valueForKey:@"towerInstance"];
            CCSprite * s = d[@"characterSprite"];
            if([self checkCircleCollision:s.position ofRadius:[s contentSize].width/4  withCircleCentered:ccp([t[@"x"] floatValue],[t[@"y"] floatValue]) ofRadius:[currentTower getAttackRange]] && !currentTower.isShooting) {
                int ctx = currentTower.towerSprite.position.x;
                int cty = currentTower.towerSprite.position.y;
                CGPoint aux = ccp(s.position.x-ctx,s.position.y-cty);
                CGPoint normalized = ccpNormalize(aux);
                [currentTower towerSprite].rotation = CC_RADIANS_TO_DEGREES(atan2(normalized.y,-normalized.x)) + 90;
                currentTower.isShooting = YES;
                long auxHP = [d[@"characterHP"] integerValue];
                auxHP -= [currentTower getDamage];
                [bgmusic playEffect:@"shot.mp3" volume:0.1f pitch:1.0f pan:0 loop:NO];
                CCSprite * bullet = [CCSprite spriteWithImageNamed:@"BulletSprite.png"];
                [self addChild: bullet];
                bullet.position =  currentTower.towerSprite.position;
                [bullet runAction: [CCActionSequence actionOne:[CCActionMoveTo actionWithDuration:0.1 position:s.position] two:[CCActionRemove action]]];
                [d setObject:[NSString stringWithFormat:@"%ld",auxHP] forKey:@"characterHP"];
                if(auxHP <= 0) {
                    [[d objectForKey:@"characterSprite"] removeFromParentAndCleanup:YES];
                    [toRemove addObject:d];
                    CGPoint currentPosition = ccp([d[@"characterPoint"][@"x"] floatValue],[d[@"characterPoint"][@"y"] floatValue]);
                    [self createFallingCharacterSprite:d[@"characterName"] withPosition:currentPosition];
                }
            }
        }
    }
    for (NSMutableDictionary * d in toRemove) {
        [currentEnemies removeObject:d];
    }
    for (NSDictionary * t in placedTowers) {
        Tower * currentTower = [t valueForKey:@"towerInstance"];
        currentTower.isShooting = NO;
    }
}

// -----------------------------------------------------------------------
#pragma mark - Schedulers
// -----------------------------------------------------------------------

- (void)update:(CCTime)delta
{
    [self characterIsNearATower];
    [self drawHealthBar];
    if (waveCount > LEVEL_WAVE_COUNT) {
        [self wonGame];
    }
    if(totalEnemyCount == 0) {
        [self nextWaveWith:@"trainjeff"];
    }
}

- (void)createCharacter:(CCTime)delta
{
    if(count <= WAVE_ENEMY_COUNT) {
        [self createCharacterSprite:currentCharacterName withPosition:
         ccp([startPoint[@"x"] integerValue],[startPoint[@"y"] integerValue])
         ];
    }
}

- (void)moveCharacter:(CCTime)delta
{
    for (NSMutableDictionary * d in currentEnemies) {
        NSDictionary * nextPoint = [objectGroup objectNamed:d[@"characterPoint"][@"next"]];
        [d setObject:nextPoint forKey:@"characterPoint"];
        [self updateCharacterSprite:d];
        CCSprite * s = d[@"characterSprite"];
        if([d[@"characterPoint"][@"next"] isEqual: @"p0"]) {
            /*
             * Enemigos que cruzaron todo el mapa.
             */
            [self playAudioEffectNamed:@"pickup.caf"];
            [self increaseTriesCount:1];
            [s stopAction:[s getActionByTag:@"walk"]];
            [[d objectForKey:@"characterSprite"]removeFromParentAndCleanup:YES];
            [d setObject:[NSString stringWithFormat:@"0"] forKey:@"characterHP"];
            totalEnemyCount--;
            // ¿Por qué pasa esto?
            if(totalEnemyCount < 0) {
                totalEnemyCount = 0;
            }
        } else {
            CGPoint destinyLocation = ccp([d[@"characterPoint"][@"x"] floatValue],[d[@"characterPoint"][@"y"] floatValue]);
            _moveAction = [CCActionMoveTo actionWithDuration:delta position:destinyLocation];
            [s runAction: _moveAction];
        }
    }
}

- (void)endCharacter:(CCTime)delta
{
    /*
     * Para los enemigos que mató el jugador.
     */
    NSMutableSet * s = [NSMutableSet setWithCapacity:100];
    CCNode * a = [self getChildByName:@"spriteSheet" recursively:NO];
    for (int i = 0; i <= WAVE_ENEMY_COUNT + 1; i++) {
        CCNode * x = [a getChildByName:[NSString stringWithFormat:@"fall%d",i] recursively:NO];
        if (x != nil) {
            totalEnemyCount--;
            // ¿Por qué pasa esto?
            if(totalEnemyCount < 0)
                totalEnemyCount = 0;
            [s addObject:x];
        }
    }
    for (CCNode * r in s) {
        [r removeFromParentAndCleanup:YES];
    }
}

// -----------------------------------------------------------------------
#pragma mark - Waves
// -----------------------------------------------------------------------

- (void)nextWaveWith:(NSString *)characterName
{
    totalEnemyCount = WAVE_ENEMY_COUNT;
    waveCount++;
    deadCount = 0;
    count = 1;
    for (NSMutableDictionary * d in currentEnemies) {
        if ([d objectForKey:@"characterSprite"] != nil){
            [[d objectForKey:@"characterSprite"] removeFromParentAndCleanup:YES];
        }
    }
    [currentEnemies removeAllObjects];
    currentCharacterName = characterName;
}

// -----------------------------------------------------------------------
#pragma mark - Alertas
// -----------------------------------------------------------------------

- (void)lostGame
{
    UIAlertView * alert = [[UIAlertView alloc]
                           initWithTitle:@"Perdiste 😭"
                           message: [NSString stringWithFormat:@"Puntaje: %d",score]
                           delegate:nil
                           cancelButtonTitle:@"Continuar"
                           otherButtonTitles:nil];
    [alert show];
    [self onBackClicked:self];
}

- (void)wonGame
{
    UIAlertView * alert = [[UIAlertView alloc]
                           initWithTitle:@"¡Ganaste! 😃"
                           message: [NSString stringWithFormat:@"Puntaje: %d",score]
                           delegate:nil
                           cancelButtonTitle:@"Continuar"
                           otherButtonTitles:nil];
    [alert show];
    [self onBackClicked:self];
}

@end