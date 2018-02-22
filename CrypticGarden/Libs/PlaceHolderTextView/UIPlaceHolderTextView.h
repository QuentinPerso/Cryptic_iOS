//
//  UIPlaceHolderTextView.h
//  CrypticGarden
//
//  Created by Quentin Beaudouin on 21/02/2018.
//  Copyright © 2018 Marks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface UIPlaceHolderTextView : UITextView

@property (nonatomic, retain) IBInspectable NSString *placeholder;
@property (nonatomic, retain) IBInspectable UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end
