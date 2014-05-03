#import "cocos2d.h"
#import "HelloWorldScene.h"

@class HelloWorldScene;
//, Enemy

@interface Tower: CCNode {
    int attackRange;
    int damage;
    float fireRate;
    BOOL attacking;
//    Enemy * chosenEnemy;
}

@property (nonatomic,assign) HelloWorldScene * theGame;
@property (nonatomic,assign) CCSprite * mySprite;

+(id)nodeWithTheGame:(HelloWorldScene *)_game location:(CGPoint)location;
-(id)initWithTheGame:(HelloWorldScene *)_game location:(CGPoint)location;
//-(void)targetKilled;
-(int)getPrice;
@end