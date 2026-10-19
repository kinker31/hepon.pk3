class BallMace: MaceFX1
{Default {BounceType "Hexen"; BounceFactor 1.0; WallBounceFactor 1.0; Speed 16;
	-NOGRAVITY; DamageFunction BallDamage(); Obituary "$BALLGUNOUCH";
	+NoTeleport; DeathSound "weapons/maceexplode"; +EXPLODEONWATER; 
	+BOUNCEMODIFIESPITCH; +USEBOUNCESTATE; +DONTBOUNCEONSHOOTABLES;
	SeeSound "weapons/maceshoot"; BounceSound "weapons/macebounce"; 
	BounceCount 5;} BallMace b; Actor f; mixin FlagMixin;
	uint iteration, iMax, bSpawn, fSpawn, alterType; 
	bool variance; const DIST = 256.0; 
	const BMFLAGS = XF_CIRCULAR|XF_CIRCULARTHRUST;
	static uint BallDamage() {return random(8, 12);}

	void Split()
	{if(iteration >= iMax) {FlakSpawn(); return;} double ying, yang,
		split = variance? -1 : 360 / (bSpawn - 1); for(uint i; i < bSpawn; i++)
		{ying = variance? frandom(0, 360): split * i; yang = abs(vel.z / 2) + 7.5;
		b = BallMace(SpawnMissileAngleZ(pos.z, "BallMace", ying, yang, target));
		if(b) {b.iteration = (self.iteration + 1); b.variance = self.variance;
		b.fSpawn = self.fSpawn; b.bSpawn = self.bSpawn;}} A_Explode(32, 24, BMFLAGS);
	}

	void FlakSpawn()
	{double ying, yang; for(uint i; i < bSpawn; i++) {ying = frandom(0, 360); 
		yang = yang = abs(vel.z / 2) + 7.5;
		f = SpawnMissileAngleZ(pos.z, "BallFlak", ying, yang, target);
		if(f) {f.vel *= frandom(0.75, 1.75);}} A_Explode(48, 32, BMFLAGS);}
	
	void BallDeath() {StopFlags(); A_Explode(64, 48, BMFLAGS);
	if(iteration >= iMax) {FlakSpawn(); return;} Split();}
	
	States	{Spawn:	FX02 CD 3; Loop;
			Bounce: FX02 C 0 Split(); Goto Spawn;
			Death:	TNT1 A 0 Bright BallDeath(); FX02 FGHIJ 3 Bright; Stop;}
}

class BallFlak : Actor
{Default {Projectile; Obituary "$BALLFLAKOUCH"; -NoGravity; BounceType "Hexen";
	+NoTeleport; Radius 6; Height 4; BounceCount 8; DamageFunction FlakDamage();
	BounceFactor 1.0; WallBounceFactor 1.0; BounceSound "weapons/macebounce";
	DeathSound "weapons/maceexplode"; Speed 24;} mixin FlagMixin;
	static uint FlakDamage() {return random(2, 8);}
	
	States	{Spawn:	FX02 AB 2; Loop;
			Death:	TNT1 A 0 StopFlags();
					FX02 FGHIJ 3 Bright; Stop;}
}

class OmegaBall: Actor
{Default {Projectile; Obituary "$SUPABALLGUNOUCH"; BounceType "Hexen";
	+NoTeleport; Radius 11; Height 7; Speed 32; DeathSound "weapons/maceexplode";
	+EXPLODEONWATER; +BOUNCEMODIFIESPITCH; +DONTBOUNCEONSHOOTABLES; -NoGravity;
	SeeSound "weapons/maceshoot"; BounceSound "weapons/macebounce"; 
	DamageFunction MegaDamage(); BounceFactor 1.0; WallBounceFactor 1.0;
	+UseBounceState;} mixin FlagMixin; bool dummy; const AGE_MAX = 420;
	static uint MegaDamage() {return random(3, 9) * 10;}
	
	override void Tick()
	{super.Tick(); if(GetAge() > AGE_MAX && !dummy) 
		{dummy = true; SetStateLabel("Death");}}
	
	void BallBoom(uint amount = 3)
	{BallMace b; double d, s, f; for(uint i; i < amount; i++)
		{d = -angle + frandom(-45, 45); s = random(3, 7); f = random(4, 9);
		b = BallMace(SpawnMissileAngleZ(pos.z, "BallMace", d, 7.5, target));
		if(!b) {continue;} b.bSpawn = s; b.fSpawn = f; b.variance = true;}
	}
	
	States
	{Spawn:	FX02 E 1; Loop;
	Bounce.Floor: Bounce.Ceiling:	FX02 E 1 BallBoom(); Goto Spawn;
	Bounce.Wall:	FX02 E 1 BallBoom(5); Goto Spawn;
	Death:	TNT1 A 0 {BallBoom(9); StopFlags();} FX02 FGHIJ 3 Bright; Stop;}
}

class Maceception : BaseHepon
{Default {Weapon.SlotNumber 7; Tag "$TAGBALLGUN"; Weapon.YAdjust 15;
	Weapon.AmmoUse 1; Inventory.PickupMessage "$BALLGUNWOW";
	Weapon.SisterWeapon "SupaMaceception"; Weapon.AmmoType "NewBalls";
	BaseHepon.SwapCosts 144, 250, 300, 666;  Weapon.AmmoGive1 16;
	BaseHepon.AttackNames "$W6N1", "$W6N2", "$W6N3", "$W6N4";} 
	mixin ManaMixin; static const uint COSTS[] = {2, 3, 1, 8}; 
	enum ALT_TYPES {NONE = 0, WAND, ARROWS, BLAST, RUNES, FLAME};
	
	action void MainBalls(uint amount = 1, vector2 cone = (12.5, 1.5),
				bool unst = true, uint iter = 4, uint balls = 3, uint flak = 3)
	{if(!invoker.DepleteAmmo(false, true, invoker.COSTS[invoker.mode], true)) return;
	BallMace firedBall; double ying, yang; 
		for(uint i; i < amount; i++) {ying = frandom(-cone.x, cone.x);
		yang = frandom(-cone.y, cone.y) + 12.5; firedBall = 
		BallMace(HeponProj("BallMace", (ying, yang)));
		if(firedBall){firedBall.iMax = iter; firedBall.bSpawn = balls;
		firedBall.fSpawn = flak; firedBall.variance = unst;}}
	}
	
	States
	{Ready:		MACE A 1 A_WeaponReady(HEPON_FLAGS); Loop;
	Select:		MACE A 1 A_Raise(); Loop;
	Deselect:	MACE A 1 A_Lower(); Loop;
	Fire:		MACE B 4 {statelabel s; switch(invoker.mode)
			{case 0: s = "MainMace"; break;
			case 1: s = "AltMace"; break;
			case 2: s = "MaceStable"; break;
			case 3: s = "OhDear"; break;
			default: s = "Ready"; break;} return ResolveState(s);}
	MainMace:	MACE CDEF 2 MainBalls();
		MACE C 2 A_Refire("MainMace"); MACE C 0 A_Jump(256, "PostFire");
	AltMace:	MACE CDEF 2 MainBalls(1, (4.5, 1.75), false, 2, 3, 3); 
		MACE C 2 A_Refire("AltMace"); MACE C 0 A_Jump(256, "PostFire");
	MaceStable:	MACE CDEF 2 MainBalls(2, (7.5, 2.5), true, 1, 2, 8);
		MACE C 2 A_Refire("MaceStable"); MACE C 0 A_Jump(256, "PostFire");
	OhDear:	MACE CDEF 2 MainBalls(3, (22.5, 2.25), true, 3, 4, 6); 
		MACE C 2 A_Refire("OhDear"); MACE C 0 A_Jump(256, "PostFire");
	PostFire: MACE EFEF 2; MACE EFEF 3; Goto Ready;
	Spawn:		WMCE A -1; Stop;}
}

class SupaMaceception : Maceception
{
	Default {Obituary "$SUPABALLGUNOUCH"; Tag "$TAGSUPABALLGUN"; Weapon.AmmoUse 10;
	Weapon.YAdjust 15; Weapon.SisterWeapon "Maceception"; +WEAPON.POWERED_UP}
	Actor tBall;
	
	action void TomedBalls(uint amount = 1, vector2 cDiv = (64, 128))
	{uint tomedCost = round(invoker.COSTS[invoker.mode] * 1.5);
		if(!invoker.DepleteAmmo(false, true, tomedCost, true)) return;
		vector2 cone; for(uint i; i < amount; i++)
		{cone.x = random2()/cDiv.x; cone.y = (random2()/cDiv.y) + 12.5;
		invoker.tBall = HeponProj("OmegaBall", cone);
	if(!invoker.tBall) {continue;} invoker.tBall.vel *= frandom(0.75, 1.666);}}
	
	States
	{MainMace:	MACE C 4 TomedBalls(); MACE DEF 4; 
				MACE C 0 A_Refire(); MACE C 0 A_Jump(256, "PostTomed");
	StableMace:	MACE C 5 TomedBalls(1, (128, 128)); MACE DEF 5; 
				MACE C 0 A_Refire(); MACE C 0 A_Jump(256, "PostTomed");
	MaceStorm:	MACE C 3 TomedBalls(2, (24, 32)); MACE DEF 3; 
				MACE C 0 A_Refire(); MACE C 0 A_Jump(256, "PostTomed");
	OhDear:		MACE C 7 TomedBalls(5, (16, 48)); MACE DEF 7; 
				MACE C 0 A_Refire(); MACE C 0 A_Jump(256, "PostTomed");
	PostTomed:	MACE EFEFEF 4; MACE EFEFEF 6; Goto Ready;}
}
