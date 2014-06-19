#import "cocos2d.h"
#import "cocos2d-ui.h"

#define SPRITE_SIZE 3
#define MAX_TRIES_COUNT 5
#define WAVE_ENEMY_COUNT 5
#define LEVEL_WAVE_COUNT 2
#define SPRITESHEET_NAME "greendale"
#define MAX_HP 1000

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