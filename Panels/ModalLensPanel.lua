-- Provides info about currently active Modal Lens

include( "InstanceManager" );

-- ===========================================================================
-- Globals
-- ===========================================================================
g_KeyStackIM = InstanceManager:new( "KeyEntry", "KeyColorImage", Controls.KeyStack );

-- ===========================================================================
-- Members
-- =======================================================e====================
local m_ContinentColorList:table = {};

local m_HexColoringReligion : number = UILens.CreateLensLayerHash("Hex_Coloring_Religion");
local m_HexColoringAppeal : number = UILens.CreateLensLayerHash("Hex_Coloring_Appeal_Level");
local m_HexColoringGovernment : number = UILens.CreateLensLayerHash("Hex_Coloring_Government");
local m_HexColoringOwningCiv : number = UILens.CreateLensLayerHash("Hex_Coloring_Owning_Civ");
local m_HexColoringContinent : number = UILens.CreateLensLayerHash("Hex_Coloring_Continent");
local m_HexColoringWaterAvail : number = UILens.CreateLensLayerHash("Hex_Coloring_Water_Availablity");
local m_TouristTokens : number = UILens.CreateLensLayerHash("Tourist_Tokens");
local m_EmpireDetails : number = UILens.CreateLensLayerHash("Empire_Details");

--============================================================================
function Close()
	--ContextPtr:SetHide(true);
	UI.SetInterfaceMode(InterfaceModeTypes.SELECTION);
end

--============================================================================
function ShowAppealLensKey()
	g_KeyStackIM: ResetInstances();

	-- Breathtaking
	AddKeyEntry("LOC_TOOLTIP_APPEAL_BREATHTAKING", UI.GetColorValue("COLOR_BREATHTAKING_APPEAL"));

	-- Charming
	AddKeyEntry("LOC_TOOLTIP_APPEAL_CHARMING", UI.GetColorValue("COLOR_CHARMING_APPEAL"));

	-- Average
	AddKeyEntry("LOC_TOOLTIP_APPEAL_AVERAGE", UI.GetColorValue("COLOR_AVERAGE_APPEAL"));

	-- Uninviting
	AddKeyEntry("LOC_TOOLTIP_APPEAL_UNINVITING", UI.GetColorValue("COLOR_UNINVITING_APPEAL"));

	-- Disgusting
	AddKeyEntry("LOC_TOOLTIP_APPEAL_DISGUSTING", UI.GetColorValue("COLOR_DISGUSTING_APPEAL"));

	Controls.KeyPanel:SetHide(false);
	Controls.KeyScrollPanel:CalculateSize();
end

--============================================================================
function ShowSettlerLensKey()
	g_KeyStackIM: ResetInstances();

	-- Fresh Water
	local FreshWaterBonus:number = GlobalParameters.CITY_POPULATION_RIVER_LAKE - GlobalParameters.CITY_POPULATION_NO_WATER;
	AddKeyEntry("LOC_HUD_UNIT_PANEL_TOOLTIP_FRESH_WATER", UI.GetColorValue("COLOR_BREATHTAKING_APPEAL"), "ICON_HOUSING", "+" .. tostring(FreshWaterBonus));

	-- Coastal Water
	local CoastalWaterBonus:number = GlobalParameters.CITY_POPULATION_COAST - GlobalParameters.CITY_POPULATION_NO_WATER;
	AddKeyEntry("LOC_HUD_UNIT_PANEL_TOOLTIP_COASTAL_WATER", UI.GetColorValue("COLOR_CHARMING_APPEAL"), "ICON_HOUSING", "+" .. tostring(CoastalWaterBonus));

	-- No Water
	AddKeyEntry("LOC_HUD_UNIT_PANEL_TOOLTIP_NO_WATER", UI.GetColorValue("COLOR_AVERAGE_APPEAL"));

	-- Too Close To City
	AddKeyEntry("LOC_HUD_UNIT_PANEL_TOOLTIP_TOO_CLOSE_TO_CITY", UI.GetColorValue("COLOR_DISGUSTING_APPEAL"));

	Controls.KeyPanel:SetHide(false);
	Controls.KeyScrollPanel:CalculateSize();
end

--============================================================================
function ShowReligionLensKey()
	g_KeyStackIM:ResetInstances();

	-- Track which types we've added so we don't add duplicates
	local visibleTypes:table = {};
	local visibleTypesCount:number = 0;

	local numFoundedReligions	:number = 0;
	local pAllReligions			:table = Game.GetReligion():GetReligions();

	for _, religionInfo in ipairs(pAllReligions) do
		local religionType:number = religionInfo.Religion;
		religionData = GameInfo.Religions[religionType];
		if(religionData.Pantheon == false and Game.GetReligion():HasBeenFounded(religionType)) then
			-- Add key entry
			AddKeyEntry(Game.GetReligion():GetName(religionType), UI.GetColorValue(religionData.Color));
			visibleTypesCount = visibleTypesCount + 1;
			
		end
	end

	if visibleTypesCount > 0 then
		Controls.KeyPanel:SetHide(false);
		Controls.KeyScrollPanel:CalculateSize();
	else
		Controls.KeyPanel:SetHide(true);
	end
end

--============================================================================
function ShowGovernmentLensKey()
	g_KeyStackIM:ResetInstances();

	-- Track which types we've added so we don't add duplicates
	local visibleTypes:table = {};
	local visibleTypesCount:number = 0;

	local localPlayer = Players[Game.GetLocalPlayer()];
	local playerDiplomacy:table = localPlayer:GetDiplomacy();
	if playerDiplomacy then
		local players = Game.GetPlayers();
		for i, player in ipairs(players) do
			-- Only show goverments for players we've met (and ourselves)
			local visiblePlayer = (player == localPlayer) or playerDiplomacy:HasMet(player:GetID());
			if visiblePlayer then
				local culture = player:GetCulture();
				local governmentIndex = culture:GetCurrentGovernment();
				local government = GameInfo.Governments[governmentIndex];
				if government and visibleTypes[governmentIndex] ~= true then
					-- Get government color
					local colorString:string = "COLOR_" .. government.GovernmentType;

					-- Add key entry
					AddKeyEntry(government.Name, UI.GetColorValue(colorString));

					visibleTypes[governmentIndex] = true;
					visibleTypesCount = visibleTypesCount + 1;
				end
			end
		end
	end

	if visibleTypesCount > 0 then
		Controls.KeyPanel:SetHide(false);
		Controls.KeyScrollPanel:CalculateSize();
	else
		Controls.KeyPanel:SetHide(true);
	end
end

--============================================================================
function ShowPoliticalLensKey()
	g_KeyStackIM:ResetInstances();

	local hasAddedCityStateEntry = false;
	local localPlayer = Players[Game.GetLocalPlayer()];
	local playerDiplomacy:table = localPlayer:GetDiplomacy();
	if playerDiplomacy then
		local players = Game.GetPlayers();
		for i, player in ipairs(players) do
			-- Only show civilizations for players we've met
			local visiblePlayer = (player == localPlayer) or playerDiplomacy:HasMet(player:GetID());
			if visiblePlayer and not player:IsBarbarian() then
				local primaryColor, secondaryColor = UI.GetPlayerColors( player:GetID() );
				local playerConfig:table = PlayerConfigurations[player:GetID()];
				local playerInfluence:table = player:GetInfluence();
				if player:IsMajor() then
					-- Add key entry for civilization
					AddKeyEntry(playerConfig:GetPlayerName(), primaryColor);
				elseif hasAddedCityStateEntry == false then -- Only city states can receive influence
					-- Combine all city states into one generic city state entry
					-- Add key entry for city states
					AddKeyEntry("LOC_CITY_STATES_TITLE", primaryColor);

					hasAddedCityStateEntry = true;
				end
			end
		end
	end

	Controls.KeyPanel:SetHide(false);
	Controls.KeyScrollPanel:CalculateSize();
end

--============================================================================
function OnAddContinentColorPair( pContinentColors:table )
	m_ContinentColorList = pContinentColors;
end

--============================================================================
function ShowContinentLensKey()
	g_KeyStackIM: ResetInstances();

	for ContinentID,ColorValue in pairs(m_ContinentColorList) do
		local visibleContinentPlots:table = Map.GetVisibleContinentPlots(ContinentID); 
		if(table.count(visibleContinentPlots) > 0) then
			local ContinentName =  GameInfo.Continents[ContinentID].Description;
			AddKeyEntry( ContinentName, ColorValue);
		end
	end

	Controls.KeyPanel:SetHide(false);
	Controls.KeyScrollPanel:CalculateSize();
end

-- ===========================================================================
function AddKeyEntry(textString:string, colorValue:number, bonusIcon:string, bonusValue:string)
	local keyEntryInstance:table = g_KeyStackIM:GetInstance();

	-- Update key text
	keyEntryInstance.KeyLabel:SetText(Locale.Lookup(textString));

	-- Update key color
	keyEntryInstance.KeyColorImage:SetColor(colorValue);

	-- If bonus icon or bonus value show the bonus stack
	if bonusIcon or bonusValue then
		keyEntryInstance.KeyBonusStack:SetHide(false);

		-- Show bonus icon if passed in
		if bonusIcon then
			keyEntryInstance.KeyBonusImage:SetHide(false);
			keyEntryInstance.KeyBonusImage:SetIcon(bonusIcon, 16);
		else
			keyEntryInstance.KeyBonusImage:SetHide(true);
		end

		-- Show bonus value if passed in
		if bonusValue then
			keyEntryInstance.KeyBonusLabel:SetHide(false);
			keyEntryInstance.KeyBonusLabel:SetText(bonusValue);
		else
			keyEntryInstance.KeyBonusLabel:SetHide(true);
		end

		keyEntryInstance.KeyBonusStack:CalculateSize();
	else
		keyEntryInstance.KeyBonusStack:SetHide(true);
	end

	keyEntryInstance.KeyInfoStack:CalculateSize();
	keyEntryInstance.KeyInfoStack:ReprocessAnchoring();
end

-- ===========================================================================
function OnLensLayerOn( layerNum:number )
	if layerNum == m_HexColoringReligion then
		Controls.LensText:SetText(Locale.ToUpper(Locale.Lookup("LOC_HUD_RELIGION_LENS")));
		ShowReligionLensKey();
	elseif layerNum == m_HexColoringContinent then
		Controls.LensText:SetText(Locale.ToUpper(Locale.Lookup("LOC_HUD_CONTINENT_LENS")));
		Controls.KeyPanel:SetHide(true);
		ShowContinentLensKey();
	elseif layerNum == m_HexColoringAppeal then
		Controls.LensText:SetText(Locale.ToUpper(Locale.Lookup("LOC_HUD_APPEAL_LENS")));
		ShowAppealLensKey();
	elseif layerNum == m_HexColoringGovernment then
		Controls.LensText:SetText(Locale.ToUpper(Locale.Lookup("LOC_HUD_GOVERNMENT_LENS")));
		ShowGovernmentLensKey();
	elseif layerNum == m_HexColoringOwningCiv then
		Controls.LensText:SetText(Locale.ToUpper(Locale.Lookup("LOC_HUD_OWNER_LENS")));
		ShowPoliticalLensKey();
	elseif layerNum == m_HexColoringWaterAvail then
		Controls.LensText:SetText(Locale.ToUpper(Locale.Lookup("LOC_HUD_WATER_LENS")));
		ShowSettlerLensKey();
	elseif layerNum == m_TouristTokens then
		Controls.LensText:SetText(Locale.ToUpper(Locale.Lookup("LOC_HUD_TOURISM_LENS")));
		Controls.KeyPanel:SetHide(true);
	elseif layerNum == m_EmpireDetails then
		Controls.LensText:SetText(Locale.ToUpper(Locale.Lookup("LOC_HUD_EMPIRE_LENS")));
		Controls.KeyPanel:SetHide(true);
	end
end

-- ===========================================================================
--	Game Engine Event
-- ===========================================================================
function OnInterfaceModeChanged(eOldMode:number, eNewMode:number)
	if eNewMode == InterfaceModeTypes.VIEW_MODAL_LENS then
		ContextPtr:SetHide(false);
	end
	if eOldMode == InterfaceModeTypes.VIEW_MODAL_LENS then
		ContextPtr:SetHide(true);
	end
end

-- ===========================================================================
--	INIT (ModalLensPanel)
-- ===========================================================================
function InitializeModalLensPanel()

	if (Game.GetLocalPlayer() == -1) then
		return;
	end
	
    Controls.CloseButton:RegisterCallback(Mouse.eLClick, Close);
	
	Events.InterfaceModeChanged.Add( OnInterfaceModeChanged );
	Events.LensLayerOn.Add( OnLensLayerOn );

	LuaEvents.MinimapPanel_AddContinentColorPair.Add(OnAddContinentColorPair);
end
InitializeModalLensPanel();