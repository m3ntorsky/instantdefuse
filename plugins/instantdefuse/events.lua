AddEventHandler("OnPostGrenadeThrown", function(event --[[ Event ]])
    local playerID = event:GetInt("userid")
    local player = GetPlayer(playerID)
    local weapon = event:GetString("weapon")

    if weapon == "smokegrenade" or weapon == "flashbang" or weapon == "decoy" then return EventResult.Continue end

    if weapon == "hegrenade" then
        Threat.HE = Threat.HE + 1
    end

    if weapon == "incgrenade" or weapon == "molotov" then
        Threat.Molotov = Threat.Molotov + 1
    end

    Utils.DebugMsg(LogType_t.Debug, string.format("OnPostGrenadeThrown: %s - isBot: %s",weapon, tostring(player:IsFakeClient())))
    Utils.PrintThreatLevel()

    return EventResult.Continue
end)

AddEventHandler("OnInfernoStartburn", function(event --[[ Event ]])

    Utils.DebugMsg(LogType_t.Debug,"OnInfernoStartburn")
    Utils.DebugMsg(LogType_t.Debug,"EntityId " .. event:GetInt("entityid"))

    local infernoVector = Vector(event:GetInt("x"), event:GetInt("y"), event:GetInt("z"))

    local bombVector = Utils.Game.GetC4PlantedVector()

    if bombVector == nil then return EventResult.Continue end

    local distance = Utils.Vector3.Distance(infernoVector, bombVector)

    Utils.DebugMsg(LogType_t.Debug, string.format("Inferno Distance to bomb: %s", distance))

    if distance > 250 then return EventResult.Continue end

    table.insert(Threat.Inferno, event:GetInt("entityid"))

    Utils.PrintThreatLevel()

    return EventResult.Continue
end)

AddEventHandler("OnPostInfernoExtinguish", function(event --[[ Event ]])

    Utils.DebugMsg(LogType_t.Debug,"OnPostInfernoExtinguish")
    Utils.Table.RemoveValue(Threat.Inferno, event:GetInt("entityid"))
    Utils.PrintThreatLevel()

    return EventResult.Continue
end)

AddEventHandler("OnPostInfernoExpire", function(event --[[ Event ]])

    Utils.DebugMsg(LogType_t.Debug,"OnPostInfernoExpire")
    Utils.Table.RemoveValue(Threat.Inferno, event:GetInt("entityid"))
    Utils.PrintThreatLevel()

    return EventResult.Continue
end)

AddEventHandler("OnPostHegrenadeDetonate", function(event --[[ Event ]])

    Utils.DebugMsg(LogType_t.Debug,"OnPostHegrenadeDetonate")
    if Threat.HE > 0 then Threat.HE = Threat.HE - 1 end
    Utils.PrintThreatLevel()

    return EventResult.Continue
end)

AddEventHandler("OnPostMolotovDetonate", function(event --[[ Event ]])

    Utils.DebugMsg(LogType_t.Debug,"OnPostMolotovDetonate")
    if Threat.Molotov > 0 then Threat.Molotov = Threat.Molotov - 1 end
    Utils.PrintThreatLevel()
    return EventResult.Continue
end)

AddEventHandler("OnPostRoundStart", function(event --[[ Event ]])
    BombPlantedTime = nil
    BombTicking = false
    Threat = {
        HE = 0,
        Molotov = 0,
        Inferno = {}
    }
    Utils.DebugMsg(LogType_t.Debug,"OnPostRoundStart")
    return EventResult.Continue
end)

AddEventHandler("OnPostBombPlanted", function(event --[[ Event ]])
    Utils.DebugMsg(LogType_t.Debug,"OnPostBombPlanted")
    BombPlantedTime = GetTime()
    BombTicking = true

    return EventResult.Continue
end)

AddEventHandler("OnPostBombBegindefuse", function(event --[[ Event ]])
    Utils.DebugMsg(LogType_t.Debug,"OnPostBombBegindefuse")

    local playerID = event:GetInt("userid")
    local player = GetPlayer(playerID)

    if player == nil then return EventResult.Continue end

    TryInstantDefuse(player)

    return EventResult.Continue
end)
