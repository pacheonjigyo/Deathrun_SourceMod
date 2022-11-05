

//Include:
#include <sourcemod>
#include <sdktools>

//Maker Information:
public Plugin:myinfo =
{
	name = "데스런 플러그인 (선언및 정의)",
	author = "파천지교",
	description = "서버용 데스런 플러그인",
	version = PLUGIN_VERSION,
	url = "http://cafe.naver.com/hl2mp2"
};

#define VIRTUAL_RESPAWN 21
#define SOUND_AMOUNT 19

//Bool:
new bool:RoundEnd = false;
new bool:SystemStart = false;
new bool:WaitingTime = false;

//Handle:
new Handle:RespawnHandle = INVALID_HANDLE;
new Handle:BugFix = INVALID_HANDLE;

//Int:
new Victory;
new ReadyT;

//String:
new String:ClassName[32][255];
new String:GetPrecacheSound[SOUND_AMOUNT][128] =
{
	"ambient/alarms/klaxon1.wav",
	"ambient/energy/whiteflash.wav",
	"ambient/levels/citadel/strange_talk1.wav",
	"ambient/levels/citadel/strange_talk3.wav",
	"ambient/levels/citadel/strange_talk4.wav",
	"ambient/levels/citadel/strange_talk5.wav",
	"ambient/levels/citadel/strange_talk6.wav",
	"ambient/levels/citadel/strange_talk7.wav",
	"ambient/levels/citadel/strange_talk8.wav",
	"ambient/levels/citadel/strange_talk9.wav",
	"ambient/levels/citadel/strange_talk10.wav",
	"ambient/levels/citadel/strange_talk11.wav",
	"ambient/machines/teleport1.wav",
	"ambient/machines/teleport3.wav",
	"ambient/machines/teleport4.wav",
	"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die2.wav",
	"npc/zombie/zombie_die3.wav",
	"buttons/button10.wav"
}