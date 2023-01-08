#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <colors>

#define PLUGIN_VERSION "1.3.1"
#pragma semicolon 1

Handle g_PluginEnabled;
#define PLUGIN_ENABLED GetConVarBool(g_PluginEnabled)

public Plugin myinfo =
{
	name		= "[CS:GO/CSS] AbNeR Imposter",
	author		= "abnerfs",
	description = "Rob the skin of another player killing him with the knife",
	version		= PLUGIN_VERSION,
	url			= "https://github.com/abnerfs"
};

public OnPluginStart()
{
	CreateConVar("abner_imposter_version", PLUGIN_VERSION, "Plugin Version", FCVAR_NOTIFY | FCVAR_REPLICATED);
	g_PluginEnabled = CreateConVar("sm_imposter", "1", "Enable/Disable the imposter plugin.", FCVAR_NOTIFY | FCVAR_REPLICATED);

	HookEvent("player_death", EventPlayerDeath, EventHookMode_Pre);
	LoadTranslations("abner_imposter.phrases");
	CreateTimer(30.0, MessageTimer, _, TIMER_REPEAT);
}

public Action MessageTimer(Handle timer) {
	if(PLUGIN_ENABLED)
		CPrintToChatAll("%t%t", "prefix", "message");
	return Plugin_Handled;
}

public EventPlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	int	 victim	  = GetClientOfUserId(GetEventInt(event, "userid"));
	int	 attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

	char sWeapon[32];
	GetEventString(event, "weapon", sWeapon, sizeof(sWeapon));

	if (!PLUGIN_ENABLED || StrContains(sWeapon, "knife", false) == -1)
		return;

	if ((attacker == 0) || (GetClientTeam(attacker) == GetClientTeam(victim)) || (!IsPlayerAlive(attacker)))
		return;

	char sVictimModel[5000];
	GetClientModel(victim, sVictimModel, sizeof(sVictimModel));
	SetEntityModel(attacker, sVictimModel);

	CPrintToChatAll("%t%t", "prefix",  "Kill message", attacker, victim);

	if (GetEntProp(attacker, Prop_Send, "m_bHasDefuser") == 1)
	{
		SetEntProp(attacker, Prop_Send, "m_bHasDefuser", 0);
		CreateTimer(0.5, SetDefuser, attacker);
	}
}

public Action SetDefuser(Handle timer, any attacker)
{
	if (IsClientInGame(attacker) && GetClientTeam(attacker) != 1 && IsPlayerAlive(attacker))
	{
		SetEntProp(attacker, Prop_Send, "m_bHasDefuser", 1);
	}
	return Plugin_Handled;
}
