DungeonMarker = LibStub("AceAddon-3.0"):NewAddon("DungeonMarker", "AceConsole-3.0", "AceEvent-3.0")

local debug = false

local AvailableMarkers = {
  -- Yellow 4-point Star
  {
    guid= nil,
    unit = nil,
    icon = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:0|t",
  },
  -- Orange Circle
  {
    guid= nil,
    unit = nil,
    icon = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:0|t",
  },
  -- Purple Diamond
  {
    guid= nil,
    unit = nil,
    icon = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:0|t",
  },
  -- Green Triangle
  {
    guid= nil,
    unit = nil,
    icon = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:0|t",
  },
  -- White Crescent Moon
  {
    guid= nil,
    unit = nil,
    icon = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:0|t",
  },
  -- Blue Square
  {
    guid= nil,
    unit = nil,
    icon = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:0|t",
  },
  -- Red "X" Cross
  {
    guid= nil,
    unit = nil,
    icon = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:0|t",
  },
  -- White Skull
  {
    guid= nil,
    unit = nil,
    icon = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0|t",
  },
}

local TrackedSpells = {
  -- The Necrotic Wake
  [320462] = true, -- Necrotic Bolt (absorb) (high)
  [324293] = true, -- Rasping Scream (displacement) (high)

  [323190] = true, -- Meat Shield (absorb) (high)
  [327130] = true, -- Repair Flesh (heal) (high)
  [320822] = true, -- Final Bargain (heal) (high)
  [335143] = true, -- Bonemend (heal) (high)
  [321807] = true, -- Boneflay (dot) (medium)

  -- Surgeon Stitchflesh
  [338353] = true, -- Goresplatter (AOE damage) (high)
  [334748] = true, -- Drain Fluids (ST damage) (high)

  -- Plaguefall
  [319070] = true, -- Corrosive Gunk (AOE damage) (high)
  [329239] = true, -- Creepy Crawlers (adds) (high)
  [336451] = true, -- Bulwark of Maldraxxus (absorb) (high)
  [328016] = true, -- Wonder Grow (buff) (medium)

  -- Mists of Tirna Scithe
  [324914] = true, -- Nourish the Forest (heal) (high)
  [324776] = true, -- Bramblethorn Coat (absorb) (high)
  [326046] = true, -- Stimulate Resistance (absorb) (high)
  [340544] = true, -- Stimulate Regeneration (heal) (high)

  -- Mistcaller
  [321828] = true, -- Patty Cake (displacement) (high)

  -- Ingra Maloch
  [322938] = true, -- Harvest Essence (heal) (high)

  -- Tred'ova
  [337235] = true, -- Parasitic Pacification (displacement) (high)
  [337251] = true, -- Parasitic Incapacitation (displacement) (high)
  [337253] = true, -- Parasitic Domination (displacement) (high)
  [322450] = true, -- Consumption (AOE damage) (high)

  -- Halls of Atonement
  [325700] = true, -- Collect Sins (adds) (high)
  [325701] = true, -- Siphon Life (heal) (high)
  [326607] = true, -- Turn to Stone (displacement) (high)
  [325876] = true, -- Curse of Obliteration
  [326450] = true, -- Loyal Beasts (buff)

  -- High Adjudicator Aleez Boss
  [323552] = true, -- Volley of Power (AOE damage) (high)

  -- Theater of Pain
  [341902] = true, -- Unholy Fervor (heal) (high)
  [341969] = true, -- Withering Discharge (AOE damage) (high)
  [330868] = true, -- Necrotic Bolt Volley (AOE damage) (high)
  [330562] = true, -- Demoralizing Shout (buff) (high)
  [341977] = true, -- Meat Shield (absorb) (high)
  [330586] = true, -- Devour Flesh (heal) (high) (stun)
  [342675] = true, -- Bone Spear (ST damage) (medium)

  -- Xav the Unfallen
  [342139] = true, -- Battle Trance (buff) (high)

  -- De Other Side
  [332612] = true, -- Healing Wave (heal) (high)
  [332666] = true, -- Renew (heal) (high)
  [332706] = true, -- Heal (heal) (high)
  [332084] = true, -- Self-Cleaning Cycle (heal) (high)

  [332608] = true, -- Lightning Discharge (AOE damage) (medium)
  [332605] = true, -- Hex (displacement) (medium)
  [332196] = true, -- Discharge (ST damage) (low)

  -- Spires of Ascension
  [328295] = true, -- Greater Mending (heal) (high)
  [317936] = true, -- Forsworn Doctrine (heal) (high)
  [327413] = true, -- Rebellious Fist (AOE damage) (high)
  [317963] = true, -- Burden of Knowledge (ST damage) (medium)
  [327648] = true, -- Internal Strife (AOE damage) (medium)
  [328331] = true, -- Forced Confession (AOE damage) (medium)

  -- Sanguine Depths
  [322433] = true, -- Stoneskin (buff) (high)
  [321038] = true, -- Wrack Soul (ST damage) (high)
  [326836] = true, -- Curse of Suppression (silence) (high)
  [336277] = true, -- Explosive Anger (AOE damage) (high)
  [326837] = true, -- Gloom Burst (ST damage) (low)

  -- Kryxis
  [319654] = true, -- Hungering Drain (buff) (high)
}

function DungeonMarker:OnInitialize()
  self:RegisterEvent("UNIT_SPELLCAST_START", "CheckMarker")
  self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "CheckMarker")
  self:RegisterEvent("UNIT_SPELLCAST_FAILED", "CheckMarker")
  self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", "CheckMarker")
end

function DungeonMarker:GetFreeMarker(castGUID, unitTarget)
  for index, marker in pairs(AvailableMarkers) do
    if marker.guid == nil then
      marker.guid = castGUID
      marker.target = unitTarget
      return index
    end
  end

  return nil
end

function DungeonMarker:ShouldMarkerBeApplied(unitTarget, castGUID)
  if GetRaidTargetIndex(unitTarget) ~= nil then return false end

  for _, marker in pairs(AvailableMarkers) do
    if marker.guid == castGUID then
      return false
    end
  end
  return true
  end

function DungeonMarker:ApplyMarker(unitTarget, castGUID, spellID)
  -- Events are triggered multiple times for the same cast but different unitTargets
  if self:ShouldMarkerBeApplied(unitTarget, castGUID) then
    local markerId = self:GetFreeMarker(castGUID, unitTarget)
    local marker = AvailableMarkers[markerId]
    local name, _, icon = GetSpellInfo(spellID)
    local unitName = GetUnitName(unitTarget)

    if debug then self:Print("Adding " .. marker.icon .. " to " .. unitName .. " casting |T" .. icon .. ":0|t " .. name) end
    SetRaidTarget(unitTarget, markerId)
  end
end

function DungeonMarker:RemoveMarker(unitTarget, castGUID)
  for _, marker in pairs(AvailableMarkers) do
    if marker.guid == castGUID then
      marker.guid = nil
      marker.target = nil
      SetRaidTarget(unitTarget, 0)
    end
  end
end

function DungeonMarker:CheckMarker(event, unitTarget, castGUID, spellID)
  if TrackedSpells[spellID] then
    if event == "UNIT_SPELLCAST_START" then
      self:ApplyMarker(unitTarget, castGUID, spellID)
    else
      self:RemoveMarker(unitTarget, castGUID)
    end
  end
end
