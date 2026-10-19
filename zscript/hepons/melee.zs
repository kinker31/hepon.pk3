class WhackStick : BaseHepon
{
	Default {Weapon.SlotNumber 1; Weapon.SisterWeapon "SupaWhackStick";
	+WEAPON.WIMPY_WEAPON; +WEAPON.MELEEWEAPON; Obituary "$STICKOUCH";
	Tag "$TAGSTICK"; WhackStick.BaseDamage 7, 15; WhackStick.Treshhold 4, 2;}
	uint combo; //coMax1: Non-Tomed, coMax2: Tomed
	readonly uint minDam, maxDam;	property BaseDamage: minDam, maxDam;
	readonly uint coMax1, coMax2;	property Treshhold:	 coMax1, coMax2;
	
	//Base Mulitplier, Crit Chance, Crit Factor, Units/sec.
	uint StickDamage(uint baseMult, double d, uint f, double sped, bool tomed = false)
	{uint temp, baseDamage, multiplier; double dTemp, speedMult, mulpy;
		baseDamage = random(minDam, maxDam); if(tomed){baseDamage += 2;}
		baseDamage *= baseMult; multiplier = critHandler(d, false, f);
		speedMult = vel.Length() / sped; mulpy = tomed? 1.5: 1.0;
		dtemp = baseDamage * (multiplier * (mulpy + speedMult));
		temp = ceil(dTemp); return temp;}
	
	action void WhackEm(bool tomed)
	{uint finDam = invoker.StickDamage(3, 128.0, 4, 144.0, tomed);
		let puffity = tomed? "StaffPuff2":"StaffPuff";
		A_CustomPunch(finDam, true, CPF_NOTURN, puffity, 128.0);}
	
	action void ComboWhack(bool tomed)
	{uint finDam = invoker.StickDamage(2, 37.5, 2, 256.0, tomed);
		A_CustomPunch(finDam, true, CPF_NOTURN, "StaffPuff", 112.0);
		if(target != null && target.bIsMonster) {++invoker.combo;}}
	
	action void SuperWhack(bool tomed)
	{uint finDam = invoker.StickDamage(6, 192.0, 2, 112.0, tomed);
		A_CustomPunch(finDam, true, CPF_NOTURN, "StaffPuff2", 144.0);
		invoker.combo = 0;}
	
	States
	{
		Ready:		STFF A 1 A_WeaponReady(); Loop;
		Select:		STFF A 1 A_Raise(12); Loop;
		Deselect:	STFF A 1 A_Lower(12); Loop;
		Fire:	STFF B 5; STFF C 7 WhackEm(false);
				STFF BA 5; STFF A 0 A_Refire(); Goto Ready;
		Altfire:	STFF A 0 {if(invoker.combo > invoker.coMax1)
					{ResolveState("ComboBreaker");} return ResolveState(null);} 
					STFF B 3; //Intentional State fallthrough
		NormalCombo:	STFF C 4 ComboWhack(false); STFF B 2; 
						STFF B 2 A_Refire("Altfire"); Goto Ready;
		ComboBreaker:	STFF C 20 SuperWhack(false); STFF B 2;
						STFF B 2 A_Refire("Altfire");Goto Ready;
	}
}

class SupaWhackStick : WhackStick
{
	Default {Weapon.SisterWeapon "WhackStick"; +WEAPON.WIMPY_WEAPON;
	+WEAPON.MELEEWEAPON; +WEAPON.POWERED_UP; Obituary "$SUPASTICKOUCH";
	Tag "$TAGSUPASTICK";}
	States
	{
		Ready:		STFF DEF 2 A_WeaponReady(); Loop;
		Select:		STFF D 1 A_Raise(16); Loop;
		Deselect:	STFF D 1 A_Lower(16); Loop;
		Fire:	STFF G 4; STFF H 6 WhackEm(true);
				STFF GF 4; STFF F 0 A_Refire(); Goto Ready;
		Altfire:	STFF D 0 {if(invoker.combo > invoker.coMax2)
					{ResolveState("ComboBreaker");} return ResolveState(null);} 
					STFF G 2; //Intentional State fallthrough
		NormalCombo:	STFF H 3 ComboWhack(true); STFF G 2;
						STFF G 1 A_Refire("Altfire"); Goto Ready;
		ComboBreaker:	STFF H 12 SuperWhack(true); STFF G 2;
						STFF G 1 A_Refire("Altfire"); Goto Ready;
	}
}

class GauntBonus : BasicArmorBonus 
{Default {Armor.MaxSaveAmount 75; Armor.SavePercent 50; Armor.SaveAmount 1;}}
class Zappo1 : Actor
{Default {Projectile; Damage 2; +RIPPER; Speed 24; Height 8; +Bright;
	+THRUGHOST; Translation "ZapOne";} States {Spawn: FX17 ABCDE 2; Stop;}}
class Zappo2 : Zappo1 {Default{Damage 4; Speed 32; Translation "ZapTwo";}}

class FapHands : BaseHepon
{
	Default {Weapon.SlotNumber 1; Weapon.SisterWeapon "SupaFapHands";
	Tag "$TAGFAPHAND"; +WEAPON.MELEEWEAPON; Obituary "$FAPHANDOUCH"; Weapon.YAdjust 15;
	Inventory.PickupMessage "$FAPHANDWOW";Weapon.UpSound "weapons/gauntletsactivate";}
	
	const M_FLAGS1 = CPF_PULLIN|CPF_NOTURN|CPF_NORANDOMPUFFZ;
	const M_FLAGS2 = M_FLAGS1|CPF_STEALARMOR; const maxAngle = 22.5;
	const DAMNFLAGS = DMG_NO_ARMOR|DMG_NO_PROTECT|DMG_THRUSTLESS;
	
	uint GetTheDamage(bool tomed)
	{ if(!owner) {return 0;}
		uint temp = tomed? randompick(11, 13, 17, 23) : randompick(3, 5, 11, 13);
		temp *= CritHandler(16.0, true, 4); return temp;}
	
	//Primary: Steals health, tomed also steals armor too
	action void NotSawAttack(bool tomed)
	{if (!invoker) {return;}
		double stealFactor = tomed? 0.75 : 0.25;
		uint stealMax = tomed? 0 : 75, range = tomed? 192 : 128;
		int flags = tomed? M_FLAGS2 : M_FLAGS1;
		let puffity = tomed? "GauntletPuff2" : "GauntletPuff1";
		let soundy = tomed? "weapons/gauntletspowhit" : "weapons/gauntletshit";
		A_CustomPunch(invoker.GetTheDamage(tomed), true, flags, 
			puffity, range, stealFactor, stealMax, "GauntBonus", soundy, soundy);
	}
	
	//Altfire: Drain Health for Zappy Attack
	action void SigilRipoff(bool tomed, uint amount)
	{if (!invoker) {return;}
		let proj = tomed? "Zappo2" : "Zappo1"; uint dam = tomed? 5 : 3;
		let soundy = tomed? "weapons/gauntletspowhit" : "weapons/gauntletshit";
		DamageMobj(invoker, null, dam, "Normal", DAMNFLAGS); A_StartSound(soundy);
		HeponProjFan(proj, amount, maxAngle, (-MaxAngle / 2));
	}
	
	States
	{
		Ready:		GAUN A 1 A_WeaponReady(); Loop;
		Select:		GAUN A 1 A_Raise(10); Loop;
		Deselect:	GAUN A 1 A_Lower(10); Loop;
		Fire:		GAUN B 2 Bright;
					GAUN C 2 Bright A_StartSound("weapons/gauntletsuse");
		Hold:	GAUN DEF 3 Bright NotSawAttack(false);
				GAUN C 2 A_Refire(); GAUN B 2; Goto Ready;
		Altfire:	GAUN BCD 3;	GAUN E 4 SigilRipoff(false, 2);
					GAUN F 4;	GAUN E 4 SigilRipoff(false, 3);
					GAUN F 4;	GAUN E 4 SigilRipoff(false, 3);
					GAUN DCB 3; Goto Ready;
		Spawn:		WGNT A -1; Stop;
	}
}

class SupaFapHands : FapHands
{
	Default {Weapon.SisterWeapon "FapHands"; +WEAPON.POWERED_UP; 
	Obituary "$SUPAFAPHANDOUCH"; Tag "$TAGSUPAFAPHAND";}
	
	States
	{
		Ready:		GAUN GHI 2 A_WeaponReady(); Loop;
		Select:		GAUN A 1 A_Raise(12); Loop;
		Deselect:	GAUN A 1 A_Lower(12); Loop;
		Fire:	GAUN J 2 Bright;
				GAUN K 2 Bright A_StartSound("weapons/gauntletsuse");
		Hold:	GAUN LMN 3 Bright NotSawAttack(true);
				GAUN K 2 A_Refire(); GAUN J 2; Goto Ready;
		Altfire:	GAUN JKL 2;	GAUN M 2 SigilRipoff(true, 3);
					GAUN N 2;	GAUN M 2 SigilRipoff(true, 3);
					GAUN M 2;	GAUN M 2 SigilRipoff(true, 5);
					GAUN N 2;	GAUN M 2 SigilRipoff(true, 5);
					GAUN M 2;	GAUN M 2 SigilRipoff(true, 7);
					GAUN LKJ 2;	Goto Ready;
	}
}
