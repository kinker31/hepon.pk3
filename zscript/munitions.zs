class NewCrystal : Ammo
{ Default 
	{Inventory.Amount 8; Inventory.MaxAmount 200; Ammo.BackpackAmount 16;
	Ammo.BackpackMaxAmount 500; Inventory.Icon "INAMGLD"; 
	Inventory.PickupMessage "$TXT_AMMOGOLDWAND1";}
	States {Spawn: AMG1 A -1 Bright; Stop;}
}
class JankCrystal : NewCrystal
{Default {Inventory.Amount 32; Inventory.PickupMessage "$TXT_AMMOGOLDWAND2";} 
	States {Spawn: AMG2 A -1 Bright; Stop; }}

class NewArrows : Ammo
{Default {Inventory.Amount 4; Inventory.MaxAmount 64; Ammo.BackpackAmount 8; 
	Ammo.BackpackMaxAmount 160; Inventory.Icon "INAMBOW"; 
	Inventory.PickupMessage "$TXT_AMMOCROSSBOW1";}
	States {Spawn: AMC1 A -1 Bright; Stop;}
}
class JankArrows : NewArrows
	{Default {Inventory.Amount 16; Inventory.PickupMessage "$TXT_AMMOCROSSBOW2";} 
	States { Spawn: AMC2 A -1 Bright; Stop; }}

class NewPewPew : Ammo
{ Default {Inventory.Amount 20; Inventory.MaxAmount 320; Ammo.BackpackAmount 40;
	Ammo.BackpackMaxAmount 800; Inventory.Icon "INAMBST";
	Inventory.PickupMessage "$TXT_AMMOBLASTER1";}
	States {Spawn: AMB1 ABC 2 Bright; Loop;}
}
class JankPewPew : NewPewPew 
	{Default {Inventory.Amount 80; Inventory.PickupMessage "$TXT_AMMOBLASTER2";}
	States { Spawn: AMB2 ABC 2 Bright; Loop; }}

class NewRunes : Ammo
{ Default {Inventory.Amount 15; Inventory.MaxAmount 250; Ammo.BackpackAmount 30;
	Ammo.BackpackMaxAmount 666; Inventory.Icon "INAMRAM";
	Inventory.PickupMessage "$TXT_AMMOSKULLROD1";}
	States { Spawn: AMS1 AB 3 Bright; Loop; }
}
class JankRunes : NewRunes
	{Default {Inventory.Amount 60; Inventory.PickupMessage "$TXT_AMMOSKULLROD2";}
	States { Spawn: AMS2 AB 3 Bright; Loop; }}

class NewBirb : Ammo
{ Default 
	{Inventory.Amount 1; Inventory.MaxAmount 32; Ammo.BackpackAmount 2;
	Ammo.BackpackMaxAmount 80; Inventory.Icon "INAMPNX";
	Inventory.PickupMessage "$TXT_AMMOPHOENIXROD1";}
	States { Spawn: AMP1 ABC 2 Bright; Loop; }
}
class JankBirb : NewBirb
{Default {Inventory.Amount 4; Inventory.PickupMessage "$TXT_AMMOPHOENIXROD2";}
	States { Spawn: AMP2 ABC 2 Bright; Loop; }}

class NewBalls : Ammo
{ Default 
	{Inventory.Amount 6; Inventory.MaxAmount 128; Ammo.BackpackAmount 12;
	Ammo.BackpackMaxAmount 320; Inventory.Icon "INAMLOB"; 
	Inventory.PickupMessage "$TXT_AMMOMACE1";}
	States { Spawn: AMM1 A -1; Stop; }
}
class JankBalls : NewBalls 
{Default {Inventory.Amount 18; Inventory.PickupMessage "$TXT_AMMOMACE2";} 
	States {Spawn: AMM2 A -1; Stop;}}
