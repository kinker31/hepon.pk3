class ManaOrb: Ammo
{Default {Inventory.Amount 2; Inventory.MaxAmount 666; +Bright;
	Inventory.InterHubAmount 25; +FLOATBOB; +INVENTORY.INVBAR; Tag "$ORBTAG";
	Inventory.PickupSound "misc/p_pkup"; Inventory.PickupMessage "$ORBGET";
	+INVENTORY.KEEPDEPLETED; +INVENTORY.UNCLEARABLE; Translation "Sparkly";
	Inventory.Icon "MICON";} uint age; bool isDying;
	
	override void PostBeginPlay() {super.PostBeginPlay();A_SpriteOffset(0, -24.0);}
	override void Tick() {super.Tick(); if (self.owner) {return;} age++;}
	action void AgeCrap() {if(invoker.age > 120 && !invoker.isDying)
	{invoker.isDying = true; invoker.SetStateLabel("Dying");}
	else if (invoker.age > 180) {invoker.SetStateLabel("Death");}}
	
	States {Spawn:	AMB1 AABBCC 1 AgeCrap(); Loop;
			Dying:	AMB1 A 1 AgeCrap(); TNT1 A 1 AgeCrap();
					AMB1 B 1 AgeCrap(); TNT1 A 1 AgeCrap();
					AMB1 C 1 AgeCrap(); TNT1 A 1 AgeCrap(); Loop;
			Death: FX05 DEFG 2; Stop;}
}

class HeftyOrb: ManaOrb
{Default {Inventory.PickupMessage "$BIGORBGET"; Inventory.Amount 10;}
	States {Spawn:	AMB2 AAABBBCCC 1 AgeCrap(); Loop;
			Dying:	AMB2 AA 1 AgeCrap(); TNT1 AA 1 AgeCrap();
					AMB2 BB 1 AgeCrap(); TNT1 AA 1 AgeCrap();
					AMB2 CC 1 AgeCrap(); TNT1 AA 1 AgeCrap(); Loop;
			Death: FX05 DEFG 4; Stop;}
}

//Potent Brew: Worse healing at 75%+, Better healing 50% or lower
class ArtiHealth2 : ArtiHealth 
{Default {Health 10; Inventory.Icon "HELF2"; Translation "Helf2"; 
Inventory.PickupMessage "$HELF3WOW"; Tag "$HELF3TAG"; HealthPickup.Autouse 2;} 
	
	uint GetTheHealth()
	{	if(!owner){return 0;} uint value = self.health;
		if 		(owner.health <= 25) {value += 55;}
		else if (owner.health <= 50) {value += 25;}
		else if (owner.health <= 65) {value += 10;} return value;}
	
	override bool Use(bool pickup)
	{if(!owner) {return false;} if(owner.health >= 85) 
		{A_Print("$TOOHEALTHY", 1.0); return false;}
		else {int temp = GetTheHealth(); owner.GiveBody(temp);} return true;}
}

//Sludgy Catalyst: Damages you, but grants damage resistance
class ArtiHealth3 : ArtiHealth
{Default {Health 1; Inventory.PickupMessage "$HELF4WOW"; Tag "$HELF4TAG";
	HealthPickup.Autouse 2;Inventory.Icon "HELF3"; Translation "Helf3";} 
	const damVal = 35; const FALGS = DMG_NO_ARMOR|DMG_NO_PROTECT|DMG_THRUSTLESS;
	override bool Use(bool pickup) {if(!owner) {return false;}
		if(owner.health < damVal) {return false;}
		owner.DamageMobj(self, null, damVal, "Normal", FALGS);
		owner.GiveInventory("SludgyRegen", 1); return true;}
}

class SludgyRegen: Powerup
{Default {Powerup.Duration -30;}
	uint healVal; bool canHeal, rightTime, bumpVal;
	override void BeginPlay() {super.BeginPlay(); healVal = 3;}
	override void DoEffect() {super.DoEffect();
		if(!owner) {return;} canHeal = (owner.health > 0);
		rightTime = (Level.maptime % 70) == 0;
		bumpVal = ((Level.maptime & 350) == 0) && (healVal < 12);
		if(canHeal && rightTime) {owner.GiveBody(healVal); if(bumpVal){healVal += 3;}}
	}
}

//Cursed Tome: Damages the user to 10HP, but gives a longer powerup
class CursedTome : ArtiTomeOfPower
{Default {Inventory.Icon "BOOK2"; Inventory.PickupMessage "$BOOK2WOW";
	Tag "$BOOK2TAG"; Powerup.Type "CursedPWL2"; Translation "Book2";} 
	uint damVal; const FALGS = DMG_NO_ARMOR|DMG_NO_PROTECT|DMG_THRUSTLESS;
	
	uint DamageGet() {if(!owner){return 0;} 
		int temp = 10 - owner.health; return abs(temp);}
	
	override bool Use(bool pickup)
	{if(!owner) {return false;} damVal = DamageGet();
	owner.DamageMobj(self, null, damVal, "Normal", FALGS);
		super.Use(pickup); return true;}}
class CursedPWL2 : PowerWeaponLevel2 {Default {Powerup.Duration -100;}}

//Super Tome: Shorter Duration, but higher damage and resistance
class SuperTome : ArtiTomeOfPower
{Default {Inventory.Icon "BOOK3"; Inventory.PickupMessage "$BOOK3WOW";
	Tag "$BOOK3TAG"; Powerup.Type "SuperPWL2"; Translation "Book3";}}
class SuperPWL2 : PowerWeaponLevel2
{Default {Powerup.Duration -20;}
	//UZDoom insists all the normal properties be there for some reason
	override void ModifyDamage(int damage, Name damageType, out int newdamage, 
		bool passive, Actor inflictor, Actor source, int flags)
	{if(passive) {newdamage = round(damage * 0.25);}
		else {newdamage = damage * 2;}}}

class SlipSphere : ArtiInvisibility
{Default {Alpha 0.75; Powerup.Type "SlipSpeed"; Inventory.Icon "ARTICEY";
		Inventory.PickupMessage "$ICEYWOW"; Tag "$ICEYTAG";}
States {Spawn: SICE A 350 Bright; Loop;}}

class SlipSpeed : PowerSpeed
{Default {Powerup.Duration -45; Speed 1.75; Inventory.Icon "SICEA0";}
	override void DoEffect() {if(!owner){return;} 
	Super.DoEffect(); owner.friction = 1.25;}
	override void DetachFromOwner()
	{if(!owner){return;} owner.friction = 1.0; super.DetachFromOwner();}}

class SupaEgg : ArtiEgg
{Default {Inventory.MaxAmount 32; Inventory.InterHubAmount 8;}
	vector2 stangles; uint eggs, track; override void BeginPlay() 
	{super.BeginPlay(); stangles = (32.0, 64.0); eggs = 7;}
	action void EggTime(uint amount, vector2 cDiv) {vector2 cone;
		for(uint i; i < amount; i++) {cone.x = random2() / cDiv.x;
		cone.y = (random2() / cDiv.y) - invoker.pitch; 
		A_FireProjectile("EggFX", cone.x, false, 0, 0, 0, cone.y);
		invoker.eggs += 5; invoker.stangles *= 0.85; ++invoker.track;}
		if(invoker.track >= 4) {invoker.track = 0; 
				invoker.stangles = (32.0, 64.0); invoker.eggs = 7;}}
	States {Use: TNT1 AAAAA 12 EggTime(invoker.eggs, invoker.stangles); Stop;}
}

//Portable Quad Damage that lasts for 15s
class QuadRing: ArtiInvulnerability 
	{Default{Inventory.Icon "QUADA0"; Powerup.Type "RingQuad";
	Inventory.PickupMessage "$QUADWOW"; Tag "$QUADTAG"; Powerup.Color "Blue";}
	States{Spawn: QUAD ABCD 1; Loop;}}
class RingQuad : PowerDamage {Default {Powerup.Duration -15; DamageFactor "Normal", 4.0;}}

class FoolsGoldShield : BasicArmorPickup
{Default {Armor.SavePercent 66; Armor.SaveAmount 150; +FLOATBOB;
	Inventory.Pickupmessage "$GOLDSHIELDGET"; Inventory.Icon "GOLDA0";}
	States {Spawn: GOLD A -1; Loop;}}

class ProtectorateShield : BasicArmorPickup
{Default {Armor.SavePercent 100; Armor.SaveAmount 300; +FLOATBOB;
	Inventory.Pickupmessage "$COOLSHIELDGET"; Inventory.Icon "PROCA0";}
	States {Spawn: PROC A -1; Loop;}}