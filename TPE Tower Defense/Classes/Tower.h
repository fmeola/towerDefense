#import "cocos2d.h"
#import "HelloWorldScene.h"

#define kTOWER_COST 300

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

@end