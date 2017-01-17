#include <sourcemod>
#include <sdktools>
#include <voiceannounce_ex>
#include <warden>
#pragma newdecls required

bool g_bIsClientSpeaking[MAXPLAYERS+1];
bool g_bIsWardenSpeaking;

int g_iWarningCounter[MAXPLAYERS+1];

ConVar g_cvShowWarning;

public Plugin myinfo =
{
	name = "Target Talking",
	author = "eXiLe",
	description = "Plugin for admins to target players who are talking (Made for JailBreak)",
	version = "1.2",
	url = "https://github.com/eXiLe1/TargetTalking"
};

public void OnPluginStart()
{
	LoadTranslations("targettalking.phrases");
	
	AddConVars();
	AddTargetFilters();
	HookEvents();
}

public void OnPluginEnd()
{
	RemoveTargetFilters();
}

public void OnClientPutInServer(int client)
{
	g_bIsClientSpeaking[client] = false;
	g_iWarningCounter[client] = 0;
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
		return;
	}	
	
	if (g_cvShowWarning.IntValue != 0 && g_bIsWardenSpeaking && g_bIsClientSpeaking[client])
	{
		g_iWarningCounter[client]++;
		if (g_iWarningCounter[client] >= g_cvShowWarning.IntValue)
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

public void warden_OnWardenRemoved(int client)
{
	g_bIsWardenSpeaking = false;
}

void HookEvents()
{
	HookEvent("round_start", Event_RoundStart);
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_bIsWardenSpeaking = false;
}

void AddTargetFilters()
{
	AddMultiTargetFilter("@talking", TargetTalkingPlayers, "Talking", false);
	AddMultiTargetFilter("@talkingct", TargetTalkingCTs, "Talking CT", false);
	AddMultiTargetFilter("@talkingt", TargetTalkingTs, "Talking T", false);
}

void RemoveTargetFilters()
{
	RemoveMultiTargetFilter("@talking", TargetTalkingPlayers);
	RemoveMultiTargetFilter("@talkingct", TargetTalkingCTs);
	RemoveMultiTargetFilter("@talkingt", TargetTalkingTs);
}

public bool TargetTalkingPlayers(const char[] pattern, Handle clients)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!warden_iswarden(i) && g_bIsClientSpeaking[i])
		{
			PushArrayCell(clients, i);
		}
	}
}

public bool TargetTalkingCTs(const char[] pattern, Handle clients)
{
	int client;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!warden_iswarden(i) && g_bIsClientSpeaking[i] && GetClientTeam(client) == 3)
		{
			PushArrayCell(clients, i);
		}
	}
}

public bool TargetTalkingTs(const char[] pattern, Handle clients)
{
	int client;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!warden_iswarden(i) && g_bIsClientSpeaking[i] && GetClientTeam(client) == 2)
		{
			PushArrayCell(clients, i);
		}
	}
}

void AddConVars()
{
	g_cvShowWarning = CreateConVar("showwarning", "0", "After how many offenses to show hinttext warning to player (0 to disable)");
	
	AutoExecConfig(true, "TargetTalking");
}

