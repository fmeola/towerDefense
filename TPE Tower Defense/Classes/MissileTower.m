#import "MissileTower.h"

@implementation MissileTower : Tower

- (NSString *)getTowerName
{
    return @"Tower2";
}

- (int)getPrice
{
    return 20;
}

- (int)getDamage
{
    return 10;
}

-(int)getAttackRange
{
    return 100;
}

@end