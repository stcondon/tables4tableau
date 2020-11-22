def fte_england_tb(df):
    t = fte_mvp(df)
    t = t.sort_values(by=['points', 'goal_difference', 'scored'], ascending = False)
    t['position'] = t.reset_index().index + 1
    return t
