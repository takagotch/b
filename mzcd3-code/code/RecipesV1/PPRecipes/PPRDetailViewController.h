/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
@interface PPRDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) NSManagedObject *recipeMO;

@property (nonatomic, weak) IBOutlet UILabel *recipeNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *typeLabel;
@property (nonatomic, weak) IBOutlet UILabel *servesLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;


- (IBAction)action:(id)sender;

@end
