//
//  Conference.m
//  harbaughsim16
//
//  Created by Akshay Easwaran on 3/16/16.
//  Copyright © 2016 Akshay Easwaran. All rights reserved.
//

#import "Conference.h"
#import "Team.h"
#import "HBSharedUtils.h"
#import "Player.h"
#import "PlayerQB.h"
#import "PlayerRB.h"
#import "PlayerWR.h"
#import "PlayerK.h"
#import "PlayerOL.h"
#import "PlayerDL.h"
#import "PlayerLB.h"
#import "PlayerCB.h"
#import "PlayerS.h"

@implementation Conference
@synthesize ccg,confName,confTeams,confFullName,confPrestige,allConferencePlayers,league,week,robinWeek;

+(instancetype)newConferenceWithName:(NSString*)name fullName:(NSString*)fullName league:(League*)league {
    Conference *conf = [[Conference alloc] init];
    if (conf) {
        conf.confName = name;
        conf.confFullName = fullName;
        conf.confPrestige = 75;
        conf.confTeams = [NSMutableArray array];
        conf.allConferencePlayers = [NSDictionary dictionary];
        conf.league = league;
        conf.week = 0;
        conf.robinWeek = 0;
    }
    return conf;
}

-(NSString*)getCCGString {
    if (self.ccg == nil) {
        // Give prediction, find top 2 teams
        Team *team1 = nil, *team2 = nil;
        int score1 = 0, score2 = 0;
        for (int i = [NSNumber numberWithInteger:self.confTeams.count].intValue - 1; i >= 0; --i) { //count backwards so higher ranked teams are predicted
            Team *t = self.confTeams[i];
            if ([t calculateConfWins] >= score1) {
                score2 = score1;
                score1 = [t calculateConfWins];
                team2 = team1;
                team1 = t;
            } else if ([t calculateConfWins] > score2) {
                score2 = [t calculateConfWins];
                team2 = t;
            }
        }
        return [NSString stringWithFormat:@"%@ Conference Championship:\n\t\t%@ vs %@", self.confName,
        [team1 strRep], [team2 strRep]];
    } else {
        if (!self.ccg.hasPlayed) {
            return [NSString stringWithFormat:@"%@ Conference Championship:\n\t\t%@ vs %@", self.confName, [self.ccg.homeTeam strRep], [self.ccg.awayTeam strRep]];
        } else {
            NSString *sb = @"";
            Team *winner, *loser;
            sb = [self.confName stringByAppendingString:@" Conference Championship:\n"];
            if (self.ccg.homeScore > self.ccg.awayScore) {
                winner = self.ccg.homeTeam;
                loser = self.ccg.awayTeam;
                sb = [sb stringByAppendingString:[[winner strRep] stringByAppendingString:@" W "]];
                sb = [sb stringByAppendingString:[NSString stringWithFormat:@"%ld - %ld,",(long)self.ccg.homeScore, (long)self.ccg.awayScore]];
                sb = [sb stringByAppendingString:[NSString stringWithFormat:@"vs %@", [loser strRep]]];
                //sb.append("vs " + [loser strRep]);
                return sb;
            } else {
                winner = self.ccg.awayTeam;
                loser = self.ccg.homeTeam;
                sb = [sb stringByAppendingString:[[winner strRep] stringByAppendingString:@" W "]];
                sb = [sb stringByAppendingString:[NSString stringWithFormat:@"%ld - %ld,",(long)self.ccg.homeScore, (long)self.ccg.awayScore]];
                sb = [sb stringByAppendingString:[NSString stringWithFormat:@"@ %@", [loser strRep]]];
                return sb;
            }
        }
    }

}

-(void)playConfChamp {
    [self.ccg playGame];
     if (self.ccg.homeScore > self.ccg.awayScore) {
         self.confTeams[0].confChampion = @"CC";
         self.confTeams[0].totalCCs++;
         self.confTeams[1].totalCCLosses++;
         NSMutableArray *week13 = self.league.newsStories[13];
         [week13 addObject:[NSString stringWithFormat:@"%@ wins the %@!\n%@ took care of business in the conference championship against %@, winning at home with a score of %ld to %ld.",self.ccg.homeTeam.name, self.confName, self.ccg.homeTeam.strRep, self.ccg.awayTeam.strRep, (long)self.ccg.homeScore, (long)self.ccg.awayScore]];
     } else {
         self.confTeams[1].confChampion = @"CC";
         self.confTeams[1].totalCCs++;
         self.confTeams[0].totalCCLosses++;
         NSMutableArray *week13 = self.league.newsStories[13];
         [week13 addObject:[NSString stringWithFormat:@"%@ wins the %@!\n%@ surprised many in the conference championship against %@, winning on the road with a score of %ld to %ld.",self.ccg.awayTeam.name, self.confName, self.ccg.awayTeam.strRep, self.ccg.homeTeam.strRep, (long)self.ccg.awayScore, (long)self.ccg.homeScore]];
     }
     self.confTeams = [[self.confTeams sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
         Team *a = (Team*)obj1;
         Team *b = (Team*)obj2;
         return a.teamPollScore > b.teamPollScore ? -1 : a.teamPollScore == b.teamPollScore ? 0 : 1;
     
     }] mutableCopy];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newNewsStory" object:nil];
}

-(void)scheduleConfChamp {
    [self sortConfTeams];
     
    self.ccg = [Game newGameWithHome:self.confTeams[0]  away:self.confTeams[1] name:[NSString stringWithFormat:@"%@ CCG", self.confName]];
    [self.confTeams[0].gameSchedule addObject:self.ccg];
    [self.confTeams[1].gameSchedule addObject:self.ccg];
}

-(void)sortConfTeams {
    for ( int i = 0; i < self.confTeams.count; ++i ) {
        [self.confTeams[i] updatePollScore];
    }

    [self.confTeams sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        Team *a = (Team*)obj1;
        Team *b = (Team*)obj2;
        if ([a.confChampion isEqualToString:@"CC"]) return -1;
        else if ([b.confChampion isEqualToString:@"CC"]) return 1;
        else if ([a calculateConfWins] > [b calculateConfWins]) {
            return -1;
        } else if ([b calculateConfWins] > [a calculateConfWins]) {
            return 1;
        } else {
            //check for h2h tiebreaker
            if ([a.gameWinsAgainst containsObject:b]) {
                return -1;
            } else if ([b.gameWinsAgainst containsObject:a]) {
                return 1;
            } else {
                return 0;
            }
        }
    }];
    
    int winsFirst = [self.confTeams[0] calculateConfWins];
    Team *t = self.confTeams[0];
    NSInteger i = 0;
    NSMutableArray<Team*> *teamTB = [NSMutableArray array];
    while ([t calculateConfWins] == winsFirst) {
        [teamTB addObject:t];
        ++i;
        if (i < self.confTeams.count) {
            t = self.confTeams[i];
        } else {
            break;
        }
    }
    if (teamTB.count > 2) {
        // ugh 3 way tiebreaker
        [teamTB sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            Team *a = (Team*)obj1;
            Team *b = (Team*)obj2;
            return a.teamPollScore > b.teamPollScore ? -1 : a.teamPollScore == b.teamPollScore ? 0 : 1;
        }];
        for (int j = 0; j < teamTB.count; ++j) {
            [self.confTeams replaceObjectAtIndex:j withObject:teamTB[j]];
        }
        
    }
    
    int winsSecond = [self.confTeams[1] calculateConfWins];
    t = self.confTeams[1];
    i = 1;
    [teamTB removeAllObjects];
    while ([t calculateConfWins] == winsSecond) {
        [teamTB addObject:t];
        ++i;
        if (i < self.confTeams.count) {
            t = self.confTeams[i];
        } else {
            break;
        }
    }
    if (teamTB.count > 2) {
        // ugh 3 way tiebreaker
        [teamTB sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            Team *a = (Team*)obj1;
            Team *b = (Team*)obj2;
            return a.teamPollScore > b.teamPollScore ? -1 : a.teamPollScore == b.teamPollScore ? 0 : 1;
        }];
        for (int j = 0; j < teamTB.count; ++j) {
            [self.confTeams replaceObjectAtIndex:(j+1) withObject:teamTB[j]];
        }
        
    }
}

-(Game*)ccgPrediction {
    if (!self.ccg) { // ccg hasn't been scheduled so we can project it
        [self sortConfTeams];
        
        return [Game newGameWithHome:self.confTeams[0]  away:self.confTeams[1] name:[NSString stringWithFormat:@"%@ CCG", self.confName]];
    } else { //ccg has been scheduled/played so send that forward
        return self.ccg;
    }
}

-(void)playWeek {
    if ( self.week == 12 ) {
        [self playConfChamp];
    } else {
        for ( int i = 0; i < self.confTeams.count; ++i ) {
            [[self.confTeams[i] gameSchedule][self.week] playGame];
        }
        if (self.week == 11 ) [self scheduleConfChamp];
        self.week++;
    }
}

-(void)insertOOCSchedule {
    for (int i = 0; i < self.confTeams.count; ++i) {
        [[self.confTeams[i] gameSchedule] insertObject:[self.confTeams[i] oocGame0] atIndex:0];
        [[self.confTeams[i] gameSchedule] insertObject:[self.confTeams[i] oocGame4] atIndex:4];
        [[self.confTeams[i] gameSchedule] insertObject:[self.confTeams[i] oocGame9] atIndex:9];
    }
}

-(void)setUpOOCSchedule {
    
    //schedule OOC games
    NSInteger confNum = [self.league.conferences indexOfObject:self];
    if (confNum > 2)
        confNum = -1;
    
    if ( confNum != -1 ) {
        for ( int offsetOOC = 3; offsetOOC < 6; ++offsetOOC ) {
            NSMutableArray<Team*> *availTeams = [NSMutableArray array];
            int selConf = (int)confNum + offsetOOC;
            if (selConf == 6) selConf = 3;
            if (selConf == 7) selConf = 4;
            if (selConf == 8) selConf = 5;
            
            for (int i = 0; i < 10; ++i) {
                [availTeams addObject:self.league.conferences[selConf].confTeams[i]];
            }
            
            for (int i = 0; i < 10; ++i) {
                int selTeam = (int)([HBSharedUtils randomValue] * availTeams.count);
                Team *a = self.confTeams[i];
                Team *b = availTeams[selTeam];
                
                Game *gm;
                if ([HBSharedUtils randomValue] > 0.5) {
                    gm = [Game newGameWithHome:a away:b name:[NSString stringWithFormat:@"%@ vs %@",[b.conference substringWithRange:NSMakeRange(0, 3)],[a.conference substringWithRange:NSMakeRange(0, 3)]]];
                } else {
                    gm = [Game newGameWithHome:b away:a name:[NSString stringWithFormat:@"%@ vs %@",[a.conference substringWithRange:NSMakeRange(0, 3)],[b.conference substringWithRange:NSMakeRange(0, 3)]]];
                }
                
                if ( offsetOOC == 3 ) {
                    a.oocGame0 = gm;
                    b.oocGame0 = gm;
                    [availTeams removeObjectAtIndex:selTeam];
                } else if ( offsetOOC == 4 ) {
                    a.oocGame4 = gm;
                    b.oocGame4 = gm;
                    [availTeams removeObjectAtIndex:selTeam];
                } else if ( offsetOOC == 5 ) {
                    a.oocGame9 = gm;
                    b.oocGame9 = gm;
                    [availTeams removeObjectAtIndex:selTeam];
                }
            }
        }
    }

}

-(NSString *)confShortName {
    return [self.confName substringWithRange:NSMakeRange(0, 3)];
}

-(void)setUpSchedule {
    
    self.robinWeek = 0;
    for (int r = 0; r < 9; ++r) {
        for (int g = 0; g < 5; ++g) {
            Team *a = self.confTeams[(self.robinWeek + g) % 9];
            Team *b;
            if ( g == 0 ) {
                b = self.confTeams[9];
            } else {
                b = self.confTeams[(9 - g + self.robinWeek) % 9];
            }
            
            Game *gm;
            if ([HBSharedUtils randomValue] > 0.5) {
                gm = [Game
                      newGameWithHome:a away:b name:@"In Conf"];
            } else {
                gm = [Game
                      newGameWithHome:b away:a name:@"In Conf"];
            }
            
            [a.gameSchedule addObject:gm];
            [b.gameSchedule addObject:gm];
        }
        self.robinWeek++;
    }
    
}

-(void)refreshAllConferencePlayers {
    NSMutableArray *leadingQBs = [NSMutableArray array];
    NSMutableArray *leadingRBs = [NSMutableArray array];
    NSMutableArray *leadingWRs = [NSMutableArray array];
    NSMutableArray *leadingKs = [NSMutableArray array];
    
    for (Team *t in self.confTeams) {
        [leadingQBs addObject:[t getQB:0]];
        [leadingRBs addObject:[t getRB:0]];
        [leadingRBs addObject:[t getRB:1]];
        [leadingWRs addObject:[t getWR:0]];
        [leadingWRs addObject:[t getWR:1]];
        [leadingWRs addObject:[t getWR:2]];
        [leadingKs addObject:[t getK:0]];
    }
    
    [leadingQBs sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        Player *a = (Player*)obj1;
        Player *b = (Player*)obj2;
        if (a.isHeisman) return -1;
        else if (b.isHeisman) return 1;
        else return [a getHeismanScore] > [b getHeismanScore] ? -1 : [a getHeismanScore] == [b getHeismanScore] ? 0 : 1;
    }];
    
    [leadingRBs sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        Player *a = (Player*)obj1;
        Player *b = (Player*)obj2;
        if (a.isHeisman) return -1;
        else if (b.isHeisman) return 1;
        else return [a getHeismanScore] > [b getHeismanScore] ? -1 : [a getHeismanScore] == [b getHeismanScore] ? 0 : 1;
    }];
    
    [leadingWRs sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        Player *a = (Player*)obj1;
        Player *b = (Player*)obj2;
        if (a.isHeisman) return -1;
        else if (b.isHeisman) return 1;
        else return [a getHeismanScore] > [b getHeismanScore] ? -1 : [a getHeismanScore] == [b getHeismanScore] ? 0 : 1;
    }];
    
    [leadingKs sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        PlayerK *a = (PlayerK*)obj1;
        PlayerK *b = (PlayerK*)obj2;
        if (a.isHeisman) return -1;
        else if (b.isHeisman) return 1;
        else return [a getHeismanScore] > [b getHeismanScore] ? -1 : [a getHeismanScore] == [b getHeismanScore] ? 0 : 1;
    }];
    
    PlayerQB *qb = leadingQBs[0];
    qb.careerAllConferences++;
    qb.isAllConference = YES;
    
    PlayerRB *rb1 = leadingRBs[0];
    rb1.careerAllConferences++;
    rb1.isAllConference = YES;
    
    PlayerRB *rb2 = leadingRBs[1];
    rb2.careerAllConferences++;
    rb2.isAllConference = YES;
    
    PlayerWR *wr1 = leadingWRs[0];
    wr1.careerAllConferences++;
    wr1.isAllConference = YES;
    
    PlayerWR *wr2 = leadingWRs[1];
    wr2.careerAllConferences++;
    wr2.isAllConference = YES;
    
    PlayerWR *wr3 = leadingWRs[2];
    wr3.careerAllConferences++;
    wr3.isAllConference = YES;
    
    PlayerK *k = leadingKs[0];
    k.careerAllConferences++;
    k.isAllConference = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"awardsPosted" object:nil];

    self.allConferencePlayers = @{
                           @"QB" : @[qb],
                           @"RB" : @[rb1,rb2],
                           @"WR" : @[wr1,wr2,wr3],
                           @"K"  : @[k]
                           };
    
}

@end
