void SetSkillGroups()
{
    char fileLocation[] = "cfg/sourcemod/myranks/skillgroups.cfg";
    KeyValues kv = new KeyValues("Myranks.SkillGroups");
    kv.ImportFromFile(fileLocation);

    // Go into list of ranks, if exists
    if (!kv.GotoFirstSubKey())
    {
        LogError("File does not contain skillgroups in correct format: %s", fileLocation);
        delete kv;
        return;
    }

    // Iterate over subsections at the same nesting level
    char name[SG_NAME_MAXLENGTH];
    char percentage[SG_PERCENTAGE_MAXLENGTH];
    int count = 0;
    do
    {
        kv.GetString("name", name, SG_NAME_MAXLENGTH);
        kv.GetString("percentage", percentage, SG_PERCENTAGE_MAXLENGTH);

        gS_SkillGroupName[count] = name;
        gF_SkillGroupPercentage[count] = StringToFloat(percentage);
        count++;
    } while (kv.GotoNextKey() && count < SG_MAXCOUNT);

    gI_SkillGroupCount = count;

    delete kv;
}

int GetSkillGroup(int score, int mode)
{
    int skillgroup = 0;

    for (int i = 0; i < gI_SkillGroupCount; i++)
    {
        if (score > gF_SkillGroupPercentage[i] * gI_MaxScore[mode])
        {
            skillgroup = i;
        }
        else
        {
            break;
        }
    }

    return skillgroup;
}