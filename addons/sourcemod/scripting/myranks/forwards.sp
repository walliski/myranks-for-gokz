static Handle H_OnScoreChange;
static Handle H_OnMaxScoreChange;

void CreateGlobalForwards()
{
    H_OnScoreChange = CreateGlobalForward("Myrank_OnScoreChange", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
    H_OnMaxScoreChange = CreateGlobalForward("Myrank_OnMaxScoreChange", ET_Ignore, Param_Cell, Param_Cell);
}

void Call_OnScoreChange(int client, int newScore, int mode)
{
    Call_StartForward(H_OnScoreChange);
    Call_PushCell(client);
    Call_PushCell(newScore);
    Call_PushCell(mode);
    Call_Finish();
}

void Call_OnMaxScoreChange(int newScore, int mode)
{
    Call_StartForward(H_OnMaxScoreChange);
    Call_PushCell(newScore);
    Call_PushCell(mode);
    Call_Finish();
}
