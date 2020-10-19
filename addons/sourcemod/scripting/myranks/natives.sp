void CreateNatives()
{
    CreateNative("Myrank_GetSkillGroupColor", Native_GetSkillGroupColor);
    CreateNative("Myrank_GetSkillGroupName", Native_GetSkillGroupName);
    CreateNative("Myrank_GetSkillGroup", Native_GetSkillGroup);
    CreateNative("Myrank_GetScore", Native_GetScore);
}

public int Native_GetSkillGroupColor(Handle plugin, int numParams)
{
    SetNativeString(2, gS_SkillGroupColor[GetNativeCell(1)], MYRANK_SG_NAME_MAXLENGTH);
}

public int Native_GetSkillGroupName(Handle plugin, int numParams)
{
    SetNativeString(2, gS_SkillGroupName[GetNativeCell(1)], MYRANK_SG_NAME_MAXLENGTH);
}

public int Native_GetSkillGroup(Handle plugin, int numParams)
{
    return GetSkillGroup(GetNativeCell(1), GetNativeCell(2));
}

public int Native_GetScore(Handle plugin, int numParams)
{
    return gI_Score[GetNativeCell(2)][GetNativeCell(1)];
}