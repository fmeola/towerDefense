#import "CCNode.h"
#import "HelloWorldScene.h"

@interface Enemy : CCNode {
    CGPoint myPosition;
    int maxHp;
    int currentHp;
    float walkingSpeed;
    BOOL active;
    NSMutableArray * attackedBy;
}

@property (nonatomic,assign) HelloWorldScene * theGame;
@property (nonatomic,assign) CCSprite * mySprite;

+ (id)nodeWithTheGame:(HelloWorldScene *)game;
- (id)initWithTheGame:(HelloWorldScene *)game;

@end