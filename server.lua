

ranks = {'02', '03', '04', '05', '06', '07', '08', '09', '10', --[['11',]] 'JACK', 'QUEEN', 'KING', 'ACE'}
suits = {'SPD', 'HRT', 'DIA', 'CLUB'}

function shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

function getDeck()
	local tDeck = {}
	for _,rank in pairs(ranks) do
		for _,suit in pairs(suits) do
			table.insert(tDeck, suit .. "_" .. rank)
		end
	end
	return shuffle(tDeck)
end

function takeCard(tDeck)
	return table.remove(tDeck, math.random(1,#tDeck))
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
		
players = {
	-- [1] = { -- table
		-- [1] = { -- player
			-- player = source
			-- seat = 1
			-- hand = {},
			-- splitHand = {}
			-- player_in = true,
			-- bet = 1500,
		-- }
	-- },
	-- [2] = {},
	-- [3] = {},
	-- [4] = {},
}

tableTracker = {
	-- ["2"] = 1,
}

--[===[
	exports["kgv-blackjack"]:SetGetChipsCallback(function(source)
		return 0 -- [[ return money ]]
	end)

	exports["kgv-blackjack"]:SetTakeChipsCallback(function(source, amount)
		--[[ money = money - amount? ]]
	end)

	exports["kgv-blackjack"]:SetGiveChipsCallback(function(source, amount)
		--[[ money = money + amount? ]]
	end)
--]===]

getChipsCallback = nil
takeChipsCallback = nil
giveChipsCallback = nil

function FindPlayerIdx(tbl, src)

	for i = 1, #tbl do
		if tbl[i].player == src then
			return i
		end
	end

	return nil
end

function SetGetChipsCallback(cb)
	getChipsCallback = cb
end

function SetTakeChipsCallback(cb)
	takeChipsCallback = cb
end

function SetGiveChipsCallback(cb)
	giveChipsCallback = cb
end

function GiveMoney(player, money)
	if giveChipsCallback ~= nil then
		giveChipsCallback(player, money)
	end
	-- DebugPrint("MONEY: GIVE "..GetPlayerName(player):upper().." "..money)
end

function TakeMoney(player, money)
	if takeChipsCallback ~= nil then
		takeChipsCallback(player, money)
	end
	-- DebugPrint("MONEY: TAKE "..GetPlayerName(player):upper().." "..money)
end

function HaveAllPlayersBetted(table)
	for i,v in pairs(table) do
		if v.bet < 1 then 
			return false
		end
	end
	return true
end

function ArePlayersStillIn(table)
	for i,v in pairs(table) do
		if v.player_in == true then
			return true
		end
	end
	return false
end

function PlayDealerAnim(dealer, animDict, anim)
	TriggerClientEvent("BLACKJACK:PlayDealerAnim", -1, dealer, animDict, anim)
end

function PlayDealerSpeech(dealer, speech)
	TriggerClientEvent("BLACKJACK:PlayDealerSpeech", -1, dealer, speech)
end

function SetPlayerBet(i, seat, bet, betId, double, split)
	split = split or false
	double = double or false


	local num = FindPlayerIdx(players[i], source)

	if num ~= nil then
		if double == false and split == false then
			TakeMoney(source, bet)

			players[i][num].bet = tonumber(bet)			
		end
		
		TriggerClientEvent("BLACKJACK:PlaceBetChip", -1, i, 5-seat, bet, double, split)
	else
		DebugPrint("TABLE "..i..": PLAYER "..source.." ATTEMPTED BET BUT NO LONGER TRACKED?")
	end
end

RegisterServerEvent("BLACKJACK:SetPlayerBet")
AddEventHandler('BLACKJACK:SetPlayerBet', SetPlayerBet)

function CheckPlayerBet(i, bet)
	DebugPrint("TABLE "..i..": CHECKING "..GetPlayerName(source):upper().."'s CHIPS")

	local playerChips = 0 -- Get money

	if getChipsCallback ~= nil then
		playerChips = getChipsCallback(source)
	end

	local canBet = false

	if playerChips ~= nil then
		if playerChips >= bet then
			canBet = true
		end
	end

	TriggerClientEvent("BLACKJACK:BetReceived", source, canBet)
end

RegisterServerEvent("BLACKJACK:CheckPlayerBet")
AddEventHandler("BLACKJACK:CheckPlayerBet", CheckPlayerBet)

RegisterServerEvent("BLACKJACK:ReceivedMove")

function StartTableThread(i)
	Citizen.CreateThread(function()
		local index = i
		-- DebugPrint(index)
		while true do Wait(0)
			if players[index] and #players[index] ~= 0 then
				DebugPrint("WAITING FOR ALL PLAYERS AT TABLE "..index.." TO PLACE THEIR BETS.")
				
				-- TODO: DONT FORGET TO REMOVE THIS JESUS CHRIST
				
				-- local bet = 15000
				
				-- TakeMoney(players[index][1].player, bet)
				-- players[index][1].bet = bet
				
				-- for num,_ in pairs(players[index]) do
					-- TriggerClientEvent("BLACKJACK:RequestBets", players[index][num].player)
				-- end
				
				PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_place_bet_request")
				PlayDealerSpeech(index, "MINIGAME_DEALER_PLACE_CHIPS")
				
				repeat Wait(0) until HaveAllPlayersBetted(players[index]) or #players[index] == 0
				
				if #players[index] == 0 then
					DebugPrint("BETTING ENDED AT TABLE "..index..", NO MORE PLAYERS")
					-- break
				else
					DebugPrint("BETS PLACED AT TABLE "..index..", STARTING GAME")
	
					PlayDealerSpeech(index, "MINIGAME_DEALER_CLOSED_BETS")
					
					local currentPlayers = {table.unpack(players[i])}
					local deck = getDeck()
					local dealerHand = {}
					
					local gameRunning = true
					
					Wait(1500)
					
					for x=1,2 do
						local card = takeCard(deck)
						table.insert(dealerHand, card)
						
						TriggerClientEvent("BLACKJACK:GiveCard", -1, index, 0, #dealerHand, card, #dealerHand == 1)
						
						if #dealerHand == 1 then
							PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_deal_card_self")
							DebugPrint("TABLE "..index..": DEALT DEALER [HIDDEN]")
						else
							PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_deal_card_self_second_card")
							DebugPrint("TABLE "..index..": DEALT DEALER "..card)
						end
						Wait(2000)
	
						if #dealerHand > 1 then
							PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_"..cardValue(dealerHand[2]))
						end
						
						for i,v in pairs(currentPlayers) do
							local card = takeCard(deck)
							TriggerClientEvent("BLACKJACK:GiveCard", -1, index, v.seat, #v.hand+1, card)
							PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_deal_card_player_0" .. 5-v.seat)
							table.insert(v.hand, card)
							
							Wait(2000)
						
							
							DebugPrint("TABLE "..index..": DEALT "..GetPlayerName(v.player):upper().." "..card)
							
							if handValue(v.hand) == 21 then
								TriggerClientEvent("BLACKJACK:GameEndReaction", v.player, "good")
								DebugPrint("TABLE "..index..": "..GetPlayerName(v.player):upper().." HAS BLACKJACK")
								GiveMoney(v.player, v.bet*2.5)
								v.player_in = false
								PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_BLACKJACK")
							else
								PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_"..handValue(v.hand))
							end
						end
					end
					
					-- female_dealer_focus_player_01_idle
					
					if handValue(dealerHand) == 21 then
						DebugPrint("TABLE "..index..": DEALER HAS BLACKJACK")
						PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_check_and_turn_card")
						Wait(2000)
						PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_BLACKJACK")
						TriggerClientEvent("BLACKJACK:DealerTurnOverCard", -1, index)
						gameRunning = false
					elseif cardValue(dealerHand[2]) == 10 or cardValue(dealerHand[2]) == 11 then
						DebugPrint("TABLE "..index..": DEALER HAS A 10, CHECKING..")
						PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_check_card")
						Wait(2000)
					end
					
					if gameRunning == true then
						for i,v in pairs(currentPlayers) do
							if v.player_in then
								PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_intro")
								Wait(1500)
								PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_ANOTHER_CARD")
								while v.player_in == true and #v.hand < 5 do
									Wait(0)
									PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle")
									DebugPrint("TABLE "..index..": AWAITING MOVE FROM "..GetPlayerName(v.player):upper())
									TriggerClientEvent("BLACKJACK:RequestMove", v.player)
									local receivedMove = false
									local move = "stand"
									local eventHandler = AddEventHandler("BLACKJACK:ReceivedMove", function(m)
										if source ~= v.player then return end
										move = m
										receivedMove = true
									end)

									while receivedMove == false and tableTracker[tostring(v.player)] ~= nil do
										Citizen.Wait(0)
									end
									--repeat Wait(0) until receivedMove == true
									RemoveEventHandler(eventHandler)
									
									if not receivedMove then
										DebugPrint("TABLE "..index..": "..v.player.." WAS PUT OUT DUE TO LEAVING")
										v.player_in = false
										TriggerClientEvent("BLACKJACK:RetrieveCards", -1, index, v.seat)
									else
										if move == "hit" then
											local card = takeCard(deck)
											TriggerClientEvent("BLACKJACK:GiveCard", -1, index, v.seat, #v.hand+1, card)
											-- PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_outro")
											-- Wait(1500)
											PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_hit_card_player_0" .. 5-v.seat)
											table.insert(v.hand, card)
											Wait(1500)
											DebugPrint("TABLE "..index..": DEALT "..GetPlayerName(v.player):upper().." "..card)
											
											if handValue(v.hand) == 21 then
												-- PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_outro")
												-- Wait(1500)
												DebugPrint("TABLE "..index..": "..GetPlayerName(v.player):upper().." HAS 21")
												-- v.player_in = false
												PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_"..handValue(v.hand))
												break
											elseif handValue(v.hand) > 21 then
												-- PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_outro")
												-- Wait(1500)
												TriggerClientEvent("BLACKJACK:GameEndReaction", v.player, "bad")
												DebugPrint("TABLE "..index..": "..GetPlayerName(v.player):upper().." WENT BUST")
												v.player_in = false
												PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_PLAYER_BUST")
											else
												-- Wait(1000)
												PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_"..handValue(v.hand))
											end
										elseif move == "double" then
											TakeMoney(v.player, v.bet)
											v.bet = v.bet*2
											
											-- TriggerClientEvent("BLACKJACK:PlaceBetChip", -1, i, 5-v.seat, betId)
											
											local card = takeCard(deck)
											TriggerClientEvent("BLACKJACK:GiveCard", -1, index, v.seat, #v.hand+1, card)
											-- PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_outro")
											-- Wait(1500)
											PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_hit_card_player_0" .. 5-v.seat)
											table.insert(v.hand, card)
											Wait(1500)
											DebugPrint("TABLE "..index..": DEALT "..GetPlayerName(v.player):upper().." "..card)
											
											if handValue(v.hand) == 21 then
												-- PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_outro")
												-- Wait(1500)
												DebugPrint("TABLE "..index..": "..GetPlayerName(v.player):upper().." HAS 21")
												-- v.player_in = false
												PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_"..handValue(v.hand))
												break
											elseif handValue(v.hand) > 21 then
												-- PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_outro")
												-- Wait(1500)
												TriggerClientEvent("BLACKJACK:GameEndReaction", v.player, "bad")
												DebugPrint("TABLE "..index..": "..GetPlayerName(v.player):upper().." WENT BUST")
												v.player_in = false
												PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_PLAYER_BUST")
											else
												-- Wait(2000)
												PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_"..handValue(v.hand))
											end
											
											break
										elseif move == "split" then
											TakeMoney(v.player, v.bet)
											v.bet = v.bet*2
											
											-- TriggerClientEvent("BLACKJACK:PlaceBetChip", -1, i, 5-v.seat, betId)
											
											PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_split_card_player_0" .. 5-v.seat)
											
											v.splitHand = {}
											
											local splitCard = table.remove(v.hand, 2)
											table.insert(v.splitHand, splitCard)
											
											Wait(500)
											
											TriggerClientEvent("BLACKJACK:SplitHand", -1, index, v.seat, #v.splitHand)
											
											Wait(1000)
											
											local card = takeCard(deck)
											TriggerClientEvent("BLACKJACK:GiveCard", -1, index, v.seat, #v.hand+1, card, false, false)
											-- PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_outro")
											-- Wait(1500)
											PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_hit_card_player_0" .. 5-v.seat)
											
											-- female_dealer_focus_player_01_idle_split
											
											table.insert(v.hand, card)
											Wait(1500)
											DebugPrint("TABLE "..index..": DEALT "..GetPlayerName(v.player):upper().." "..card)
											
											if handValue(v.hand) == 21 then
												-- PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_outro")
												-- Wait(1500)
												DebugPrint("TABLE "..index..": "..GetPlayerName(v.player):upper().." HAS 21")
												-- v.player_in = false
												PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_BLACKJACK")
												break
											elseif handValue(v.hand) > 21 then
												-- PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_outro")
												-- Wait(1500)
												TriggerClientEvent("BLACKJACK:GameEndReaction", v.player, "bad")
												DebugPrint("TABLE "..index..": "..GetPlayerName(v.player):upper().." WENT BUST")
												-- v.player_in = false
												PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_PLAYER_BUST")
											else
												-- Wait(2000)
												PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_"..handValue(v.hand))
											end
											
											local card = takeCard(deck)
											TriggerClientEvent("BLACKJACK:GiveCard", -1, index, v.seat, #v.splitHand+1, card, false, true)
											-- PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_outro")
											-- Wait(1500)
											PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_hit_second_card_player_0" .. 5-v.seat)
											
											table.insert(v.splitHand, card)
											Wait(1500)
											DebugPrint("TABLE "..index..": DEALT "..GetPlayerName(v.player):upper().." "..card)
											
											if handValue(v.splitHand) == 21 then
												-- PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_outro")
												-- Wait(1500)
												DebugPrint("TABLE "..index..": "..GetPlayerName(v.player):upper().." HAS 21")
												-- v.player_in = false
												PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_"..handValue(v.splitHand))
												break
											elseif handValue(v.splitHand) > 21 then
												-- PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_outro")
												-- Wait(1500)
												TriggerClientEvent("BLACKJACK:GameEndReaction", v.player, "bad")
												DebugPrint("TABLE "..index..": "..GetPlayerName(v.player):upper().." WENT BUST")
												-- v.player_in = false
												PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_PLAYER_BUST")
											else
												-- Wait(2000)
												PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_"..handValue(v.splitHand))
											end
										
											-- PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_intro")
											-- Wait(1500)
											PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_ANOTHER_CARD")
											repeat Wait(0)
												PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle")
												DebugPrint("TABLE "..index..": AWAITING MOVE FROM "..GetPlayerName(v.player):upper())
												TriggerClientEvent("BLACKJACK:RequestMove", v.player)
												local receivedMove = false
												local move = "stand"
												local eventHandler = AddEventHandler("BLACKJACK:ReceivedMove", function(m)
													if source ~= v.player then return end
													move = m
													receivedMove = true
												end)
												repeat Wait(0) until receivedMove == true
												RemoveEventHandler(eventHandler)
												
												if move == "hit" then
													local card = takeCard(deck)
													TriggerClientEvent("BLACKJACK:GiveCard", -1, index, v.seat, #v.hand+1, card, false, false)
													-- PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_outro")
													-- Wait(1500)
													PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_hit_card_player_0" .. 5-v.seat)
													table.insert(v.hand, card)
													Wait(1500)
													DebugPrint("TABLE "..index..": DEALT "..GetPlayerName(v.player):upper().." "..card)
													
													if handValue(v.hand) == 21 then
														-- PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_outro")
														-- Wait(1500)
														DebugPrint("TABLE "..index..": "..GetPlayerName(v.player):upper().." HAS 21")
														-- v.player_in = false
														PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_"..handValue(v.hand))
														break
													elseif handValue(v.hand) > 21 then
														-- PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_outro")
														-- Wait(1500)
														TriggerClientEvent("BLACKJACK:GameEndReaction", v.player, "bad")
														DebugPrint("TABLE "..index..": "..GetPlayerName(v.player):upper().." WENT BUST")
														-- v.player_in = false
														PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_PLAYER_BUST")
													else
														-- Wait(1000)
														PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_"..handValue(v.hand))
													end
												elseif move == "stand" then
													-- PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_outro_split")
													-- Wait(1500)
													break
												end
											until handValue(v.hand) >= 21 or #v.hand == 5
											
											PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_outro")
											Wait(1500)
											
											PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_intro_split")
											Wait(1500)
											PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_ANOTHER_CARD")
											
											repeat Wait(0)
												PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_split")
												DebugPrint("TABLE "..index..": AWAITING MOVE FROM "..GetPlayerName(v.player):upper())
												TriggerClientEvent("BLACKJACK:RequestMove", v.player)
												local receivedMove = false
												local move = "stand"
												local eventHandler = AddEventHandler("BLACKJACK:ReceivedMove", function(m)
													if source ~= v.player then return end
													move = m
													receivedMove = true
												end)
												repeat Wait(0) until receivedMove == true
												RemoveEventHandler(eventHandler)
												
												if move == "hit" then
													local card = takeCard(deck)
													TriggerClientEvent("BLACKJACK:GiveCard", -1, index, v.seat, #v.splitHand+1, card, false, true)
													-- PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_outro")
													-- Wait(1500)
													PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_hit_second_card_player_0" .. 5-v.seat)
													table.insert(v.splitHand, card)
													Wait(1500)
													DebugPrint("TABLE "..index..": DEALT "..GetPlayerName(v.player):upper().." "..card)
													
													if handValue(v.splitHand) == 21 then
														-- PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_outro")
														-- Wait(1500)
														DebugPrint("TABLE "..index..": "..GetPlayerName(v.player):upper().." HAS 21")
														-- v.player_in = false
														PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_"..handValue(v.splitHand))
														break
													elseif handValue(v.splitHand) > 21 then
														-- PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_outro")
														-- Wait(1500)
														TriggerClientEvent("BLACKJACK:GameEndReaction", v.player, "bad")
														DebugPrint("TABLE "..index..": "..GetPlayerName(v.player):upper().." WENT BUST")
														-- v.player_in = false
														PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_PLAYER_BUST")
													else
														-- Wait(1000)
														PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_"..handValue(v.splitHand))
													end
												elseif move == "stand" then
													break
												end
											until handValue(v.splitHand) >= 21 or #v.splitHand == 5
											
											if handValue(v.hand) > 21 and handValue(v.splitHand) > 21 then
												v.player_in = false
											end
											
											PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_outro_split")
											Wait(1500)
											
											break
											
											-- end
										elseif move == "stand" then
											-- PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_outro")
											-- Wait(1500)
											break
										end
									end
								end
								if not v.splitHand then
									PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_dealer_focus_player_0".. 5-v.seat .."_idle_outro")
									Wait(1500)
								end
							end
						end
						
						--  Remove offline players from table
						local j = 1

						while j <= #currentPlayers do
							local player = currentPlayers[j]

							if tableTracker[tostring(player.player)] == nil then
								DebugPrint("TABLE "..index..": "..player.player.." WAS REMOVED FROM PLAYERS LIST FOR LEAVING")
								table.remove(currentPlayers, j)
							else
								j = j + 1
							end
						end

						if ArePlayersStillIn(currentPlayers) then
							PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_turn_card")
							Wait(1000)
							TriggerClientEvent("BLACKJACK:DealerTurnOverCard", -1, index)
							Wait(1000)
							PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_"..handValue(dealerHand))
						end
							
						if handValue(dealerHand) < 17 and ArePlayersStillIn(currentPlayers) then
							repeat
								local card = takeCard(deck)
								table.insert(dealerHand, card)
								
								TriggerClientEvent("BLACKJACK:GiveCard", -1, index, 0, #dealerHand, card, #dealerHand == 1)
								
								PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_deal_card_self_second_card")
								DebugPrint("TABLE "..index..": DEALT DEALER "..card)
								Wait(2000)
								PlayDealerSpeech(index, "MINIGAME_BJACK_DEALER_"..handValue(dealerHand))
							until handValue(dealerHand) >= 17
						end
					end
					
					if handValue(dealerHand) > 21 then
						PlayDealerSpeech(index, "MINIGAME_DEALER_BUSTS")
					-- elseif handValue(dealerHand) < 21 and ArePlayersStillIn(currentPlayers) then
						-- PlayDealerSpeech(index, "MINIGAME_DEALER_WINS")
					end
					
					DebugPrint("TABLE "..index..": DEALER HAS "..handValue(dealerHand))
						
					for i,v in pairs(currentPlayers) do
						-- if v.player_in then
						
							DebugPrint("TABLE "..index..": "..GetPlayerName(v.player):upper().." HAS "..handValue(v.hand))
					
							if v.player_in == true and (handValue(v.hand) > handValue(dealerHand) or handValue(dealerHand) > 21) then -- WIN
								if v.splitHand then
									if handValue(v.splitHand) > handValue(dealerHand) or handValue(dealerHand) > 21 then -- WIN
										TriggerClientEvent("BLACKJACK:GameEndReaction", v.player, "good")
										DebugPrint("TABLE "..index..": "..GetPlayerName(v.player):upper().." WON")
										v.player_in = false
									end
								end
								TriggerClientEvent("BLACKJACK:GameEndReaction", v.player, "good")
								DebugPrint("TABLE "..index..": "..GetPlayerName(v.player):upper().." WON")
								GiveMoney(v.player, v.bet*2)
								v.player_in = false
							end
							if v.player_in == true and handValue(v.hand) == handValue(dealerHand) then -- PUSH
								if v.splitHand then
									if handValue(v.splitHand) == handValue(dealerHand) then -- PUSH
										TriggerClientEvent("BLACKJACK:GameEndReaction", v.player, "impartial")
										DebugPrint("TABLE "..index..": "..GetPlayerName(v.player):upper().." IS PUSH")
										v.player_in = false
									end
								end
								TriggerClientEvent("BLACKJACK:GameEndReaction", v.player, "impartial")
								DebugPrint("TABLE "..index..": "..GetPlayerName(v.player):upper().." IS PUSH")
								GiveMoney(v.player, v.bet)
								v.player_in = false
							end
							if v.player_in == true and handValue(v.hand) < handValue(dealerHand) and handValue(dealerHand) <= 21 then -- LOSE
								if v.splitHand then
									if handValue(v.splitHand) < handValue(dealerHand) and handValue(dealerHand) <= 21 then -- LOSE
										TriggerClientEvent("BLACKJACK:GameEndReaction", v.player, "bad")
										DebugPrint("TABLE "..index..": "..GetPlayerName(v.player):upper().." LOST")
										v.player_in = false
									end
								end
								TriggerClientEvent("BLACKJACK:GameEndReaction", v.player, "bad")
								DebugPrint("TABLE "..index..": "..GetPlayerName(v.player):upper().." LOST")
								v.player_in = false
							end
						-- end
					end
					
					if handValue(dealerHand) >= 17 then
						PlayDealerAnim(index, "anim_casino_b@amb@casino@games@shared@dealer@", "female_dealer_reaction_impartial_var0"..math.random(1,3))
					elseif handValue(dealerHand) > 21 then
						PlayDealerAnim(index, "anim_casino_b@amb@casino@games@shared@dealer@", "female_dealer_reaction_good_var0"..math.random(1,3))
					else
						PlayDealerAnim(index, "anim_casino_b@amb@casino@games@shared@dealer@", "female_dealer_reaction_bad_var0"..math.random(1,3))
					end
					
					Wait(2500)
					
					for i,v in pairs(currentPlayers) do
						PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_retrieve_cards_player_0".. 5-v.seat)
						Wait(500)
						TriggerClientEvent("BLACKJACK:RetrieveCards", -1, index, v.seat)
						Wait(1500)
				
						v.bet = 0
						v.player_in = true
						v.hand = {}
						v.splitHand = nil
						
						TriggerClientEvent("BLACKJACK:RequestBets", v.player, index)
					end
					
					PlayDealerAnim(index, "anim_casino_b@amb@casino@games@blackjack@dealer", "female_retrieve_own_cards_and_remove")
					Wait(500)
					TriggerClientEvent("BLACKJACK:RetrieveCards", -1, index, 0)
					Wait(1500)
					
					-- while true do Wait(0) end
				end
			end
		end
	end)
end

Citizen.CreateThread(function() -- INIT
	for i,_ in pairs(tables) do
		StartTableThread(i)
		players[i] = {}
	end
end)

function PlayerSatDown(i, seat)
	DebugPrint(GetPlayerName(source):upper() .. " SAT DOWN AT TABLE " .. i)
	
	-- player = source
	-- index = i
	-- chair = seat
	
	table.insert(players[i], {player = source, seat = seat, hand = {}, player_in = true, bet = 0})
	tableTracker[tostring(source)] = i
	
	-- PlayDealerSpeech(i, "MINIGAME_DEALER_GREET")
	
	TriggerClientEvent("BLACKJACK:RequestBets", source, i)
	
	-- DebugPrint(#players[i])
	
	-- Citizen.CreateThread(function()
		-- local deck = getDeck()
		
		-- local card1 = takeCard(deck)
		-- TriggerClientEvent("BLACKJACK:GiveCard", player, index, card1)
		-- TriggerClientEvent("BLACKJACK:ANIM:DealCard", -1, index, chair)
		
		-- Wait(3000)
		
		-- local card2 = takeCard(deck)
		-- TriggerClientEvent("BLACKJACK:GiveCard", player, index, card2)
		-- TriggerClientEvent("BLACKJACK:ANIM:DealCard", -1, index, chair)
	-- end)
	
	-- local card1 = takeCard(deck)
	-- local card2 = takeCard(deck)
	
	-- TriggerEvent('_chat:messageEntered', GetPlayerName(source), {0, 0, 0}, "has " .. handValue({card1, card2}) .. " ("..cardValue(card1)..", "..cardValue(card2)..")")
end

RegisterServerEvent("BLACKJACK:PlayerSatDown")
AddEventHandler('BLACKJACK:PlayerSatDown', PlayerSatDown)


function PlayerSatUp(i)
	DebugPrint(GetPlayerName(source):upper() .. " LEFT TABLE "..i)

	local num = FindPlayerIdx(players[i], source)

	if num ~= nil then
		DebugPrint(GetPlayerName(source):upper() .. " SUCCESSFULLY REMOVED FROM TABLE "..i)
		
		table.remove(players[i], num)
	
		PlayDealerSpeech(i, "MINIGAME_DEALER_LEAVE_NEUTRAL_GAME")
	end
end

RegisterServerEvent("BLACKJACK:PlayerSatUp")
AddEventHandler('BLACKJACK:PlayerSatUp', PlayerSatUp)

function PlayerLeft()
	local playerTbl = tableTracker[tostring(source)]

	if playerTbl ~= nil then
		DebugPrint(GetPlayerName(source):upper() .. " LEFT SERVER")

		local num = FindPlayerIdx(players[playerTbl], source)
		
		if num ~= nil then
			DebugPrint(GetPlayerName(source):upper() .. " REMOVED FROM TABLE FOR LEAVING")
			table.remove(players[playerTbl], num)
		end

		tableTracker[tostring(source)] = nil
	end
end

AddEventHandler("playerDropped", PlayerLeft)

exports("SetGetChipsCallback", SetGetChipsCallback)
exports("SetTakeChipsCallback", SetTakeChipsCallback)
exports("SetGiveChipsCallback", SetGiveChipsCallback)