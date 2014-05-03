#import "Tower.h"
//#import "Enemy.h"
#import "CCDrawingPrimitives.h"

@implementation Tower

@synthesize mySprite,theGame;

+(id)nodeWithTheGame:(HelloWorldScene *)_game location:(CGPoint)location
{
    return [[self alloc] initWithTheGame:_game location:location];
}

-(id)initWithTheGame:(HelloWorldScene *)_game location:(CGPoint)location
{
	if( (self=[super init])) {
		theGame = _game;
        attackRange = 70;
        damage = 10;
        fireRate = 1;
        mySprite = [CCSprite spriteWithImageNamed:
                    [NSString stringWithFormat:@"%@.png",[self getTowerName]]];
		[self addChild:mySprite];
        //ver de hacerlo más genérico
        CGPoint trueLocation = ccp(location.x+20, location.y+20);
        [mySprite setPosition:trueLocation];
        [theGame addChild:self];
//        [self scheduleUpdate];
	}
	return self;
}

-(NSString *)getTowerName
{
    return @"Gattling";
}

-(int)getPrice
{
    return 10;
}

-(void)draw
{
    ccDrawColor4B(255,255,255,255);
    ccDrawCircle(mySprite.position, attackRange, 360, 30, false);
    [super draw];
}

//-(void)update:(CCTime)dt
//{
//    if (chosenEnemy){
//        
//        //We make it turn to target the enemy chosen
//        CGPoint normalized = ccpNormalize(ccp(chosenEnemy.mySprite.position.x-mySprite.position.x,chosenEnemy.mySprite.position.y-mySprite.position.y));
//        mySprite.rotation = CC_RADIANS_TO_DEGREES(atan2(normalized.y,-normalized.x))+90;
//        
//        if(![theGame circle:mySprite.position withRadius:attackRange collisionWithCircle:chosenEnemy.mySprite.position collisionCircleRadius:1])
//        {
//            [self lostSightOfEnemy];
//        }
//    } else {
//        for(Enemy * enemy in theGame.enemies)
//        {
//            if([theGame circle:mySprite.position withRadius:attackRange collisionWithCircle:enemy.mySprite.position collisionCircleRadius:1])
//            {
//                [self chosenEnemyForAttack:enemy];
//                break;
//            }
//        }
//    }
//}
//
//-(void)attackEnemy
//{
//    [self schedule:@selector(shootWeapon) interval:fireRate];
//}
//
//-(void)chosenEnemyForAttack:(Enemy *)enemy
//{
//    chosenEnemy = nil;
//    chosenEnemy = enemy;
//    [self attackEnemy];
//    [enemy getAttacked:self];
//}
//
//-(void)shootWeapon
//{
//    CCSprite * bullet = [CCSprite spriteWithFile:@"bullet.png"];
//    [theGame addChild:bullet];
//    [bullet setPosition:mySprite.position];
//    [bullet runAction:[CCSequence actions:[CCMoveTo actionWithDuration:0.1 position:chosenEnemy.mySprite.position],[CCCallFunc actionWithTarget:self selector:@selector(damageEnemy)],[CCCallFuncN actionWithTarget:self selector:@selector(removeBullet:)], nil]];
//    
//    
//}
//
//-(void)removeBullet:(CCSprite *)bullet
//{
//    [bullet.parent removeChild:bullet cleanup:YES];
//}
//
//-(void)damageEnemy
//{
//    [chosenEnemy getDamaged:damage];
//}
//
//-(void)targetKilled
//{
//    if(chosenEnemy)
//        chosenEnemy =nil;
//    
//    [self unschedule:@selector(shootWeapon)];
//}
//
//-(void)lostSightOfEnemy
//{
//    [chosenEnemy gotLostSight:self];
//    if(chosenEnemy)
//        chosenEnemy =nil;
//    
//    [self unschedule:@selector(shootWeapon)];
//}

@end