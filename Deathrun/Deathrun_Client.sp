

//Include:
#include <sourcemod>
#include <sdktools>

//Maker Information:
public Plugin:myinfo =
{
	name = "데스런 플러그인 (클라이언트)",
	author = "파천지교",
	description = "서버용 데스런 플러그인",
	version = PLUGIN_VERSION,
	url = "http://cafe.naver.com/hl2mp2"
};

//Weapon Manager:
public Action:WeaponRemove(Handle:Timer, any:Client)
{
	//Offset:
	new Weapon_Offset = FindSendPropOffs("CHL2MP_Player", "m_hMyWeapons");
	new Max_Guns = 16;
	Max_Guns = 20;

	//Loop:
	for(new i = 0; i < Max_Guns; i = (i + 4))
	{
		//Data:
		new Weapon_ID = GetEntDataEnt2(Client, Weapon_Offset + i);
		
		//Check:
		if(Weapon_ID > 0)
		{
			//Remove:
			RemovePlayerItem(Client, Weapon_ID);
			RemoveEdict(Weapon_ID);
		}
	}

	//Check:
	if(IsStillAlive(Client))
	{
		//Setting:
		GivePlayerItem(Client, "weapon_crowbar");

		//Check:
		if(ReadyT != -1)
		{
			//Setting:
			SetEntityMoveType(Client, MOVETYPE_NONE);
			SetEntProp(Client, Prop_Data, "m_takedamage", 0, 1);
		}
		else
		{
			//Setting:
			SetEntityMoveType(Client, MOVETYPE_WALK);
			SetEntProp(Client, Prop_Data, "m_takedamage", 2, 1);
		}

		//Setting:
		if(StrContains(ClassName[Client], "Trapper", false) != -1)
		{
			SetEntPropFloat(Client, Prop_Data, "m_flLaggedMovementValue", 2.0);

			PrecacheModel("models/gman.mdl", true);
			SetEntityModel(Client, "models/gman.mdl");
		}

		if(StrContains(ClassName[Client], "Escaper", false) != -1)
		{
			PrecacheModel("models/kleiner.mdl", true);
			SetEntityModel(Client, "models/kleiner.mdl");
		}
	}
}

//Respawn:
public Action:Respawn(Handle:Timer, any:Client)
{
	//Check:
	if(IsStillConnect(Client))
	{
		//Setting:
		ClassName[Client] = "Trapper";
		ChangeClientTeam(Client, 1);
		ChangeClientTeam(Client, 2);
		RoundEnd = false;

		//Call:
		SDKCall(RespawnHandle, Client);

		//Sound:
		EmitSoundToAll("ambient/alarms/klaxon1.wav", SOUND_FROM_PLAYER, _, _, _, 1.0);

		//Loop:
		for(new X; X <= GetMaxClients(); X++)
		{
			//Check:
			if(IsStillAlive(X))
			{
				//Setting:
				SetEntityMoveType(X, MOVETYPE_WALK);
				SetEntProp(X, Prop_Data, "m_takedamage", 2, 1);
			}
		}
	}
}

//Death:
public Action:SetSpector(Handle:Timer, any:Client)
{
	//Check:
	if(IsStillConnect(Client))
	{
		//Check:
		if(StrContains(ClassName[Client], "Spector", false) == -1) ClassName[Client] = "Dead";
	
		//Setting:
		ChangeClientTeam(Client, 1);
	}
}

//Select Trapper:
public Action:TrapperSelect(Handle:Timer)
{
	//Define:
	new Maxselect = 0;
	new Selects[MaxClients+1];

	//Loop:
	for(new i = 1;i <= MaxClients; i++)
	{
		//Check:
		if(IsClientConnected(i) && IsStillAlive(i) == true)
		{
			//Check:
			if(StrContains(ClassName[i], "Escaper", false) != -1)
			{
				Maxselect++;
				Selects[Maxselect] = i;
			}
		}
	}

	//Check:
	if(Maxselect > 0)
	{
		//String:
		new Select = Selects[GetRandomInt(1, Maxselect)];
			
		//Check:
		if(IsClientConnected(Select) && IsPlayerAlive(Select))
		{
			//String:
			new String:Client[32];

			//Get:
			GetClientName(Select, Client, 32);
	
			//Print:
			PrintToChatAll("\x04%s \x05Be A Trapper", Client);

			//Setting:
			ReadyT = -1;

			//Timer:
			CreateTimer(0.01, Respawn, Select);
		}
	}
}