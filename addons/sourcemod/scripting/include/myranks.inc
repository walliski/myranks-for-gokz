/** Double-include prevention */
#if defined _myrank_included_
  #endinput
#endif
#define _myrank_included_

#define MYRANK_VERSION "1.0.1"

#define MYRANK_SG_NAME_MAXLENGTH 24
#define MYRANK_SG_PERCENTAGE_MAXLENGTH 8
#define MYRANK_SG_MAXCOUNT 32

// NATIVES

/*
 * Gets the color of a skill group
 *
 * @param skillGroup        The skillgroup to get the color for.
 * @param skillGroupColor   The char[] to put the color into.
*/
native void Myrank_GetSkillGroupColor(int skillGroup, char[] skillGroupColor);

/*
 * Gets the name of a skill group
 *
 * @param skillGroup       The skillgroup to get the color for.
 * @param skillGroupName   The char[] to put the name into.
*/
native void Myrank_GetSkillGroupName(int skillGroup, char[] skillGroupName);

/*
 * Gets the skillgroup for a certain mode and score
 *
 * @param score   The score for which to get a skillgroup
 * @param mode    The mode for which to get a skillgroup
*/
native int Myrank_GetSkillGroup(int score, int mode);

/*
 * Gets the skillgroup for a certain mode and score
 *
 * @param client   The client to get score for
 * @param mode     The mode for which to get score
 */
native int Myrank_GetScore(int client, int mode);

// FORWARDS

/*
 * Called when a players score changes.
 *
 * @param client      For which client the score changed
 * @param newScore    The new score for the client
 * @param mode        In which mode the score changed
*/

forward void Myrank_OnScoreChange(int client, int newScore, int mode);

/*
 * Called when the max score changes for a mode.
 *
 * @param newScore    The new score for the mode
 * @param mode        In which mode the score changed
*/

forward void Myrank_OnMaxScoreChange(int newScore, int mode);
