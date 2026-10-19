//WOO YEAH QUATERNION BLACK MAGIC: but there's actual magic edition
class BaseHepon : Weapon abstract
{Default {+BLOODSPLATTER; BaseHepon.AttackNames "$W0N1", "$W0N2", "$W0N3", "$W0N4"; 
	BaseHepon.SwapCosts 10, 20, 40, 80;}readonly string s1, s2, s3, s4; 
	property AttackNames: s1, s2, s3, s4; bool confirmLock; uint c1, c2, c3, c4,
	mode, nextMode, confirmDelay; property SwapCosts: c1, c2, c3, c4;
	const HEPON_FLAGS = WRF_ALLOWZOOM|WRF_ALLOWUSER1|WRF_ALLOWUSER2|WRF_ALLOWUSER3|WRF_ALLOWUSER4;
	
	override void PostBeginPlay() {super.PostBeginPlay(); confirmLock = false;}
	
	override void Tick()
	{super.Tick(); if(confirmLock) {if(confirmDelay < 35){confirmDelay++;} 
	else{confirmLock = false;}}  else{confirmDelay = 0;}}

	static vector3 SpOff(double dist, vector2 pitches)
	{double ying = frandom(0., 360.), yang = frandom(pitches.x, pitches.y);
	vector3 vf = dist * ((cos(ying) * cos(yang)),
	(sin(ying) * cos(yang)), (sin(yang))); return vf;}

	static double, double RandomizerCrap(double minnie, double mickey)
	{double temp1, temp2; temp1 = frandom(minnie, mickey);
	temp2 = frandom(minnie, mickey); return temp1, temp2;}
	
	static vector2 Vec2Aim(vector2 vec)
	{vector2 temp; 
		temp.x = frandom(-vec.x, vec.x); temp.y = frandom(-vec.y, vec.y); 
	return temp;}
	
	//pDir: Player Direction, amplitude: Random Devation Mode
	static double, double GimbalUnlocker(quat pDir, vector2 direction,
										bool amplitude = false)
	{	quat 	offy; 	double yin, yan, temppyX, temppyY;
		vector3 up =	(0, 0, 1), forwards =	(1, 0, 0),
				right =	(0, -1, 0), finalDir;
		
		if(amplitude)
		{temppyX = frandom[QuatRand](-direction.x, direction.x);
		temppyY = frandom[QuatRand](-direction.y, direction.y);
		offy = (Quat.AxisAngle(up, temppyX)) * (Quat.AxisAngle(right, temppyY));}
		else {offy = (Quat.AxisAngle(up, direction.x)) * 
					 (Quat.AxisAngle(right, direction.y));}
		
		finalDir = ((pDir * offy) * forwards).Unit();
		yin = atan2(finalDir.y, finalDir.x); 
		yan = -asin(clamp(finalDir.z, -1.0, 1.0)); return yin, yan;}
	
	quat playerAngle; double yin2, yan2; vector3 offThree;
	
	//num follows A_FireBullets convention, hence the signed int
	action void HeponBoolet(int num, uint dam, uint modu = 1, vector2 deviation = (0, 0),
							class<Actor> p = "GoldWandPuff1", bool nomAmmo = false,
							uint ammoNom = 0, bool explicit = false, 
							vector2 offsets = (0, 0))
	{if(nomAmmo && !invoker.DepleteAmmo(invoker.bAltFire, true, ammoNom)) {return;}
		uint iterations = abs(num); if(num == 0) {iterations = 1;}
		double autoPitch = BulletSlope();
		invoker.playerAngle = Quat.FromAngles(angle, autoPitch, roll);
		
		bool firstOne = ((num == 1) && (self.Player.refire == 0)), applyS;
		for(uint i = 0; i < iterations; i++) {int finalDam = dam * random(1, modu);
		applyS = (!firstOne && (num != 0) && !explicit); if(firstOne) {deviation = (0, 0);}
		[invoker.yin2, invoker.yan2] = 
		GimbalUnlocker(invoker.playerAngle, deviation, applyS);
		LineAttack(invoker.yin2, PLAYERMISSILERANGE, invoker.yan2, finalDam,
					'Hitscan', p, 0, null, offsets.y, 0, offsets.x);}
	}
	
	action void HeponBooletFan(int num, uint dam, uint modu = 1, double sp = 12.5,
	double width = 0, class<Actor> p = "GoldWandPuff1", double zOff = 0)
	{uint bNum = abs(num); if(bNum == 0) {bNum = 1;} double ying = -sp,
		step = (sp * 2) / bNum, yang = -width, step2 = (width * 2) / bNum; 
		for(uint i; i < bNum; i++)
		{HeponBoolet(0, dam, modu, (ying, 0), p, false, 0, true, (yang, zOff));
		ying += step; yang += step2;}
	}
	
	bool LimitCheck(uint size, uint limit)
	{if(limit == 0) {return true;} else {return size <= limit;}}
	
	vector3 APUnit(double ang, double pit)
	{vector2 plane = AngleToVector(ang);
		return (plane.x, plane.y, sin(-pit));}

	action void HeponPierce(uint dam = 5, uint limit = 3, double maxDist = 8192, 
	vector2 stangle = (0, 0), vector2 offset = (0, 0), class<actor> pSpawn = "BulletPuff")
	{double budget = maxDist; Array<Actor> monters; FLineTraceData datum;
		vector3 orPos = (pos.x, pos.y, pos.z + player.viewz - pos.z), pomp; 
		bool hit, realHit; double autoPitch = BulletSlope();
		invoker.playerAngle = Quat.FromAngles(angle, autoPitch, roll);
		[invoker.yin2, invoker.yan2] = 
			GimbalUnlocker(invoker.playerAngle, stangle, false);
		vector3 hump = invoker.APUnit(invoker.yin2, invoker.yan2);
		do 
			{realHit = false; hit = LineTrace(invoker.yin2, budget, invoker.yan2, 
                TRF_ABSPOSITION, orPos.z, orPos.x, orPos.y, datum);
			if (datum.HitType == TRACE_HitNone) {break;}
				pomp = datum.HitLocation;
			if(datum.HitType == TRACE_HitWall)
				{vector3 norm = pomp - (hump);
					Spawn(pSpawn, norm); break;} let pointy = datum.HitActor; 
			if(!pointy){break;} if(monters.Find(pointy) == monters.Size() && 
			invoker.LimitCheck(monters.Size(), limit)) 
				{realHit = true; pointy.DamageMobj(self, self, dam, 'Hitscan'); 
					monters.Push(pointy); pointy.SpawnBlood(pomp, angle, dam);
					orPos = pomp + (hump * 2); budget -= datum.Distance;
					Spawn(pSpawn, pomp);}
			else 
				{realHit = true; budget -= datum.Distance; 
					orPos = pomp + (hump * 2);}
		} while(realHit && budget > 0)
	}
	
	action void HeponPBoolet(uint dam = 5, uint num = 1, uint modu = 1,
	uint limit = 3,  double maxDist = 8192, vector2 stangle = (0, 0),
	vector2 offset = (0, 0), bool eat = false, uint ammoEat = 1, 
	bool soundo = true, class<actor> pSpawn = "BulletPuff")
	{if(eat && !invoker.DepleteAmmo(invoker.bAltFire, true, ammoEat)) {return;}
		if(soundo) {A_StartSound(player.ReadyWeapon.AttackSound, CHAN_WEAPON);}
		uint damResult; vector2 aim; for(uint i; i < num; i++)
			{damResult = dam * random(1, modu); aim = Vec2Aim(stangle);
			HeponPierce(dam, limit, maxDist, aim, offset, pSpawn);}
	}
	
	action Actor, Actor HeponProj(class<Actor> flingy, vector2 eulerAng = (0, 0),
	vector2 offsets = (0, 0), bool nomAmmo = false, 
	EFireCustomMissileFlags customFlags = FPF_NOAUTOAIM)
	{Actor misl1, misl2; double tangle, titch;
		invoker.playerAngle = Quat.FromAngles(angle, pitch, roll);
		[invoker.yin2, invoker.yan2] = 
		GimbalUnlocker(invoker.playerAngle, eulerAng, false);
		tangle = DeltaAngle(angle, invoker.yin2);
		titch = DeltaAngle(pitch, invoker.yan2);
		[misl1, misl2] = A_FireProjectile(flingy, tangle, nomAmmo, offsets.x,
										  offsets.y, customFlags, titch);
		if(misl1 && misl2) {return misl1, misl2;} 
		else if (misl2) {return null, misl2;}
		return null, null;}
	
	action void HeponProjFan(class<Actor> flingy, uint amount, double sp = 15.0,
	double width = 0.0, double zOff = 0.0)
	{double ying = -sp, step = (sp * 2) / (amount - 1), 
			yang = -width, step2 = (width * 2) / (amount - 1); for(uint i; i < amount; i++)
		{HeponProj(flingy, (ying, 0), (yang, zOff), false); ying += step; yang += step2;}}
	
	action void HeponRaily(int dam, vector2 an = (0, 0), vector2 off = (0, 0), 
							double ran = 0, color c1 = 0, color c2 = 0, 
							int limit = 0, class<Actor> puffity = "BulletPuff",
							int flags = RGF_EXPLICITANGLE|RGF_FULLBRIGHT|RGF_SILENT,
							double diffy = 0)
	{int finalFlags; invoker.playerAngle = Quat.FromAngles(angle, pitch, roll);
		[invoker.yin2, invoker.yan2] = GimbalUnlocker(invoker.playerAngle, an, false);
		invoker.yin2 -= angle; invoker.yan2 -= pitch;
		A_RailAttack(dam, off.x, false, c1, c2, finalFlags, diffy, puffity,
					invoker.yin2, invoker.yan2, ran, 0, 8.0, 1.0, "", off.y, 
					0, limit);
	}
	
	bool CanBuy(uint cost) {return (uint(owner.CountInv("ManaOrb")) >= cost);}	
	uint WillBuy(uint m)
	{uint r; switch(m)
		{case 0: r = c1; break; case 1: r = c2; break; 
		case 2: r = c3; break; case 3: r = c4; break; 
		default: break;} return r;}
	
	action void PickNextAttack(uint cm, uint nm)
	{if(cm == nm) {A_Print("$CANTSWAP", 1.25); return;}
	invoker.nextMode = nm; string temp = StringTable.Localize("$SELECTED"),
		fName = invoker.GetModeName(nm); uint cTemp = invoker.WillBuy(invoker.nextMode);
		A_Print(String.Format(temp, fName, cTemp), 2.5);
	}
	
	action void ConfirmAttackMode()
	{bool sameMode = invoker.mode == invoker.nextMode;
		//If debug mode's on, skip most of this stuff.
		if(manadebug) {invoker.mode = invoker.nextMode; A_Print("$MANADEBUG");
			A_PlaySound("hepon/swap"); invoker.SetSister(); return;}
		//Normal Logic goeth here.
		if(sameMode) {A_Print("$CANTPICK", 0.75); return;}
		if(invoker.bPowered_Up) {A_Print("$CANTMODE", 0.75); return;}
		int tempVal = invoker.WillBuy(invoker.nextMode); 
		if(!invoker.CanBuy(tempVal)) {A_Print("$BROKEBOI", 0.75); return;}
		if(!invoker.confirmLock) {invoker.confirmLock = true; 
			A_Print("$MANAYOUSURE", 2.5); return;}
		TakeInventory("ManaOrb", tempVal); invoker.mode = invoker.nextMode;
		A_Print("$MANANOREFUNDS"); A_PlaySound("hepon/swap");
		invoker.SetSister();}
	
	void SetSister() {if (!owner) {return;} 
	let pointy = BaseHepon(SisterWeapon); if(pointy) {pointy.mode = mode;}}
	
	string GetModeName(uint m)
	{string r = "$MODEFB"; switch(m)
		{case 0: r = s1; break; case 1: r = s2; break;
		case 2: r = s3; break; case 3: r = s4; break;
		default: Console.Printf("$MODEFB"); break;}
	return StringTable.Localize(r);}
	
	//'chance' being a double allows for better control
	static uint critHandler(double chance, bool isHitscan, uint baseFactor)
	{uint result = 1; double hatValue = frandom(0, 256) - chance;
		if(hatValue > 0) {uint multi = isHitscan? (baseFactor / 2): baseFactor;
		result *= multi;} return result;}
}

// D'Sparil himself is immune to freezing.
// Mostly cause I don't wanna have to fnagle with his stupid Deathstate bullshit.
extend class HereticImp	{mixin FreezeDat;} extend class Mummy 	{mixin FreezeDat;}
extend class Knight 	{mixin FreezeDat;} extend class Clink	{mixin FreezeDat;}
extend class Chicken	{mixin FreezeDat;} extend class Beast	{mixin FreezeDat;}
extend class Wizard		{mixin FreezeDat;} extend class Ironlich {mixin FreezeDat;}
extend class Minotaur	{mixin FreezeDat;}