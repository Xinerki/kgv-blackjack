seatSideAngle = 30

function DisplayHelpText(helpText, time)
	BeginTextCommandDisplayHelp("STRING")
	AddTextComponentSubstringWebsite(helpText)
	EndTextCommandDisplayHelp(0, 0, 1, time or -1)
end

function SetSubtitle(subtitle, duration)
    ClearPrints()
    BeginTextCommandPrint("STRING")
    AddTextComponentSubstringWebsite(subtitle)
	EndTextCommandPrint(duration, true)
	if _DEBUG == true then
		print("SUBTITLE: "..subtitle)
	end
end

-- function translateAngle(x1, y1, ang, offset)
	-- x1 = x1 + math.sin(ang) * offset
	-- y1 = y1 + math.cos(ang) * offset
	-- return {x1, y1}
-- end

function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < -180 and t + 180 or t
end

function cardValue(card)
	local rank = 10
	for i=2,11 do
		if string.find(card, tostring(i)) then
			rank = i
		end
	end
	if string.find(card, 'ACE') then
		rank = 11
	end
	
	return rank
end

function handValue(hand)
	local tmpValue = 0
	local numAces = 0
	
	for i,v in pairs(hand) do
		tmpValue = tmpValue + cardValue(v)
	end
	
	for i,v in pairs(hand) do
		if string.find(v, 'ACE') then numAces = numAces + 1 end
	end
	
	repeat
		if tmpValue > 21 and numAces > 0 then
			tmpValue = tmpValue - 10
			numAces = numAces - 1
		else
			break
		end
	until numAces == 0
	
	return tmpValue
end

function CanSplitHand(hand)
	if hand[1] and hand[2] and #hand == 2 then
		if cardValue(hand[1]) == cardValue(hand[2]) then
			return true
		end
	end
	return _DEBUG
end

RegisterCommand("bet", function(source, args, rawCommand)
	if args[1] and _DEBUG == true then
		TriggerServerEvent("BLACKJACK:SetPlayerBet", g_seat, closestChair, args[1])
	end
end, false)


spawnedPeds = {}
spawnedObjects = {}
AddEventHandler("onResourceStop", function(r)
	if r == GetCurrentResourceName() then
		for i,v in ipairs(spawnedPeds) do
			DeleteEntity(v)
		end
		for i,v in ipairs(spawnedObjects) do
			DeleteEntity(v)
		end
	end
end)

renderScaleform = false

Citizen.CreateThread(function()

    scaleform = RequestScaleformMovie_2("INSTRUCTIONAL_BUTTONS")

    repeat Wait(0) until HasScaleformMovieLoaded(scaleform)

	while true do Wait(0)
	
		if renderScaleform == true then
			DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
		end
	
		if _DEBUG == true then
		
			-- for i,p in pairs(cardSplitOffsets) do
				-- for _,v in pairs(p) do
					-- for n,m in pairs(tables) do
						-- local x, y, z = GetObjectOffsetFromCoords(m.coords.x, m.coords.y, m.coords.z, m.coords.w, v)
						
						-- if GetDistanceBetweenCoords(GetGameplayCamCoord(), x, y, z, true) < 5.0 then
							
							-- DrawMarker(28, v.x, v.y, chipHeights[1], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 150, 150, 255, 150, false, false, false, false)
						
							-- SetTextFont(0)
							-- SetTextProportional(1)
							-- SetTextScale(0.0, 0.35)
							-- SetTextColour(255, 255, 255, 255)
							-- SetTextDropshadow(0, 0, 0, 0, 255)
							-- SetTextEdge(2, 0, 0, 0, 150)
							-- SetTextDropShadow()
							-- SetTextOutline()
							-- SetTextCentre(1)
							-- SetTextEntry("STRING")
							-- SetDrawOrigin(GetObjectOffsetFromCoords(m.coords.x, m.coords.y, m.coords.z, m.coords.w, v.x, v.y, chipHeights[1]))
							-- AddTextComponentString(tostring(_))
							-- DrawText(0.0, 0.0)
							-- ClearDrawOrigin()
						
						-- end
					-- end
				-- end
			-- end
		
			if hand then
				SetTextFont(0)
				SetTextProportional(1)
				SetTextScale(0.0, 0.35)
				SetTextColour(255, 255, 255, 255)
				SetTextDropshadow(0, 0, 0, 0, 255)
				SetTextEdge(2, 0, 0, 0, 150)
				SetTextDropShadow()
				SetTextOutline()
				SetTextCentre(1)
				SetTextEntry("STRING")
				AddTextComponentString("HAND VALUE: "..handValue(hand))
				DrawText(0.90, 0.15)
				
				for i,v in ipairs(hand) do
					SetTextFont(0)
					SetTextProportional(1)
					SetTextScale(0.0, 0.35)
					SetTextColour(255, 255, 255, 255)
					SetTextDropshadow(0, 0, 0, 0, 255)
					SetTextEdge(2, 0, 0, 0, 150)
					SetTextDropShadow()
					SetTextOutline()
					SetTextCentre(1)
					SetTextEntry("STRING")
					AddTextComponentString(v.." ("..cardValue(v)..")")
					DrawText(0.90, 0.15+(i/40))
				end
				
				if CanSplitHand(hand) then
					SetTextFont(0)
					SetTextProportional(1)
					SetTextScale(0.0, 0.35)
					SetTextColour(50, 255, 50, 255)
					SetTextDropshadow(0, 0, 0, 0, 255)
					SetTextEdge(2, 0, 0, 0, 150)
					SetTextDropShadow()
					SetTextOutline()
					SetTextCentre(1)
					SetTextEntry("STRING")
					AddTextComponentString("CAN SPLIT HAND")
					DrawText(0.90, 0.125)
				end
				
			end
		
			for i,v in pairs(spawnedPeds) do
				SetTextFont(0)
				SetTextProportional(1)
				SetTextScale(0.0, 0.25)
				SetTextColour(255, 255, 255, 255)
				SetTextDropshadow(0, 0, 0, 0, 255)
				SetTextEdge(2, 0, 0, 0, 150)
				SetTextDropShadow()
				SetTextOutline()
				SetTextEntry("STRING")
				SetTextCentre(1)
				SetDrawOrigin(GetEntityCoords(v))
				AddTextComponentString("i = "..i.. "\nv = " .. spawnedPeds[i])
				DrawText(0.0, 0.0)
				ClearDrawOrigin()
			end
			for i,v in pairs(spawnedObjects) do
				SetTextFont(0)
				SetTextProportional(1)
				SetTextScale(0.0, 0.25)
				SetTextColour(255, 255, 255, 255)
				SetTextDropshadow(0, 0, 0, 0, 255)
				SetTextEdge(2, 0, 0, 0, 150)
				SetTextDropShadow()
				SetTextOutline()
				SetTextEntry("STRING")
				SetTextCentre(1)
				SetDrawOrigin(GetEntityCoords(spawnedObjects[i]))
				AddTextComponentString("i = "..i.. "\nv = " .. spawnedObjects[i])
				DrawText(0.0, 0.0)
				ClearDrawOrigin()
			end
		end
	end
end)

function IsSeatOccupied(coords, radius)
	local players = GetActivePlayers()
	local playerId = PlayerId()
	for i = 1, #players do
		if players[i] ~= playerId then
			local ped = GetPlayerPed(players[i])
			if IsEntityAtCoord(ped, coords, radius, radius, radius, 0, 0, 0) then
				return true
			end
		end
	end

	return false
end

dealerHand = {}
dealerHandObjs = {}
handObjs = {}
		
Citizen.CreateThread(function()
	if not HasAnimDictLoaded("anim_casino_b@amb@casino@games@blackjack@dealer") then
		RequestAnimDict("anim_casino_b@amb@casino@games@blackjack@dealer")
		repeat Wait(0) until HasAnimDictLoaded("anim_casino_b@amb@casino@games@blackjack@dealer")
	end

	if not HasAnimDictLoaded("anim_casino_b@amb@casino@games@shared@dealer@") then
		RequestAnimDict("anim_casino_b@amb@casino@games@shared@dealer@")
		repeat Wait(0) until HasAnimDictLoaded("anim_casino_b@amb@casino@games@shared@dealer@")
	end

	if not HasAnimDictLoaded("anim_casino_b@amb@casino@games@blackjack@player") then
		RequestAnimDict("anim_casino_b@amb@casino@games@blackjack@player")
		repeat Wait(0) until HasAnimDictLoaded("anim_casino_b@amb@casino@games@blackjack@player")
	end
	
	for i,v in pairs(customTables) do
		
		local model = `vw_prop_casino_blckjack_01`
		if v.highStakes == true then
			model = `vw_prop_casino_blckjack_01b`
		end
		
		if not HasModelLoaded(model) then
			RequestModel(model)
			repeat Wait(0) until HasModelLoaded(model)
		end
	
		local tableObj = CreateObjectNoOffset(model, v.coords.x, v.coords.y, v.coords.z, false, false, false)
		SetEntityRotation(tableObj, 0.0, 0.0, v.coords.w, 2, 1)
		SetObjectTextureVariant(tableObj, 3)
		table.insert(spawnedObjects, tableObj)
	end
	
	chips = {}
							
	hand = {}
	handObjs = {}
	
	for i,v in pairs(tables) do
	
		dealerHand[i] = {}
		dealerHandObjs[i] = {}
		local model = `s_f_y_casino_01`

		chips[i] = {}
		
		for x=1,4 do
			chips[i][x] = {}
		end
		handObjs[i] = {}
		
		for x=1,4 do
			handObjs[i][x] = {}
		end
		
		if not HasModelLoaded(model) then
			RequestModel(model)
			repeat Wait(0) until HasModelLoaded(model)
		end
		
		local dealer = CreatePed(4, model, v.coords.x, v.coords.y, v.coords.z, v.coords.w, false, true)
		-- local dealer = ClonePed(PlayerPedId(), 0.0, false, false)
		SetEntityCanBeDamaged(dealer, false)
		SetBlockingOfNonTemporaryEvents(dealer, true)
		SetPedCanRagdollFromPlayerImpact(dealer, false)
		
		-- SetPedVoiceGroup(dealer, `S_F_Y_Casino_01_ASIAN_02`)
		
		-- SetPedDefaultComponentVariation(dealer)
		
		SetPedResetFlag(dealer, 249, true)
		SetPedConfigFlag(dealer, 185, true)
		SetPedConfigFlag(dealer, 108, true)
		SetPedConfigFlag(dealer, 208, true)
		
		SetDealerOutfit(dealer, i+6)
		
		-- NetworkSetEntityInvisibleToNetwork(dealer, true)
		
		-- N_0x352e2b5cf420bf3b(dealer, true)
		-- N_0x2f3c3d9f50681de4(dealer, true)
		
		-- SetNetworkIdCanMigrate(PedToNet(dealer), false)
		
		-- local scene = NetworkCreateSynchronisedScene(v.coords.x, v.coords.y, v.coords.z, vector3(0.0, 0.0, v.coords.w), 2, true, true, 1065353216, 0, 1065353216)
		-- NetworkAddPedToSynchronisedScene(dealer, scene, "anim_casino_b@amb@casino@games@shared@dealer@", "idle", 2.0, -2.0, 13, 16, 1148846080, 0)
		-- NetworkStartSynchronisedScene(scene)
		
		local scene = CreateSynchronizedScene(v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, v.coords.w, 2)
		TaskSynchronizedScene(dealer, scene, "anim_casino_b@amb@casino@games@shared@dealer@", "idle", 1000.0, -8.0, 4, 1, 1148846080, 0)
		
		-- TaskLookAtEntity(dealer, PlayerPedId(), -1, 2048, 3)
		
		-- Wait(1500)
		
		-- TaskPlayAnim(dealer, anim, "idle", 4.0, -1.0, -1, 0, -1.0, true, true, true)
		
		spawnedPeds[i] = dealer
	end
end)

-- function getCardOffset(seat, cardIndex)
	-- if seat == 1 then
		-- if cardIndex = 
	-- end
-- end

RegisterNetEvent("BLACKJACK:PlayDealerAnim")
AddEventHandler("BLACKJACK:PlayDealerAnim", function(i, animDict, anim)
	Citizen.CreateThread(function()
	
		local v = tables[i]
		
		if not HasAnimDictLoaded(animDict) then
			RequestAnimDict(animDict)
			repeat Wait(0) until HasAnimDictLoaded(animDict)
		end
	
		-- if GetEntityModel(spawnedPeds[i]) == `s_f_y_casino_01` then
			-- anim = "female_"..anim
		-- end
		
		DebugPrint("PLAYING "..anim:upper().." ON DEALER "..i)
		
		-- if seat == 0 then
			-- local scene = CreateSynchronizedScene(v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, v.coords.w, 2)
			-- TaskSynchronizedScene(spawnedPeds[i], scene, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_deal_card_self", 1000.0, -8.0, 4, 1, 1148846080, 0)
		-- else
			-- local scene = CreateSynchronizedScene(v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, v.coords.w, 2)
			-- TaskSynchronizedScene(spawnedPeds[i], scene, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_deal_card_player_0" .. 5-seat, 1000.0, -8.0, 4, 1, 1148846080, 0)
		-- end
		
		local scene = CreateSynchronizedScene(v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, v.coords.w, 2)
		TaskSynchronizedScene(spawnedPeds[i], scene, animDict, anim, 1000.0, -8.0, 4, 1, 1148846080, 0)
	
	end)
end)

RegisterNetEvent("BLACKJACK:PlayDealerSpeech")
AddEventHandler("BLACKJACK:PlayDealerSpeech", function(i, speech)
	Citizen.CreateThread(function()
		DebugPrint("PLAYING SPEECH "..speech:upper().." ON DEALER "..i)
		StopCurrentPlayingAmbientSpeech(spawnedPeds[i])
		PlayAmbientSpeech1(spawnedPeds[i], speech, "SPEECH_PARAMS_FORCE_NORMAL_CLEAR")
	end)
end)

RegisterNetEvent("BLACKJACK:DealerTurnOverCard")
AddEventHandler("BLACKJACK:DealerTurnOverCard", function(i)
	SetEntityRotation(dealerHandObjs[i][1], 0.0, 0.0, tables[i].coords.w + cardRotationOffsetsDealer[1].z)
end)

RegisterNetEvent("BLACKJACK:SplitHand")
AddEventHandler("BLACKJACK:SplitHand", function(index, seat, splitHandSize)
	
	DebugPrint("splitHandSize = "..splitHandSize)
	DebugPrint("split card coord = "..tostring(GetObjectOffsetFromCoords(tables[index].coords.x, tables[index].coords.y, tables[index].coords.z, tables[index].coords.w, cardSplitOffsets[seat][1])))
	
	SetEntityCoordsNoOffset(handObjs[index][seat][#handObjs[index][seat]], GetObjectOffsetFromCoords(tables[index].coords.x, tables[index].coords.y, tables[index].coords.z, tables[index].coords.w, cardSplitOffsets[5-seat][1]))
	SetEntityRotation(handObjs[index][seat][#handObjs[index][seat]], 0.0, 0.0, cardSplitRotationOffsets[seat][splitHandSize])
end)

selectedBet = 1

RegisterNetEvent("BLACKJACK:PlaceBetChip")
AddEventHandler("BLACKJACK:PlaceBetChip", function(index, seat, bet, double, split)
	Citizen.CreateThread(function()
	
		local model = GetHashKey(chipModels2[bet])
		
		DebugPrint(bet)
		DebugPrint(seat)
		DebugPrint(tostring(chipModels2[bet]))
		DebugPrint(tostring(chipOffsets[seat]))
	
		RequestModel(model)
		repeat Wait(0) until HasModelLoaded(model)
	
		local location = 1
		if double == true then location = 2 end
		
		local chip = CreateObjectNoOffset(model, tables[index].coords.x, tables[index].coords.y, tables[index].coords.z, false, false, false)
		
		table.insert(spawnedObjects, chip)
		table.insert(chips[index][seat], chip)
		
		if split == false then
			SetEntityCoordsNoOffset(chip, GetObjectOffsetFromCoords(tables[index].coords.x, tables[index].coords.y, tables[index].coords.z, tables[index].coords.w, chipOffsets[seat][location].x, chipOffsets[seat][location].y, chipHeights[1]))
			SetEntityRotation(chip, 0.0, 0.0, tables[index].coords.w + chipRotationOffsets[seat][2].z)
		else
			SetEntityCoordsNoOffset(chip, GetObjectOffsetFromCoords(tables[index].coords.x, tables[index].coords.y, tables[index].coords.z, tables[index].coords.w, chipSplitOffsets[seat][2].x, chipSplitOffsets[seat][2].y, chipHeights[1]))
			SetEntityRotation(chip, 0.0, 0.0, tables[index].coords.w + chipSplitRotationOffsets[seat][1].z)
		end
	end)
end)

RegisterNetEvent("BLACKJACK:RequestBets")
AddEventHandler("BLACKJACK:RequestBets", function(index)
	Citizen.CreateThread(function()
		scrollerIndex = index
		renderScaleform = true
		while true do Wait(0)
			BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
			ScaleformMovieMethodAddParamInt(0)
			ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, 175, 0))
			ScaleformMovieMethodAddParamPlayerNameString("")
			EndScaleformMovieMethod()
			
			BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
			ScaleformMovieMethodAddParamInt(1)
			ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, 174, 0))
			ScaleformMovieMethodAddParamPlayerNameString("Change Bet")
			EndScaleformMovieMethod()
		
			BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
			ScaleformMovieMethodAddParamInt(2)
			ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, 201, 0))
			ScaleformMovieMethodAddParamPlayerNameString("Bet")
			EndScaleformMovieMethod()
		
			BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
			ScaleformMovieMethodAddParamInt(3)
			ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, 192, 0))
			ScaleformMovieMethodAddParamPlayerNameString("Max Bet")
			EndScaleformMovieMethod()
		
			BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
			ScaleformMovieMethodAddParamInt(4)
			ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, 51, 0))
			ScaleformMovieMethodAddParamPlayerNameString("Quit")
			EndScaleformMovieMethod()
			
			BeginScaleformMovieMethod(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
			EndScaleformMovieMethod()
			
			if IsControlJustPressed(1, 192) then
				selectedBet = #bettingNums
			elseif IsControlJustPressed(1, 175) then -- RIGHT
				selectedBet = selectedBet + 1
				if selectedBet > #bettingNums then selectedBet = 1 end
			elseif IsControlJustPressed(1, 174) then -- LEFT
				selectedBet = selectedBet - 1
				if selectedBet < 1 then selectedBet = #bettingNums end
			elseif IsControlJustPressed(1, 51) then
				leavingBlackjack = true
				renderScaleform = false
				return
			end
			
			bet = bettingNums[selectedBet] or 34404
			if tables[scrollerIndex].highStakes == true then bet = bet * 10 end
			
			DisplayHelpText("CURRENT BET:\n"..bet, -1)
		
			if IsControlJustPressed(1, 201) then
				
				local exists, money = StatGetInt("MP0_WALLET_BALANCE")
				
				if bet <= money then
					renderScaleform = false
					if selectedBet < 27 then
						local anim = "place_bet_small"
					
						playerBusy = true
						local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, false, 1065353216, 0, 1065353216)
						NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@blackjack@player", anim, 2.0, -2.0, 13, 16, 1148846080, 0)
						NetworkStartSynchronisedScene(scene)
						
						Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@blackjack@player", anim)*500))
						
						TriggerServerEvent("BLACKJACK:SetPlayerBet", g_seat, closestChair, bet, selectedBet, false)

						Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@blackjack@player", anim)*500))
						
						playerBusy = false
						
						local idleVar = "idle_var_0"..math.random(1,5)
						
						DebugPrint("IDLING POST-BUSY: "..idleVar)

						local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, true, 1065353216, 0, 1065353216)
						NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", idleVar, 2.0, -2.0, 13, 16, 1148846080, 0)
						NetworkStartSynchronisedScene(scene)
					else
						local anim = "place_bet_large"
					
						playerBusy = true
						local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, false, 1065353216, 0, 1065353216)
						NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@blackjack@player", anim, 2.0, -2.0, 13, 16, 1148846080, 0)
						NetworkStartSynchronisedScene(scene)
						
						Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@blackjack@player", anim)*500))
						
						TriggerServerEvent("BLACKJACK:SetPlayerBet", g_seat, closestChair, bet, selectedBet, false)

						Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@blackjack@player", anim)*500))
						
						playerBusy = false
						
						local idleVar = "idle_var_0"..math.random(1,5)
						
						DebugPrint("IDLING POST-BUSY: "..idleVar)

						local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, true, 1065353216, 0, 1065353216)
						NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", idleVar, 2.0, -2.0, 13, 16, 1148846080, 0)
						NetworkStartSynchronisedScene(scene)
					end
					return
				else
					SetSubtitle("~r~You don't have enough money for the bet.", 5000)
				end
			end
		end
		-- TriggerServerEvent("BLACKJACK:SetPlayerBet", g_seat, closestChair, bet)
	end)
end)

RegisterNetEvent("BLACKJACK:RequestMove")
AddEventHandler("BLACKJACK:RequestMove", function()
	Citizen.CreateThread(function()
		renderScaleform = true
		while true do Wait(0)
		
			BeginScaleformMovieMethod(scaleform, "CLEAR_ALL")
			EndScaleformMovieMethod()

			BeginScaleformMovieMethod(scaleform, "SET_BACKGROUND_COLOUR")
			ScaleformMovieMethodAddParamInt(0)
			ScaleformMovieMethodAddParamInt(0)
			ScaleformMovieMethodAddParamInt(0)
			ScaleformMovieMethodAddParamInt(80)
			EndScaleformMovieMethod()
			
			-- BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
			-- ScaleformMovieMethodAddParamInt(0)
			-- ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, 51, 0))
			-- ScaleformMovieMethodAddParamPlayerNameString("Quit")
			-- EndScaleformMovieMethod()

			BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
			ScaleformMovieMethodAddParamInt(1)
			ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, 201, 0))
			ScaleformMovieMethodAddParamPlayerNameString("Hit")
			EndScaleformMovieMethod()

			BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
			ScaleformMovieMethodAddParamInt(2)
			ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, 203, 0))
			ScaleformMovieMethodAddParamPlayerNameString("Stand")
			EndScaleformMovieMethod()
			
			if #hand < 3 then
				BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
				ScaleformMovieMethodAddParamInt(3)
				ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, 192, 0))
				ScaleformMovieMethodAddParamPlayerNameString("Double Down")
				EndScaleformMovieMethod()
			end

			if CanSplitHand(hand) == true then
				BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
				ScaleformMovieMethodAddParamInt(4)
				ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(1, 209, 0))
				ScaleformMovieMethodAddParamPlayerNameString("Split")
				EndScaleformMovieMethod()
			end
			
			DisplayHelpText("YOUR HAND:\n"..handValue(hand))
			
			BeginScaleformMovieMethod(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
			EndScaleformMovieMethod()
		
			if IsControlJustPressed(1, 201) then
				TriggerServerEvent("BLACKJACK:ReceivedMove", "hit")
				
				renderScaleform = false
				
				local anim = requestCardAnims[math.random(1,#requestCardAnims)]
				
				playerBusy = true
				local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, false, 1065353216, 0, 1065353216)
				NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@blackjack@player", anim, 2.0, -2.0, 13, 16, 1148846080, 0)
				NetworkStartSynchronisedScene(scene)
				Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@blackjack@player", anim)*990))
				playerBusy = false
				
				local idleVar = "idle_var_0"..math.random(1,5)
				
				DebugPrint("IDLING POST-BUSY: "..idleVar)

				local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, true, 1065353216, 0, 1065353216)
				NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", idleVar, 2.0, -2.0, 13, 16, 1148846080, 0)
				NetworkStartSynchronisedScene(scene)
				
				return
			end
			if IsControlJustPressed(1, 203) then
				TriggerServerEvent("BLACKJACK:ReceivedMove", "stand")
				
				renderScaleform = false
				
				local anim = declineCardAnims[math.random(1,#declineCardAnims)]
				
				playerBusy = true
				local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, false, 1065353216, 0, 1065353216)
				NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@blackjack@player", anim, 2.0, -2.0, 13, 16, 1148846080, 0)
				NetworkStartSynchronisedScene(scene)
				Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@blackjack@player", anim)*990))
				playerBusy = false
				
				local idleVar = "idle_var_0"..math.random(1,5)
				
				DebugPrint("IDLING POST-BUSY: "..idleVar)

				local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, true, 1065353216, 0, 1065353216)
				NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", idleVar, 2.0, -2.0, 13, 16, 1148846080, 0)
				NetworkStartSynchronisedScene(scene)

				return
			end
			if IsControlJustPressed(1, 192) and #hand == 2 then
				TriggerServerEvent("BLACKJACK:ReceivedMove", "double")
				
				renderScaleform = false
				
				local anim = "place_bet_double_down"
				
				playerBusy = true
				local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, false, 1065353216, 0, 1065353216)
				NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@blackjack@player", anim, 2.0, -2.0, 13, 16, 1148846080, 0)
				NetworkStartSynchronisedScene(scene)
				Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@blackjack@player", anim)*500))
				
				TriggerServerEvent("BLACKJACK:SetPlayerBet", g_seat, closestChair, bet, selectedBet, true)
				
				Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@blackjack@player", anim)*500))
				playerBusy = false
				
				local idleVar = "idle_var_0"..math.random(1,5)
				
				DebugPrint("IDLING POST-BUSY: "..idleVar)

				local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, true, 1065353216, 0, 1065353216)
				NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", idleVar, 2.0, -2.0, 13, 16, 1148846080, 0)
				NetworkStartSynchronisedScene(scene)

				return
			end
			if IsControlJustPressed(1, 209) and CanSplitHand(hand) == true then
				TriggerServerEvent("BLACKJACK:ReceivedMove", "split")
				
				renderScaleform = false
				
				local anim = "place_bet_small_split"
				
				if selectedBet > 27 then
					anim = "place_bet_large_split"
				end
				
				playerBusy = true
				local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, false, 1065353216, 0, 1065353216)
				NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@blackjack@player", anim, 2.0, -2.0, 13, 16, 1148846080, 0)
				NetworkStartSynchronisedScene(scene)
				Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@blackjack@player", anim)*500))
				
				TriggerServerEvent("BLACKJACK:SetPlayerBet", g_seat, closestChair, bet, selectedBet, false, true)
				
				Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@blackjack@player", anim)*500))
				playerBusy = false
				
				local idleVar = "idle_var_0"..math.random(1,5)
				
				DebugPrint("IDLING POST-BUSY: "..idleVar)

				local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, true, 1065353216, 0, 1065353216)
				NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", idleVar, 2.0, -2.0, 13, 16, 1148846080, 0)
				NetworkStartSynchronisedScene(scene)

				return
			end
			
			-- not yet
			-- if IsControlJustPressed(1, 51) then
				-- TriggerServerEvent("BLACKJACK:ReceivedMove", "leave")
				-- leavingBlackjack = true
				-- return
			-- end
		end
	end)
end)

RegisterNetEvent("BLACKJACK:GameEndReaction")
AddEventHandler("BLACKJACK:GameEndReaction", function(result)
	Citizen.CreateThread(function()
		hand = {}
		
		-- handObjs = {}
		-- handObjs[i] = {}
		
		-- for x=1,4 do
			-- handObjs[i][x] = {}
		-- end
	
		local anim = "reaction_"..result.."_var_0"..math.random(1,4)
		
		DebugPrint("Reacting: "..anim)
		
		playerBusy = true
		local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, false, false, 1065353216, 0, 1065353216)
		NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", anim, 2.0, -2.0, 13, 16, 1148846080, 0)
		NetworkStartSynchronisedScene(scene)
		Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@shared@player@", anim)*990))
		playerBusy = false
		
		idleVar = "idle_var_0"..math.random(1,5)

		local scene = NetworkCreateSynchronisedScene(g_coords, g_rot, 2, true, true, 1065353216, 0, 1065353216)
		NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", idleVar, 2.0, -2.0, 13, 16, 1148846080, 0)
		NetworkStartSynchronisedScene(scene)
	end)
end)

RegisterNetEvent("BLACKJACK:RetrieveCards")
AddEventHandler("BLACKJACK:RetrieveCards", function(i, seat)

	-- if g_seat == i then 
		-- for z,v in pairs(chips[i]) do
			-- if v then
				-- DeleteEntity(v)
			-- end
		-- end
	-- end

	-- DeleteEntity(chips[i][seat])

	if seat == 0 then
		for x,v in pairs(dealerHandObjs[i]) do
			DeleteEntity(v)
			dealerHandObjs[i][x] = nil
		end
	else
		for x,v in pairs(handObjs[i][seat]) do
			DeleteEntity(v)
			-- handObjs[i][seat][x] = nil
			-- table.remove(handObjs[i][seat], i)
		end
		for x,v in pairs(chips[i][5-seat]) do
			DeleteEntity(v)
		end
	end
end)
	

RegisterNetEvent("BLACKJACK:GiveCard")
AddEventHandler("BLACKJACK:GiveCard", function(i, seat, handSize, card, flipped, split)
	
	flipped = flipped or false
	split = split or false
	
	if seat == closestChair then
		table.insert(hand, card)
		
		DebugPrint("GOT CARD "..card.." ("..cardValue(card)..")")
		DebugPrint("HAND VALUE "..handValue(hand))
	elseif seat == 0 then
		table.insert(dealerHand[i], card)
	end
	
	local model = GetHashKey("vw_prop_cas_card_"..card)
	
	RequestModel(model)
	repeat Wait(0) until HasModelLoaded(model)
	
	local card = CreateObjectNoOffset(model, tables[i].coords.x, tables[i].coords.y, tables[i].coords.z, false, false, false)
	
	table.insert(spawnedObjects, card)
	
	-- if seat == closestChair then
		-- table.insert(handObjs, card)
	-- end
	
	if seat > 0 then
		table.insert(handObjs[i][seat], card)
	end
	
	-- SetNetworkIdCanMigrate(ObjToNet(card), false)
	
	AttachEntityToEntity(card, spawnedPeds[i], GetPedBoneIndex(spawnedPeds[i], 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 1, 2, 1)
	
	Wait(500)
	
	-- AttachEntityToEntity(card, spawnedPeds[i], GetPedBoneIndex(spawnedPeds[i], 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 1, 2, 1)
	
	Wait(800)
	
	DetachEntity(card, 0, true)
	
	if seat == 0 then
		table.insert(dealerHandObjs[i], card)
		
		SetEntityCoordsNoOffset(card, GetObjectOffsetFromCoords(tables[i].coords.x, tables[i].coords.y, tables[i].coords.z, tables[i].coords.w, cardOffsetsDealer[handSize]))
		
		if flipped == true then
			SetEntityRotation(card, 180.0, 0.0, tables[i].coords.w + cardRotationOffsetsDealer[handSize].z)
		else
			SetEntityRotation(card, 0.0, 0.0, tables[i].coords.w + cardRotationOffsetsDealer[handSize].z)
		end
	else
		if split == true then
			SetEntityCoordsNoOffset(card, GetObjectOffsetFromCoords(tables[i].coords.x, tables[i].coords.y, tables[i].coords.z, tables[i].coords.w, cardSplitOffsets[5-seat][handSize]))
			SetEntityRotation(card, 0.0, 0.0, tables[i].coords.w + cardSplitRotationOffsets[5-seat][handSize])
		else
			SetEntityCoordsNoOffset(card, GetObjectOffsetFromCoords(tables[i].coords.x, tables[i].coords.y, tables[i].coords.z, tables[i].coords.w, cardOffsets[5-seat][handSize]))
			SetEntityRotation(card, 0.0, 0.0, tables[i].coords.w + cardRotationOffsets[5-seat][handSize])
		end
	end
	
	-- DebugPrint(cardOffsets[5-seat][handSize])
end)

function ProcessTables()	
	RequestAnimDict("anim_casino_b@amb@casino@games@shared@player@")
	
	while true do Wait(0)
		for i,v in pairs(tables) do
			local cord = v.coords
			local highStakes = v.highStakes
			
			if GetDistanceBetweenCoords(cord.x, cord.y, cord.z, GetEntityCoords(PlayerPedId()), true) < 3.0 then
			
				-- local pCoords = vector3(cord.x, cord.y, cord.z)
				local pCoords = GetEntityCoords(PlayerPedId())
				local tableObj = GetClosestObjectOfType(pCoords, 1.0, `vw_prop_casino_blckjack_01`, false, false, false)
				-- highStakes = false
				
				if GetEntityCoords(tableObj) == vector3(0.0, 0.0, 0.0) then
					tableObj = GetClosestObjectOfType(pCoords, 1.0, `vw_prop_casino_blckjack_01b`, false, false, false)
					-- highStakes = true
				end
				
				if GetEntityCoords(tableObj) ~= vector3(0.0, 0.0, 0.0) then
					closestChair = 1
					local coords = GetWorldPositionOfEntityBone(tableObj, GetEntityBoneIndexByName(tableObj, "Chair_Base_0"..closestChair))
					local rot = GetWorldRotationOfEntityBone(tableObj, GetEntityBoneIndexByName(tableObj, "Chair_Base_0"..closestChair))
					dist = GetDistanceBetweenCoords(coords, GetEntityCoords(PlayerPedId()), true)
					
					for i=1,4 do
						local coords = GetWorldPositionOfEntityBone(tableObj, GetEntityBoneIndexByName(tableObj, "Chair_Base_0"..i))
						if GetDistanceBetweenCoords(coords, GetEntityCoords(PlayerPedId()), true) < dist then
							dist = GetDistanceBetweenCoords(coords, GetEntityCoords(PlayerPedId()), true)
							closestChair = i
						end
					end
					
					local coords = GetWorldPositionOfEntityBone(tableObj, GetEntityBoneIndexByName(tableObj, "Chair_Base_0"..closestChair))
					local rot = GetWorldRotationOfEntityBone(tableObj, GetEntityBoneIndexByName(tableObj, "Chair_Base_0"..closestChair))
					
					g_coords = coords
					g_rot = rot
					
					local angle = rot.z-findRotation(coords.x, coords.y, pCoords.x, pCoords.y)+90.0
					
					local seatAnim = "sit_enter_"
					
					if angle > 0 then seatAnim = "sit_enter_left" end
					if angle < 0 then seatAnim = "sit_enter_right" end
					if angle > seatSideAngle or angle < -seatSideAngle then seatAnim = seatAnim .. "_side" end
					
					if GetDistanceBetweenCoords(coords, GetEntityCoords(PlayerPedId()), true) < 1.5 and not IsSeatOccupied(coords, 0.5) then
						
						if highStakes then
							DisplayHelpText("Press ~INPUT_CONTEXT~ to play High-Limit Blackjack.")
						else
							DisplayHelpText("Press ~INPUT_CONTEXT~ to play Blackjack.")
						end
						
						if _DEBUG == true then
							SetTextFont(0)
							SetTextProportional(1)
							SetTextScale(0.0, 0.45)
							SetTextColour(255, 255, 255, 255)
							SetTextDropshadow(0, 0, 0, 0, 255)
							SetTextEdge(2, 0, 0, 0, 150)
							SetTextDropShadow()
							SetTextOutline()
							SetTextEntry("STRING")
							SetTextCentre(1)
							SetDrawOrigin(cord.x, cord.y, cord.z)
							AddTextComponentString("table = "..i)
							DrawText(0.0, 0.0)
							ClearDrawOrigin()
						end
						
						if IsControlJustPressed(1, 51) then
							local initPos = GetAnimInitialOffsetPosition("anim_casino_b@amb@casino@games@shared@player@", seatAnim, coords, rot, 0.01, 2)
							local initRot = GetAnimInitialOffsetRotation("anim_casino_b@amb@casino@games@shared@player@", seatAnim, coords, rot, 0.01, 2)
							
							TaskGoStraightToCoord(PlayerPedId(), initPos, 1.0, 5000, initRot.z, 0.01)
							repeat Wait(0) until GetScriptTaskStatus(PlayerPedId(), 2106541073) == 7
							Wait(50)
							
							SetPedCurrentWeaponVisible(PlayerPedId(), 0, true, 0, 0)
							
							local scene = NetworkCreateSynchronisedScene(coords, rot, 2, true, true, 1065353216, 0, 1065353216)
							NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", seatAnim, 2.0, -2.0, 13, 16, 1148846080, 0)
							NetworkStartSynchronisedScene(scene)

							local scene = NetworkConvertSynchronisedSceneToSynchronizedScene(scene)
							repeat Wait(0) until GetSynchronizedScenePhase(scene) >= 0.99 or HasAnimEventFired(PlayerPedId(), 2038294702) or HasAnimEventFired(PlayerPedId(), -1424880317)

							Wait(1000)

							idleVar = "idle_cardgames"

							scene = NetworkCreateSynchronisedScene(coords, rot, 2, true, true, 1065353216, 0, 1065353216)
							NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", "idle_cardgames", 2.0, -2.0, 13, 16, 1148846080, 0)
							NetworkStartSynchronisedScene(scene)

							repeat Wait(0) until IsEntityPlayingAnim(PlayerPedId(), "anim_casino_b@amb@casino@games@shared@player@", "idle_cardgames", 3) == 1

							g_seat = i
	
							leavingBlackjack = false

							TriggerServerEvent("BLACKJACK:PlayerSatDown", i, closestChair)

							local endTime = GetGameTimer() + math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@shared@player@", idleVar)*990)

							while true do
								Wait(0)
								if GetGameTimer() >= endTime then
									if playerBusy == true then
										repeat Wait(0) until playerBusy == false
									end
								
									idleVar = "idle_var_0"..math.random(1,5)

									local scene = NetworkCreateSynchronisedScene(coords, rot, 2, true, true, 1065353216, 0, 1065353216)
									NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", idleVar, 2.0, -2.0, 13, 16, 1148846080, 0)
									NetworkStartSynchronisedScene(scene)
									endTime = GetGameTimer() + math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@shared@player@", idleVar)*990)
									-- DebugPrint("idling again")
								end
								
								-- DisplayHelpText("Press ~INPUT_CONTEXT~ to leave Blackjack.")
								-- if IsControlJustPressed(1, 51) then
								if leavingBlackjack == true then
									local scene = NetworkCreateSynchronisedScene(coords, rot, 2, false, false, 1065353216, 0, 1065353216)
									NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", "sit_exit_left", 2.0, -2.0, 13, 16, 1148846080, 0)
									NetworkStartSynchronisedScene(scene)
									TriggerServerEvent("BLACKJACK:PlayerSatUp", i)
									Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@shared@player@", "sit_exit_left")*800))
									ClearPedTasks(PlayerPedId())
									break
								end

								-- if IsEntityPlayingAnim(PlayerPedId(), "anim_casino_b@amb@casino@games@shared@player@", idleVar, 3) ~= 1 then break end
							end
						end
					end
				end
			end
		end		
	end
end

Citizen.CreateThread(ProcessTables)