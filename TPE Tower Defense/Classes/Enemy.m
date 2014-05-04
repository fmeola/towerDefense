#import "Enemy.h"

@implementation Enemy

+ (id)nodeWithTheGame:(HelloWorldScene *)game
{
    return [[self alloc] initWithTheGame:game];
}

- (id)initWithTheGame:(HelloWorldScene *)game
{
	if ((self=[super init])) {
		_theGame = game;
        maxHp = 40;
        currentHp = maxHp;
        active = NO;
        walkingSpeed = 0.5;
        _mySprite = [CCSprite spriteWithImageNamed:@"jeff-right-1.png"];
        _mySprite.position = ccp(0.5f, 0.8f);
		[self addChild:_mySprite];
        attackedBy = [[NSMutableArray alloc] initWithCapacity:5];
        [_theGame addChild:self];
	}
	return self;
}

@end
