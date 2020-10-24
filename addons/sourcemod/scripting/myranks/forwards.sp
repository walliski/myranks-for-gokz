static Handle H_OnScoreChange;
static Handle H_OnMaxScoreChange;
static Handle H_OnInitialScoreLoad;

void CreateGlobalForwards()
{
    H_OnScoreChange = CreateGlobalForward("Myrank_OnScoreChange", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
    H_OnMaxScoreChange = CreateGlobalForward("Myrank_OnMaxScoreChange", ET_Ignore, Param_Cell, Param_Cell);
    H_OnInitialScoreLoad = CreateGlobalForward("Myrank_OnInitialScoreLoad", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
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

void Call_OnInitialScoreLoad(int client, int newScore, int mode)
{
    Call_StartForward(H_OnInitialScoreLoad);
    Call_PushCell(client);
    Call_PushCell(newScore);
    Call_PushCell(mode);
    Call_Finish();
}
