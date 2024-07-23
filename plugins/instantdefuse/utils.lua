Utils = {
    DebugMsg = function(logType --[[LogType_t]], message --[[string]])
        if not config:Fetch("instantdefuse.Debug") then return end
        print(message)
        logger:Write(logType , message)
    end
    ,
    PrintThreatLevel = function()
        Utils.DebugMsg(LogType_t.Debug, string.format("Threat-Levels: HE [%s], Molotov [%s], Inferno [%s]", Threat.HE, Threat.Molotov, #Threat.Inferno));
        print("Before removal:", table.concat(Threat.Inferno, ", "))
    end
    ,

    Game = {

        GetCPlantedC4 = function()
            local bombManagers = FindEntitiesByClassname("planted_c4")
            if #bombManagers < 1 then return nil end
            return CPlantedC4(bombManagers[#bombManagers]:ToPtr())
        end
        ,
        GetC4PlantedVector = function ()
            local bombManagers = FindEntitiesByClassname("planted_c4")
            if #bombManagers < 1 then return nil end
            local entity = CBaseEntity(bombManagers[#bombManagers]:ToPtr())
            return entity.CBodyComponent.SceneNode.AbsOrigin
        end
        ,
        GetCountTeamAlivePlayers = function(teamID --[[Team]])
            local playersAlive = 0
            for i = 0, playermanager:GetPlayerCap() - 1, 1 do
                local player = GetPlayer(i)
                if player ~= nil and not player:IsFakeClient() and player:CCSPlayerController():IsValid() and player:CCSPlayerController().PawnIsAlive and player:CBaseEntity().TeamNum == teamID then
                    playersAlive = playersAlive + 1
                end
            end
            return playersAlive
        end
        ,

        GetPlayersTeam = function (teamID --[[Team]])
            local players = {}
            for i = 0, playermanager:GetPlayerCap() - 1, 1 do
                local player = GetPlayer(i)
                if player ~= nil and not player:IsFakeClient() and player:CCSPlayerController():IsValid() and player:CBaseEntity().TeamNum == teamID then
                    table.insert(players,player)
                end
            end
            return players
        end
    }
    ,
    
    Table = {
        RemoveValue = function(tbl --[[table]], value --[[Any]])
            for k, v in pairs(tbl) do
                if v == value then
                    table.remove(tbl, k)
                end
            end
        end
            
    },

    Vector3 = {
        Distance = function(vector1 --[[Vector]], vector2 --[[Vector]])
            local distanceX = vector2.x - vector1.x
            local distanceY = vector2.y - vector1.y
            local distanceZ = vector2.z - vector1.z
            
            local distance = math.sqrt(distanceX * distanceX + distanceY * distanceY + distanceZ * distanceZ)
            return distance
        end
    }

}