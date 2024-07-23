TryInstantDefuse = function (player --[[Player]])
    Utils.DebugMsg(LogType_t.Debug, "Attempting instant defuse...")

    if not BombTicking  then
        Utils.DebugMsg(LogType_t.Debug, "Bomb is not planted!")
        return
    end

    Utils.PrintThreatLevel()

    local plantedBomb =  Utils.Game.GetCPlantedC4()

    if plantedBomb == nil then
        Utils.DebugMsg(LogType_t.Debug, "Planted bomb is nil!")
        return
    end

    if plantedBomb.CannotBeDefused then
        Utils.DebugMsg(LogType_t.Debug, "Planted bomb can not be defused!")
        return       
    end

    if config:Fetch("instantdefuse.HEThreatCheck") and Threat.HE > 0 then
        Utils.DebugMsg(LogType_t.Debug, "Instant Defuse not possible because a HE threat is active!")
        player:SendMsg(MessageType.Chat, string.format("%s %s", config:Fetch("instantdefuse.Prefix"), FetchTranslation("instantdefuse.warning.hethreat")))
        return
    end

    if config:Fetch("instantdefuse.MolotovThreatCheck") and (Threat.Molotov > 0 or #Threat.Inferno > 0) then
        Utils.DebugMsg(LogType_t.Debug, "Instant Defuse not possible because a molotov threat is active")
        player:SendMsg(MessageType.Chat, string.format("%s %s", config:Fetch("instantdefuse.Prefix"), FetchTranslation("instantdefuse.warning.molotovthreat")))
        return
    end

    if config:Fetch("instantdefuse.AliveTerroristCheck") and Utils.Game.GetCountTeamAlivePlayers(Team.T) > 0 then
        Utils.DebugMsg(LogType_t.Debug, "Terrorists are still alive")
        return
    end

    local bombTimeUntilDetonation = plantedBomb.TimerLength - (GetTime() - BombPlantedTime)

    local defuseLength = plantedBomb.defuseLength

    if(defuseLength ~= 5 and defuseLength ~= 10) then
        if player:CCSPlayerController().PawnHasDefuser then  defuseLength = 5 else defuseLength = 10 end
    end

    Utils.DebugMsg(LogType_t.Debug, string.format("DefuseLength: %s", DefuseLength))

    local bombCanBeDefusedInTime = (bombTimeUntilDetonation - defuseLength) >= 0

    local bombCanBeDefusedInTimeWithKit = (bombTimeUntilDetonation - 5) >= 0


    if config:Fetch("instantdefuse.AdditionalKitCheck") and not bombCanBeDefusedInTime and bombCanBeDefusedInTimeWithKit and defuseLength == 10 then
        local  playersTeam = Utils.Game.GetPlayersTeam(Team.CT)
        local hasDefuseKit = false
        for i = 1, #playersTeam, 1 do
            local tempPlayer = playersTeam[i]
            if tempPlayer:CCSPlayerController().PawnIsAlive and tempPlayer:CCSPlayerController().PawnHasDefuser then
                hasDefuseKit = true             
            end
        end

        if hasDefuseKit then
            playermanager:SendMsg(MessageType.Chat, string.format("%s %s", config:Fetch("instantdefuse.Prefix"), FetchTranslation("instantdefuse.info.teammatehasdefkit")))
            Utils.DebugMsg(LogType_t.Debug,"Bomb can not be defused in time but another Counter-Terrorist player has a Defuse-Kit!");
            return
        end
        return
    end

    NextTick( function ()
        plantedBomb.DefuseCountDown = 0
        Utils.DebugMsg(LogType_t.Debug,"Instant Defuse was successful");
        player:SendMsg(MessageType.Chat, string.format("%s %s", config:Fetch("instantdefuse.Prefix"), FetchTranslation("instantdefuse.info.defusesuccess")))
    end)
     
end