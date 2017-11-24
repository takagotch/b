/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
@interface PPRSetDateViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, copy) void (^dateChangedBlock)(NSDate *newDate);

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
