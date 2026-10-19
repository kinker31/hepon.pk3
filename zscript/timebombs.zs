//Inventory Definitions
class SupaTimebomb : ArtiTimebomb
{Default {Inventory.MaxAmount 40; Inventory.InterHubAmount 20; Tag "$SUPATIME"; 
		SupaTimebomb.SpawnThingy "SactBomb"; Inventory.PickupMessage "$SUPATIME";
		Inventory.Icon "FBMBE0"; SupaTimebomb.StartWith (24.0, 64.0);}
	class<actor> ap; vector2 inVal; property SpawnThingy: ap; 
	property StartWith: inVal;

	vector3 GetPos(double ds)
	{vector3 temp; double a = Owner.angle, b = Owner.Floorclip;
		temp = Owner.Vec3Angle(ds, a, b); return temp;}
	
	bool DothSpawn(double dist, double vel)
	{actor temp = Spawn(ap, GetPos(dist), ALLOW_REPLACE);
		if(temp == null) {return false;} temp.target = owner;
		temp.angle = owner.angle; temp.VelFromAngle(); return true;}
	
	override bool Use(bool pickup) {return DothSpawn(inVal.x, inVal.y);}
	States {Spawn: FBMB E 350; Loop;}
}

class TimeMine : SupaTimebomb
{Default {Inventory.MaxAmount 36; Inventory.InterHubAmount 18;
		SupaTimebomb.SpawnThingy "SactMine"; Tag "$SUPAMINE";
		Inventory.PickupMessage "$SUPAMINE"; Inventory.Icon "BOMB2";
		SupaTimebomb.StartWith (26.0, 48.0); Translation "Bomb2";}
}

class BouncyBomb : SupaTimebomb
{Default {Inventory.MaxAmount 16; Inventory.InterHubAmount 8;
		SupaTimebomb.SpawnThingy "SactBouncy"; Tag "$SUPABOUNCE";
		Inventory.PickupMessage "$SUPABOUNCE"; Inventory.Icon "BOMB3";
		SupaTimebomb.StartWith (16.0, 72.0); Translation "Bomb3";}
}

class ClusterTime : SupaTimebomb
{Default {Inventory.MaxAmount 8; Inventory.InterHubAmount 2;
		SupaTimebomb.SpawnThingy "SactCluster"; Tag "$SUPACLUST";
		Inventory.PickupMessage "$SUPACLUST"; Inventory.Icon "BOMB4";
		SupaTimebomb.StartWith (24.0, 32.0); Translation "Bomb4";}
	const vMax = 7.5;

	bool SpawnDem(uint amount) {bool tempio; actor apple; double ying;
		for(uint i; i < amount; i++) {ying = owner.angle + frandom(-vMax, vMax);
		apple = Spawn(ap, GetPos(inVal.y), ALLOW_REPLACE);
		if(apple == null){return false;} apple.target = owner;
		apple.angle = ying; apple.VelFromAngle();} tempio = true; return tempio;}
	
	override bool Use(bool pickup) {return SpawnDem(7);}
}

//Explosive Definitions [S]upa-[Act]ive [Timebomb]
class SactBomb : ActivatedTimeBomb
{Default {SactBomb.SlowFactor 0.95; Speed 48.0; SactBomb.BombLifetime 140;
	+MISSILE; SactBomb.BombVals 128, 96.0;} 
	property SlowFactor: slow; double slow, radio; uint maxAge, dambo, age;
	property BombLifetime: maxAge; property BombVals: dambo, radio;
	const EXFLAGS = XF_HURTSOURCE|XF_NOSPLASH|XF_THRUSTLESS|XF_CIRCULAR;
	
	override void Tick() {if (self.vel.length() ~== 0) {self.vel = (0, 0, 0);}
	else {self.vel *= slow;} age++; super.Tick();}
	
	void AgeKrupp() {if(age > maxAge) {SetState(ResolveState("Death"));}}
	action void Explodey(uint dam, double rad)
	{double ying = rad / 2;
		AddZ(32.0, false); A_SetRenderStyle(0.85, STYLE_Translucent);
		A_Explode(dam, rad, EXFLAGS, false, ying);}
	
	States
	{Spawn:	FBMB ABCDEDCB 4 AgeKrupp(); Loop;
	Death:	FBMB E 4 Bright A_Scream();
			XPL1 A 3 Bright Explodey(invoker.dambo, invoker.radio);
			XPL1 BCDEF 2 Bright; Stop;}
}

class SactMine : SactBomb
{Default {SactBomb.SlowFactor 0.85; Speed 32.0; SactBomb.BombLifetime 1400; 
	SactBomb.BombVals 160, 72.0; Translation "Bomb2";}
}

class SactBouncy : SactBomb
{Default {SactBomb.SlowFactor 0.995; Speed 52.0; SactBomb.BombLifetime 666;
	+BOUNCEONWALLS; SactBomb.BombVals 48, 32.0; WallBounceFactor 1.05; 
	BounceCount 24; Translation "Bomb3"; +USEBOUNCESTATE;}
	void Boink() {A_PlaySound("weapons/macebounce", CHAN_AUTO); 
				dambo += 8; radio += 8.0; scale.x += 0.125; scale.y = 0.125;}
	States {Bounce:	TNT1 A 0 Boink(); Goto Spawn;}
}

class SactCluster : SactBomb
{Default {SactBomb.SlowFactor 0.90; Speed 96.0; SactBomb.BombLifetime 90;
		SactBomb.BombVals 96, 144.0; Translation "Bomb4";}
}
