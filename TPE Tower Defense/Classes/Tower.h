#import "HelloWorldScene.h"

@interface Tower : CCNode
// -----------------------------------------------------------------------

@property (nonatomic,strong) HelloWorldScene * theGame;
@property (nonatomic,strong) CCSprite * towerSprite;
@property (nonatomic) Boolean * isShooting;

+ (id)nodeWithTheGame:(HelloWorldScene *)game location:(CGPoint)location;
- (id)initWithTheGame:(HelloWorldScene *)game location:(CGPoint)location;
- (int)getPrice;
- (int)getDamage;
- (int)getAttackRange;

// -----------------------------------------------------------------------
@end