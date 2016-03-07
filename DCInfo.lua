LoadAddOn("Blizzard_InspectUI");
LoadAddOn("LibItemUpgradeInfo-1.0");
local FontStrings = {};
local InspectFontStrings = {};
local ActiveFontStrings = {};
local Icons = {};
local InspectIcons = {};
local ActiveIcons = {};
local InspectAilvl;
local EnchantIcons = {};
local InspectEnchantIcons = {};
local ActiveEnchantIcons = {};
local ItemUpgradeInfo = LibStub("LibItemUpgradeInfo-1.0");
local ilvlFrame = CreateFrame("frame");
local iconSize = 16;
local iconOffset = 18;
local fontStyle = "SystemFont_Med1";
local UpdateInProgress = false;
local UpdateInProgressInspect = false;
ILvlTotal = CharacterFrame:CreateFontString("DCFrame_20", "OVERLAY", fontStyle);
ilvlFrame:RegisterEvent("VARIABLES_LOADED");

local OPvP = {"Interface/PVPFrame/UI-CHARACTER-PVP-ELEMENTS",460/512,1,0,75/512}

--Layout Helpers
local slotID = {1,2,3,15,5,4,18,9,10,6,7,8,11,12,13,14,16,17} ;

local InvSlotID = { 1,2,3,6,5,10,11,12,8,9,13,14,15,16,4,17,18,7 };

local slotAlign1 = {"TOPLEFT","TOPLEFT","TOPLEFT","TOPLEFT","TOPLEFT","TOPLEFT","TOPLEFT","TOPLEFT",
			"TOPRIGHT","TOPRIGHT","TOPRIGHT","TOPRIGHT","TOPRIGHT","TOPRIGHT","TOPRIGHT","TOPRIGHT",
			"TOPRIGHT","TOPLEFT" }
local slotAlign2 = {"TOPRIGHT","TOPRIGHT","TOPRIGHT","TOPRIGHT","TOPRIGHT","TOPRIGHT","TOPRIGHT","TOPRIGHT",
			"TOPLEFT","TOPLEFT","TOPLEFT","TOPLEFT","TOPLEFT","TOPLEFT","TOPLEFT","TOPLEFT",
			"TOPLEFT","TOPRIGHT" }
local slotOffsetx = { 10, 10, 10, 10, 10, 10, 10, 10, 
			-10, -10, -10, -10, -10, -10, -10, -10, 
			-7, 7 } ;

local slotOffsety = { -5, -5, -5, -5, -5, -5, -5, 2, 
			-5, -5, -5, -5, -5, -5, -5, 2, 
			0, 0 } ;
			
local iconAlign1 = {"TOPLEFT","TOPLEFT","TOPLEFT","TOPLEFT","TOPLEFT","TOPLEFT","TOPLEFT","TOPLEFT",
			"TOPRIGHT","TOPRIGHT","TOPRIGHT","TOPRIGHT","TOPRIGHT","TOPRIGHT","TOPRIGHT","TOPRIGHT",
			"BOTTOMRIGHT","BOTTOMLEFT" }
local iconAlign2 = {	"BOTTOMLEFT","BOTTOMLEFT","BOTTOMLEFT","BOTTOMLEFT","BOTTOMLEFT","BOTTOMLEFT","BOTTOMLEFT","BOTTOMLEFT",
			"BOTTOMRIGHT","BOTTOMRIGHT","BOTTOMRIGHT","BOTTOMRIGHT","BOTTOMRIGHT","BOTTOMRIGHT","BOTTOMRIGHT","BOTTOMRIGHT",
			"TOPRIGHT","TOPLEFT" }
local iconOffsetx = { iconOffset, iconOffset, iconOffset, iconOffset, iconOffset, iconOffset, iconOffset, iconOffset, 
			-iconOffset, -iconOffset, -iconOffset, -iconOffset, -iconOffset, -iconOffset, -iconOffset, -iconOffset, 
			-iconOffset, iconOffset } ;

local iconOffsety = { -2, -2, -2, -2, -2, -2, -2, -2, 
			 -2, -2, -2, -2, -2, -2, -2, -2,  
			2, 2 } ;

-- Globals
DC_UpdateInterval = 1.0;
DCItemLevel_variablesLoaded = false;
DCItemLevel_details = {
	name = "DCItemLevel",
	frame = "ilvlFrame",
	optionsframe = "DCItemLevelConfigFrame"
	};

local DCItemLevelConfig_defaultOn = true;
local DCItemLevelConfig_defaultUpgrades = true;
local DCItemLevelConfig_defaultCharacter = true;
local DCItemLevelConfig_defaultInspection = true;
local DCItemLevelConfig_defaultColor = true;
local DCItemLevelConfig_defaultSmall = false;
local DCItemLevelConfig_defaultPVP = true;

local emptySockets = { ["Meta "]    = "INTERFACE/ITEMSOCKETINGFRAME/UI-EmptySocket-Meta",
                      ["Red "]     = "INTERFACE/ITEMSOCKETINGFRAME/UI-EmptySocket-Red",
                      ["Blue "]    = "INTERFACE/ITEMSOCKETINGFRAME/UI-EmptySocket-Blue",
					  ["Yellow "]  = "INTERFACE/ITEMSOCKETINGFRAME/UI-EmptySocket-Yellow",
					  ["Prismatic "]  = "INTERFACE/ITEMSOCKETINGFRAME/UI-EmptySocket-Prismatic",
                    } ;
--	lvl 100
local enchantableItems={ [ 1  ] = nil,
						[ 2  ] = true,
						[ 3  ] = nil,
						[ 15 ] = true,
						[ 5  ] = nil,
						[ 9  ] = nil,
						[ 10 ] = nil,
						[ 6  ] = nil,
						[ 7  ] = nil,
						[ 8  ] = nil,
						[ 11 ] = true,
						[ 12 ] = true,
						[ 13 ] = nil,
						[ 14 ] = nil,
						[ 16 ] = true,
						[ 17 ] = true };
						
local enchantableItems90={ [ 1  ] = nil,
						[ 2  ] = nil,
						[ 3  ] = true,
						[ 15 ] = true,
						[ 5  ] = true,
						[ 9  ] = true,
						[ 10 ] = true,
						[ 6  ] = nil,
						[ 7  ] = true,
						[ 8  ] = true,
						[ 11 ] = nil,
						[ 12 ] = nil,
						[ 13 ] = nil,
						[ 14 ] = nil,
						[ 16 ] = true,
						[ 17 ] = true };

function DCItemLevel_OnLoad()
	
	
end

function DC_OnShow(self,...)
	if(DCItemLevel_variablesLoaded)then
		if(DCItemLevelConfig.Character) then
			UpdateInProgress = true;
			updatePlayer();
		end
	end
end

function updatePlayer()
	if (DCItemLevelConfig.Character) then
		findItemInfo("player");
	end
end

function updateInspect()
	findItemInfo(InspectFrame.unit);
end

function DC_OnUpdate(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
	
	if(self.TimeSinceLastUpdate > DC_UpdateInterval) then
		if not(UnitAffectingCombat("player")) then
			findItemInfo("player");
			print("Update");
		else
			print("In Combat");
		end
		self.TimeSinceLastUpdate = 0;
	end
	
end

local waitTable = {};
local waitFrame = nil;

function DC_wait(delay, func, ...)
  if(type(delay)~="number" or type(func)~="function") then
    return false;
  end
  if(waitFrame == nil) then
    waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
    waitFrame:SetScript("onUpdate",function (self,elapse)
      local count = #waitTable;
      local i = 1;
      while(i<=count) do
        local waitRecord = tremove(waitTable,i);
        local d = tremove(waitRecord,1);
        local f = tremove(waitRecord,1);
        local p = tremove(waitRecord,1);
        if(d>elapse) then
          tinsert(waitTable,i,{d-elapse,f,p});
          i = i + 1;
        else
          count = count - 1;
          f(unpack(p));
        end
      end
    end);
  end
  tinsert(waitTable,{delay,func,{...}});
  return true;
end

function eventHandler(self,event,...)
	--print(UnitGroupRolesAssigned("target"));
	
	
	if(DCItemLevelConfig.on)then
		if (event == "INSPECT_READY" and DCItemLevelConfig.Inspection) then
			if(InspectFrame.unit)then
				if(UpdateInProgressInspect == false) then
					C_Timer.After(0.5,updateInspect);
					C_Timer.After(1.5,updateInspect);
					C_Timer.After(3,updateInspect);
					C_Timer.After(5,updateInspect);
					C_Timer.After(8,updateInspect);
					UpdateInProgressInspect = true;
				end
			end
		elseif(DCItemLevelConfig.Character) then
			
			if(UpdateInProgress == false) then
				UpdateInProgress = true;
				C_Timer.After(0.2,updatePlayer);
			
			end
		end
	end
end

--Register Event Handler
function setupEventHandler(self,event,...)
	if (event == "VARIABLES_LOADED") then
		DCItemLevelFrame_VARIABLES_LOADED();
		ilvlFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
		ilvlFrame:RegisterEvent("SOCKET_INFO_CLOSE");
		ilvlFrame:RegisterEvent("SOCKET_INFO_SUCCESS");
		ilvlFrame:RegisterEvent("SOCKET_INFO_UPDATE");
		ilvlFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
		ilvlFrame:RegisterEvent("INSPECT_READY");
		ilvlFrame:SetScript("OnEvent",eventHandler);
		DCFrame:SetScript("OnShow",DC_OnShow);
		if(DCItemLevelConfig.Character)then
			C_Timer.After(0.2,updatePlayer);
		end
	end
end
ilvlFrame:SetScript("OnEvent",setupEventHandler);

--Create Config Panel
function DCItemLevelFrame_VARIABLES_LOADED()
	if(DCItemLevel_variablesLoaded)then
		return;
	end
	DCItemLevel_variablesLoaded = true;
	if (DCItemLevelConfig == nil) then
		DCItemLevelConfig = {};
	end
	
	if (DCItemLevelConfig.on == nil) then
		DCItemLevelConfig.on = DCItemLevelConfig_defaultOn;
	end
	if (DCItemLevelConfig.upgrades == nil) then
		DCItemLevelConfig.upgrades = DCItemLevelConfig_defaultUpgrades;
	end
	if (DCItemLevelConfig.Character == nil) then
		DCItemLevelConfig.Character = DCItemLevelConfig_defaultCharacter;
	end
	if (DCItemLevelConfig.Inspection == nil) then
		DCItemLevelConfig.Inspection = DCItemLevelConfig_defaultInspection;
	end
	if (DCItemLevelConfig.Color == nil) then
		DCItemLevelConfig.Color = DCItemLevelConfig_defaultColor;
	end
	if (DCItemLevelConfig.Small == nil) then
		DCItemLevelConfig.Small = DCItemLevelConfig_defaultSmall;
	end
	if (DCItemLevelConfig.PVP == nil) then
		DCItemLevelConfig.PVP = DCItemLevelConfig_defaultPVP;
	end
	
	local ConfigPanel = CreateFrame("Frame", "DCItemLevelConfigPanel", UIParent);
	ConfigPanel.name = "DC Item Level";
	
	local b = CreateFrame("CheckButton","Enabled",ConfigPanel,"UICheckButtonTemplate");
	b:SetPoint("TOPLEFT",ConfigPanel,"TOPLEFT",15,-15);
	b:SetChecked(DCItemLevelConfig.on);
	_G[b:GetName() .. "Text"]:SetText("Enable Dc Item Level");
	b:SetScript("OnClick", function(self, button, isDown) if ( self:GetChecked() ) then DCItemLevelConfig.on = true; cleanUp(); else DCItemLevelConfig.on = false; cleanUp(); end end)
	
	local b1 = CreateFrame("CheckButton","Upgrades",ConfigPanel,"UICheckButtonTemplate");
	b1:SetPoint("TOPLEFT",b,"BOTTOMLEFT",0,0);
	b1:SetChecked(DCItemLevelConfig.upgrades);
	_G[b1:GetName() .. "Text"]:SetText("Show upgrades, e.g. (2/2)");
	b1:SetScript("OnClick", function(self, button, isDown) if ( self:GetChecked() ) then DCItemLevelConfig.upgrades = true; cleanUp(); else DCItemLevelConfig.upgrades = false; cleanUp(); end end)
	
	local b2 = CreateFrame("CheckButton","Char",ConfigPanel,"UICheckButtonTemplate");
	b2:SetPoint("TOPLEFT",b1,"BOTTOMLEFT",0,0);
	b2:SetChecked(DCItemLevelConfig.Character);
	_G[b2:GetName() .. "Text"]:SetText("Show on Character Sheet");
	b2:SetScript("OnClick", function(self, button, isDown) if ( self:GetChecked() ) then DCItemLevelConfig.Character = true; cleanUp(); else DCItemLevelConfig.Character = false; cleanUp(); end end)
	
	local b3 = CreateFrame("CheckButton","Insp",ConfigPanel,"UICheckButtonTemplate");
	b3:SetPoint("TOPLEFT",b2,"BOTTOMLEFT",0,0);
	b3:SetChecked(DCItemLevelConfig.Inspection);
	_G[b3:GetName() .. "Text"]:SetText("Show on Inspection Frame");
	b3:SetScript("OnClick", function(self, button, isDown) if ( self:GetChecked() ) then DCItemLevelConfig.Inspection = true; cleanUp(); else DCItemLevelConfig.Inspection = false; cleanUp(); end end)
	
	local b4 = CreateFrame("CheckButton","Small",ConfigPanel,"UICheckButtonTemplate");
	b4:SetPoint("TOPLEFT",b3,"BOTTOMLEFT",0,0);
	b4:SetChecked(DCItemLevelConfig.Small);
	_G[b4:GetName() .. "Text"]:SetText("Smaller ilvl text (requires reload)");
	b4:SetScript("OnClick", function(self, button, isDown) if ( self:GetChecked() ) then DCItemLevelConfig.Small = true; cleanUp(); else DCItemLevelConfig.Small = false; cleanUp(); end end)
	
	local b5 = CreateFrame("CheckButton","Color",ConfigPanel,"UICheckButtonTemplate");
	b5:SetPoint("TOPLEFT",b4,"BOTTOMLEFT",0,0);
	b5:SetChecked(DCItemLevelConfig.Small);
	_G[b5:GetName() .. "Text"]:SetText("Color ilvl text");
	b5:SetScript("OnClick", function(self, button, isDown) if ( self:GetChecked() ) then DCItemLevelConfig.Color = true; cleanUp(); else DCItemLevelConfig.Color = false; cleanUp(); end end)
	
	local b6 = CreateFrame("CheckButton","Show PVP iLvl",ConfigPanel,"UICheckButtonTemplate");
	b6:SetPoint("TOPLEFT",b5,"BOTTOMLEFT",0,0);
	b6:SetChecked(DCItemLevelConfig.PVP);
	_G[b6:GetName() .. "Text"]:SetText("Show PVP iLvl");
	b6:SetScript("OnClick", function(self, button, isDown) if ( self:GetChecked() ) then DCItemLevelConfig.PVP = true; cleanUp(); else DCItemLevelConfig.PVP = false; cleanUp(); end end)
	
	if(DCItemLevelConfig.Small) then
		fontStyle = "SystemFont_Small";
	end
	createFontStrings();
	createInspectFontStrings();
	
	cleanUp();
	
	InterfaceOptions_AddCategory(ConfigPanel);
end

function cleanUp()
	
	--No need to clean up anymore. It is now done per-item when needed. =)

	--for i = 1, 17 do
		--if(FontStrings[i])then
			--FontStrings[i]:SetText("");
			--EnchantIcons[i].texture:SetAlpha(0.0);
			--EnchantIcons[i]:SetScript("OnEnter",nil);
			
			--InspectFontStrings[i]:SetText("");
			--InspectEnchantIcons[i].texture:SetAlpha(0.0);
			--InspectEnchantIcons[i]:SetScript("OnEnter",nil);
			
		--	local slotID = (i - 1) * 3 + 1;
		--	for j = slotID, slotID + 2 do
				--Icons[j].texture:SetAlpha(0.0);
				--Icons[j]:SetScript("OnEnter",nil);
				--InspectIcons[j].texture:SetAlpha(0.0);
				--InspectIcons[j]:SetScript("OnEnter",nil);
		--	end
		--end
	--end
	
	eventHandler(self,"PLAYER_EQUIPMENT_CHANGED");
end

local OPvPFrame = CreateFrame('GameTooltip', 'OPvPTooltip', UIParent, 'GameTooltipTemplate');
function GetPvpILevel(item)
	print(item);
	OPvPFrame:SetOwner(UIParent, 'ANCHOR_NONE');
	OPvPFrame:ClearLines();
	OPvPFrame:SetHyperlink(item);
	
	for i = 1, 30 do
		if _G["OPvPTooltipTextLeft"..i]:GetText() then
			local pvpilvl = _G["OPvPTooltipTextLeft"..i]:GetText():match(PVP_ITEM_LEVEL_TOOLTIP:gsub("%%d","(%%d+)"));
			if  pvpilvl then
				OPvPFrame:Hide();
				return tonumber(pvpilvl);
			end
		else
			break
		end
	end
	OPvPFrame:Hide();
	return 0;
end

local ActiveEnchantableItems;
function findItemInfo(who)
	if not (who) then
		return
	end
	
	if (who == "player") then
		ActiveFontStrings = FontStrings;
		ActiveIcons = Icons;
		ActiveEnchantIcons = EnchantIcons;
		UpdateInProgress = false;
		ActiveEnchantableItems = enchantableItems;
	else
		ActiveFontStrings = InspectFontStrings;
		ActiveIcons = InspectIcons;
		ActiveEnchantIcons = InspectEnchantIcons;
		UpdateInProgressInspect = false;
		ActiveEnchantableItems = enchantableItems;
	end
	
	local tilvl = 0;
	local tilvlPvp = 0;
	local numItems = 15;
	
	GameTooltip:Hide();
	
	for i = 1, 17 do
		
		if (ActiveFontStrings[i]) then
			local itemlink = GetInventoryItemLink(who,i)
			
			if (itemlink) then
			
				if(i == 17) then
					numItems = numItems + 1;
				end
				
				GameTooltip:SetOwner(ilvlFrame,"CENTER");
				GameTooltip:SetHyperlink(itemlink);
				
				--Find Enchants
				if(ActiveEnchantableItems[i]) then
					getEnchant(i,itemlink);
				end
				
				--Find ilvl
				local upgrade, max, delta = ItemUpgradeInfo:GetItemUpgradeInfo(itemlink)
				local ilvl = ItemUpgradeInfo:GetUpgradedItemLevel(itemlink)
				if not(ilvl) then 
					ilvl = 0;
				end
				
				local quality = select(3, GetItemInfo(itemlink));
				
				if (quality == 7) then
					ilvl = findHeirloomilvl();
				end
				
				if(quality) then
					_,_,_, color = GetItemQualityColor(quality);
				end
				
				if (upgrade and DCItemLevelConfig.upgrades) then
					ActiveFontStrings[i]:SetText(ilvl .." ("..upgrade.."/"..max..")")
				else
					ActiveFontStrings[i]:SetText(ilvl)
				end
				
				if(DCItemLevelConfig.Color and color and ActiveFontStrings[i]:GetText()) then
					  ActiveFontStrings[i]:SetText("|c" .. color .. ActiveFontStrings[i]:GetText());
				end
				
				if(ilvl)then
					tilvl = tilvl + ilvl
					
					if(itemlink) then
						OPvPFrame:SetOwner(UIParent, 'ANCHOR_NONE');
						OPvPFrame:ClearLines();
						OPvPFrame:SetHyperlink(itemlink);
	
						for i = 1, 30 do
							if _G["OPvPTooltipTextLeft"..i]:GetText() then
								local pvpilvl = _G["OPvPTooltipTextLeft"..i]:GetText():match(PVP_ITEM_LEVEL_TOOLTIP:gsub("%%d","(%%d+)"));
								if  pvpilvl then
									OPvPFrame:Hide();
									tilvlPvp = tilvlPvp + tonumber(pvpilvl) - ilvl;
								end
							else
								break
							end
						end
						OPvPFrame:Hide();
					end
				end
				
			else
				if(FontStrings[i])then
					ActiveFontStrings[i]:SetText("");
					if (ActiveEnchantableItems[i]) then
						ActiveEnchantIcons[i].texture:SetAlpha(0.0);
						ActiveEnchantIcons[i]:SetScript("OnEnter",nil);
					end
				end
			end
		end
	end
	
	local pvpilvl = tilvl + tilvlPvp;
	
	local iLvlText = "ilvl: ".."|cFFFFFF00"..math.floor(tilvl / numItems).."|cFFFFFFFF".." PvP: ".."|cFFFFFF00"..math.floor(pvpilvl / numItems);
	
	if(who == "player") then
		IlvlTotal:SetText(iLvlText);
		
	else
		InspectAilvl:SetText(iLvlText);
	end
	
	GameTooltip:Hide();
end

function getEnchant(i,itemlink)

	--Look for enchants
	local enchantInfo;
	local line = "";
	for i = 2, GameTooltip:NumLines() do
		line = _G[GameTooltip:GetName().."TextLeft"..i];
		if (line) then
			line = line:GetText();
			if (line) then
				if (line:find(ENCHANTED)) then
					enchantInfo = line;
					
					break;
				end
			end
		end
	end

	local enchantID;
	
	--if(enchantInfo) then
 	--	local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, Name =  string.find(itemlink,"|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
	--	enchantID = Enchant;
	--end
	
	--Did we find any enchants?
	if(enchantInfo) then
		ActiveEnchantIcons[i].texture:SetTexture("INTERFACE/ICONS/INV_Jewelry_Talisman_08");
		ActiveEnchantIcons[i].texture:SetAlpha(1.0);
		
		--if(enchantID == "4442") then
		--	ActiveEnchantIcons[i]:SetScript("OnEnter",function(s,m)
		--		GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR");
		--		GameTooltip:SetHyperlink("item:74724:0:0:0:0:0:0:0");		
		--		GameTooltip:Show(); 
		--		end);
		--else
			ActiveEnchantIcons[i]:SetScript("OnEnter",function(s,m)
				GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR");
				GameTooltip:ClearLines();
				GameTooltip:AddLine(enchantInfo);
				GameTooltip:Show(); 
				end);
		--end
		ActiveEnchantIcons[i]:SetScript("OnLeave",function(s,m)
			GameTooltip:Hide(); 
			end);
	else
		ActiveEnchantIcons[i].texture:SetAlpha(0.0);
		ActiveEnchantIcons[i]:SetScript("OnEnter",nil);
		ActiveEnchantIcons[i]:SetScript("OnLeave",nil);
	end
	
end

function findHeirloomilvl()
	local line = "";
	for i = 2, GameTooltip:NumLines() do
		line = _G[GameTooltip:GetName().."TextLeft"..i];
		
		if (line) then
			line = line:GetText();
			
			if (line) then
				if(line:match("%d+")) then
					local number = tonumber(line:match("%d+"));
					if(number > 0) then
						return number;
					end
				end
			end
		end
	end	

end

--Create Font Strings and Icons
function createFontStrings()
	local kids = { PaperDollItemsFrame:GetChildren() };
	ActiveEnchantableItems = enchantableItems;
	
	IlvlTotal = CharacterModelFrame:CreateFontString("DCFrame_20", "OVERLAY", fontStyle);
	IlvlTotal:SetPoint("TOP", CharacterModelFrame,"TOP", 0, 15);
	
	for i = 1, 17 do
		if not (i == 4) then --exclude 4 and 18, shirt and tabard
			local SlotID = InvSlotID[i];
			FontStrings[i] = kids[SlotID]:CreateFontString("DCFrame_"..SlotID, "OVERLAY", fontStyle)
			--FontStrings[i]:SetParent(PaperDollItemsFrame)
			FontStrings[i]:SetText("")
			FontStrings[i]:SetPoint(slotAlign1[SlotID], kids[SlotID], slotAlign2[SlotID] , slotOffsetx[SlotID], slotOffsety[SlotID])
			
			
			local offset = 0;
			
			if(ActiveEnchantableItems[i]) then
				offset = iconOffsetx[SlotID];
						
				EnchantIcons[i] = CreateFrame("Frame","EnchantIcon"..i,kids[SlotID]);
				EnchantIcons[i]:SetPoint(iconAlign1[SlotID],FontStrings[i],iconAlign2[SlotID], 0, iconOffsety[SlotID]);
				EnchantIcons[i]:SetSize(iconSize,iconSize);
						
				local texture = EnchantIcons[i]:CreateTexture("EnchantIconTex"..i,"OVERLAY");
				texture:SetAllPoints();
				EnchantIcons[i].texture = texture;
				EnchantIcons[i].texture:SetTexture("INTERFACE/ICONS/INV_Jewelry_Talisman_08");
				EnchantIcons[i].texture:SetAlpha(0.0);
			end
		end
	end
	
	
end

--Create Font Strings and Icons for the Inspection Window
function createInspectFontStrings()
	local kids = { InspectPaperDollItemsFrame:GetChildren() };
	for i = 1, 17 do
		if not (i == 4) then --exclude 4 and 18, shirt and tabard
			local SlotID = InvSlotID[i];
			InspectFontStrings[i] = kids[SlotID]:CreateFontString("DCFrame_"..SlotID, "OVERLAY", fontStyle)
			--InspectFontStrings[i]:SetParent(PaperDollItemsFrame)
			InspectFontStrings[i]:SetText("")
			InspectFontStrings[i]:SetPoint(slotAlign1[SlotID], kids[SlotID], slotAlign2[SlotID] , slotOffsetx[SlotID], slotOffsety[SlotID])
			
			
			local offset = 0;
			
			if(enchantableItems[i]) then
				--Offset gems to make space for enchants;
				offset = iconOffsetx[SlotID];
						
				InspectEnchantIcons[i] = CreateFrame("Frame","EnchantIcon"..i,kids[SlotID]);
				InspectEnchantIcons[i]:SetPoint(iconAlign1[SlotID],InspectFontStrings[i],iconAlign2[SlotID], 0, iconOffsety[SlotID]);
				InspectEnchantIcons[i]:SetSize(iconSize,iconSize);
						
				local texture = InspectEnchantIcons[i]:CreateTexture("EnchantIconTex"..i,"OVERLAY");
				texture:SetAllPoints();
				InspectEnchantIcons[i].texture = texture;
				InspectEnchantIcons[i].texture:SetTexture("INTERFACE/ICONS/INV_Jewelry_Talisman_08");
				InspectEnchantIcons[i].texture:SetAlpha(0.0);
			end
		end
	end	
	
	InspectAilvl = InspectModelFrame:CreateFontString("DCFrame_Inspect_Ailvl", "OVERLAY", fontStyle);
	InspectAilvl:SetText("ilvl: 0");
	InspectAilvl:SetPoint("TOP", InspectModelFrame,"TOP", 0, 15);
	
end



