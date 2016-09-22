//
//  TileButtons.h
//  Pods
//
//  Created by Nick Blackwell on 2016-01-25.
//
//

#import <Foundation/Foundation.h>
#import "StyleButton.h"
#import "TileButtonDelegate.h"
#import "StyleProvider.h"

/**
 A TileButtons instance manages the behavior of a number of StyledButton objects placed in a UIView, and
 linked programmatically using addButtons:ToRow: or addButtons:ToRow:Toggler: methods. 
 
 */
@interface TileButtons : NSObject

@property id<TileButtonDelegate> delegate;

-(instancetype)initWithStyler:(id<StyleProvider>)styler;

/**
 Adds buttons to an existing row, or creates a new row without a toggler. Usually only called with one button.
 */
-(void)addButtons:(NSArray *) buttons ToRow:(NSString *) name;
/**
 Adds buttons to a row, with a toggler, horizontal, and vertical placement might be adjusted in to fill any gaps.
 */
-(void)addButtons:(NSArray *) buttons ToRow:(NSString *) name Toggler:(StyleButton *)button;


-(void)hide:(NSString *) name;
-(void)show:(NSString *) name;


-(void)disableRow:(NSString *) name;
-(void)hideRow:(NSString *) name;

-(void)setAutoSpaceTiles:(bool)space;
-(void)alignTiles;
-(void)horizontalAlign:(int)offset;

@end
