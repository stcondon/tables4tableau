import pandas as pd
import os
import math

def fte_last_season(path, league_dict):
    df = pd.read_csv(path)
    for key in league_dict:
        q = ''.join(['league_id == ', league_dict[key]])
        league = df.query(q).reset_index()
        num_teams = len(league.loc[:50, 'team1'].unique())
        i = math.floor(league.shape[0]/(num_teams * (num_teams - 1))) - 1
        return league.loc[((num_teams * (num_teams - 1)) * i):,:]
