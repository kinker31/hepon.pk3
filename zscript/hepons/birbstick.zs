//Birb Crockets are used by the nontomed Birbrod, Napalmlets are for the tomed version.

//Uses FX04xx/FX08xx
class BirbCrocket: PhoenixFX1
{Default {Obituary "$BIRBOUCH"; DamageFunction DamTweet(20); +Bright;}
	bool smart;

	static uint DamTweet(uint base)
	{return base * random[BirbRNG](1, 3) * 
		BaseHepon.CritHandler(32.0, false, 4);}
	
	void BirbFly()
	{if(smart) {A_SeekerMissile(5, 7, SMF_LOOK|SMF_PRECISE, 100);} A_PhoenixPuff();}
	
	States {Spawn:	FX04 A 4 BirbFly(); Loop;
			Death:	FX08 A 4 A_Explode(144); FX08 BC 3; FX08 DEFGH 2; Stop;}
}

class MiniCrocket: BirbCrocket
{Default {DamageFunction DamTweet(4); XScale 0.25; YScale 0.25; Radius 5; Height 4;}}

class ExtraLorgBirb : BirbCrocket
{Default {-THRUGHOST; DamageFunction DamTweet(60); XScale 3.0; YScale 3.0; 
	Radius 24; Height 16;} bool coinFlip; BirbCrocket tweet1, tweet2;
	uint modulo;
	
	override void BeginPlay() {modulo = 1; super.BeginPlay();}
	void SupaBirbFly() {modulo++; if(modulo % 5 != 0)
		{BirbFly(); return;} coinFlip = random(0, 1);
		tweet1 = BirbCrocket(
			SpawnMissileAngleZ(pos.z, "BirbCrocket", angle + 90, 1.25, target));
		if(tweet1) {tweet1.target = self.target; 
			if(coinFlip) {tweet1.smart = true;}}
		tweet1 = BirbCrocket(
			SpawnMissileAngleZ(pos.z, "BirbCrocket", angle - 90, 1.25, target));
		if(tweet1) {tweet1.target = self.target; 
			if(coinFlip) {tweet1.smart = true;}}
	}
	
	void BirbSplode(uint max)
	{vector3 v; uint j = random(2, max); 
		for(uint i; i < j; i++) {v = BaseHepon.SpOff(16.0, (-0.25, 1.5));
		tweet2 = BirbCrocket(Spawn("BirbCrocket", self.pos));
		if(!tweet2) {continue;} tweet2.smart = true; 
			tweet2.vel = v; tweet2.target = self.target;}
	}
	
	States {Spawn:	FX04 A 2 SupaBirbFly(); Loop;
			Death:	FX08 A 0 BirbSplode(7); Goto Super::Death;}
}

//Uses BICExx/XICExx
class BirbFrost: BirbCrocket {Default {DamageType 'Ice'; Obituary "$ICEBIRBOUCH"; 
DamageFunction DamTweet(32); Translation "IceBirb";}}

//Uses FX09xx
class Napalmlet: PhoenixFX2
{Default {DamageFunction FlameDam(12, 24); Obituary "$SUPABIRBOUCH"; Speed 12;
	-NoGravity; Gravity 0.333; +HitTracer; +Bright; Napalmlet.BmVal 'Fire';} 
	uint chance, cMax; bool burn1, burn2, postBurn; vector4 v; name n;
	//burn1 means an actor was it, burn2 is when actor enters Death.Burn/Stick
	const MAX_AGE1 = 25; const MAX_AGE2 = 500; property BmVal: n;
	const BMFLAGS = XF_CIRCULAR|XF_CIRCULARTHRUST; 
	const BMFLAGS2 = RADF_THRUSTLESS|RADF_CIRCULAR; 
	
	override void BeginPlay() {super.BeginPlay(); v.x = frandom(0.1, 2.5);
	v.y = frandom(-1.2, 1.2); v.z = frandom(0, 2.5);}
	
	static uint FlameDam(uint min, uint max) {return random[BirbRNG](min, max);}
	
	void StickyCheck(bool hitActor) {bMissile = false; A_Stop(); vel.z += 1.8; 
		if(!hitActor) {SetStateLabel("Death.Burn"); burn2 = true; return;}
		if(!tracer) {SetStateLabel("Death.Normal"); return;}
		chance = random(0, 255); if(chance < cMax) 
		{SetStateLabel("Death.Stick"); burn2 = true; return;} 
		SetStateLabel("Death.Normal");}
	
	override void Tick() {Super.Tick(); if(postBurn) {return;}
	if((GetAge() > MAX_AGE1) && !burn1) 
		{postBurn = true; SetStateLabel("Death.Piffle");}
	else if ((GetAge() > MAX_AGE1) && burn2)
		{postBurn = true; SetStateLabel("Death.PostDie");}}
	
	void MainDeath(uint dam)
	{double dist = (dam * 2) / 3; A_Explode(dam, dist, BMFLAGS);}
	
	void NapalmBurn()
	{double p1 = random(64, 80), p2 = random(80, 112), p3;
		RadiusAttack(target, p1, p2, n, BMFLAGS2, 16.0);}
	
	void NapalmStick() {if(!tracer) {return;}
		double zOff = (tracer.Height / 2) + v.z;
		A_Warp(AAPTR_TRACER, v.x, v.y, zOff, v.w, WARPF_ABSOLUTEANGLE);
		DamageMobj(target, self, FlameDam(3, 7), 'Normal'); 
		v.w += frandom(0.75, 2.25);}
	
	void PiffleDed() {MainDeath(32); A_Stop(); bMissile = false; bNoGravity = true;}
	
	States
	{Spawn:	FX09 AB 3; Loop;
	Death:	FX09 B 0 {burn1 = true; StickyCheck(false);}
	XDeath:	FX09 B 0 {burn1 = true; StickyCheck(true);}
	Crash:	FX09 B 0 {Vel.z += 1.2;} Goto Death.Piffle;
	Death.Normal:	FX09 G 3 MainDeath(72); FX09 HI 4; FX09 JK 5; Stop;
	Death.Stick:	FX09 GHIH 3 NapalmStick(); Loop;
	Death.Burn:		FX09 GHIH 5 NapalmBurn(); Loop;
	Death.PostDie:	FX09 G 3; FX09 HI 4; FX09 JK 5; Stop;
	Death.Piffle:	FX09 C 4 PiffleDed(); FX09 DEF 4; Stop;}
}

//Uses PICExx
class Frostlet: Napalmlet {Default {DamageType 'Ice'; Obituary "$SUPAICEBIRBOUCH"; 
Napalmlet.BmVal 'Ice'; Translation "IceBirb";}}

//Non-Tomed altfire

class PCurse: Powerup
{Default {Powerup.Duration -90; Powerup.Color "Orange", 0.25;
	Inventory.Icon "AMP2B0"; PCurse.DVals 1.25, 1.5; PCurse.Spawns 4, 16;}
	double inVal, outVal; uint tracker; Property DVals: inVal, outVal;
	uint smol, large; property Spawns: smol, large;	MiniCrocket m; 
	const HT1 = 35; const HT2 = 15;
	//UZDoom insists all the normal properties be there for some reason
	override void ModifyDamage(int damage, Name damageType, out int newdamage, 
		bool passive, Actor inflictor, Actor source, int flags)
	{if(passive) {newdamage = round(damage * inVal); tracker += damage;}
	else {newdamage = round(damage * outVal);}}

	double Stankle() {return frandom(owner.angle - 90, owner.angle + 90);}
	
	//False: Small, True: Large
	void Retaliation(bool mode)
	{uint amount = mode? large: smol; for(uint i; i < amount; i++) 
	{m = MiniCrocket(Spawn("MiniCrocket", owner.pos)); if(!m) {continue;}
	m.target = owner; m.VelFromAngle(); m.angle = Stankle(); m.smart = true;}}

	override void Tick()
	{super.Tick(); if(tracker > HT1) 
		{tracker = 0; A_SetBlend("Yellow", 0.5, 15); Retaliation(false);}
	if(owner.health < HT2) {A_SetBlend("Yellow", 1.0, 25); Retaliation(true); 
		Owner.GiveBody(75, 50); Destroy();}}
}

//Tomed Altfire: Removed Downside
class PCurse2: PCurse
{Default {Powerup.Duration -90; Powerup.Color "Orange", 0.15;
	Inventory.Icon "AMP2OR"; PCurse.DVals 0.9, 1.5; PCurse.Spawns 6, 18;}}

//Tomed Altfire: Amplified Effect
class PCurse3: PCurse
{Default {Powerup.Duration -150; Powerup.Color "Red", 0.25;
	Inventory.Icon "AMP2RED"; PCurse.DVals 1.75, 2.25; PCurse.Spawns 16, 32;}}

class PGiver: PowerupGiver {Default {+Inventory.AUTOACTIVATE;
	+Inventory.ALWAYSPICKUP; Powerup.Type "PCurse";}}
class PGiver2: PGiver {Default {Powerup.Type "PCurse2";}}
class PGiver3: PGiver {Default {Powerup.Type "PCurse3";}}

class TweetTweet: BaseHepon
{
	Default {Weapon.SlotNumber 6; Tag "$TAGBIRB"; +Weapon.NoAutoFire;
	Inventory.PickupMessage "$BIRBWOW"; Weapon.AmmoType "NewBirb";
	Weapon.SisterWeapon "SupaTweetTweet"; Weapon.YAdjust 15; Weapon.AmmoUse 1;
	Weapon.AmmoGive1 4;  BaseHepon.SwapCosts  90, 120, 150, 210;
	BaseHepon.AttackNames "$W5N1", "$W5N2", "$W5N3", "$W5N4";}
	mixin ManaMixin; BirbCrocket birb; const ALT_COST = 12;
	static const uint COSTS[] = {1, 2, 3, 8}; bool ch;
	
	override void OnDeselect()
	{if(!owner) {return;} 
		if(owner.CountInv("PCurse") > 0) {owner.A_TakeInventory("PCurse");}
		if(owner.CountInv("PCurse3") > 0) {owner.A_TakeInventory("PCurse3");
		owner.A_GiveInventory("PCurse");} super.OnDeselect();}
	
	action void BirbReady()
	{if(invoker.mode == 2 && !invoker.ch)
		{invoker.ch = true; A_OverlayTranslation(PSP_WEAPON, "IceWeap"); 
			A_SetBlend("Cyan", 0.85, 15);}
	else if (invoker.mode != 2 && invoker.ch)
		{invoker.ch = false; A_OverlayTranslation(PSP_WEAPON, ""); 
			A_SetBlend("Yellow", 0.85, 15);} A_WeaponReady(HEPON_FLAGS);}
	
	action void EngageBirb(uint amount = 1, vector2 cone = (7.5, 2.25))
	{if(!invoker.DepleteAmmo(false, true, invoker.COSTS[invoker.mode], true)) {return;}
		Class<actor> a, b; double kick = invoker.mode == 3? 15.0 : 1.25; vector2 v;
		switch(invoker.mode) {case 0: case 1: default: a = "BirbCrocket"; break;
		case 2: a = "BirbFrost"; break; case 3: a = "ExtraLorgBirb"; break;}
	for (uint i; i < amount; i++) {if(i == 0) {v = (0, 0);}
		else {v.x = frandom[BirbRNG](-cone.x, cone.x);
		v.y = frandom[BirbRNG](-cone.y, cone.y);}
		invoker.birb = BirbCrocket(HeponProj(a, v));
		if(invoker.birb && invoker.mode == 1) {invoker.birb.smart = true; 
		invoker.birb.bThruGhost = false;} A_Recoil(kick);}
	}
	
	action void EngageCurse()
	{if(!invoker.DepleteAmmo(false, true, invoker.ALT_COST, true)) {return;}
		if(invoker.CountInv("PCurse") > 0) {return;} A_SetBlend("Yellow", 0.75, 25);
		A_StartSound("world/lavasizzle"); A_GiveInventory("PGiver");}
	
	States
	{Ready:		PHNX A 1 BirbReady(); Loop;
	Select:		PHNX A 0 {if(invoker.mode == 2)
	{A_OverlayTranslation(PSP_WEAPON, "IceWeap"); A_SetBlend("Cyan", 0.85, 15);}}
	RaiseLoop:	PHNX A 1 A_Raise(); Loop;
	Deselect:	PHNX A 0 {if(invoker.mode == 2) 
	{A_OverlayTranslation(PSP_WEAPON, ""); A_SetBlend("Yellow", 0.25, 10);}}
	LowerLoop:	PHNX A 1 A_Lower(); Loop;
	Fire:		PHNX A 0 {statelabel s; switch(invoker.mode)
				{case 0: s = "BirdMain";	break; case 1: s = "BirdAlt"; break;
				 case 2: s = "BirdFrez";	break; case 3: s = "BirdSol"; break;
				 default: s = "Ready";		break;}
				return ResolveState(s);}
	BirdMain:	PHNX B 2; PHNX C 4 EngageBirb(4); PHNX DB 2; 
				PHNX B 0 A_Refire(); Goto Ready;
	BirdAlt:	PHNX B 3; PHNX C 5 EngageBirb(3, (3.25, 1.0)); PHNX DB 2; 
				PHNX B 0 A_Refire(); Goto Ready;
	BirdFrez:	PHNX B 4; PHNX C 6 EngageBirb(3, (8.0, 3.0)); PHNX DB 3; 
				PHNX B 0 A_Refire(); Goto Ready;
	BirdSol:	PHNX B 3; PHNX C 7 EngageBirb(); PHNX DB 4; 
				PHNX B 0 A_Refire(); Goto Ready;
	Altfire:	PHNX B 7; PHNX C 8 EngageCurse(); Goto Ready;
	Spawn:		WPHX A -1; Stop;}
}

class SupaTweetTweet: TweetTweet
{
	Default {Tag "$SUPABIRBTAG"; Weapon.SisterWeapon "TweetTweet";
		Weapon.YAdjust 15; +WEAPON.POWERED_UP;} 
	//aTimer is for most firing modes, sTimer is for Sol's Wrath
	const TIMER_MOD = 245; const STIMER_MOD = 700; uint aTimer, sTimer;
	Napalmlet n; static const uint STICKS[] = {128, 72, 48, 192};
	
	//copied most of this from the normal weapon's definition
	override void EndPowerup()
	{if(aTimer > 0 || sTimer > 0) {DepleteAmmo(bAltFire);} 
		owner.player.refire = 0; owner.A_StopSound (CHAN_WEAPON);
		Owner.player.ReadyWeapon = SisterWeapon;
		Owner.player.SetPsprite(PSP_WEAPON, SisterWeapon.GetReadyState());}
	
	action void NapalmBarf(uint amount = 7, vector2 cone = (12.5, 0.75),
							double initVel = 24.0)
	{if(++invoker.aTimer > invoker.TIMER_MOD) {invoker.SetStateLabel("OkayDone");}
	 if(!player.refire) 
		{A_StartSound("weapons/phoenixpowshoot", CHAN_WEAPON, CHANF_LOOPING);}
	class<Actor> a = invoker.mode == 2? "Frostlet" : "Napalmlet";
	vector2 c; for(uint i; i < amount; i++)
		{c.x = frandom(-cone.x, cone.x); c.y = frandom(-cone.y, cone.y) + 7.5;
		invoker.n = Napalmlet(HeponProj(a, (c.x, c.y))); if(invoker.n) 
		{invoker.n.cMax = invoker.STICKS[invoker.mode]; invoker.n.Speed = initVel;}}
	}
	
	action void SuperNapalm()
	{if(++invoker.sTimer > invoker.STIMER_MOD) {invoker.SetStateLabel("OkayDone");}
	uint maxAmount = random(24, 32); vector2 cone; if(!player.refire) 
		{A_StartSound("weapons/phoenixpowshoot", CHAN_WEAPON, CHANF_LOOPING);}
	for(uint i; i < maxAmount; i++)
		{cone.x = frandom (-30, 30); cone.y = frandom(0, 12.5) + 12.5;
		invoker.n = Napalmlet(HeponProj("Napalmlet", (cone.x, cone.y)));
		if(invoker.n) {invoker.n.cMax = invoker.STICKS[3]; 
		invoker.n.Speed = 24.0;}}
	}
	
	action void NapalmFinish()
	{invoker.DepleteAmmo(invoker.bAltFire); A_StopSound(CHAN_WEAPON);
		invoker.aTimer = 0; invoker.sTimer = 0;}
	
	bool AlreadyHas()
	{return (CountInv("PCurse2") > 0) || (CountInv("PCurse3") > 0);}
	
	action void EngageTomedCurse()
	{if(!invoker.DepleteAmmo(false, true, invoker.ALT_COST, true)) {return;}
		if(invoker.AlreadyHas()) {return;}
		class<Inventory> give = random(0, 1)? "PGiver3" : "PGiver2";
		A_SetBlend("Yellow", 0.75, 25); A_StartSound("world/lavasizzle");
		A_GiveInventory(give);}
	
	States
	{BirdMain:	PHNX B 3; 
	Loop1:	PHNX CC 1 NapalmBarf();
			PHNX B 0 A_Refire("Loop1"); Goto OkayDone;
	BirdAlt:	PHNX B 3; 
	Loop2:	PHNX CCC 1 NapalmBarf(4, (7.0, 0.1), 32.0);
				PHNX B 0 A_Refire("Loop2"); Goto OkayDone;
	BirdFrez:	PHNX B 3; 
	Loop3:	 PHNX CCCC 1 NapalmBarf(5, (15.0, 1.25), 18);
				PHNX B 0 A_Refire("Loop3"); Goto OkayDone;
	BirdSol:	PHNX B 3; 
	Loop4:	PHNX CCCCCC 1 SuperNapalm();
				PHNX B 0 A_Refire("Loop4"); Goto OkayDone;
	OkayDone:	PHNX B 4 NapalmFinish(); Goto Ready;
	Altfire:	PHNX B 7; PHNX C 6 EngageTomedCurse(); Goto Ready;}
}
