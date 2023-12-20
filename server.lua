
local newdata

RegisterServerEvent("hud:setServerMeta")
AddEventHandler("hud:setServerMeta", function(health, armor, thirst, hunger, stress)
    local src = source
    local p1 = ESX.GetPlayerFromId(src)
    local citizenid = p1.identifier
    
	
    meta = { 
        ["health"] = health,
        ["armor"] = armor,
        ["thirst"] = thirst,
        ["hunger"] = hunger,
        ["stress"] = stress
    }

    local encode = json.encode(meta)
    exports.oxmysql:execute('UPDATE users SET metadata = ? WHERE identifier = ?', {encode, identifier})

    TriggerClientEvent('DoLongHudText',src, 'Staatus salvestatud')
    print(json.encode(meta))
end)



    


RegisterServerEvent('hud:SetMeta')
AddEventHandler('hud:SetMeta', function()
    local src = source
    local p2 = ESX.GetPlayerFromId(src)
    local cid = p2.identifier
    local meta = MySQL.query.await("SELECT * FROM users WHERE identifier = ?", {cid})
    
    if meta then
        TriggerClientEvent("hud:setClientMeta", src, json.decode(meta[1].charmeta))
    end
    --cb(meta)
    /*MySQL.query.await("SELECT * FROM players WHERE citizenid = ?", {cid}, function(result))
	exports.oxmysql:execute("SELECT * FROM players WHERE citizenid = ?", {cid}, function(result)
        TriggerClientEvent("hud:setClientMeta", src, json.decode(result[1].charmeta))
	end)*/

end)


RegisterServerEvent('server:alterStress')
AddEventHandler('server:alterStress',function(positive, alteredValue)
	local src = source
    local p2 = NPX.Functions.GetPlayer(src)
    local cid = p2.PlayerData.citizenid
	exports.oxmysql:execute("SELECT * FROM players WHERE citizenid = ?", {cid}, function(result)
		local myStress = result[1].stress_level
		Citizen.Wait(500)
		if positive then
			if myStress < tonumber(10000) then
				newStress = myStress + alteredValue
				exports.oxmysql:execute("UPDATE players SET `stress_level` = ? WHERE citizenid = ?",{newStress, cid})
				TriggerClientEvent('client:updateStress', src, newStress)
			end
		else
			if myStress > tonumber(1000) then
				Stress = myStress - alteredValue
				exports.oxmysql:execute("UPDATE players SET `stress_level` = ? WHERE citizenid = ?",{Stress, cid})
				TriggerClientEvent('client:updateStress', src, Stress)
			end
		end
	end)
end)


