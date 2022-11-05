

//Include:
#include <sourcemod>
#include <sdktools>

//Maker Information:
public Plugin:myinfo =
{
	name = "데스런 플러그인 (후크 이벤트)",
	author = "파천지교",
	description = "서버용 데스런 플러그인",
	version = PLUGIN_VERSION,
	url = "http://cafe.naver.com/hl2mp2"
};

//Say Event:
public Action:SayHook(Client, Args)
{
	//String:
	new String:clientsteamid[32], String:name[32], String:msg[255], String:buffer[255], String:cmdbuffer[255];

	//Get:
	GetClientAuthString(Client, clientsteamid, 32);
	GetClientName(Client, name, sizeof(name));
	GetCmdArgString(msg, sizeof(msg));
	
	//Buffer:
	strcopy(cmdbuffer, 255, msg);
	msg[strlen(msg)-1] = '\0';
	StripQuotes(cmdbuffer);
	TrimString(cmdbuffer);

	//Format:
	Format(buffer, sizeof(buffer), "\x03[\x04%s\x03] \x03%s \x01: %s", ClassName[Client], name, msg[1]);

	//Call:
	SayText2ToAll(Client, buffer);
	PrintToServer(buffer);

	//Return:
	return Plugin_Handled;
}

//Spawn:
public Event_Spawn(Handle:Spawn_Event, const String:Spawn_Name[], bool:Spawn_Broadcast)
{
	//String:
	new Client = GetClientOfUserId(GetEventInt(Spawn_Event, "userid"));

	//Timer:
	CreateTimer(0.5, WeaponRemove, Client);
}

//Death:
public Action:Player_Death(Handle:Event, const String:Name[], bool:Broadcast)
{
	//String:
	new Client = GetClientOfUserId(GetEventInt(Event, "userid"));
	//new Attacker = GetClientOfUserId(GetEventInt(Event, "attacker"));

	//Check:
	if(ReadyT == -1) CreateTimer(0.1, SetSpector, Client);

	if(StrContains(ClassName[Client], "Trapper", false) != -1)
	{
		//Random BGM:
		decl RandomBackground;
		RandomBackground = GetRandomInt(1, 3);

		//Sound:
		if(RandomBackground == 1) EmitSoundToAll("npc/zombie/zombie_die1.wav", SOUND_FROM_PLAYER, _, _, _, 1.0);
		if(RandomBackground == 2) EmitSoundToAll("npc/zombie/zombie_die2.wav", SOUND_FROM_PLAYER, _, _, _, 1.0);
		if(RandomBackground == 3) EmitSoundToAll("npc/zombie/zombie_die3.wav", SOUND_FROM_PLAYER, _, _, _, 1.0);
	}
}

//Team:
public Action:Team_Event(Handle:Team_Event, const String:name[], bool:dontBroadcast)
{
	//Check:
	if(!dontBroadcast && !GetEventBool(Team_Event, "silent"))
	{
		//Setting:
		SetEventBroadcast(Team_Event, true);

		//Change:
		return Plugin_Changed;
	}

	//Continue:
	return Plugin_Continue;
}

//Name:
public Action:Name_Event(Handle:Name_Event, const String:name[], bool:dontBroadcast)
{
	//Check:
	if(!dontBroadcast && !GetEventBool(Name_Event, "silent"))
	{
		//Setting:
		SetEventBroadcast(Name_Event, true);

		//Change:
		return Plugin_Changed;
	}

	//Continue:
	return Plugin_Continue;
}