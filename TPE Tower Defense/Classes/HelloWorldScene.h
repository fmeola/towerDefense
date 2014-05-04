#import "cocos2d.h"
#import "cocos2d-ui.h"

#define SPRITE_SIZE 3
// -----------------------------------------------------------------------

@interface HelloWorldScene : CCScene <CCPhysicsCollisionDelegate>

@property (nonatomic,strong) CCTiledMap * tileMap;
@property (nonatomic,strong) CCTiledMapLayer * background;
@property (nonatomic,strong) CCSprite * character;
@property (nonatomic,strong) CCAction * walkAction;
@property (nonatomic,strong) CCAction * moveAction;
@property (nonatomic,strong) CCAnimation * walkAnim;
@property (nonatomic,strong) NSMutableArray * towers;

// -----------------------------------------------------------------------

+ (HelloWorldScene *) scene;
- (id)init;

// -----------------------------------------------------------------------
@end