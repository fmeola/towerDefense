#import "cocos2d.h"
#import "cocos2d-ui.h"

@interface IntroScene : CCScene
// -----------------------------------------------------------------------

+ (IntroScene *)scene;
- (id)init;
- (void)onSpinningClicked:(id)sender;
- (void)onAboutClicked:(id)sender;

// -----------------------------------------------------------------------
@end