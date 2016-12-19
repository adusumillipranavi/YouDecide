//
//  MPKAccountsViewController.m
//  Pods
//
//  Created by Daniel Loomb on 1/30/15.
//
//

#import "MPKAccountsViewController.h"
#import "MPKCore.h"



@interface MPKAccountsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *keys;
@property (strong, nonatomic) UIAlertController *actionController;

@end

@implementation MPKAccountsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



#pragma mark - TableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.sourceSessions.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AccountsCell" forIndexPath:indexPath];
	
	MPKSourceSession *sourceSession = self.sourceSessions[indexPath.row];
	cell.textLabel.text = sourceSession.sourceTitle;
	cell.imageView.image = sourceSession.sourceImage;
	
	if (sourceSession.isSessionActive)
	{
		cell.detailTextLabel.text = sourceSession.displayName;
		cell.detailTextLabel.textColor = [UIColor colorWithRed:0.176 green:0.800 blue:0.443 alpha:1.000];
	}
	else
	{
		cell.detailTextLabel.text = @"Connect";
		cell.detailTextLabel.textColor = cell.detailTextLabel.tintColor;
	}

	
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	MPKSourceSession *sourceSession = self.sourceSessions[indexPath.row];
	
	void (^reloadBlock)() = ^void()
	{
		[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationAutomatic)];
        
        //After logging out / in clears all cookies to fix the log / login bug
        //Which was reauthenticating users without their details from cookies
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in [storage cookies]) {
            [storage deleteCookie:cookie];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
	};
	
    if (sourceSession.isSessionActive)
    {
        NSString *logoutTitle = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"logout_message", nil) ,sourceSession.sourceTitle];
        
        if((floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_8_0)){
            if(self.actionController.isViewLoaded){
                [self.actionController dismissViewControllerAnimated:YES completion:nil];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.actionController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:logoutTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [sourceSession endSessionWithCompletionHandler:reloadBlock];
                }];
                UIAlertAction *changeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"switch_user_message", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    //Logout
                    [sourceSession endSessionWithCompletionHandler:^{
                        //Login
                        [sourceSession activateSourceSessionWithCompletionHandler:^(BOOL activated, NSError *error) {
                            reloadBlock();
                        }];
                        
                    }];
                }];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil];
                [self.actionController addAction:changeAction];
                [self.actionController addAction:logoutAction];
                [self.actionController addAction:cancelAction];
                
                UIPopoverPresentationController *popPresenter = [self.actionController popoverPresentationController];
                popPresenter.sourceView = [tableView cellForRowAtIndexPath:indexPath].detailTextLabel;
                popPresenter.sourceRect = [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.bounds;
                
                [self presentViewController:self.actionController animated:YES completion:nil];
            });
        }else{
//            RIButtonItem *logoutItem = [RIButtonItem itemWithLabel:logoutTitle action:^{
//                [sourceSession endSessionWithCompletionHandler:reloadBlock];
//            }];
//            
//            RIButtonItem *changeItem = [RIButtonItem itemWithLabel:NSLocalizedString(@"switch_user_message", nil) action:^{
//                //Logout
//                [sourceSession endSessionWithCompletionHandler:^{
//                    //Login
//                    [sourceSession activateSourceSessionWithCompletionHandler:^(BOOL activated, NSError *error) {
//                        reloadBlock();
//                    }];
//                    
//                }];
//            }];
//            
//            RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:NSLocalizedString(@"cancel", nil)];
//            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:cancelItem destructiveButtonItem:nil otherButtonItems:changeItem,logoutItem, nil];
//            [actionSheet showInView:self.view];
        }
    }
	else
	{
		[sourceSession activateSourceSessionWithCompletionHandler:^(BOOL activated, NSError *error)
		{
			if (activated)
			{
				reloadBlock();
			}
			else
			{
				NSLog(@"Accounts: Failed to activate session\nError = %@",error);
//				[[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
			}
		}];
	}
}

@end
