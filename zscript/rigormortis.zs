/*	Thanks to PySpy's mod(s) for the... uh... 'gernerous donation'!

	Also, for the record, I know it's not quite kosher to put my miscellaneous
	scripts and actors in here, but what am I gonna do? Just make some file 
	called 'misc_scripts.zs' and just do it like that? Like a SANE person? */

class Freechelf : HereticPlayer 
{Default {Player.StartItem "NewCrystal", 40;
	Player.StartItem "ElfWand"; Player.StartItem "WhackStick";}
}

// Keeping this as a mixin because "####" states don't work otherwise.
mixin class ManaMixin
{
	States
	{
		Zoom: "####" "#" 35 ConfirmAttackMode();			 Goto Ready;
		User1: "####" "#" 5 PickNextAttack(invoker.mode, 0); Goto Ready;
		User2: "####" "#" 5 PickNextAttack(invoker.mode, 1); Goto Ready;
		User3: "####" "#" 5 PickNextAttack(invoker.mode, 2); Goto Ready;
		User4: "####" "#" 5 PickNextAttack(invoker.mode, 3); Goto Ready;
	}
}

//This is also a mixin as Heretic's monsters only inherit from Actor.
mixin class FreezeDat
{uint timer; const MAXT = 175;
	
	bool WoahWait() {timer++; if(timer > MAXT)
	{return true;} else {return false;}}
	
	//Undocumented functionality for the epic win lmao
	override void DamageMobj(Actor inflictor, Actor source, int damage,
		Name mod, int flags, double angle)
	{bool chanceTime = random(0, 15), overkill = damage > self.health;
		if(overkill && chanceTime) {A_PlaySound("hepon/die", CHAN_BODY, 0.5);}
		return Super.DamageMobj(inflictor, source, damage, mod, flags, angle);}
	
	States	{Death.Ice:	"####" "#" 5 A_GenericFreezeDeath();
			Freezo: 	"####" "#" 1 {if(WoahWait()) {return ResolveState("Shatter");}
									else{return  ResolveState(null);}} Loop;
			Shatter:	"----" A  10 A_FreezeDeathChunks();	Stop;
			XDeath.Ice:	"----" A  5  A_IceGuyDie();	Stop;}
}

mixin class FlagMixin
{void StopFlags() {bNoGravity = true; bBounceOnWalls = false; 
bBounceOnFloors = false; bBOUNCEONCEILINGS = false; bMissile = false; A_Stop();}}

class ItsAllCheese : Actor 
{override void PostBeginPlay() {super.PostBeginPlay();
ThrowAbortException("I got the munchies, I eat my lunchies...");}}

class UZDoomDiesWhenItsKilled : StaticEventHandler
{ui uint uzdied_rand, temp, itr; ui bool heponIsGo;
	static const string CUSTOM_CHEATS[] = {"iddqd", "idkfa", "phonymana"};
	
	override void uiTick() {if(gamestate == GS_LEVEL) {heponIsGo = true;}
		else if(gamestate == GS_FULLCONSOLE && heponIsGo)
		{heponIsGo = false; uzdied_rand = crandom(0, 4096);
		S_StartSound("world/vmabort", 0, CHAN_UI);if(uzdied_rand == 4096)
		{for(itr = 0; itr < 9; itr++) {console.printf(ULTRA_SECRET_TEXT[itr]);}}
		else {temp = uzdied_rand % 8; string holdem = 
		StringTable.localize(string.format("$CRASH_%u", temp)); console.printf(holdem);
		console.printf(StringTable.localize("$CRASH_WOW"));}}}
	
	//If you saw this in SLADE, no you didn't.
	static const string ULTRA_SECRET_TEXT[] =
	{
		"the heated intimacy came to an end",
		"there was a silence their thoughts",
		"could not drown. as the steam settled",
		"they rubbed their hands against the",
		"windows to see if anyone had caught",
		"them admist the act. but they were",
		"both too distracted by how moist their",
		"fingertips had now become, and how cold",
		"they felt against their tender skin."
	};
}