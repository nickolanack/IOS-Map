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


@end

@implementation TileButtons

-(instancetype)init{

    self=[super init];
    
    
    _tiles=[[NSMutableDictionary alloc] init];
    _rows=[[NSMutableArray alloc] init];
    
    
    
    return self;

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
    }
    
    [[_tiles objectForKey:name] addObjectsFromArray:buttons];

}
-(void)addButtons:(NSArray *) buttons ToRow:(NSString *) name Toggler:(StyleButton *)button{

    [button addTarget:self action:@selector(toggle:) forControlEvents:UIControlEventTouchUpInside];
   
    
    [self addButtons:@[button] ToRow:name];
    [self addButtons:buttons ToRow:name];
    
    

}

-(void)toggle:(id)sender{
  
    StyleButton *toggler=(StyleButton *)sender;
    [toggler setSelected:!toggler.isSelected];
    for (NSString *row in _rows) {
        
        bool isCurrentRow=false;
        
       
        for (StyleButton *button in [_tiles objectForKey:row]) {
            
            
            if(button==toggler){
                isCurrentRow=true;
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


-(void)hide:(NSString *) name{
    
    [self toggle:[[_tiles objectForKey:name] firstObject]];

}
-(void)show:(NSString *) name{

    [self toggle:[[_tiles objectForKey:name] firstObject]];
    
}

@end
