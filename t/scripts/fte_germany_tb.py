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
