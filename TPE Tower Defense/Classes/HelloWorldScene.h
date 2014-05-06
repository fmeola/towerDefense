#import "cocos2d.h"
#import "cocos2d-ui.h"

#define SPRITE_SIZE 3
// -----------------------------------------------------------------------

@interface HelloWorldScene : CCScene

@property (nonatomic,strong) CCTiledMap * tileMap;
@property (nonatomic,strong) CCTiledMapLayer * background;
@property (nonatomic,strong) CCAction * moveAction;
@property (nonatomic,strong) NSMutableArray * towers;

// -----------------------------------------------------------------------

+ (HelloWorldScene *) scene;
- (id)init;

// -----------------------------------------------------------------------
@end