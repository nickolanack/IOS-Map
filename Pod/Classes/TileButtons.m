//
//  TileButtons.m
//  Pods
//
//  Created by Nick Blackwell on 2016-01-25.
//
//

#import "TileButtons.h"




@interface TileButtons ()

@property NSMutableDictionary *tiles;
@property NSMutableArray *rows;

@property NSMutableArray *disabledRows;


@property id<StyleProvider>styler;
@property bool autoSpace;
@property int space;


@end

@implementation TileButtons

@synthesize delegate;

-(instancetype)initWithStyler:(id<StyleProvider>)styler{

    self=[super init];
    
    _styler=styler;
    _tiles=[[NSMutableDictionary alloc] init];
    _rows=[[NSMutableArray alloc] init];
    _disabledRows=[[NSMutableArray alloc] init];
    
    _space=-1;
    
    return self;

}

-(void)setAutoSpaceTiles:(bool)space{
    _autoSpace=space;
}

-(void)addButtons:(NSArray *) buttons ToRow:(NSString *) name{

    if([_rows indexOfObject:name]==NSNotFound){

        [_rows addObject:name];
        [_tiles setObject:[[NSMutableArray alloc] init] forKey:name];
    
    }
    
    for (StyleButton *b in buttons) {
        if(![b isKindOfClass:[StyleButton class]]){
            @throw [[NSException alloc] initWithName:@"Tried to put non StyleButton into TileButtons" reason:nil userInfo:nil];
        }
        
        UIColor *c=[_styler colorForNamedStyle:[NSString stringWithFormat:@"tilebutton.%@.%i", name, [buttons indexOfObject:b]] withDefault:[b getDefaultColor]];
        [b setDefaultColor:c];
        
        UIColor *s=[_styler colorForNamedStyle:[NSString stringWithFormat:@"tilebutton.%@.%i.selected", name, [buttons indexOfObject:b]] withDefault:[b getSelectedColor]];
        [b setSelectedColor:s];
        
        
        
        [b addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [[_tiles objectForKey:name] addObjectsFromArray:buttons];
    
    
    if(_autoSpace&&[_rows count]==2){
        StyleButton *a=[[_tiles objectForKey:[_rows objectAtIndex:0]] objectAtIndex:0];
        StyleButton *b=[[_tiles objectForKey:[_rows objectAtIndex:1]] objectAtIndex:0];
        
        //TODO:
        //measure tiles and set _space,
        
    }

}
-(void)addButtons:(NSArray *) buttons ToRow:(NSString *) name Toggler:(StyleButton *)button{

    [button addTarget:self action:@selector(toggle:) forControlEvents:UIControlEventTouchUpInside];
   
    
    [self addButtons:@[button] ToRow:name];
    [self addButtons:buttons ToRow:name];
    
    

}

-(void)tap:(id)sender{

    StyleButton *tapped=(StyleButton *)sender;
    for (NSString *row in _rows) {
    
        
        NSMutableArray *tiles=[_tiles objectForKey:row];
        
        for (int i=0;i<[tiles count];i++) {
            
            StyleButton *button=[tiles objectAtIndex:i];
            
            if(button==tapped){
                
                if([_disabledRows indexOfObject:row]!=NSNotFound){
                    
                    if(self.delegate&&[self.delegate respondsToSelector:@selector(userTappedDisabledButton:InRow:AtIndex:)]){
                        [self.delegate userTappedDisabledButton:button InRow:row AtIndex:i];
                    }
                    
                    return;
                }
               
                if(self.delegate&&[self.delegate respondsToSelector:@selector(userTappedButton:InRow:AtIndex:)]){
                    [self.delegate userTappedButton:button InRow:row AtIndex:i];
                }
                return;
            }
        }
    }

}

-(void)toggle:(id)sender{
  
    StyleButton *toggler=(StyleButton *)sender;

    for (NSString *row in _rows) {
        
        bool isCurrentRow=false;
        
       
        for (StyleButton *button in [_tiles objectForKey:row]) {
            
            
            if(button==toggler){
                isCurrentRow=true;
                if([_disabledRows indexOfObject:row]!=NSNotFound){
                    return;
                }
                [toggler setSelected:!toggler.isSelected];
            }
            
            
            if(button!=sender&&isCurrentRow){
              
                [button setHidden:!toggler.isSelected];
                
            }
            
        }
        
        if(isCurrentRow){
            return;
        }
        
    }
    
    
}

-(void)disableRow:(NSString *) name{
    [_disabledRows addObject:name];
    for (StyleButton *b in [_tiles objectForKey:name]) {
        [b setAlpha:0.5];
    }
}


-(void)hideRow:(NSString *) name{
    [_disabledRows addObject:name];
    for (StyleButton *b in [_tiles objectForKey:name]) {
        [b setHidden:true];
    }
    
    if(_autoSpace){
        //TODO
        //_space should be set. apply -offset to all rows after row[name]
    }
    
}


-(void)hide:(NSString *) name{
    
    StyleButton *b=[[_tiles objectForKey:name] firstObject];
    if(b.isSelected){
        [self toggle:b];
    }

}
-(void)show:(NSString *) name{

    StyleButton *b=[[_tiles objectForKey:name] firstObject];
    if(!b.isSelected){
        [self toggle:b];
    }
    
}

@end
