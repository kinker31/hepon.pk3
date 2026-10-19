class DagronRipper: Ripper
{ Default {DamageFunction RipDam(); +THRUGHOST;}
	uint RipDam() {return randompick(2, 3, 5, 13);}
	override int DoSpecialDamage (Actor target, int damage, Name damagetype)
	{if (target.bBoss) {damage = randompick(1, 2, 3);}
	if(damage == 0){return 0;} return damage;}
}

class DagronNyoom : BlasterFX1
{ Default {Damage 0; SeeSound "";} uint nType; 
	void TastersRip(uint amount = 8, double offset = 0.0)
	{double ying = offset, step = 360 / amount; actor r; for(uint i; i < amount; i++)
		{r = Spawn("DagronRipper", pos, ALLOW_REPLACE); if(r == null) {return;}
		r.target = target; r.angle = ying; r.VelFromAngle();
		r.CheckMissileSpawn(radius); ying += step; if(ying > 360){ying -= 360;}}
	}
	
	States
	{
		Spawn: ALCO E 200; Loop;
		Death: FX18 A 0 {switch(invoker.nType)
		{case 0: return ResolveState("Spawner1");
		 case 1: return ResolveState("Spawner2");
		 case 2: return ResolveState("Spawner3");
		 case 3: return ResolveState("Spawner4");
		default: return ResolveState("Spawner1");}}
		Spawner1:
			FX18 A 2 Bright TastersRip(); FX18 BCDEFG 3 Bright; Stop;
		Spawner2:
			FX18 A 4 Bright TastersRip(6); FX18 BCDEFG 3 Bright; Stop;
		Spawner3:
			FX18 A 5 Bright TastersRip(2);
			FX18 B 5 Bright TastersRip(2, 90);
			FX18 DEFG 4 Bright; Stop;
		Spawner4:
			FX18 A 6 Bright TastersRip(4); FX18 B 5 Bright;
			FX18 C 6 Bright TastersRip(4, 22.5); FX18 D 5 Bright;
			FX18 E 6 Bright TastersRip(4, 45.0); FX18 FG 4 Bright; Stop;
	}
}

class TastersChoice : BaseHepon
{
	Default
	{Weapon.SlotNumber 4; Obituary "$DAGRONOUCH"; Tag "$TAGDAGRON";
	Inventory.PickupMessage "$DAGRONWOW"; Weapon.AmmoType1 "NewPewPew";
	Weapon.SisterWeapon "SupaTastersChoice"; BaseHepon.SwapCosts 30, 50, 75, 115;
	Weapon.AmmoGive1 20; Weapon.AmmoType2 "NewCrystal"; Weapon.AmmoUse2 4;
	BaseHepon.AttackNames "$W3N1", "$W3N2", "$W3N3", "$W3N4";}
	
	uint spedFact, chomp, gromp; const B_DAMM = 8; const B_DICE = 6;
	const WAND_NOM = 4; const MAX_FACT = 6; mixin ManaMixin;
	static const uint COSTS[] = {2, 5, 10, 15};
	
	action void MagDakka(bool tomed, uint num = 7, double maxSp = 12.5)
	{if(!invoker) {return;} if(!invoker.DepleteAmmo(invoker.bAltfire)) {return;}
		uint bDam = B_DAMM, bDice = B_DICE, eio = invoker.mode, theDamage = 1;
		switch(eio)
		{case 0: default:	break;
		 case 1:	FixedShots(tomed, num, maxSp); break;
		 case 2:	bDam = 24; bDice = 6; break;
		 case 3:	bDam = 12; bDice = 12; break;}
		A_StartSound("weapons/blastershoot", CHAN_WEAPON);
		if(eio == 1) {return;} double d = maxSp / 4;
		HeponPBoolet(bDam, num, bDice, 
			stangle: (maxSp, d), pSpawn: "BlasterPuff");}
	
	action void FixedShots(bool tomed, uint num, double stepM)
	{double ying = -stepM, step = (stepM * 2) / num; for(uint i; i <= num; i++)
		{HeponPBoolet(B_DAMM, 1, 4, 4, 
			stangle: (ying, 0), pSpawn: "BlasterPuff");}
	}
	
	action void RipperRage()
	{if(!invoker) {return;} DagronNyoom a;
	a = DagronNyoom(HeponProj("DagronNyoom", (0.75, 0.75)));
	if(a){a.nType = invoker.mode;}}
	
	action void FeedDragon()
	{if(!invoker.DepleteAmmo(true, true, -1, true)){return;}
	invoker.chomp++; A_PlaySound("hepon/voip"); if(invoker.chomp > 3) 
	{invoker.spedFact++; invoker.chomp = 0;}}
	
	action void Sped(uint initial)
	{uint temp = initial - invoker.spedFact; A_SetTics(temp); 
	if(invoker.spedFact > 0) {invoker.gromp++;}
	if(invoker.gromp > 8) {--invoker.spedFact; invoker.gromp = 0;}}
	
	bool CanFire(uint m) {return DepleteAmmo(false, true, COSTS[m], true);}
	
	States
	{Ready:		BLSR A 1 A_WeaponReady(HEPON_FLAGS); Loop;
	Select:		BLSR A 1 A_Raise(); Loop;
	Deselect:	BLSR A 1 A_Lower(); Loop;
	Fire:		BLSR A 0
		{statelabel s; switch(invoker.mode)
			{case 0: s = "MainClaw"; break;
			case 1: s = "AltClaw"; break;
			case 2: s = "SnipeClaw"; break;
			case 3: s = "SpamClaw"; break;
			default: s = "Ready"; break;}
		return ResolveState(s);}
	MainClaw:	BLSR BC 1;
	MainLoop:	BLSR D 0 {if(!invoker.CanFire(invoker.mode))
				{return ResolveState("Ready");} else {return ResolveState(null);}}
				BLSR D 2 Bright MagDakka(false);
				BLSR CB 1; BLSR A 1 Sped(7);
				BLSR A 0 A_Refire("MainLoop"); Goto Ready;
	AltClaw:	BLSR BC 2; 
	AltLoop:	BLSR D 0 {if(!invoker.CanFire(invoker.mode))
				{return ResolveState("Ready");} else {return ResolveState(null);}}
				BLSR D 3 Bright MagDakka(false, 9, 9.5);
				BLSR CB 2; BLSR A 1 Sped(8);
				BLSR A 0 A_Refire("AltLoop"); Goto Ready;
	SnipeClaw:	BLSR BC 3; 
	SnipeLoop:	BLSR D 0 {if(!invoker.CanFire(invoker.mode))
				{return ResolveState("Ready");} else {return ResolveState(null);}}
				BLSR D 4 Bright MagDakka(false, 7, 1.25);
				BLSR CB 2; BLSR A 12 Sped(15);
				BLSR A 0 A_Refire("SnipeLoop"); Goto Ready;
	SpamClaw:	BLSR BC 1; 
	SpamLoop:	BLSR D 0 {if(!invoker.CanFire(invoker.mode))
				{return ResolveState("Ready");} else {return ResolveState(null);}}
				BLSR D 2 Bright MagDakka(false, 17, 17.5);
				BLSR CB 1; BLSR A 1 Sped(11);
				BLSR A 0 A_Refire("SpamLoop"); Goto Ready;
	Altfire:
		BLSR A 0 {if(invoker.ammo2.amount < invoker.WAND_NOM ||
						invoker.spedFact >= invoker.MAX_FACT)
				{return ResolveState("Ready");}
				else {return ResolveState(null);}}
		BLSR EF 2; BLSR G 3 Bright FeedDragon();
		BLSR A 2 A_Refire(); Goto Ready;
	Spawn:		WBLS A -1; Stop;}
}

class SupaTastersChoice : TastersChoice
{
	Default {Obituary "$SUPADAGRONOUCH"; Tag "$TAGSUPADAGRON";
			Weapon.SisterWeapon "TastersChoice"; +WEAPON.POWERED_UP}
	States
	{MainClaw:	BLSR BC 3; 
	MainLoop:	BLSR D 0 {if(!invoker.CanFire(invoker.mode))
				{return ResolveState("Ready");} else {return ResolveState(null);}}
				BLSR D 4 Bright {MagDakka(true, 5); RipperRage();}
				BLSR A 7 Sped(9); BLSR A 0 A_Refire("MainLoop"); Goto Ready;
	AltClaw:	BLSR BC 4; 
	AltLoop:	BLSR D 0 {if(!invoker.CanFire(invoker.mode))
				{return ResolveState("Ready");} else {return ResolveState(null);}}
				BLSR D 6 Bright {MagDakka(true, 7, 7.5); RipperRage();}
				BLSR A 9 Sped(10); BLSR A 0 A_Refire("AltLoop"); Goto Ready;
	SnipeClaw:	BLSR BC 2; 
	SnipeLoop:	BLSR D 0 {if(!invoker.CanFire(invoker.mode))
				{return ResolveState("Ready");} else {return ResolveState(null);}}
				BLSR D 3 Bright {MagDakka(true, 3, 1.25); RipperRage();}
				BLSR A 32 Sped(17); BLSR A 0 A_Refire("SnipeLoop"); Goto Ready;
	SpamClaw:	BLSR BC 2; 
	SpamLoop:	BLSR D 0 {if(!invoker.CanFire(invoker.mode))
				{return ResolveState("Ready");} else {return ResolveState(null);}}
				BLSR D 3 Bright {MagDakka(true, 9, 12.5); RipperRage();}
				BLSR A 24 Sped(13); BLSR A 0 A_Refire("SpamLoop"); Goto Ready;}
}
