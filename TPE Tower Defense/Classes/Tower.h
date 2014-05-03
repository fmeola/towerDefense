#import "cocos2d.h"
#import "HelloWorldScene.h"

@class HelloWorldScene;

@interface Tower : CCNode {
    int attackRange;
    int damage;
    float fireRate;
    BOOL attacking;
}

@property (nonatomic,strong) HelloWorldScene * theGame;
@property (nonatomic,strong) CCSprite * towerSprite;

+(id)nodeWithTheGame:(HelloWorldScene *)_game location:(CGPoint)location;
-(id)initWithTheGame:(HelloWorldScene *)_game location:(CGPoint)location;
-(int)getPrice;

@end