def fte_mvp(df):
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
    t['xg_difference'] = t['xg_scored'] - t['xg_conceded']
    t['nsxg_difference'] = t['nsxg_scored'] - t['nsxg_conceded']
    t['adj_goal_difference'] = t['adj_goals_scored'] - t['adj_goals_conceded']
    return t
