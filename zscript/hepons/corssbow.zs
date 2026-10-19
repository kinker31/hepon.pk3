mixin class ArrMix
{uint GetDamage(uint base, double critC = 16.0, vector2 vals = (1, 1))
	{uint mult = random(vals.x, vals.y); return 
		(base * mult * BaseHepon.CritHandler(critC, false, 3));}
}

class BigArrowd : CrossbowFX1
{Default {SeeSound ""; Speed 48; DamageFunction GetDamage(8, 16.0, (1, 3));} mixin ArrMix;}

//random2[BoltSpark] spam is to make sure the inherited bolts behave visually
class BiggerArrowd : BigArrowd
{Default {Speed 64; DamageFunction GetDamage(6, 24.0, (4, 7));}
	States {Spawn:	FX03 B 2 Bright A_SpawnItemEx("CrossbowFX4", random2[BoltSpark]()*0.032, 
	random2[BoltSpark]()*0.032, 0, 0, 0, 0, 0, SXF_ABSOLUTEPOSITION, 64); Loop;}
}

class SmolArrowd : CrossbowFX3
{Default {SeeSound ""; Speed 32; DamageFunction GetDamage(4, 48.0);} mixin ArrMix;}

class NotSmolArrowd : SmolArrowd
{Default {Speed 48; DamageFunction GetDamage(3, 96.0, (1, 4));}
	States {Spawn:	FX03 A 8 Bright A_SpawnItemEx("CrossbowFX4", random2[BoltSpark]()*0.016,
	random2[BoltSpark]()*0.016, 0, 0, 0, 0, 0, SXF_ABSOLUTEPOSITION, 128); Loop;}
}

class ArrowClip: Ammo
{Default {Inventory.MaxAmount 5; +INVENTORY.IGNORESKILL; Inventory.Icon "ARROWCLIP";}}

class ArrowdTheWeapon : BaseHepon
{
	Default {Weapon.SlotNumber 3; Obituary "$ARROWDOUCH"; Tag "$TAGARROWD"; 
	Weapon.YAdjust 15; Inventory.PickupMessage "$ARROWDWOW"; 
	Weapon.SisterWeapon "SupaArrowdTheWeapon"; Weapon.AmmoType1 "NewArrows"; 
	Weapon.AmmoType2 "ArrowClip"; Weapon.AmmoGive1 8; Weapon.AmmoGive2 0;
	BaseHepon.SwapCosts 25, 45, 75, 125; Weapon.AmmoUse1 1; Weapon.AmmoUse2 0;
	BaseHepon.AttackNames "$W2N1", "$W2N2", "$W2N3", "$W2N4";}
	mixin ManaMixin; static const uint COSTS[] = {1, 2, 2, 5};
	const WFACT = 7.5; bool done; const OFFLAGS = WOF_INTERPOLATE|WOF_KEEPX|WOF_ADD;
	
	//[n]Val.x = Tomed Value, [n]Val.y = Non-Tomed Value
	vector2 RanCrap(bool tomed, vector2 xVal, vector2 yVal)
	{vector2 tempy;
		tempy.x = tomed? frandom(-xVal.x, xVal.x):frandom(-xVal.y, xVal.y);
		tempy.y = tomed? frandom(-yVal.x, yVal.x):frandom(-yVal.y, yVal.y);
	return tempy;}
	
	action void FixedBolts(uint a1, uint a2, Class<actor> a, Class<actor> b)
	{double ying = -WFACT, yang = ying / 6, step1 = (WFACT * 2) / a2, 
			step2 = ((WFACT / 6) * 2) / (a1 - 1);
		for(uint i; i <= a2; i++) 
		{if(ying ~== 0.0) for(uint j; j < a1; j++)
			{HeponProj(a, (yang, 0)); yang += step2;}
		else{HeponProj(b, (ying, 0));} ying += step1;}
	}
	
	action void CrossbowAction(bool tomed, uint baseBig = 3, uint baseSmol = 7)
	{ Class<actor> a = tomed? "BiggerArrowd":"BigArrowd",
				b = tomed? "NotSmolArrowd":"SmolArrowd";
		uint aNum, bNum, i, qBuffer = invoker.ammo2.amount,
		divOne = invoker.ammo2.maxamount / 2,
		divTwo = invoker.ammo2.maxamount / 3; 
		vector2 spreadBig, spreadSmol; A_TakeInventory("ArrowClip", 0);
		//Handle Big Arrows (disable if Boltstorm)
		if(invoker.mode != 2) {aNum = round(baseBig * (1 + (qBuffer / divOne)));
		if(invoker.mode == 3) {aNum *= 2;}}
		//Handle Smol Arrows (disable if Big Bois)
		if(invoker.mode != 3) {bNum = round(baseSmol * (1 + (qBuffer / divTwo)));
		if(invoker.mode == 2) {bNum *= 2;}}
		A_StartSound("weapons/bowshoot", CHAN_WEAPON);
		//If Wayfarer mode's on, don't bother with spread
		if(invoker.mode == 1) {FixedBolts(aNum, bNum, a, b); qBuffer = 0; return;}
		if(aNum != 0) {for(i; i < aNum; i++) 
		{spreadBig = invoker.RanCrap(tomed, (1.5, 2.25), (0.5, 0.75));
		HeponProj(a, spreadBig);}} if(bNum != 0) {for(i = 0; i < bNum; i++)
		{spreadSmol = invoker.RanCrap(tomed, (2.5, 5.25), (1.5, 2.5));
		HeponProj(b, spreadSmol);}}
	}
	
	action void LoadEmUpDan()
	{if(!invoker.DepleteAmmo(false, true, 3, true)) {return;}
		A_GiveInventory("ArrowClip", 1); if(invoker.StopLoad())
		{invoker.done == true;}}
	
	bool StopLoad()
	{bool temp1 = (ammo2.amount == ammo2.MaxAmount),
		temp2 = (ammo1.amount < 3); return temp1 || temp2;}
	
	States
	{Ready:		CRBW ABC 6 A_WeaponReady(HEPON_FLAGS); Loop;
	Select:		CRBW A 1 A_Raise(); Loop;
	Deselect:	CRBW A 1 A_Lower(); Loop;
	Fire:		CRBW A 0
		{statelabel s = "Ready"; switch(invoker.mode)
			{case 0: s = "QuiverFire"; break;
			case 1: s = "AirFire"; break;
			case 2: s = "FletchFire"; break;
			case 3: s = "OverFire"; break;
			default: break;}
		if(!invoker.DepleteAmmo(false, true, invoker.COSTS[invoker.mode], true))
		{s = "Ready";} return ResolveState(s);}
	QuiverFire:	CRBW D 6 Bright CrossbowAction(false); CRBW EF 5;
				CRBW A 4 A_Refire("Fire"); Goto Ready;
	AirFire:	CRBW D 8 Bright CrossbowAction(false, 3, 6); CRBW EF 7;
				CRBW A 6 A_Refire("Fire"); Goto Ready;
	FletchFire:	CRBW D 5 Bright CrossbowAction(false, 0, 9); CRBW EF 3;
				CRBW A 2 A_Refire("Fire"); Goto Ready;
	OverFire:	CRBW D 15 Bright CrossbowAction(false, 5, 0); CRBW EF 12;
				CRBW A 9 A_Refire("Fire"); Goto Ready;
	Altfire:	CRBW A 0 
		{if(invoker.StopLoad()) {return ResolveState("Ready");}
			else{return ResolveState(null);}}
		CRBW DDDD 2 A_WeaponOffset(0, 6.0, OFFLAGS);
	LoopEmUpDan:	CRBW D 0 
		{if(invoker.StopLoad()) {return ResolveState("LoopBeDone");}
			else{return ResolveState(null);}}
		CRBW D 6 {A_StartSound("weapons/staffhit"); LoadEmUpDan();}
		CRBW E 3 {if(invoker.done) {return ResolveState("LoopBeDone");}
					return ResolveState(null);}
		CRBW E 3 A_Refire("LoopEmUpDan"); Goto LoopBeDone;
	LoopBeDone:	CRBW DDDDDDDD 2 A_WeaponOffset(0, 3.0, OFFLAGS); 
				CRBW A 0 {invoker.done = false;} Goto Ready;
	Spawn:		WBOW A -1; Stop;
	}
}

class SupaArrowdTheWeapon : ArrowdTheWeapon
{
	Default {Obituary "$SUPARROWDOUCH"; Tag "$TAGSUPARROWD"; 
		Weapon.SisterWeapon "ArrowdTheWeapon"; +WEAPON.POWERED_UP}
	
	States
	{Ready:		CRBW ABC 3 A_WeaponReady(HEPON_FLAGS); Loop;
	QuiverFire:	CRBW F 5 Bright CrossbowAction(true, 5, 9); CRBW ED 4;
				CRBW A 3 A_Refire("Fire"); Goto Ready;
	AirFire:	CRBW F 6 Bright CrossbowAction(true, 5, 14); CRBW ED 5;
				CRBW A 4 A_Refire("Fire"); Goto Ready;
	FletchFire:	CRBW F 3 Bright CrossbowAction(true, 0, 13); CRBW ED 2;
				CRBW A 2 A_Refire("Fire"); Goto Ready;
	OverFire:	CRBW F 9 Bright CrossbowAction(true, 9, 0); CRBW ED 7;
				CRBW A 6 A_Refire("Fire"); Goto Ready;
	}
}
