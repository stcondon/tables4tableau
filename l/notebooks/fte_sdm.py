import pandas as pd
import os
import math

def fte_mvp(df):
    df.dropna(subset = ['score1'], inplace = True)
    season = '-'.join([df.iloc[0]['date'][0:4],df.iloc[-1]['date'][0:4]])
    home = df.groupby('team1').apply(
        lambda x: (x['score1'] > x['score2']).sum() * 3 + (x['score1'] == x['score2']).sum()).reset_index(name='points')
    pt = pd.pivot_table(df, values = ['score1', 'score2', 'xg1', 'xg2', 'nsxg1', 'nsxg2', 'adj_score1','adj_score2'],
                        index = 'team1', aggfunc=sum)
    home = home.merge(pt.reset_index(), on = 'team1')
    pt = pd.pivot_table(df, values = 'date', index = 'team1', aggfunc=pd.Series.nunique)
    home = home.merge(pt.reset_index(), on = 'team1')
    cols = {'date':'played', 'team1':'team', 'score1':'scored', 'score2':'conceded', 'xg1':'xg_scored',
            'xg2':'xg_conceded', 'nsxg1':'nsxg_scored', 'nsxg2':'nsxg_conceded', 'adj_score1':'adj_goals_scored',
            'adj_score2':'adj_goals_conceded'}
    home = home.rename(columns = cols)
    away = df.groupby('team2').apply(
        lambda x: (x['score2'] > x['score1']).sum() * 3 + (x['score1'] == x['score2']).sum()).reset_index(name='points')
    pt = pd.pivot_table(df, values = ['score1', 'score2', 'xg1', 'xg2', 'nsxg1', 'nsxg2', 'adj_score1','adj_score2'],
                        index = 'team2', aggfunc=sum)
    away = away.merge(pt.reset_index(), on = 'team2')
    pt = pd.pivot_table(df, values = 'date', index = 'team2', aggfunc=pd.Series.nunique)
    away = away.merge(pt.reset_index(), on = 'team2')
    cols = {'date':'played', 'team2':'team', 'score2':'scored', 'score1':'conceded', 'xg2':'xg_scored',
            'xg1':'xg_conceded', 'nsxg2':'nsxg_scored', 'nsxg1':'nsxg_conceded', 'adj_score2':'adj_goals_scored',
            'adj_score1':'adj_goals_conceded'}
    away = away.rename(columns = cols)
    t = pd.concat([home, away], ignore_index=True)
    t = t.groupby('team').sum()
    t['goal_difference'] = t['scored'] - t['conceded']
    t['season'] = season
    return t

def fte_england_tb(df):
    t = fte_mvp(df)
    t = t.sort_values(by=['points', 'goal_difference', 'scored'], ascending = False)
    t['position'] = t.reset_index().index + 1
    return t

def fte_spain_tb(df):
    t = fte_mvp(df)
    if t.duplicated(subset='points', keep = False).sum() > 0:
        t['tb'] = 0
        ties = t[t.duplicated(subset='points', keep = False)]['points'].unique()
        for tie in ties:
            teams = t[t['points'] == tie].index.values
            temp = df.loc[df['team1'].isin(teams) & df['team2'].isin(teams)].dropna()
            if len(temp.index) < (len(teams) * (len(teams) - 1)):
                for team in teams: t.at[team, 'tb'] = 1
            else:
                mini = fte_mvp(temp)
                if mini.duplicated(subset = ['points', 'goal_difference'], keep = False).sum() > 0:
                    mini = pd.merge(mini, t[['goal_difference']], how = 'inner', left_index=True, right_index=True, suffixes=['', '_total'])
                    mini = mini.sort_values(by=['points', 'goal_difference', 'goal_difference_total'], ascending = False)
                else:
                    mini = mini.sort_values(by=['points', 'goal_difference'], ascending = False)

                mini['tb'] = [2 * mini.shape[0]] * len(mini.index) - mini.reset_index().index
                t.update(mini['tb'])
        t = t.sort_values(by=['points', 'tb', 'goal_difference', 'scored'], ascending = False)
        t.drop('tb', axis = 1, inplace=True)
    else:
        t = t.sort_values(by='points', ascending = False)
    t['position'] = t.reset_index().index + 1
    return t

def fte_france_tb(df):
    t = fte_mvp(df)
    t = t.sort_values(by=['points', 'goal_difference', 'scored'], ascending = False)
    t['position'] = t.reset_index().index + 1
    return t

def fte_germany_tb(df):
    # home
    t = fte_mvp(df)
    if t.duplicated(subset=['points', 'goal_difference', 'scored'], keep = False).sum() > 0:
        t['tb'] = 0
        ties = t[t.duplicated(subset='points', keep = False)]['points'].unique()
        for tie in ties:
            teams = t[t['points'] == tie].index.values
            temp = df.loc[df['team1'].isin(teams) & df['team2'].isin(teams)].dropna()
            mini = fte_mvp(temp)
            if mini.duplicated(subset = ['points', 'goal_difference'], keep = False).sum() > 0:
                mini_away = temp.loc[temp['team2'].isin(teams)].dropna()
                mini_away = mvp(mini_away)
                away = mvp(df,date = date, home_team = home_team, away_team = away_team, home_goals = home_goals, away_goals = away_goals)
                mini = pd.merge(mini, mini_away[['team','scored']], how = 'inner', left_index=True,
                                right_on = 'team', suffixes=['', '_away'])
                mini = pd.merge(mini, away[['team','scored']], how = 'inner', on = 'team_name',
                                suffixes=['', '_total_away'])
                mini = mini.sort_values(by=['points', 'goal_difference', 'scored_away', 'scored_total_away'], ascending = False)
            else:
                mini = mini.sort_values(by=['points', 'goal_difference'], ascending = False)
            mini['tb'] = 2 * mini.shape[0] - mini.reset_index().index
            t.update(mini['tb'])
        t = t.sort_values(by=['points', 'tb', 'goal_difference', 'scored'], ascending = False)
        t.drop('tb', axis = 1, inplace=True)
    else:
        t = t.sort_values(by=['points', 'goal_difference', 'scored'], ascending = False)
    t['position'] = t.reset_index().index + 1
    return t

def fte_italy_tb(df):
    t = fte_mvp(df)
    if t.duplicated(subset='points', keep = False).sum() > 0:
        t['tb'] = 0
        ties = t[t.duplicated(subset='points', keep = False)]['points'].unique()
        for tie in ties:
            teams = t[t['points'] == tie].index.values
            temp = df.loc[df['team1'].isin(teams) & df['team2'].isin(teams)].dropna()
            if len(temp.index) < (len(teams) * (len(teams) - 1)):
                for team in teams: t.at[team, 'tb'] = 1
            else:
                mini = fte_mvp(temp)
                if mini.duplicated(subset = ['points', 'goal_difference'], keep = False).sum() > 0:
                    mini = pd.merge(mini, t[['goal_difference']], how = 'inner', left_index=True, right_index=True, suffixes=['', '_total'])
                    mini = mini.sort_values(by=['points', 'goal_difference', 'goal_difference_total'], ascending = False)
                else:
                    mini = mini.sort_values(by=['points', 'goal_difference'], ascending = False)
                mini['tb'] = [2 * mini.shape[0]] * len(mini.index) - mini.reset_index().index
                t.update(mini['tb'])
        t = t.sort_values(by=['points', 'tb', 'goal_difference', 'scored'], ascending = False)
        t.drop('tb', axis = 1, inplace=True)
    else:
        t = t.sort_values(by='points', ascending = False)
    t['position'] = t.reset_index().index + 1
    return t

def fte_spain_tb(df):
    t = fte_mvp(df)
    if t.duplicated(subset='points', keep = False).sum() > 0:
        t['tb'] = 0
        ties = t[t.duplicated(subset='points', keep = False)]['points'].unique()
        for tie in ties:
            teams = t[t['points'] == tie].index.values
            temp = df.loc[df['team1'].isin(teams) & df['team2'].isin(teams)].dropna()
            if len(temp.index) < (len(teams) * (len(teams) - 1)):
                for team in teams: t.at[team, 'tb'] = 1
            else:
                mini = fte_mvp(temp)
                if mini.duplicated(subset = ['points', 'goal_difference'], keep = False).sum() > 0:
                    mini = pd.merge(mini, t[['goal_difference']], how = 'inner', left_index=True, right_index=True, suffixes=['', '_total'])
                    mini = mini.sort_values(by=['points', 'goal_difference', 'goal_difference_total'], ascending = False)
                else:
                    mini = mini.sort_values(by=['points', 'goal_difference'], ascending = False)
                mini['tb'] = [2 * mini.shape[0]] * len(mini.index) - mini.reset_index().index
                t.update(mini['tb'])
        t = t.sort_values(by=['points', 'tb', 'goal_difference', 'scored'], ascending = False)
        t.drop('tb', axis = 1, inplace=True)
    else:
        t = t.sort_values(by='points', ascending = False)
    t['position'] = t.reset_index().index + 1
    return t
