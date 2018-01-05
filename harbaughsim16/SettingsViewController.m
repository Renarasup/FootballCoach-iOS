//
//  SettingsViewController.m
//  harbaughsim16
//
//  Created by Akshay Easwaran on 3/18/16.
//  Copyright © 2016 Akshay Easwaran. All rights reserved.
//

#import "SettingsViewController.h"
#import "HBSettingsCell.h"
#import "MyTeamViewController.h"
#import "Team.h"
#import "RebrandConferenceSelectorViewController.h"
#import "HelpViewController.h"

#import "HexColors.h"
#import "FCFileManager.h"
#import "STPopup.h"
#import <StoreKit/StoreKit.h>
#import "MBProgressHUD.h"
@import MessageUI;
@import SafariServices;

@interface SettingsViewController () <MFMailComposeViewControllerDelegate>
{
    STPopupController *popupController;
    NSString *currentYear;
}
@end

@implementation SettingsViewController

-(id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}

-(void)changeTeamName {
    if ([HBSharedUtils currentLeague].canRebrandTeam) {
        Team *userTeam = [HBSharedUtils currentLeague].userTeam;
        NSString *oldName = userTeam.name;
        NSString *oldAbbrev = userTeam.abbreviation;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Rebrand Team" message:@"Enter your new team name and abbreviation below." preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Team Name";
            textField.text = userTeam.name;
        }];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Abbreviation";
            textField.text = userTeam.abbreviation;
        }];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"State";
            textField.text = userTeam.state;
        }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure you want to rebrand your team?" message:@"You can rebrand again at any time during the offseason." preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                //save
                UITextField *name = alert.textFields[0];
                UITextField *abbrev = alert.textFields[1];
                UITextField *state = alert.textFields[2];
                NSArray* words = [name.text.lowercaseString componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString* trimmedName = [words componentsJoinedByString:@""];
                NSLog(@"TRIMMED: %@",trimmedName);
                if (
                    [[HBSharedUtils currentLeague] isTeamNameValid:name.text allowUserTeam:NO allowOverwrite:NO]
                    && [[HBSharedUtils currentLeague] isTeamAbbrValid:abbrev.text allowUserTeam:NO allowOverwrite:NO]
                    && [[HBSharedUtils currentLeague] isStateValid:state.text]) {
                    
                    [[HBSharedUtils currentLeague].userTeam setName:name.text];
                    [[HBSharedUtils currentLeague].userTeam setAbbreviation:abbrev.text];
                    [[HBSharedUtils currentLeague].userTeam setState:state.text];
                    
                    Team *rival = [[HBSharedUtils currentLeague] findTeam:[HBSharedUtils currentLeague].userTeam.rivalTeam];
                    if (![userTeam isEqual:[[HBSharedUtils currentLeague] findTeam:@"GEO"]] && [rival.abbreviation isEqualToString:@"ALA"]) {
                        [rival setRivalTeam:@"GEO"];
                    }
                    rival = [[HBSharedUtils currentLeague] findTeam:[HBSharedUtils currentLeague].userTeam.rivalTeam];
                    [rival setRivalTeam:abbrev.text];

                    NSMutableArray *tempLeagueYear;
                    for (int k = 0; k < [HBSharedUtils currentLeague].leagueHistoryDictionary.count; k++) {
                        NSArray *leagueYear = [HBSharedUtils currentLeague].leagueHistoryDictionary[[NSString stringWithFormat:@"%ld",(long)([HBSharedUtils currentLeague].baseYear + k)]];
                        tempLeagueYear = [NSMutableArray arrayWithArray:leagueYear];
                        for (int i =0; i < leagueYear.count; i++) {
                            NSString *teamString = leagueYear[i];
                            if ([teamString containsString:oldName]) {
                                teamString = [teamString stringByReplacingOccurrencesOfString:oldName withString:name.text];
                                [tempLeagueYear replaceObjectAtIndex:i withObject:teamString];
                            }
                            
                            if ([teamString containsString:oldAbbrev]) {
                                teamString = [teamString stringByReplacingOccurrencesOfString:oldAbbrev withString:abbrev.text];
                                [tempLeagueYear replaceObjectAtIndex:i withObject:teamString];
                            }
                        }
                        
                        [[HBSharedUtils currentLeague].leagueHistoryDictionary setObject:[tempLeagueYear copy] forKey:[NSString stringWithFormat:@"%ld",(long)([HBSharedUtils currentLeague].baseYear + k)]];
                        [tempLeagueYear removeAllObjects];
                    }
                    
                    for (int j = 0; j < [HBSharedUtils currentLeague].userTeam.teamHistoryDictionary.count; j++) {
                        NSString *yearString = [HBSharedUtils currentLeague].userTeam.teamHistoryDictionary[[NSString stringWithFormat:@"%ld",(long)([HBSharedUtils currentLeague].baseYear + j)]];
                        if ([yearString containsString:oldAbbrev]) {
                            yearString = [yearString stringByReplacingOccurrencesOfString:oldAbbrev withString:abbrev.text];
 
                            [[HBSharedUtils currentLeague].userTeam.teamHistoryDictionary setObject:yearString forKey:[NSString stringWithFormat:@"%ld",(long)([HBSharedUtils currentLeague].baseYear + j)]];
                        }
                    }
                    
                    for (int j = 0; j < [HBSharedUtils currentLeague].heismanHistoryDictionary.count; j++) {
                        NSString *heisString = [HBSharedUtils currentLeague].heismanHistoryDictionary[[NSString stringWithFormat:@"%ld",(long)([HBSharedUtils currentLeague].baseYear + j)]];
                        if ([heisString containsString:[NSString stringWithFormat:@", %@ (", oldAbbrev]]) {
                            heisString = [heisString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@", %@ (", oldAbbrev] withString:[NSString stringWithFormat:@", %@ (", abbrev.text]];
     
                            [[HBSharedUtils currentLeague].heismanHistoryDictionary setObject:heisString forKey:[NSString stringWithFormat:@"%ld",(long)([HBSharedUtils currentLeague].baseYear + j)]];
                        }
                    }
                    
                    [[HBSharedUtils currentLeague] save];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"newTeamName" object:nil];
                    [self.tableView reloadData];

                    [HBSharedUtils showNotificationWithTintColor:[HBSharedUtils styleColor] title:@"Rebrand successful!" message:[NSString stringWithFormat:@"Successfully rebranded your team to %@ (%@)!", name.text, abbrev.text] onViewController:self];
                } else if (![[HBSharedUtils currentLeague] isTeamAbbrValid:name.text allowUserTeam:NO allowOverwrite:NO]) {
                    [HBSharedUtils showNotificationWithTintColor:[HBSharedUtils errorColor] title:@"Error" message:@"Unable to rebrand your team - Invalid team name provided." onViewController:self];
                } else if (![[HBSharedUtils currentLeague] isTeamAbbrValid:abbrev.text allowUserTeam:NO allowOverwrite:NO]) {
                    [HBSharedUtils showNotificationWithTintColor:[HBSharedUtils errorColor] title:@"Error" message:@"Unable to rebrand your team - Invalid abbreviation provided." onViewController:self];
                } else if (![[HBSharedUtils currentLeague] isStateValid:state.text]) {
                    [HBSharedUtils showNotificationWithTintColor:[HBSharedUtils errorColor] title:@"Error" message:@"Unable to rebrand your team - Invalid state provided." onViewController:self];
                } else {
                    [HBSharedUtils showNotificationWithTintColor:[HBSharedUtils errorColor] title:@"Error" message:@"Unable to rebrand your team - Invalid inputs provided." onViewController:self];
                }
            }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Settings";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissVC)];
    
    [self.view setBackgroundColor:[HBSharedUtils styleColor]];
    [[UILabel appearanceWhenContainedInInstancesOfClasses:@[[UITableViewHeaderFooterView class],[self class]]] setTextColor:[UIColor lightTextColor]];
    [self.tableView registerNib:[UINib nibWithNibName:@"HBSettingsCell" bundle:nil] forCellReuseIdentifier:@"HBSettingsCell"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAll) name:@"newTeamName" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleConfError) name:@"updatedConferenceError" object:nil];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    currentYear = [formatter stringFromDate:[NSDate date]];
}

-(void)handleConfError {
    [HBSharedUtils showNotificationWithTintColor:[HBSharedUtils errorColor] title:@"Error" message:@"Unable to rebrand the selected conference - A conference with that name already exists." onViewController:self];
}

-(void)reloadAll {
    [self.view setBackgroundColor:[HBSharedUtils styleColor]];
    [self.tableView reloadData];
    self.navigationController.navigationBar.barTintColor = [HBSharedUtils styleColor];
    
}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setFont:[UIFont systemFontOfSize:15.0]];
    [header.textLabel setTextColor:[UIColor lightTextColor]];
}

-(void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *)view;
    [footer.textLabel setFont:[UIFont systemFontOfSize:15.0]];
    [footer.textLabel setTextColor:[UIColor lightTextColor]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return 50;
    } else {
        return 20;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
     return 36;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 50;
    } else {
        return UITableViewAutomaticDimension;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 2) {
        return 6;
    } else if (section == 1) {
        return 12;
    } else {
        return 5;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LinkCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LinkCell"];
            cell.backgroundColor = [UIColor whiteColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell.textLabel setFont:[UIFont systemFontOfSize:17.0]];
        }
        
        if (indexPath.row == 0) {
            [cell.textLabel setText:@"ATAppUpdater"];
        } else if (indexPath.row == 1) {
            [cell.textLabel setText:@"AutoCoding"];
        } else if (indexPath.row == 2) {
            [cell.textLabel setText:@"ios-charts"];
        } else if (indexPath.row == 3) {
            [cell.textLabel setText:@"DZNEmptyDataSet"];
        } else if (indexPath.row == 4) {
            [cell.textLabel setText:@"Fabric"];
        } else if (indexPath.row == 5) {
            [cell.textLabel setText:@"FCFileManager"];
        } else if (indexPath.row == 6) {
            [cell.textLabel setText:@"HexColors"];
        } else if (indexPath.row == 7) {
            [cell.textLabel setText:@"Icons8"];
        } else if (indexPath.row == 8) {
            [cell.textLabel setText:@"MBProgressHUD"];
        } else if (indexPath.row == 9) {
            [cell.textLabel setText:@"RMessage"];
        } else if (indexPath.row == 10) {
            [cell.textLabel setText:@"ScrollableSegmentedControl"];
        } else {
            [cell.textLabel setText:@"STPopup"];
        }
        return cell;
    } else if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Sec2Cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Sec2Cell"];
            cell.backgroundColor = [UIColor whiteColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell.textLabel setFont:[UIFont systemFontOfSize:17.0]];
        }
        
        if (indexPath.row == 0) {
            [cell.textLabel setText:@"Game Guide"];
        } else if (indexPath.row == 1) {
            [cell.textLabel setText:@"Developer's Website"];
        } else if (indexPath.row == 2) {
            [cell.textLabel setText:@"Email Developer"];
        } else if (indexPath.row == 3) {
            [cell.textLabel setText:@"Football Coach on GitHub"];
        } else if (indexPath.row == 4) {
            [cell.textLabel setText:@"Football Coach on Reddit"];
        } else {
            [cell.textLabel setText:@"Submit a Review"];
        }
        return cell;
    }else {
        if (indexPath.row == 0) {
            HBSettingsCell *setCell = (HBSettingsCell*)[tableView dequeueReusableCellWithIdentifier:@"HBSettingsCell"];
            BOOL notifsOn = [[NSUserDefaults standardUserDefaults] boolForKey:HB_IN_APP_NOTIFICATIONS_TURNED_ON];
            [setCell.settingSwitch setOnTintColor:[HBSharedUtils styleColor]];
            [setCell.settingSwitch setOn:notifsOn];
            [setCell.titleLabel setText:@"Weekly Summary Notifications"];
            [setCell.settingSwitch addTarget:self action:@selector(changeNotificationSettings:) forControlEvents:UIControlEventValueChanged];
            
            return setCell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptionsCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OptionsCell"];
                cell.backgroundColor = [UIColor whiteColor];
                [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell.textLabel setFont:[UIFont systemFontOfSize:17.0]];
               
            }
            
            if (indexPath.row == 1) {
                [cell.textLabel setText:@"Rebrand Team"];
                if ([HBSharedUtils currentLeague].canRebrandTeam) {
                    [cell.textLabel setTextColor:[HBSharedUtils styleColor]];
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                } else {
                    [cell.textLabel setTextColor:[UIColor lightGrayColor]];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                }
            } else if (indexPath.row == 2) {
                [cell.textLabel setText:@"Rebrand Conferences"];
                if ([HBSharedUtils currentLeague].canRebrandTeam) {
                    [cell.textLabel setTextColor:[HBSharedUtils styleColor]];
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                } else {
                    [cell.textLabel setTextColor:[UIColor lightGrayColor]];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
            } else if (indexPath.row == 3) {
                [cell.textLabel setText:@"Export League Metadata"];
                [cell.textLabel setTextColor:[HBSharedUtils styleColor]];
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            } else {
                [cell.textLabel setText:@"Delete Save File"];
                [cell.textLabel setTextColor:[HBSharedUtils errorColor]];
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            }
            return cell;
        }
    }
}

-(void)changeNotificationSettings:(UISwitch*)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:HB_IN_APP_NOTIFICATIONS_TURNED_ON];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) return @"Libraries Used in this App";
    else if (section == 2) return @"Support";
    else return @"Options";
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 2)
        return [NSString stringWithFormat:@"Version %@ (%@)\nCopyright © %@ Akshay Easwaran.",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], currentYear];
    else
        return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        NSString *url;
        if (indexPath.row == 0) {
            url = @"https://github.com/apptality/ATAppUpdater";
        } else if (indexPath.row == 1) {
            url = @"https://github.com/nicklockwood/AutoCoding";
        } else if (indexPath.row == 2) {
            url = @"https://github.com/danielgindi/Charts";
        } else if (indexPath.row == 3) {
            url = @"https://github.com/dzenbot/DZNEmptyDataSet";
        } else if (indexPath.row == 4) {
            url = @"https://fabric.io";
        } else if (indexPath.row == 5) {
            url = @"https://github.com/fabiocaccamo/FCFileManager";
        } else if (indexPath.row == 6) {
            url = @"https://github.com/mRs-/HexColors";
        } else if (indexPath.row == 7) {
            url = @"http://icons8.com";
        } else if (indexPath.row == 8) {
            url = @"https://github.com/jdg/MBProgressHUD/";
        } else if (indexPath.row == 9) {
            url = @"https://github.com/donileo/RMessage";
        } else if (indexPath.row == 10) {
            url = @"https://github.com/GocePetrovski/ScrollableSegmentedControl";
        } else {
            url = @"https://github.com/kevin0571/STPopup";
        }
        
        SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]];
        safariVC.preferredBarTintColor = [HBSharedUtils styleColor];
        safariVC.preferredControlTintColor = [UIColor whiteColor];
        [self presentViewController:safariVC animated:YES completion:nil];
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self.navigationController pushViewController:[[HelpViewController alloc] initWithStyle:UITableViewStyleGrouped] animated:YES];
        } else if (indexPath.row == 1) {
            SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://akeaswaran.me"]];
            safariVC.preferredBarTintColor = [HBSharedUtils styleColor];
            safariVC.preferredControlTintColor = [UIColor whiteColor];
            [self presentViewController:safariVC animated:YES completion:nil];
        } else if (indexPath.row == 2) {
            MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
            composer.navigationBar.tintColor = [UIColor whiteColor];
            composer.view.tintColor = [HBSharedUtils styleColor];
            [composer setMailComposeDelegate:self];
            [composer setToRecipients:@[@"akeaswaran@me.com"]];
            [composer setSubject:[NSString stringWithFormat:@"College Football Coach %@ (%@)",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
            [self presentViewController:composer animated:YES completion:nil];
        } else if (indexPath.row == 3) {
            SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://github.com/akeaswaran/FootballCoach-iOS"]];
            safariVC.preferredBarTintColor = [HBSharedUtils styleColor];
            safariVC.preferredControlTintColor = [UIColor whiteColor];
            [self presentViewController:safariVC animated:YES completion:nil];
            
        } else if (indexPath.row == 4) {
            SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://reddit.com/r/FootballCoach"]];
            safariVC.preferredBarTintColor = [HBSharedUtils styleColor];
            safariVC.preferredControlTintColor = [UIColor whiteColor];
            [self presentViewController:safariVC animated:YES completion:nil];
            
        } else {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.3")) {
                [SKStoreReviewController requestReview];
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Do you want to leave College Football Coach?" message:nil preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
                [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:HB_APP_REVIEW_URL]];
                }]];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    } else {
        if (indexPath.row == 4) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to delete your save file and start your career over?" message:@"This will take you back to the Team Selection screen." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                BOOL success = [FCFileManager removeItemAtPath:@"league.cfb"];
                if (success) {
                    [HBSharedUtils currentLeague].userTeam = nil;
                    
                    [self dismissViewControllerAnimated:YES completion:^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"noSaveFile" object:nil];
                    }];
                    
                } else {
                    ////NSLog(@"ERROR");
                }
            }]];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else if (indexPath.row == 1) {
            if ([HBSharedUtils currentLeague].canRebrandTeam) {
                [self changeTeamName];
            }
        } else if (indexPath.row == 2) {
            if ([HBSharedUtils currentLeague].canRebrandTeam) {
                popupController = [[STPopupController alloc] initWithRootViewController:[[RebrandConferenceSelectorViewController alloc] init]];
                [popupController.backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewDidTap)]];
                [popupController.navigationBar setDraggable:YES];
                popupController.style = STPopupStyleBottomSheet;
                [popupController presentInViewController:self];
            }
        } else if (indexPath.row == 3) { // export
            NSString *metadataFile = [[HBSharedUtils currentLeague] leagueMetadataJSON];
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[metadataFile] applicationActivities:nil];
            activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,UIActivityTypeAirDrop,UIActivityTypePostToVimeo,UIActivityTypePostToFlickr,UIActivityTypeOpenInIBooks,UIActivityTypePostToWeibo,UIActivityTypeAddToReadingList,UIActivityTypePostToFacebook,UIActivityTypePostToTencentWeibo];
            [self presentViewController:activityVC animated:YES completion:nil];
        }
    }
}

- (void)textFieldDidChange:(UITextField*)sender
{
    UIResponder *resp = sender;
    while (![resp isKindOfClass:[UIAlertController class]]) {
        resp = resp.nextResponder;
    }
    UIAlertController *alertController = (UIAlertController *)resp;
    NSURL* url = [NSURL URLWithString:sender.text];
    [((UIAlertAction *)alertController.actions[0]) setEnabled:(!([sender.text isEqualToString:@""] || sender.text.length == 0 || !url))];
    
    
    if (![((UIAlertAction *)alertController.actions[0]) isEnabled]) {
        [alertController setMessage:@"Please enter the valid URL of a metadata file."];
    } else {
        [alertController setMessage:@"Tap \"Import\" to apply the changes from your metadata file to your league!"];
    }
}

-(void)backgroundViewDidTap {
    [popupController dismiss];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultFailed:
            [self dismissViewControllerAnimated:YES completion:nil];
            [self emailFail:error];
            break;
        case MFMailComposeResultSent:
            [self dismissViewControllerAnimated:YES completion:nil];
            [self emailSuccess];
        default:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
    }
}

-(void)emailSuccess {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Your email was sent successfully!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)emailFail:(NSError*)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Your email was unable to be sent." message:[NSString stringWithFormat:@"Sending failed with the following error: \"%@\".",error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
