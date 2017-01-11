#include <sourcemod>
#include <voiceannounce_ex>
#include <warden>
#pragma newdecls required

bool g_bIsClientSpeaking[MAXPLAYERS+1];
bool g_bIsWardenSpeaking;

int g_WarningCounter;

ConVar g_cvEnabled;
ConVar g_cvShowWarning;

public Plugin myinfo =
{
	name = "Target Talking",
	author = "eXiLe",
	description = "Plugin for admins to target players who are talking (Made for JailBreak)",
	version = "1.0",
	url = "TBD"
};

public void OnPluginStart()
{
	LoadTranslations("targettalking.phrases");
	
	g_cvEnabled = CreateConVar("targettalking_enabled", "1", "Sets whether the plugin is enabled");
	g_cvShowWarning = CreateConVar("showwarning", "0", "After how many offenses to show hinttext warning to player (0 to disable)");
	
	AddMultiTargetFilter("@talking", DoTalking, "Talking", false);
	AddMultiTargetFilter("@talkingct", DoTalkingct, "Talking CT", false);
	AddMultiTargetFilter("@talkingt", DoTalkingt, "Talking T", false);
	
	AutoExecConfig(true, "TargetTalking");
}

public void OnPluginEnd()
{
	RemoveMultiTargetFilter("@talking", DoTalking);
	RemoveMultiTargetFilter("@talkingct", DoTalkingct);
	RemoveMultiTargetFilter("@talkingt", DoTalkingt);
}
public void onMapStart()
{
	if(!g_cvEnabled)
		return;
}

public void OnClientPutInServer(int client)
{
	g_bIsClientSpeaking[client] = false;
    g_bIsWardenSpeaking = false;
}

public void OnClientSpeakingEx(int client)
{
    if (g_bIsClientSpeaking[client])
    {
        // This client was speaking already, we don't need to do things "as long as the player speaks" here so ignore this situation
        return;
    }

    // The player has only just started speaking
    g_bIsClientSpeaking[client] = true;

    // Do your checks to see if the warden is speaking here
	if (warden_iswarden(client))
	{
		g_bIsWardenSpeaking = true;
	}	
	
	if (g_cvShowWarning != 0 && g_bIsWardenSpeaking && g_bIsClientSpeaking[client])
	{
		g_WarningCounter = g_WarningCounter++
		if (g_WarningCounter == g_cvShowWarning)
		{
			PrintHintText(client, "%t", "Warning");
		}
	}
}

public void OnClientSpeakingEnd(int client)
{
	g_bIsClientSpeaking[client] = false;
    if (warden_iswarden(client))
	{
		g_bIsWardenSpeaking = false;
	}
}


public bool DoTalking(const char[] pattern, Handle clients)
{
	int client = GetNativeCell(1);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!warden_iswarden(client) && g_bIsWardenSpeaking == true && g_bIsClientSpeaking[client] == true)
			PushArrayCell(clients, i);
	}
}

public bool DoTalkingct(const char[] pattern, Handle clients)
{
	int client = GetNativeCell(1);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!warden_iswarden(client) && g_bIsWardenSpeaking == true && g_bIsClientSpeaking[client] == true && GetClientTeam(client) == 3)
			PushArrayCell(clients, i);
	}
}

public bool DoTalkingt(const char[] pattern, Handle clients)
{
	int client = GetNativeCell(1);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!warden_iswarden(client) && g_bIsWardenSpeaking && g_bIsClientSpeaking[client] && GetClientTeam(client) == 2)
			PushArrayCell(clients, i);
	}
}
