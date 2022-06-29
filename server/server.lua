local VorpCore = {}

TriggerEvent("getCore",function(core)
    VorpCore = core
end)

VorpInv = exports.vorp_inventory:vorp_inventoryApi()

VorpInv.RegisterUsableItem("electricitypaper", function(data)
	VorpInv.CloseInv(data.source)
    VorpInv.subItem(data.source, "electricitypaper", 1)
	TriggerClientEvent("void_blackout:usepaper", data.source)
end)

RegisterServerEvent('void_blackout:checkitem')
AddEventHandler('void_blackout:checkitem', function(itemname)
    local _source = source
    local count = VorpInv.getItemCount(_source, itemname)
    if count >= 1 then
        TriggerClientEvent('void_blackout:minigame', _source)
    else
        TriggerClientEvent('vorp:TipBottom',_source, _U("NoLock"), 5000)
    end

end)

RegisterServerEvent('void_blackout:setupblackout')
AddEventHandler('void_blackout:setupblackout', function()
    TriggerClientEvent('void_blackout:explosion', -1, Config.explosion.coords.x, Config.explosion.coords.y, Config.explosion.coords.z, Config.explosion.Tagid, Config.explosion.vfxTaghash, Config.explosion.damageScale, true, false, true)
    TriggerClientEvent('void_blackout:blackouton', -1)
    Citizen.Wait(1000)
    TriggerClientEvent('vorp:ShowTopNotification', -1, _U("BlackoutOn1"), _U("BlackoutOn2"), 10000)
    Citizen.Wait(Config.blackoutperiod*60000)
    TriggerClientEvent('vorp:ShowTopNotification', -1, _U("BlackoutOff1"), _U("BlackoutOff2"), 10000)
    TriggerClientEvent('void_blackout:blackoutoff', -1)
end)

RegisterServerEvent('void_blackout:removeitem')
AddEventHandler('void_blackout:removeitem', function(itemname)
    local _source = source
    local item = itemname
    VorpInv.subItem(_source, item, 1)

end)