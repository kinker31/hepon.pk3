class ReplaceThatCrap : EventHandler
{
	//Stolen from wepon.pk3, which was stolen from Kinsie
	static const string oldOnes[] =
		{"GoldWandAmmo", "CrossbowAmmo", "BlasterAmmo", "SkullRodAmmo",
		"PhoenixRodAmmo", "MaceAmmo", "GoldWandHefty", "CrossbowHefty",
		"BlasterHefty", "SkullRodHefty", "PhoenixRodHefty", "MaceHefty", 
		"GoldWand", "Gauntlets", "Crossbow", "Blaster", 
		"SkullRod", "PhoenixRod", "Mace"};
	static const string newOnes[] = 
		{"NewCrystal", "NewArrows", "NewPewPew", "NewRunes",
		"NewBirb", "NewBalls", "JankCrystal", "JankArrows",
		"JankPewPew", "JankRunes", "JankBirb", "JankBalls",
		"Elfwand", "FapHands", "ArrowdTheWeapon", "TastersChoice",
		"SpookyStaff", "TweetTweet", "Maceception"};
	
	void RepoLog(ReplaceEvent a, class<actor> thingOne, class<actor> thingTwo, uint thresh, bool thingOn)
	{if(!thingOn){return;}
		bool temp = (uint(random[HandlerRNG](0, 255)) < thresh);
		if(a.Replacee == thingOne && temp)
		{a.Replacement = thingTwo;}}
	
	void TimebombLog(ReplaceEvent a)
	{if(!exitem || a.Replacee != "SupaTimebomb") {return;}
		uint goRando = random(0, 256);
		if(goRando >= 224) {a.Replacement = "ClusterTime";}
		else if(goRando >= 192) {a.Replacement = "BouncyBomb";}
		else if(goRando >= 160) {a.Replacement = "TimeMine";}}
	
	override void CheckReplacement(ReplaceEvent e)
	{
		for(uint i = 0; i < oldOnes.size(); i++)
		{if(e.Replacee == oldOnes[i]) {e.Replacement = newOnes[i];}}
		RepoLog(e, "ArtiTimeBomb", "SupaTimebomb", 256, exitem); TimebombLog(e);
		RepoLog(e, "SilverShield", "FoolsGoldShield", 38, armors);
		RepoLog(e, "EnchantedShield", "ProtectorateShield", 18, armors);
		RepoLog(e, "ArtiHealth", "ArtiHealth2", 64, exitem);
		RepoLog(e, "ArtiHealth2", "ArtiHealth3", 32, exitem);
		RepoLog(e, "ArtiTomeOfPower", "CursedTome", 64, exitem);
		RepoLog(e, "CursedTome", "SuperTome", 48, exitem);
		RepoLog(e, "ArtiInvulnerability", "QuadRing", 16, exitem);
		RepoLog(e, "ArtiInvisibility", "SlipSphere", 48, exitem);
		RepoLog(e, "ArtiEgg", "SupaEgg", 256, exitem);
	}
}

class DroppyOrb : EventHandler
{
	vector3 WorlVel(double factor)
	{double temp1 = frandom[HandlerRNG](-factor, factor),
			temp2 = frandom[HandlerRNG](-factor, factor),
			tempZ = frandom(4.5, 9.0);
		return (temp1, temp2, tempZ);}
	
	vector3 WorlPos(vector3 origin, double zz, double rad = 4.0)
	{vector3 result; double h = zz / 2; vector2 temp;
		temp = (frandom(-rad, rad), frandom(-rad, rad));
		result = (origin.x + temp.x, origin.y + temp.y, origin.z + h);
	return result;}
	
	void ManaSyst(WorldEvent e)
	{vector3 pos = e.Thing.pos; bool highHealth; int dec; vector3 v; 
	int amount = e.thing.getMaxHealth();
	while(amount > 0) {highHealth = (amount >= 150);
		dec = highHealth? 150 : 25; if(e.thing.bBoss) {dec *= 2;}
		class<Actor> ac = highHealth? "HeftyOrb": "ManaOrb";
		v = WorlPos(e.thing.pos, e.thing.height, 6.0);
		let s = Actor.Spawn(ac, v, NO_REPLACE); if(s) 
		{s.vel = WorlVel(3.33);;} amount -= dec;}}
	
	override void WorldThingDied(WorldEvent e)
	{if(!e.thing.bISMONSTER) {return;} if(manasystem) {ManaSyst(e);}}
}
