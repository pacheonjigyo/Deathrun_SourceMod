

//Include:
#include <sourcemod>
#include <sdktools>

//Maker Information:
public Plugin:myinfo =
{
	name = "������ �÷����� (�Լ�)",
	author = "��õ����",
	description = "������ ������ �÷�����",
	version = PLUGIN_VERSION,
	url = "http://cafe.naver.com/hl2mp2"
};

//Bool:
public bool:IsCanEntity(Client)
{
	if(IsValidEntity(Client)) return true;
	return false;
}

public bool:IsStillConnect(Client)
{
	if(IsValidEntity(Client)) if(Client <= GetMaxClients()) if(Client != 0) if(IsClientConnected(Client)) return true;
	return false;
}

public bool:IsStillAlive(Client)
{
	if(IsValidEntity(Client)) if(Client < GetMaxClients() +1) if(Client != 0) if(IsClientConnected(Client)) if(IsPlayerAlive(Client)) return true;
	return false;
}

//Stock:
stock SayText2ToAll(client, const String:message[])
{
	//Handle:
	new Handle:Msg = StartMessageAll("SayText2");

	//Check:
	if(Msg != INVALID_HANDLE)
	{
		//Print:
		BfWriteByte(Msg, client);
		BfWriteByte(Msg, true);
		BfWriteString(Msg, message);
		EndMessage(); 
	}
}