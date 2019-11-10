if SERVER then
	resource.AddFile("materials/vgui/ttt/icon_bbylauncher.vmt")
	resource.AddFile("sound/baby_amused.wav")
end

SWEP.PrintName = "Baby Launcher"
SWEP.Author	= "Original by Viveret, modified by Menof36go"
SWEP.Instructions = "Left mouse to fire a bby!"
SWEP.Category = "TTT"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_EQUIP1
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.InLoadoutFor = nil
SWEP.LimitedStock = true
SWEP.EquipMenuData = {
   type = "item_weapon",
   desc = "Throw a baby at another baby"
};
SWEP.AllowDrop = true
SWEP.IsSilent = false
SWEP.NoSights = false
SWEP.AutoSpawnable = false
SWEP.HoldType = "pistol"
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Weight	= 7
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/weapons/v_pist_deagle.mdl"
SWEP.WorldModel	= "models/weapons/w_pist_deagle.mdl"
SWEP.Icon = "vgui/ttt/icon_bbylauncher"

local ShootSound = Sound("baby_amused.wav")

function SWEP:PrimaryAttack()
	if (CLIENT) then 
		return 
	end

	self:EmitSound(ShootSound) 

	local ent = ents.Create("prop_physics")
	if (!IsValid(ent)) then 
		return 
	end
	ent:SetModel("models/props_c17/doll01.mdl")
 	util.SpriteTrail(ent, 0, Color(255,69,184), false, 15, 1, 4, 1/(15+1)*0.5, "trails/plasma.vmt")

	ent:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 16))
	ent:SetAngles(self.Owner:EyeAngles())
	ent.Attacker64 = self.Owner:SteamID64()
	ent.SWEP = self
	ent.SWEPClass = "bbylauncher"
	ent:Spawn()

	local phys = ent:GetPhysicsObject()
	if !IsValid(phys) then 
		ent:Remove() 
		return 
	end
	phys:SetMass(200)
	local velocity = self.Owner:GetAimVector()
	velocity = velocity * 500000
	phys:ApplyForceCenter(velocity)

	if self.Owner:GetAmmoCount(self.Primary.Ammo) < 1 then
		self.Owner:DropWeapon(self)
		self:Remove() 
		return false
	end
end

local bbyRef = nil

local function BBYGetDmg(ent,dmginfo)
	if (ent:GetClass() ~= "player") then
		return
	end

	local inflictor = dmginfo:GetInflictor()

	if !inflictor.SWEPClass then
		return
	end
	if !inflictor.SWEPClass == "bbylauncher" then
		return
	end

	-- We need to set the attacker since the damage is prop damage and will otherwhise be recognized as world damage.
	if inflictor.Attacker64 ~= nil then
		local owner = player.GetBySteamID64(inflictor.Attacker64)
		if owner then
			dmginfo:SetAttacker(owner)
		end
	end

	-- We use the proper inflictor in case that the swep which shot the baby was removed. If it was we create a dummy swep so it shows up correctly when identifying the corpse.
	local properInflictor = nil
	if IsValid(inflictor.SWEP) then
		properInflictor = inflictor.SWEP
	else
		bbyRef = IsValid(bbyRef) and bbyRef or ents.Create("bbylauncher")
		properInflictor = bbyRef
	end
	dmginfo:SetInflictor(properInflictor)
end
hook.Add("EntityTakeDamage", "BBYSetupDamage", BBYGetDmg)