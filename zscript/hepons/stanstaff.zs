//Uses FX00 [AB|HIJKLM]
class SpookyShot: HornRodFX1
{Default {Speed 24; DamageFunction GetTheDamage(false, 10); +BounceOnWalls;}
	const DECEL = 0.985; const MINMIN = 35; const MAXMAX = 420; bool dummy;
	mixin FlagMixin; override void PostBeginPlay()
	{super.PostBeginPlay(); if(random(0, 1) == 0) {self.CurState.NextState;}}
	
	uint GetTheDamage(bool tomed, uint base)
	{uint ageVal = self.GetAge(); if(ageVal < MINMIN) {ageVal = MINMIN;}
	if(ageVal > MAXMAX) {ageVal = MAXMAX;} double div = tomed? .875 : .75,
			min = tomed? 1.75: 1.33, max = tomed? 6.66: 4.33,
			temp = (ageVal / (base / div)) * frandom(min, max);
	return round(temp) * BaseHepon.CritHandler(22.5, false, 4);}
	
	void IsNowBouncy() {self.bNoGravity = false; self.bBounceOnFloors = true;
	self.bAllowBounceOnActors = true; self.bBounceAutoOffFloorOnly = true;
	self.bBounceModifiesPitch = true;}
	bool TooOld() {return self.GetAge() > round(MAXMAX * 1.5);}
	
	override void Tick()
	{super.Tick(); if(self.vel.Length() > self.speed){self.vel *= DECEL;}
	if(TooOld() && !dummy) {dummy = true; StopFlags(); SetStateLabel("Death");}}
	
	/*Usually, you don't need to worry about setting this flag, but one of the
	firing modes of the Skullstaff enables gracity on these things, and an
	explosion that's falling down looks rather stupid on a projectile*/
	States {Death: TNT1 A 0 {bNoGravity = true;} Goto Super::Death;}
}

class SpookierShot: Spookyshot
{Default {Speed 32; DamageFunction GetTheDamage(true, 15); XScale 1.75; YScale 1.75;}}

class Rainlet: Actor
{Default {Projectile; DamageFunction random(12, 24); Radius 3; Height 4; Mass 4;
		-NOGRAVITY; Gravity 2.0; +Bright; DeathSound "weapons/wandhit";}
	bool IsGoingUp() {return self.vel.z > 0;}
	override void Tick() {super.Tick(); self.Scale.Y = IsGoingUp()? -1.0: 1.0;}
	States{	Spawn:	FX22 A 1; Loop;
			Death:	FX22 B 3 {if(GetZAt(0, 0) ~== 0.0) 
					{return ResolveState(null);} return ResolveState("NotF");}
					FX22 CDEF 3; Stop;
			NotF:	FX22 GHI 4; Stop;}
}

//Uses FX00 [CDEF|HIJKLM]
class OrbitalSpook: Actor
{	Default {+HITTRACER; Speed 0; Health 640; Projectile; +BRIGHT; +SHOOTABLE;
	DamageFunction OrbitDam(false); +NOBLOOD; DeathSound "world/podexplode";} 
	const DEGREE = (255.0 / 35.0); vector3 offSpin; double stangle;
	const xSC = 72.; const ySC = 16.; const zSC = 12.;
	double offX; const MINAGE = 35; const MAXAGE = 420;
	const EXPLAGE = (2 * MAXAGE) / 3; const BASE_X = MINAGE * 4;
	const BMFLAGS = XF_CIRCULAR|XF_CIRCULARTHRUST;
	const WFLAGS = WARPF_WARPINTERPOLATION|WARPF_STOP|WARPF_ABSOLUTEANGLE;
	
	uint OrbitDam(bool tomed) 
	{uint base = tomed? 14: 8, temp = base * randompick(1, 1, 2, 4);
	return base * BaseHepon.CritHandler(12.8, false, 3);}
	override void PostBeginPlay() {super.PostBeginPlay(); stangle = self.target.angle;}
	override int DamageMobj(actor inf, actor src, int dam, name mod, int f, double ang)
	{if(src == self.target) {return 0;} return Super.DamageMobj(inf, src, dam, mod, f, ang);}
	
	double SineSet(double scalar = 8.0, uint tmult = 1, uint tDiv = 1)
	{return scalar * cos((tMult * M_PI * self.GetAge()) / tDiv);}
	
	void UpdateOffsets(bool tomed) 
	{vector2	xVals = tomed? (4 , 1) : (2 , 1),
				yVals = tomed? (2 , 1) : (1 , 2),
				zVals = tomed? (1 , 4) : (1 , 8);
		offSpin.x = SineSet(xSC, xVals.x, xVals.y);
		offSpin.y = SineSet(ySC, yVals.x, yVals.y);
		offSpin.z = SineSet(zSC, zVals.x, zVals.y);}
	
	void UpdateDist(bool tomed)
	{uint minTemp = tomed? 6: 4, maxTemp = tomed? 24: 16;
		if(GetAge() < MINAGE) {offX += minTemp; return;}
		if(GetAge() > MAXAGE) {OffX += maxTemp; return;}
		double stangStep = tomed? (DEGREE * 3): DEGREE;
		UpdateOffsets(tomed); offX = BASE_X + offSpin.x; stangle += stangStep;}
	
	void GatherRound(bool tomed)
	{self.UpdateDist(tomed); A_Warp(AAPTR_TARGET, self.OffX, self.offspin.Y,
		(self.offSpin.z + 42.0), self.stangle, WFLAGS);}
	
	//vector.x: Speed, vector.y: Pitch
	void ExplodoProjecto(class<Actor> toss, uint amount = 15, vector2 vector = (24., 45.))
	{vector3 attempt; actor a; for(uint i; i < amount; i++)
		{attempt = BaseHepon.SpOff(vector.x, (1.25, vector.y));
		a = Spawn(toss, self.pos + attempt); if(a) {a.bNoGravity = false; 
		a.vel = attempt * 1.25; a.target = self.target;}}
	}
	
	void KickBucket(bool tomed) {if(self.GetAge() > EXPLAGE)
	{uint raino = random(24, 48); vector2 temp; vector3 poss; actor a;
	ExplodoProjecto("Rainlet", raino, (64., 75.));
	double boomAdd = self.GetAge() / 8, boom = 128 + boomAdd;
	A_Explode(boom, (boom /2), BMFLAGS, false, 32.); if(tomed)
	{uint rando = random(16, 24); ExplodoProjecto("SpookyShot", rando);}}}
	
	states	{Spawn:	FX00 CCCDDDEEEFFF 1 GatherRound(false); Loop;
			Death:	FX00 G 0 KickBucket(false); FX00 HIJ 3; FX00 KLM 4; Stop;}
}

class SuperOrbital: OrbitalSpook
{Default {Health 1920; XScale 2.25; YScale 2.25; DamageFunction OrbitDam(true);}
	States {Spawn:	FX00 CCDDEEFF 1 GatherRound(true); Loop;
			Death: FX00 G 0 KickBucket(true); FX00 HIJKLM 2; Stop;}}

class SpookyStaff : BaseHepon
{
	Default
	{Weapon.SlotNumber 5; Obituary "$STANOUCH"; Tag "$TAGSTAN";Weapon.YAdjust 15;
	Inventory.PickupMessage "$STANWOW"; Weapon.SisterWeapon "SupaSpookyStaff";
	Weapon.AmmoType "NewRunes"; Weapon.AmmoUse 1; Weapon.AmmoGive1 20;
	BaseHepon.AttackNames "$W4N1", "$W4N2", "$W4N3", "$W4N4"; 
	BaseHepon.SwapCosts 50, 75, 125, 175;} mixin ManaMixin; uint altTimer;
	static const uint COSTS[] = {1, 3, 7, 10}; const MAX_SHOTS = 24; uint timer;
	const MAX_ORBS = 6; const ALT_COST = 8; OrbitalSpook[MAX_ORBS] spooks;
	override void DetachFromOwner()	{NukeOrbitals(); super.DetachFromOwner();}
	override void OnDeselect()		{NukeOrbitals(); super.OnDeselect();}
	bool SpookCanHappen(actor v)	{return v == null || v.bNoSector == true;}
	
	//[V]aguely [E]vil Spread
	action void VE_Spread(bool tomed, uint amount, double spread)
	{SpookyShot s; double ying = -spread, step = (spread * 2) / MAX_SHOTS,
	yeet = (invoker.mode == 2)? 17.5 : 0, yonp; uint hatVal; 
	Class<actor> shot = tomed? "SpookierShot" : "SpookyShot";
		uint loops = tomed? round(amount * 1.75): amount;
		for(uint i; i <= loops; i++)  {hatVal = random(0, (MAX_SHOTS - 1));
		yonp = ying + (step * hatVal); s = SpookyShot(HeponProj(shot, (yonp, yeet)));
		if(s) {s.vel *= frandom(1.333, 6.666); if(invoker.mode == 2) {s.IsNowBouncy();}}}
	}
	
	//[V]aguely [F]ocused Spread
	action void VF_Spread(bool tomed, uint shots, double s)
	{class<actor> a = tomed? "SpookierShot" : "SpookyShot"; HeponProjFan(a, shots, s);}
	
	vector3 InOff(double l)
	{vector2 temp = Vec2Angle(l, angle); return pos + (temp.x, temp.y, 42.0);}
	
	//Altfire: Spawn Orbital Reflectors
	action void Reflects()
	{invoker.altTimer++; if(!((invoker.altTimer % 35 == 0) && 
		(invoker.DepleteAmmo(false, true, ALT_COST, true)))) {return;}
		for(uint i; i < MAX_ORBS; i++) {let v = invoker.spooks[i];
		if(invoker.SpookCanHappen(invoker.spooks[i]))
		{vector3 spawnVec = invoker.InOff(24.0); invoker.spooks[i] = 
		OrbitalSpook(Spawn("OrbitalSpook", spawnVec)); 
		A_PlaySound("weapons/hornrodpowshoot"); if(invoker.spooks[i]) 
		{invoker.spooks[i].target = self;} return;}}
	}
	
	action void NukeOrbitals()
	{for(uint i; i < MAX_ORBS; i++)
		{let v = invoker.spooks[i]; if(v) {v.ExplodeMissile();;}}}
	
	States
	{
		Ready:		HROD A 1 A_WeaponReady(HEPON_FLAGS); Loop;
		Select:		HROD A 1 A_Raise(); Loop;
		Deselect:	HROD A 1 A_Lower(); Loop;
		Fire:		HROD A 0
			{statelabel s; switch(invoker.mode)
				{case 0: s = "StaffShot"; break; case 1: s = "FocusShot"; break;
				case 2: s = "PopShot"; break; case 3: s = "HSpread"; break;
				default: s = "Ready"; break;}
			if(!invoker.DepleteAmmo(false, true, (invoker.COSTS[invoker.mode] * 2), true))
			{s = "Ready";} return ResolveState(s);}
		StaffShot:	HROD AB 4 VE_Spread(false, 5, 22.5);
					HROD A 0 A_Refire(); Goto Ready;
		FocusShot:	HROD AB 6 VF_Spread(false, 4, 12.5);
					HROD A 0 A_Refire(); Goto Ready;
		PopShot:	HROD AB 4 VE_Spread(false, 7, 45.0);
					HROD A 0 A_Refire(); Goto Ready;
		HSpread:	HROD AB 8 VE_Spread(false, 13, 30.0);
					HROD A 0 A_Refire(); Goto Ready;
		Altfire:	HROD ABAB 6; HROD ABAB 4; HROD ABAB 2;
		AltLoop:	HROD AABB 1 Reflects(); HROD A 0 A_Refire("AltLoop");
		PostAlt:	HROD B 3 NukeOrbitals(); HROD A 6; Goto Ready;
		Spawn:		WSKL A -1; Stop;
	}
}

class SupaSpookyStaff : SpookyStaff
{
	Default { Obituary "$SUPASTANOUCH"; Tag "$SUPASTANTAG"; Weapon.AmmoUse 2;
	Weapon.SisterWeapon "SpookyStaff"; Weapon.YAdjust 15; +WEAPON.POWERED_UP}
	const MAX_ORBS_T = 9; SuperOrbital[MAX_ORBS_T] xSpooks;
	override void DetachFromOwner()	{SuperNukeOrbitals(); super.DetachFromOwner();}
	override void OnDeselect()	{SuperNukeOrbitals(); super.OnDeselect();}
	
	action void SuperReflects()
	{invoker.altTimer++; if(!((invoker.altTimer % 12 == 0) && 
		(invoker.DepleteAmmo(false, true, ALT_COST, true)))) {return;}
		for(uint i; i < MAX_ORBS_T; i++) {let v = invoker.xSpooks[i];
		if(invoker.SpookCanHappen(invoker.xSpooks[i]))
		{vector3 spawnVec = invoker.InOff(24.0); invoker.xSpooks[i] = 
		SuperOrbital(Spawn("SuperOrbital", spawnVec));
		A_PlaySound("weapons/hornrodpowshoot"); if(invoker.xSpooks[i])
		{invoker.xSpooks[i].target = self;} return;}}
	}
	
	action void SuperNukeOrbitals()
	{for(uint i; i < MAX_ORBS_T; i++)
		{let v = invoker.xspooks[i]; if(v) {v.ExplodeMissile();}}}
	
	States
	{
		StaffShot:	HROD AB 6 VE_Spread(true, 7, 15.0);
					HROD A 0 A_Refire(); Goto Ready;
		FocusShot:	HROD AB 8 VF_Spread(true, 6, 7.5);
					HROD A 0 A_Refire(); Goto Ready;
		PopShot:	HROD AB 6 VE_Spread(true, 11, 7.5);
					HROD A 0 A_Refire(); Goto Ready;
		HSpread:	HROD AB 12 VE_Spread(true, 17, 22.5);
					HROD A 0 A_Refire(); Goto Ready;
		Altfire:	HROD ABAB 8; HROD ABAB 6; HROD ABAB 4;
		AltLoop:	HROD AAABBB 1 SuperReflects(); HROD A 0 A_Refire("AltLoop");
		PostAlt:	HROD B 5 SuperNukeOrbitals(); HROD A 9; Goto Ready;
	}
}
