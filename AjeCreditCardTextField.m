//
//  AjeCreditCardTextField.m
//  AjeCreditCardTextField
//
//  Created by Aje on 3/12/18.
//  Copyright © 2018 Aje. All rights reserved.
//  Thanks to

#import "AjeCreditCardTextField.h"
@interface AjeCreditCardTextField ()<UITextFieldDelegate>
{
    NSString *previousTextFieldContent;
    UITextRange *previousSelection;
    id userdelegate;
}

@end

@implementation AjeCreditCardTextField



- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addTarget:self action:@selector(reformatAsCardNumber:) forControlEvents:UIControlEventEditingChanged];
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.delegate = self;
    }
    return self;
}

-(void)setDelegate:(id<UITextFieldDelegate>)delegate
{
    super.delegate = self;
    if (self != delegate) {
        userdelegate = delegate;
    }
    
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self addTarget:self action:@selector(reformatAsCardNumber:) forControlEvents:UIControlEventEditingChanged];
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.delegate = self;
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addTarget:self action:@selector(reformatAsCardNumber:) forControlEvents:UIControlEventEditingChanged];
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.delegate = self;
    }
    return self;
}


// Version 1.2
// Source and explanation: http://stackoverflow.com/a/19161529/1709587
-(void)reformatAsCardNumber:(UITextField *)textField
{
// In order to make the cursor end up positioned correctly, we need to
// explicitly reposition it after we inject spaces into the text.
// targetCursorPosition keeps track of where the cursor needs to end up as
// we modify the string, and at the end we set the cursor position to it.
NSUInteger targetCursorPosition =
[textField offsetFromPosition:textField.beginningOfDocument toPosition:textField.selectedTextRange.start];
    
    NSString *cardNumberWithoutSpaces = [self removeNonDigits:textField.text andPreserveCursorPosition:&targetCursorPosition];

if ([cardNumberWithoutSpaces length] > 16) {
// If the user is trying to enter more than 19 digits, we prevent
// their change, leaving the text field in  its previous state.
// While 16 digits is usual, credit card numbers have a hard
// maximum of 19 digits defined by ISO standard 7812-1 in section
// 3.8 and elsewhere. Applying this hard maximum here rather than
    // a maximum of 16 ensures that users with unusual card numbers
    // will still be able to enter their card number even if the
    // resultant formatting is odd.
    [textField setText:previousTextFieldContent];
    textField.selectedTextRange = previousSelection;
    return;
}
    
    NSString *cardNumberWithSpaces =
    [self insertSpacesEveryFourDigitsIntoString:cardNumberWithoutSpaces
                      andPreserveCursorPosition:&targetCursorPosition];
    
    textField.text = cardNumberWithSpaces;
    UITextPosition *targetPosition =
    [textField positionFromPosition:[textField beginningOfDocument]
                             offset:targetCursorPosition];
    
    [textField setSelectedTextRange:
     [textField textRangeFromPosition:targetPosition
                           toPosition:targetPosition]
     ];
    
}



-(BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    // Note textField's current state before performing the change, in case
    // reformatTextField wants to revert it
    previousTextFieldContent = textField.text;
    previousSelection = textField.selectedTextRange;
    
    if (userdelegate) {
        [userdelegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    
    return YES;
}

/*
 Removes non-digits from the string, decrementing `cursorPosition` as
 appropriate so that, for instance, if we pass in `@"1111 1123 1111"`
 and a cursor position of `8`, the cursor position will be changed to
 `7` (keeping it between the '2' and the '3' after the spaces are removed).
 */
- (NSString *)removeNonDigits:(NSString *)string
    andPreserveCursorPosition:(NSUInteger *)cursorPosition
{
    NSUInteger originalCursorPosition = *cursorPosition;
    NSMutableString *digitsOnlyString = [NSMutableString new];
    for (NSUInteger i=0; i<[string length]; i++) {
        unichar characterToAdd = [string characterAtIndex:i];
        if (isdigit(characterToAdd)) {
            NSString *stringToAdd =
            [NSString stringWithCharacters:&characterToAdd
                                    length:1];
            
            [digitsOnlyString appendString:stringToAdd];
        }
        else {
            if (i < originalCursorPosition) {
                (*cursorPosition)--;
            }
        }
    }
    
    return digitsOnlyString;
}

/*
 Inserts spaces into the string to format it as a credit card number,
 incrementing `cursorPosition` as appropriate so that, for instance, if we
 pass in `@"111111231111"` and a cursor position of `7`, the cursor position
 will be changed to `8` (keeping it between the '2' and the '3' after the
 spaces are added).
 */
- (NSString *)insertSpacesEveryFourDigitsIntoString:(NSString *)string
                          andPreserveCursorPosition:(NSUInteger *)cursorPosition
{
    NSMutableString *stringWithAddedSpaces = [NSMutableString new];
    NSUInteger cursorPositionInSpacelessString = *cursorPosition;
    for (NSUInteger i=0; i<[string length]; i++) {
        if ((i>0) && ((i % 4) == 0)) {
            [stringWithAddedSpaces appendString:@" "];
            if (i < cursorPositionInSpacelessString) {
                (*cursorPosition)++;
            }
        }
        unichar characterToAdd = [string characterAtIndex:i];
        NSString *stringToAdd =
        [NSString stringWithCharacters:&characterToAdd length:1];
        
        [stringWithAddedSpaces appendString:stringToAdd];
    }
    
    return stringWithAddedSpaces;
}

@end
