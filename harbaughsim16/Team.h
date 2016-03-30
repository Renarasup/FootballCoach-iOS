//
//  Team.h
//  harbaughsim16
//
//  Created by Akshay Easwaran on 3/16/16.
//  Copyright © 2016 Akshay Easwaran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Conference.h"
#import "Game.h"
#import "TeamStrategy.h"
@class Player;
@class League;

@class PlayerQB;
@class PlayerRB;
@class PlayerWR;
@class PlayerOL;
@class PlayerK;
@class PlayerF7;
@class PlayerCB;
@class PlayerS;

@interface Team : NSObject <NSCoding> {
    NSMutableArray *playersLeaving;
}

@property (strong, nonatomic) League *league;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *abbreviation;
@property (strong, nonatomic) NSString *conference;
@property (strong, nonatomic) NSString *rivalTeam;
@property (strong, nonatomic) NSMutableArray *teamHistory;
@property (nonatomic) BOOL isUserControlled;
@property (nonatomic) BOOL wonRivalryGame;
@property (nonatomic) int recruitingMoney;
@property (nonatomic) int numberOfRecruits;

@property (nonatomic) int wins;
@property (nonatomic) int losses;
@property (nonatomic) int totalWins;
@property (nonatomic) int totalLosses;
@property (nonatomic) int totalCCs;
@property (nonatomic) int totalNCs;
@property (nonatomic) int totalCCLosses;
@property (nonatomic) int totalNCLosses;
@property (nonatomic) int totalBowls;
@property (nonatomic) int totalBowlLosses;

//Game Log variables
@property (strong, nonatomic) NSMutableArray *gameSchedule;
@property (strong, nonatomic) Game *oocGame0;
@property (strong, nonatomic) Game *oocGame4;
@property (strong, nonatomic) Game *oocGame9;
@property (strong, nonatomic) NSMutableArray *gameWLSchedule;
@property (strong, nonatomic) NSMutableArray *gameWinsAgainst;
@property (strong, nonatomic) NSMutableDictionary<NSString*, NSMutableArray*> *teamStreaks;
@property (strong, nonatomic) NSString *confChampion;
@property (strong, nonatomic) NSString *semifinalWL;
@property (strong, nonatomic) NSString *natlChampWL;


//Team stats
@property (nonatomic) int teamPoints;
@property (nonatomic) int teamOppPoints;
@property (nonatomic) int teamYards;
@property (nonatomic) int teamOppYards;
@property (nonatomic) int teamPassYards;
@property (nonatomic) int teamRushYards;
@property (nonatomic) int teamOppPassYards;
@property (nonatomic) int teamOppRushYards;
@property (nonatomic) int teamTODiff;
@property (nonatomic) int teamOffTalent;
@property (nonatomic) int teamDefTalent;
@property (nonatomic) int teamPrestige;
@property (nonatomic) int teamPollScore;
@property (nonatomic) int teamStrengthOfWins;

@property (nonatomic) int teamStatOffNum;
@property (nonatomic) int teamStatDefNum;

@property (nonatomic) int rankTeamPoints;
@property (nonatomic) int rankTeamOppPoints;
@property (nonatomic) int rankTeamYards;
@property (nonatomic) int rankTeamOppYards;
@property (nonatomic) int rankTeamPassYards;
@property (nonatomic) int rankTeamRushYards;
@property (nonatomic) int rankTeamOppPassYards;
@property (nonatomic) int rankTeamOppRushYards;
@property (nonatomic) int rankTeamTODiff;
@property (nonatomic) int rankTeamOffTalent;
@property (nonatomic) int rankTeamDefTalent;
@property (nonatomic) int rankTeamPrestige;
@property (nonatomic) int rankTeamPollScore;
@property (nonatomic) int rankTeamStrengthOfWins;

//prestige/talent improvements
@property (nonatomic) int diffPrestige;
@property (nonatomic) int diffOffTalent;
@property (nonatomic) int diffDefTalent;

//players on team
//offense
@property (strong, nonatomic) NSMutableArray<PlayerQB*> *teamQBs;
@property (strong, nonatomic) NSMutableArray<PlayerRB*> *teamRBs;
@property (strong, nonatomic) NSMutableArray<PlayerWR*> *teamWRs;
@property (strong, nonatomic) NSMutableArray<PlayerK*> *teamKs;
@property (strong, nonatomic) NSMutableArray<PlayerOL*> *teamOLs;

//defense
@property (strong, nonatomic) NSMutableArray<PlayerF7*> *teamF7s;
@property (strong, nonatomic) NSMutableArray<PlayerS*> *teamSs;
@property (strong, nonatomic) NSMutableArray<PlayerCB*> *teamCBs;

@property (strong, nonatomic) TeamStrategy *offensiveStrategy;
@property (strong, nonatomic) TeamStrategy *defensiveStrategy;

//records
@property (nonatomic) int teamRecordCompletions;
@property (nonatomic) int teamRecordPassYards;
@property (nonatomic) int teamRecordPassTDs;
@property (nonatomic) int teamRecordInt;

@property (nonatomic) int teamRecordFum;
@property (nonatomic) int teamRecordRushYards;
@property (nonatomic) int teamRecordRushAtt;
@property (nonatomic) int teamRecordRushTDs;

@property (nonatomic) int teamRecordRecYards;
@property (nonatomic) int teamRecordReceptions;
@property (nonatomic) int teamRecordRecTDs;

@property (nonatomic) int teamRecordXPMade;
@property (nonatomic) int teamRecordFGMade;


-(instancetype)initWithName:(NSString*)nm abbreviation:(NSString*)abbr conference:(NSString*)conf league:(League*)ligue prestige:(int)prestige rivalTeam:(NSString*)rivalTeamAbbr;
//-(instancetype)initWithString:(NSString*)loadStr league:(League*)league;
+ (instancetype)newTeamWithName:(NSString*)nm abbreviation:(NSString*)abbr conference:(NSString*)conf league:(League*)ligue prestige:(int)prestige rivalTeam:(NSString*)rivalTeamAbbr;

-(void)updateTalentRatings;
-(void)advanceSeason;
-(void)advanceSeasonPlayers;
-(void)recruitPlayers:(NSArray*)needs;
-(void)recruitPlayersFreshman:(NSArray*)needs;
-(void)recruitWalkOns:(NSArray*)needs;
-(void)resetStats;
-(void)updatePollScore;
-(void)updateTeamHistory;
-(NSString*)getTeamHistoryString;
-(void)updateStrengthOfWins;
-(void)sortPlayers;
-(int)getOffensiveTalent;
-(int)getDefensiveTalent;

-(PlayerQB*)getQB:(int)depth;
-(PlayerRB*)getRB:(int)depth;
-(PlayerWR*)getWR:(int)depth;
-(PlayerK*)getK:(int)depth;
-(PlayerOL*)getOL:(int)depth;
-(PlayerS*)getS:(int)depth;
-(PlayerCB*)getCB:(int)depth;
-(PlayerF7*)getF7:(int)depth;

-(int)getPassProf;
-(int)getRushProf;
-(int)getPassDef;
-(int)getRushDef;
-(int)getCompositeOLPass;
-(int)getCompositeOLRush;
-(int)getCompositeF7Pass;
-(int)getCompositeF7Rush;
-(NSMutableArray*)getGameSummaryStrings:(int)gameNumber;
-(NSString*)getSeasonSummaryString;
-(NSMutableArray*)getPlayerStatsExpandListStrings;
-(NSString*)getRankString:(int)num;
-(NSString*)getRankStrStarUser:(int)num;
-(int)numGames;
-(int)getConfWins;
-(NSString*)strRep;
-(NSString*)strRepWithBowlResults;
-(NSString*)weekSummaryString;
-(NSString*)gameSummaryString:(Game*)g;
-(NSString*)gameSummaryStringScore:(Game*)g;
-(NSString*)gameSummaryStringOpponent:(Game*)g;
-(NSString*)getGraduatingPlayersString;
-(NSMutableArray*)getQBRecruits;
-(NSMutableArray*)getRBRecruits;
-(NSMutableArray*)getWRRecruits;
-(NSMutableArray*)getKRecruits;
-(NSMutableArray*)getOLRecruits;
-(NSMutableArray*)getSRecruits;
-(NSMutableArray*)getCBRecruits;
-(NSMutableArray*)getF7Recruits;
-(NSMutableArray*)getOffensiveTeamStrategies;
-(NSMutableArray*)getDefensiveTeamStrategies;
-(NSArray*)getTeamStatsArray;
-(void)setStarters:(NSArray<Player*>*)starters position:(int)position;
-(NSArray*)graduateSeniorsAndGetTeamNeeds;
-(void)simulateRecruitingSeason;
@end
