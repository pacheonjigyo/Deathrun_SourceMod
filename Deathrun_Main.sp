

//Base Include:
#include <sourcemod>
#include <sdktools>

//Maker Information:
public Plugin:myinfo =
{
	name = "데스런 플러그인 (메인)",
	author = "파천지교",
	description = "서버용 데스런 플러그인",
	version = PLUGIN_VERSION,
	url = "http://cafe.naver.com/hl2mp2"
};

//Define:
#define PLUGIN_VERSION "1.0.0"

//Custom Include:
#include "Deathrun/Deathrun_Definition.sp"
#include "Deathrun/Deathrun_Stock_Bool.sp"
#include "Deathrun/Deathrun_Hook_Event.sp"
#include "Deathrun/Deathrun_Client.sp"

//Plugin Start:
public OnPluginStart()
{
	//Version:
	CreateConVar("Deathrun_Version", PLUGIN_VERSION, "by 파천지교", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

	//SDK Call:
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetVirtual(VIRTUAL_RESPAWN);
	RespawnHandle = EndPrepSDKCall();

	//Hook Event:
	HookEvent("player_spawn", Event_Spawn);
	HookEvent("player_death", Player_Death, EventHookMode_Pre);

	//Public Command:
	RegConsoleCmd("jointeam", SystemDefence);
	RegConsoleCmd("kill", SystemDefence);
	RegConsoleCmd("explode", SystemDefence);

	RegConsoleCmd("say", SayHook);
	RegConsoleCmd("say_team", SayHook);
}

//Argument:
public Action:SystemDefence(Client, Args)
{
	//Return:
	return Plugin_Handled;
}

//Map Start:
public OnMapStart()
{
	//Initialize:
	Victory = 0;
	ReadyT = 0;
	RoundEnd = false;
	SystemStart = false;
	WaitingTime = false;

	//Timer:
	CreateTimer(15.0, System);

	//Loop:
	for(new X = 0; X < SOUND_AMOUNT; X++)
	{
		//Precache:
		decl String:file[256];
		Format(file, 256, "sound/%s", GetPrecacheSound[X]);
		AddFileToDownloadsTable(file);
		PrecacheSound(GetPrecacheSound[X], true);
	}
}

//Map End:
public OnMapEnd()
{
	//Initialize:
	Victory = 0;
	ReadyT = 0;
	RoundEnd = false;
	SystemStart = false;
	WaitingTime = false;

	//Check:
	if(BugFix != INVALID_HANDLE)
	{
		//Kill:
		KillTimer(BugFix);
		CloseHandle(BugFix);
		BugFix = INVALID_HANDLE;
	}
}

//Connect:
public OnClientPutInServer(Client)
{
	//Timer:
	CreateTimer(0.1, SetSpector, Client);
}

//Disconnect:
public OnClientDisconnect(Client)
{
	//
}

//Main System:
public Action:System(Handle:Timer)
{
	//Check:
	if(!SystemStart)
	{
		//Check:
		if(GetClientCount() > 1)
		{
			//Setting:
			SystemStart = true;
			WaitingTime = true;

			//Timer:
			CreateTimer(1.0, System);

			//Print:
			PrintCenterTextAll("Round Start");

			//Random BGM:
			decl RandomBackground;
			RandomBackground = GetRandomInt(1, 3);

			//Sound:
			if(RandomBackground == 1) EmitSoundToAll("ambient/machines/teleport1.wav", SOUND_FROM_PLAYER, _, _, _, 1.0);
			if(RandomBackground == 2) EmitSoundToAll("ambient/machines/teleport3.wav", SOUND_FROM_PLAYER, _, _, _, 1.0);
			if(RandomBackground == 3) EmitSoundToAll("ambient/machines/teleport4.wav", SOUND_FROM_PLAYER, _, _, _, 1.0);
			
		}
		else
		{
			//Timer:
			CreateTimer(5.0, System);
	
			//Print:
			PrintCenterTextAll("Waiting For Another Players.");
		}
	}
	else
	{
		//Int:
		new Trapper = 0;
		new Escaper = 0;

		//Loop:
		for(new Client = 1; Client <= GetMaxClients(); Client++)
		{
			//Check:
			if(IsStillAlive(Client) && WaitingTime)
			{
				//Count:
				if(StrContains(ClassName[Client], "Trapper", false) != -1) Trapper++;
				if(StrContains(ClassName[Client], "Escaper", false) != -1) Escaper++;

				//Bug:
				if(StrContains(ClassName[Client], "Escaper", false) != -1 && GetClientTeam(Client) == 2 || StrContains(ClassName[Client], "Trapper", false) != -1 && GetClientTeam(Client) == 3) if(IsStillAlive(Client) && ReadyT == -1) ForcePlayerSuicide(Client);
			}
		}

		//Check:
		if(Trapper == 0 || Escaper == 0)
		{
			//Check:
			if(!RoundEnd && WaitingTime)
			{
				//Loop:
				for(new Client = 1; Client <= GetMaxClients(); Client++)
				{
					//Timer:
					CreateTimer(1.0, SetSpector, Client);

					//Setting:
					RoundEnd = true;

					//Check:
					if(IsStillAlive(Client))
					{
						//Check:
						if(StrContains(ClassName[Client], "Trapper", false) != -1) Victory = 2;
						if(StrContains(ClassName[Client], "Escaper", false) != -1) Victory = 3;
							
						//Print:
						PrintCenterText(Client, "Round End");
					}

					//Check:
					if(Client == GetMaxClients())
					{
						//Timer:
						CreateTimer(0.1, VictoryPrint);
						CreateTimer(10.0, RoundReset);
					}
				}
			}
		}

		//Initionalize:
		Trapper = 0;
		Escaper = 0;

		//Repeat:
		BugFix = CreateTimer(1.0, System);
	}
}

//Victory Team:
public Action:VictoryPrint(Handle:Timer)
{
	//Check:
	if(WaitingTime)
	{
		//Loop:
		for(new Client = 1; Client <= GetMaxClients(); Client++)
		{
			//Check:
			if(IsStillConnect(Client))
			{
				//Check:
				if(Victory == 2) //Trapper Win:
				{
					//Print:
					PrintCenterText(Client, "Trapper Win");

					//Sound:
					EmitSoundToClient(Client,"ambient/energy/whiteflash.wav",SOUND_FROM_PLAYER,SNDCHAN_AUTO,SNDLEVEL_NORMAL,SND_NOFLAGS,SNDVOL_NORMAL,SNDPITCH_NORMAL,-1,NULL_VECTOR,NULL_VECTOR,true,0.0);
				}
				else if(Victory == 3) //Escaper Win:
				{
					//Print:
					PrintCenterText(Client, "Escaper Win");

					//Sound:
					EmitSoundToClient(Client,"ambient/energy/whiteflash.wav",SOUND_FROM_PLAYER,SNDCHAN_AUTO,SNDLEVEL_NORMAL,SND_NOFLAGS,SNDVOL_NORMAL,SNDPITCH_NORMAL,-1,NULL_VECTOR,NULL_VECTOR,true,0.0);
				}
				else //Round Draw:
				{
					//Print:
					PrintCenterText(Client, "Resetting Round..");
				}
			}
		}
	}
}

//Resetting Round:
public Action:RoundReset(Handle:Timer)
{
	//Check:
	if(WaitingTime)
	{
		//Setting:
		ReadyT = 15;
		Victory = 0;

		//Command:
		ServerCommand("mp_restartgame 1");

		//Random BGM:
		decl RandomBackground;
		RandomBackground = GetRandomInt(1, 10);

		//Sound:
		if(RandomBackground == 1) EmitSoundToAll("ambient/levels/citadel/strange_talk1.wav", SOUND_FROM_PLAYER, _, _, _, 1.0);
		if(RandomBackground == 2) EmitSoundToAll("ambient/levels/citadel/strange_talk3.wav", SOUND_FROM_PLAYER, _, _, _, 1.0);
		if(RandomBackground == 3) EmitSoundToAll("ambient/levels/citadel/strange_talk4.wav", SOUND_FROM_PLAYER, _, _, _, 1.0);
		if(RandomBackground == 4) EmitSoundToAll("ambient/levels/citadel/strange_talk5.wav", SOUND_FROM_PLAYER, _, _, _, 1.0);
		if(RandomBackground == 5) EmitSoundToAll("ambient/levels/citadel/strange_talk6.wav", SOUND_FROM_PLAYER, _, _, _, 1.0);
		if(RandomBackground == 6) EmitSoundToAll("ambient/levels/citadel/strange_talk7.wav", SOUND_FROM_PLAYER, _, _, _, 1.0);
		if(RandomBackground == 7) EmitSoundToAll("ambient/levels/citadel/strange_talk8.wav", SOUND_FROM_PLAYER, _, _, _, 1.0);
		if(RandomBackground == 8) EmitSoundToAll("ambient/levels/citadel/strange_talk9.wav", SOUND_FROM_PLAYER, _, _, _, 1.0);
		if(RandomBackground == 9) EmitSoundToAll("ambient/levels/citadel/strange_talk10.wav", SOUND_FROM_PLAYER, _, _, _, 1.0);
		if(RandomBackground == 10) EmitSoundToAll("ambient/levels/citadel/strange_talk11.wav", SOUND_FROM_PLAYER, _, _, _, 1.0);

		//Timer:
		CreateTimer(5.0, SelectSetting);

		//Loop:
		for(new Client = 1; Client <= GetMaxClients(); Client++)
		{
			//Check:
			if(IsCanEntity(Client) && StrContains(ClassName[Client], "Spector", false) == -1)
			{
				//Setting:
				ClassName[Client] = "Escaper";
				ChangeClientTeam(Client, 1);
				ChangeClientTeam(Client, 3);
			}
		}
	}
}

public Action:SelectSetting(Handle:Timer)
{
	//Check:
	if(WaitingTime)
	{
		//Check:
		if(ReadyT > 0)
		{
			//Count:
			ReadyT--;
	
			//Print:
			if(ReadyT > 0) PrintCenterTextAll("Selecting Trapper... [Timeleft : %d Second(s)]", ReadyT);

			//Sound:
			if(ReadyT < 6) EmitSoundToAll("buttons/button10.wav", SOUND_FROM_PLAYER, _, _, _, 1.0);
					
			//Timer:
			CreateTimer(1.0, SelectSetting);
		}
		else
		{
			//Timer:
			CreateTimer(0.1, TrapperSelect);
		}
	}
}