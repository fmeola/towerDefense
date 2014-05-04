#import "HelloWorldScene.h"

@interface Tower : CCNode {
    int attackRange;
    int damage;
    float fireRate;
    BOOL attacking;
}
// -----------------------------------------------------------------------

@property (nonatomic,strong) HelloWorldScene * theGame;
@property (nonatomic,strong) CCSprite * towerSprite;

+ (id)nodeWithTheGame:(HelloWorldScene *)game location:(CGPoint)location;
- (id)initWithTheGame:(HelloWorldScene *)game location:(CGPoint)location;
- (int)getPrice;

// -----------------------------------------------------------------------
@end