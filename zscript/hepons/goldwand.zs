class WandProjectile : GoldWandFX2 
{Default {Speed 24; DamageFunction GetDamage(); +THRUGHOST;} 
uint GetDamage() {return random(5, 10);}}

class ElfWand : BaseHepon
{Default {Weapon.SlotNumber 2; Obituary "$WANDOUCH"; Tag "$TAGWAND"; 
	Inventory.PickupMessage "$WANDWOW"; Weapon.SisterWeapon "SupaElfWand"; 
	Weapon.AmmoType "NewCrystal"; Weapon.AmmoGive1 20; AttackSound "weapons/wandhit";
	BaseHepon.AttackNames "$W1N1", "$W1N2", "$W1N3", "$W1N4"; 
	BaseHepon.SwapCosts 15, 25, 45, 90;} mixin ManaMixin;
	static const uint COSTS[] = {2, 1, 5, 8};
	const RAILFLAGS = RGF_SILENT|RGF_FULLBRIGHT|RGF_EXPLICITANGLE;
	const DAMNFLAGS = DMG_NO_ARMOR|DMG_NO_PROTECT|DMG_THRUSTLESS;
	uint WandoDam(uint min, uint max, double c, uint f)
	{return random(min, max) * CritHandler(c, true, f);}
	
	action void ElfBlast(uint amount, double maxAmp)
	{double ying, tempVal, yang; for(uint i = 0; i < amount; i++)
		{tempVal = maxAmp / 2.5; [ying, yang] = RandomizerCrap(-maxAmp, maxAmp); 
		HeponProj("WandProjectile", (ying, (yang / 2.5)));}}
	
	action void NormalWand(bool tomed)
	{uint baseDam = invoker.WandoDam(6, 10, 8.0, 6);
		let p = tomed? "GoldWandPuff2": "GoldWandPuff1";
		A_StartSound("weapons/wandhit"); if(!tomed)
		{HeponBoolet(0, baseDam, 1, (0, 0), p);
		HeponBoolet(-1, baseDam, 1, (-2.25, 0), p, false, 0, true);
		HeponBoolet(-1, baseDam, 1, (2.25, 0), p, false, 0, true);}
		else {bool yomp; double ying = -15.0, yang;
			for(int i = -2; i <= 2; i++) {yang = -6;
			for(int j = -2; j <= 2; j++) {yomp = (abs(i) + abs(j)) < 3;
			if(yomp) {HeponBoolet(-1, baseDam, 1, (ying, yang), p, false, 0, true);}
			baseDam = invoker.WandoDam(12, 18, 22.5, 8); yang += 3; } ying += 7;}}
	}
	
	action void QuickWand(bool tomed)
	{uint damVal = random(4, 8), num = tomed? 4: 2, vNom = tomed? 2: 1;
	let p = tomed? "GoldWandPuff2": "GoldWandPuff1"; A_StartSound("weapons/wandhit");
	HeponBoolet(num, damVal, num, (4.5, 1.5), p, true, vNom, false);}
	
	action void LongWand(bool tomed)
	{let p = tomed? "GoldWandPuff2": "GoldWandPuff1";
		double distMult, temp, ch, dMin, dMax; uint finalDam, mint, mant;
		FTranslatedLineTarget v; let target = 
		LineAttack(0, 8192, 0, 0, "Normal", null, LAF_NOIMPACTDECAL, v);
		A_StartSound("weapons/wandhit"); if(v.linetarget != null)
		{temp = (v.linetarget.pos - invoker.pos).Length();
			dMin = tomed? 1.0 : 0.333; dMax = tomed? 8.0 : 6.66; 
			ch = tomed? 23.5 : 12.5; distMult = temp / 1024;
			mint = tomed? 13: 7; mant = tomed? 17 : 9;
			if(distMult < dMin){distMult = dMin;}
			else if (distMult > dMax){distMult = dMax;}
			temp = invoker.WandoDam(mint, mant, ch, mint) * distMult;
			uint finalDam = floor(temp);
			HeponBoolet(2, finalDam, 1, (3.5, 1.75), p, false, 2, false);}
		else {invoker.DamageMobj(invoker, null, 5, "Normal", DAMNFLAGS);}
	}
	
	action void ShotgunWand(bool tomed)
	{let p = tomed? "GoldWandPuff2": "GoldWandPuff1";
		uint baseDam = tomed? 18 : 12, numb = tomed? 13: 7;
		uint finalDam = invoker.WandoDam(6, baseDam, 7.5, 3);
		A_StartSound("weapons/wandhit");
		HeponBoolet(numb, finalDam, 1, (9.0, 4.5), p, true, 5, false);}

	action void WandRailgun(bool tomed, uint amount)
	{uint minV = tomed? 34: 16, maxV = tomed? 48: 32, comst = tomed? 12: 8;
		if(!invoker.DepleteAmmo(false, true, comst, true)) {return;}
		class<actor> puffity = tomed? "GoldWandPuff2" : "GoldWandPuff1";
		uint baseDam = invoker.WandoDam(minV, maxV, 7.5, 8);
		HeponRaily(baseDam, (0, 0), (0, 0), 512, "orange", "yellow", 3, puffity, RAILFLAGS);
		if(tomed) {baseDam = random(20, 32) * CritHandler(8.0, true, 10);
		HeponRaily(baseDam, (-7.5, 0), (0, 0), 512, "orange", "yellow", 3, puffity, RAILFLAGS);
		baseDam = random(20, 32) * CritHandler(8.0, true, 10);
		HeponRaily(baseDam, (7.5, 0), (0, 0), 512, "orange", "yellow", 3, puffity, RAILFLAGS);}
		A_PlaySound("hepon/voip", CHAN_WEAPON);}
	
	States
	{Ready:		GWND A 1 A_WeaponReady(HEPON_FLAGS); Loop;
	Select:		GWND A 1 A_Raise(12); Loop;
	Deselect:	GWND A 1 A_Lower(12); Loop;
	Fire: GWND A 0 {statelabel s; switch(invoker.mode)
			{case 0: s = "RegularFire"; break; case 1: s = "QuickFire"; break;
			case 2: s = "SnipeFire"; break; case 3: s = "ShotFire"; break;
			default: s = "Ready"; break;}
		if(!invoker.DepleteAmmo(false, true, invoker.COSTS[invoker.mode], true))
		{s = "Ready";} return ResolveState(s);}
	RegularFire:
		GWND B 3 Bright; GWND C 5 Bright {NormalWand(false); ElfBlast(3, 4.5);}
		GWND D 3 Bright; GWND D 0 A_Refire();
		Goto Ready;
	QuickFire:
		GWND B 2 Bright; GWND C 3 Bright {QuickWand(false); ElfBlast(4, 8.0);}
		GWND D 2 Bright; GWND D 0 A_Refire();
		Goto Ready;
	SnipeFire:
		GWND B 2 Bright; GWND C 3 Bright {LongWand(false); ElfBlast(4, 1.5);}
		GWND D 2 Bright; GWND A 15; GWND D 0 A_Refire();
		Goto Ready;
	ShotFire:
		GWND B 5 Bright; GWND C 7 Bright {ShotgunWand(false); ElfBlast(13, 15);}
		GWND D 5 Bright; GWND D 0 A_Refire();
		Goto Ready;
	Altfire:
		GWND B 0 {if(invoker.ammo1.amount < 8){return ResolveState("Ready");}
					else{return ResolveState(null);}}
		GWND B 3 Bright; GWND C 6 Bright WandRailgun(false, 3);
		GWND D 3 Bright; GWND D 0 A_Refire();
		Goto Ready;
	Spawn:		GWAN A -1; Stop;}
}

class SupaElfWand : ElfWand
{ Default {Obituary "$SUPAWANDOUCH"; Tag "$SUPATAGWAND";
	Weapon.SisterWeapon "ElfWand"; +WEAPON.POWERED_UP;}
	States
	{RegularFire:
		GWND B 2 Bright; GWND C 3 Bright {NormalWand(true); ElfBlast(6, 7.5);}
		GWND D 2 Bright; GWND D 0 A_Refire();
		Goto Ready;
	QuickFire:
		GWND B 1 Bright; GWND C 2 Bright {QuickWand(true); ElfBlast(4, 7.5);}
		GWND D 1 Bright; GWND D 0 A_Refire();
		Goto Ready;
	SnipeFire:
		GWND B 2 Bright; GWND C 3 Bright {LongWand(true); ElfBlast(7, 1.5);}
		GWND D 2 Bright; GWND A 10; GWND D 0 A_Refire();
		Goto Ready;
	ShotFire:
		GWND B 3 Bright; GWND C 5 Bright {ShotgunWand(true); ElfBlast(13, 12.5);}
		GWND D 3 Bright; GWND D 0 A_Refire();
		Goto Ready;
	Altfire:
		GWND B 0 {if(invoker.ammo1.amount < 12){return ResolveState("Ready");}
				else{return ResolveState(null);}}
		GWND B 3 Bright; GWND C 6 Bright WandRailgun(true, 5);
		GWND D 3 Bright; GWND D 0 A_Refire();
			Goto Ready;}
}
