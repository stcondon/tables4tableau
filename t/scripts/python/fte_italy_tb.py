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
                mini['tb'] = 2 * mini.shape[0] - mini.reset_index().index
                t.update(mini['tb'])
        t = t.sort_values(by=['points', 'tb', 'goal_difference', 'scored'], ascending = False)
        t.drop('tb', axis = 1, inplace=True)
    else:
        t = t.sort_values(by='points', ascending = False)
    t['position'] = t.reset_index().index + 1
    return t
