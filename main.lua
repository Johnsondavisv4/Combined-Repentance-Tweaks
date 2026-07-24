-- =================================================================
-- MOD UNIFICADO: Tainted Lost Anim, Eden Hair, Costumes & Deal Rework
-- =================================================================
local mod = RegisterMod("Combined Repentance Tweaks", 1)

-- =================================================================
-- 1. TAINTED LOST DEATH ANIMATION
-- =================================================================
function mod:TaintedLostInit(p)
    if p:GetPlayerType() == PlayerType.PLAYER_THELOST_B then
        p:GetSprite():ReplaceSpritesheet(13,"taintedlostdeathanim.png")
        p:GetSprite():LoadGraphics()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.TaintedLostInit)


-- =================================================================
-- 2. EDEN HAIR
-- =================================================================
local IsRepentance = Game().GetItemHistory ~= nil
local maxhairid = 40
local edenhairconfig = Isaac.GetItemConfig():GetNullItem(12)
local bedenrng = RNG()
local continuerun = false

local function rollhair()
    local hairrng = RNG()
    hairrng:SetSeed(Game():GetSeeds():GetStartSeed(), 0)
    return hairrng:RandomInt(maxhairid - 1) + 1
end

local function bedenroll()
    local applyhair = bedenrng:RandomInt(maxhairid - 1) + 1
    bedenrng:Next()
    return applyhair
end

function mod:ApplyEdenHair(player, hair, reloadanm2)
    if reloadanm2 == nil then reloadanm2 = true end -- [CORREGIDO]
    
    if reloadanm2 then
        player:GetSprite():Load('gfx/edenhair.anm2', false)
    end
    local hairpath = 'gfx/characters/costumes/character_009_edenhair'..tostring(hair)..'.png'
    player:GetSprite():ReplaceSpritesheet(15, hairpath)
    player:GetSprite():ReplaceSpritesheet(17, hairpath)
    player:GetSprite():LoadGraphics() 
    player:ReplaceCostumeSprite(edenhairconfig, hairpath, 0)
end

function mod:EdenHairInit(player)
    if not eu then
        if player:GetPlayerType() == 9 then
            local hair = rollhair()
            mod:ApplyEdenHair(player, hair)
        elseif (player:GetPlayerType() == 30 and IsRepentance) then
            player:RemoveSkinCostume()
            player:AddNullCostume(12)
            local hair = rollhair()
            mod:ApplyEdenHair(player, hair)
        end
    end
end

function mod:EdenHairDamage(took, dmgamount, flags, source, countdown)
    if not eu then
        local player = took:ToPlayer()
        if player then
            if (player:GetPlayerType() == 30 and IsRepentance) then
                player:GetData().BedenHairUpd = true
            end
        end
    end
end

function mod:EdenHairUpdate(player)
    if player:GetData().BedenHairUpd then
        player:GetData().BedenHairUpd = false
        player:RemoveSkinCostume()
        player:AddNullCostume(12)
        local hair = bedenroll()
        mod:ApplyEdenHair(player, hair, false)
        player:PlayExtraAnimation('Glitch')
    end
end

function mod:EdenHairGameStart(bool)
    if bool then
        continuerun = true
        for i = 0, Game():GetNumPlayers() - 1 do
            mod:EdenHairInit(Isaac.GetPlayer(i))
        end
    else 
        continuerun = false
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.EdenHairInit)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.EdenHairUpdate)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.EdenHairDamage, EntityType.ENTITY_PLAYER)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.EdenHairGameStart)


-- =================================================================
-- 3. MISSING COSTUMES
-- =================================================================
mod.Options = { NullCostumes = true, KeeperBAnm2 = true }
mod.Enum = { Costumes = {}, NullItemID = {} }

mod.Enum.NullItemID.ID_APOLLYON_ANTIGRAVITY         = Isaac.GetCostumeIdByPath('gfx/characters/character_015_apollyonbody_antigravity.anm2')
mod.Enum.NullItemID.ID_APOLLYON_PACT                = Isaac.GetCostumeIdByPath('gfx/characters/character_015_apollyonbody_pact.anm2')
mod.Enum.NullItemID.ID_BLUEBABY_B_IPECAC            = Isaac.GetCostumeIdByPath('gfx/characters/character_b05_bluebaby_ipecac.anm2')
mod.Enum.NullItemID.ID_BLUEBABY_B_SCORPIO           = Isaac.GetCostumeIdByPath('gfx/characters/character_b05_bluebaby_scorpio.anm2')
mod.Enum.NullItemID.ID_BLUEBABY_B_BLUECAP           = Isaac.GetCostumeIdByPath('gfx/characters/character_b05_bluebaby_bluecap.anm2')
mod.Enum.NullItemID.ID_BLUEBABY_B_SOAP              = Isaac.GetCostumeIdByPath('gfx/characters/character_b05_bluebaby_barofsoap.anm2')
mod.Enum.NullItemID.ID_BLUEBABY_B_KNOCKOUTDROPS     = Isaac.GetCostumeIdByPath('gfx/characters/character_b05_bluebaby_knockoutdrops.anm2')
mod.Enum.NullItemID.ID_BLUEBABY_B_REVELATION        = Isaac.GetCostumeIdByPath('gfx/characters/character_b05_bluebaby_revelation.anm2')
mod.Enum.NullItemID.ID_BLUEBABY_B_PLAYDOUGHCOOKIE   = Isaac.GetCostumeIdByPath('gfx/characters/character_b05_bluebaby_playdohcookie.anm2')
mod.Enum.NullItemID.ID_BLUEBABY_B_CHARMOFTHEVAMPIRE = Isaac.GetCostumeIdByPath('gfx/characters/character_b05_bluebaby_charmofthevampire.anm2')
mod.Enum.NullItemID.ID_FORGOTTEN_B_MUSHROOM         = Isaac.GetCostumeIdByPath('gfx/characters/character_b15_theforgotten_mushroom.anm2')
mod.Enum.NullItemID.ID_FORGOTTEN_B_BOB              = Isaac.GetCostumeIdByPath('gfx/characters/character_b15_theforgotten_bob.anm2')
mod.Enum.NullItemID.ID_FORGOTTEN_B_POOP             = Isaac.GetCostumeIdByPath('gfx/characters/character_b15_theforgotten_poop.anm2')

function mod:RegisterCostume(PlayerType, Collectible, PlayerForm, Costume, Default, Allowed)
    if Allowed == nil then Allowed = true end -- [CORREGIDO]
    local k = #mod.Enum.Costumes + 1

    if Collectible and not PlayerForm then
        mod.Enum.Costumes[k] = {PlayerType=PlayerType, Collectible=Collectible, Costume=Costume, Default=Default, Allowed=Allowed, Added=false}
    elseif not Collectible and PlayerForm then
        mod.Enum.Costumes[k] = {PlayerType=PlayerType, PlayerForm=PlayerForm, Costume=Costume, Default=Default, Allowed=Allowed, Added=false}
    end
end

mod:RegisterCostume(PlayerType.PLAYER_APOLLYON, CollectibleType.COLLECTIBLE_ANTI_GRAVITY, false, mod.Enum.NullItemID.ID_APOLLYON_ANTIGRAVITY, NullItemID.ID_APOLLYON)
mod:RegisterCostume(PlayerType.PLAYER_APOLLYON, CollectibleType.COLLECTIBLE_PACT, false, mod.Enum.NullItemID.ID_APOLLYON_PACT, NullItemID.ID_APOLLYON)
mod:RegisterCostume(PlayerType.PLAYER_XXX_B, CollectibleType.COLLECTIBLE_BAR_OF_SOAP, false, mod.Enum.NullItemID.ID_BLUEBABY_B_SOAP, NullItemID.ID_BLUEBABY_B)
mod:RegisterCostume(PlayerType.PLAYER_XXX_B, CollectibleType.COLLECTIBLE_BLUE_CAP, false, mod.Enum.NullItemID.ID_BLUEBABY_B_BLUECAP, NullItemID.ID_BLUEBABY_B)
mod:RegisterCostume(PlayerType.PLAYER_XXX_B, CollectibleType.COLLECTIBLE_CHARM_VAMPIRE, false, mod.Enum.NullItemID.ID_BLUEBABY_B_CHARMOFTHEVAMPIRE, NullItemID.ID_BLUEBABY_B)
mod:RegisterCostume(PlayerType.PLAYER_XXX_B, CollectibleType.COLLECTIBLE_IPECAC, false, mod.Enum.NullItemID.ID_BLUEBABY_B_IPECAC, NullItemID.ID_BLUEBABY_B)
mod:RegisterCostume(PlayerType.PLAYER_XXX_B, CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS, false, mod.Enum.NullItemID.ID_BLUEBABY_B_KNOCKOUTDROPS, NullItemID.ID_BLUEBABY_B)
mod:RegisterCostume(PlayerType.PLAYER_XXX_B, CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE, false, mod.Enum.NullItemID.ID_BLUEBABY_B_PLAYDOUGHCOOKIE, NullItemID.ID_BLUEBABY_B)
mod:RegisterCostume(PlayerType.PLAYER_XXX_B, CollectibleType.COLLECTIBLE_REVELATION, false, mod.Enum.NullItemID.ID_BLUEBABY_B_REVELATION, NullItemID.ID_BLUEBABY_B)
mod:RegisterCostume(PlayerType.PLAYER_XXX_B, CollectibleType.COLLECTIBLE_SCORPIO, false, mod.Enum.NullItemID.ID_BLUEBABY_B_SCORPIO, NullItemID.ID_BLUEBABY_B)
mod:RegisterCostume(PlayerType.PLAYER_THEFORGOTTEN_B, false, PlayerForm.PLAYERFORM_MUSHROOM, mod.Enum.NullItemID.ID_FORGOTTEN_B_MUSHROOM, NullItemID.ID_FORGOTTEN_B)
mod:RegisterCostume(PlayerType.PLAYER_THEFORGOTTEN_B, false, PlayerForm.PLAYERFORM_BOB, mod.Enum.NullItemID.ID_FORGOTTEN_B_BOB, NullItemID.ID_FORGOTTEN_B)
mod:RegisterCostume(PlayerType.PLAYER_THEFORGOTTEN_B, false, PlayerForm.PLAYERFORM_POOP, mod.Enum.NullItemID.ID_FORGOTTEN_B_POOP, NullItemID.ID_FORGOTTEN_B)

-- [CORREGIDO] Movido de MC_POST_PLAYER_RENDER a MC_POST_PLAYER_UPDATE para optimizar FPS
function mod:SetMissingCostumes(player)
    local playerSprite = player:GetSprite()
    if (player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B) and (playerSprite:GetFilename():lower() == 'gfx/001.000_player.anm2') and mod.Options.KeeperBAnm2 then
        playerSprite:Load('gfx/001.000_player_keeperb.anm2', true)
    end
    if (player:GetPlayerType() ~= PlayerType.PLAYER_KEEPER_B) and (playerSprite:GetFilename():lower() == 'gfx/001.000_player_keeperb.anm2') then
        playerSprite:Load('gfx/001.000_player.anm2', true)
    end

    if mod.Options.NullCostumes then
        for i, costume in ipairs(mod.Enum.Costumes) do
            if costume.Allowed and (costume.Costume ~= -1) then
                if costume.Collectible then
                    if player:GetPlayerType() == costume.PlayerType then
                        local hasCol = player:HasCollectible(costume.Collectible) and player:GetCollectibleNum(costume.Collectible, true) > 0
                        if hasCol and not costume.Added then
                            player:TryRemoveNullCostume(costume.Default)
                            player:AddNullCostume(costume.Costume)
                            costume.Added = true
                        elseif not hasCol and costume.Added then
                            player:TryRemoveNullCostume(costume.Costume)
                            player:AddNullCostume(costume.Default)
                            costume.Added = false
                        end
                    end
                elseif costume.PlayerForm then
                    if player:GetPlayerType() == costume.PlayerType then
                        local hasForm = player:HasPlayerForm(costume.PlayerForm)
                        if hasForm and not costume.Added then
                            player:TryRemoveNullCostume(costume.Default)
                            player:AddNullCostume(costume.Costume)
                            costume.Added = true
                        elseif not hasForm and costume.Added then
                            player:TryRemoveNullCostume(costume.Costume)
                            player:AddNullCostume(costume.Default)
                            costume.Added = false
                        end
                    end
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.SetMissingCostumes)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.SetMissingCostumes)


-- =================================================================
-- 4. DEAL REWORK
-- =================================================================
local heartsSprite = Sprite()
local heartFrames = {
    ONE_BONE_HEART = 0, RED_HEART_AND_BONE_HEART = 1, TWO_BONE_HEARTS = 2,
    BONE_ALL_SOUL = 3, BONE_ONE_BLACK = 4, BONE_ALL_BLACK = 5,
    RED_HEART_ONE_BLACK = 6, RED_HEART_ALL_BLACK = 7, TWO_SOUL_ONE_BLACK = 8,
    ONE_SOUL_TWO_BLACK = 9, ALL_BLACK = 10, ONE_BLACK_ONE_SOUL = 11,
    TWO_BLACK = 12, ONE_BLACK = 13,
}
heartsSprite:Load("gfx/deal_rework.anm2")

function mod:ToBinary(num)
    local result = "" -- [CORREGIDO] Variable global causaba conflicto
    while num ~= 1 and num ~= 0 do
        result = tostring(num % 2) .. result
        num = math.modf(num / 2)
    end
    result = tostring(num) .. result
    return result
end

-- [CORREGIDO] Reescrito para evitar el Crash y mejorar rendimiento usando Isaac.GetPlayer(0)
function mod:GetClosestPlayer(pos)
    local closestPlayer = Isaac.GetPlayer(0)
    local closestDistance = pos:Distance(closestPlayer.Position)

    for i = 1, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        local distance = pos:Distance(player.Position)
        if distance < closestDistance then
            closestPlayer = player
            closestDistance = distance
        end
    end
    return closestPlayer
end

function mod:GetRealBlackHearts(closestPlayer)
    if not closestPlayer then return 0 end
    local t = mod:ToBinary(closestPlayer:GetBlackHearts())
    local _, result = string.gsub(t, "1", "")
    return result
end

function mod:DealReworkRender(pickup, offset)
    if pickup.Type == EntityType.ENTITY_PICKUP then
        local closestPlayer = mod:GetClosestPlayer(pickup.Position)
        if not closestPlayer then return end

        local numBlackHearts = mod:GetRealBlackHearts(closestPlayer) * 2
        local totalSoulHearts = closestPlayer:GetSoulHearts()
        local numSoulHearts = totalSoulHearts - numBlackHearts
        if numSoulHearts % 2 == 1 then numSoulHearts = numSoulHearts + 1 end
        
        local pos = Isaac.WorldToScreen(pickup.Position)
        pos.X = pos.X - Game().ScreenShakeOffset.X
        pos.Y = pos.Y - Game().ScreenShakeOffset.Y

        if pickup.Price == -1 and closestPlayer:GetMaxHearts() == 0 then
            heartsSprite:SetFrame("Hearts", heartFrames.ONE_BONE_HEART)
            heartsSprite:RenderLayer(0, pos)
        elseif pickup.Price == -2 then
            if closestPlayer:GetMaxHearts() == 2 then
                heartsSprite:SetFrame("Hearts", heartFrames.RED_HEART_AND_BONE_HEART)
                heartsSprite:RenderLayer(0, pos)
            elseif closestPlayer:GetMaxHearts() == 0 then
                heartsSprite:SetFrame("Hearts", heartFrames.TWO_BONE_HEARTS)
                heartsSprite:RenderLayer(0, pos)
            end
        elseif pickup.Price == -3 then
            if numBlackHearts == 0 then return end
            if numSoulHearts == 0 and numBlackHearts >= 5 then
                heartsSprite:SetFrame("Hearts", heartFrames.ALL_BLACK)
                heartsSprite:RenderLayer(0, pos)
            elseif numSoulHearts <= 2 and numBlackHearts >= 3 then
                heartsSprite:SetFrame("Hearts", heartFrames.ONE_SOUL_TWO_BLACK)
                heartsSprite:RenderLayer(0, pos)
            elseif (numSoulHearts == 4 or totalSoulHearts < 5) and numBlackHearts >= 1 then
                heartsSprite:SetFrame("Hearts", heartFrames.TWO_SOUL_ONE_BLACK)
                heartsSprite:RenderLayer(0, pos)
            end
        elseif pickup.Price == -4 then
            if closestPlayer:GetMaxHearts() == 0 then
                if numSoulHearts == 0 and numBlackHearts >= 3 then
                    heartsSprite:SetFrame("Hearts", heartFrames.BONE_ALL_BLACK)
                    heartsSprite:RenderLayer(0, pos)
                elseif numSoulHearts <= 2 and numBlackHearts >= 1 then
                    heartsSprite:SetFrame("Hearts", heartFrames.BONE_ONE_BLACK)
                    heartsSprite:RenderLayer(0, pos)
                elseif numSoulHearts == 4 or numBlackHearts == 0 then
                    heartsSprite:SetFrame("Hearts", heartFrames.BONE_ALL_SOUL)
                    heartsSprite:RenderLayer(0, pos)
                end
            else
                if numBlackHearts == 0 then return end
                if numSoulHearts == 0 and numBlackHearts >= 3 then
                    heartsSprite:SetFrame("Hearts", heartFrames.RED_HEART_ALL_BLACK)
                    heartsSprite:RenderLayer(0, pos)
                elseif numSoulHearts <= 2 and numBlackHearts >= 1 then
                    heartsSprite:SetFrame("Hearts", heartFrames.RED_HEART_ONE_BLACK)
                    heartsSprite:RenderLayer(0, pos)
                end
            end
        elseif pickup.Price == -7 then
            if numSoulHearts == 0 then
                heartsSprite:SetFrame("Hearts", heartFrames.ONE_BLACK)
                heartsSprite:RenderLayer(0, pos)
            end
        elseif pickup.Price == -8 then
            if numBlackHearts == 0 or numSoulHearts >= 3 then return end
            if numSoulHearts == 0 and numBlackHearts > 2 then
                heartsSprite:SetFrame("Hearts", heartFrames.TWO_BLACK)
                heartsSprite:RenderLayer(0, pos)
            elseif numSoulHearts == 2 then
                heartsSprite:SetFrame("Hearts", heartFrames.ONE_BLACK_ONE_SOUL)
                heartsSprite:RenderLayer(0, pos)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, mod.DealReworkRender)