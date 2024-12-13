
local weaponID = 0
local attackTime = 0



local function dummyPrefix()
end

function OutputMessage(context)
	local file = io.open("TrueGear.log", "a")			
	file:write(os.date("%Y-%m-%d %H:%M:%S") .. "	[TrueGear]:{".. context .."}\n")
	io.close(file)
end

local function dummyPostfix(retval)
    return retval
end

function RegisterHooks()
    
    local file1 = io.open("TrueGear.log", "w")
	if file1 then
	    file1:close()
	else
	    log.info("无法打开文件TrueGear.log")
	end


    sdk.hook(sdk.find_type_definition("chainsaw.Melee"):get_method("onCalculateDamage"), MeleeHit, dummyPostfix)
    sdk.hook(sdk.find_type_definition("chainsaw.Melee"):get_method("requestParry"), requestParry, dummyPostfix)
    sdk.hook(sdk.find_type_definition("chainsaw.PlayerHeadUpdater"):get_method("onDead"), onDead,dummyPostfix )
    sdk.hook(sdk.find_type_definition("chainsaw.Item"):get_method("setItemCount"), setItemCount,dummyPostfix )
    sdk.hook(sdk.find_type_definition("chainsaw.InventoryControllersInfo"):get_method("pickupItem(chainsaw.ContextID, chainsaw.DropItemContext, chainsaw.ItemID, System.Action, System.Action`1<chainsaw.ItemWindowGuiOpenResult>)"), pickupItem,dummyPostfix)

    sdk.hook(sdk.find_type_definition("chainsaw.PlayerHeadUpdater"):get_method("onChangeCrouch"), onChangeCrouch,dummyPostfix )
    sdk.hook(sdk.find_type_definition("chainsaw.PlayerHeadUpdater"):get_method("onChangeNature"), onChangeNature,dummyPostfix )
    sdk.hook(sdk.find_type_definition("chainsaw.PlayerHeadUpdater"):get_method("onChangeCostume"), onChangeCostume,dummyPostfix )
    sdk.hook(sdk.find_type_definition("chainsaw.PlayerHeadUpdater"):get_method("onEquipWeaponChanged"), onEquipWeaponChanged,dummyPostfix )

    
    sdk.hook(sdk.find_type_definition("chainsaw.PlayerHeadUpdater"):get_method("onHitAttack"), onHitAttack,dummyPostfix )
    sdk.hook(sdk.find_type_definition("chainsaw.PlayerHeadUpdater"):get_method("onHitDamage"), onHitDamage,dummyPostfix )
    sdk.hook(sdk.find_type_definition("chainsaw.PlayerHeadUpdater"):get_method("execFire"), execFire,dummyPostfix )
    sdk.hook(sdk.find_type_definition("chainsaw.PlayerHeadUpdater"):get_method("awake"), awake,dummyPostfix )
    
    log.info("-------------------------------------------------")
    log.info("Healing")
    OutputMessage("Healing")
end
-- ****************************************************************************************************************
local playerID = 0
local playerAwakeTime = 0


function CreateBombEffect(args)
    log.info("-------------------------------------------------")
    log.info("CreateBombEffect")
end

function awake(args)
    if os.clock() - playerAwakeTime > 10 then
        log.info("-------------------------------------------------")
        log.info("awake")
        playerAwakeTime = os.clock()
        playerID = sdk.to_managed_object(args[2]):get_address()
        log.info(tostring(sdk.to_managed_object(args[2]):get_address()))
    end
end


function onHitAttack(args)
    if playerID ~= sdk.to_managed_object(args[2]):get_address() then
        return
    end
    if os.clock() - attackTime < 0.3 then
        attackTime = os.clock()
        return 
    end
    attackTime = os.clock()
    log.info("-------------------------------------------------")
    log.info("onHitAttack")    
    OutputMessage("HitAttack")
end

function execFire(args)
    if playerID ~= sdk.to_managed_object(args[2]):get_address() then
        return
    end
    if sdk.to_int64(args[3]) ~= 0 then
        return
    end
    log.info("-------------------------------------------------")
    log.info("execFire")
    if weaponID == 4100 or weaponID == 4900 or weaponID == 4101 or weaponID == 4102 or weaponID == 6100 then
        log.info("ShotgunShoot")  
        OutputMessage("ShotgunShoot")
    elseif weaponID == 4400 or weaponID == 4401 or weaponID == 4402 or weaponID == 6304 then
        log.info("RifleShoot")  
        OutputMessage("RifleShoot")
    else
        log.info("PistolShoot")  
        OutputMessage("PistolShoot")
    end   
    log.info(tostring(weaponID))   
    log.info(tostring(sdk.to_managed_object(args[2]):get_address()))
    log.info(tostring(sdk.to_int64(sdk.to_managed_object(args[2]):get_field("<CurrentSituationType>k__BackingField"))))
    log.info(tostring(sdk.to_int64(args[3])))
end


function onChangeCostume(args)
    if playerID ~= sdk.to_managed_object(args[2]):get_address() then
        return
    end
    log.info("-------------------------------------------------")
    log.info("onChangeCostume")
    log.info(tostring(sdk.to_managed_object(args[2]):get_address()))
    log.info(tostring(sdk.to_managed_object(args[2]):call("checkPlayerEqualStage")))
end


function onEquipWeaponChanged(args)
    if playerID ~= sdk.to_managed_object(args[2]):get_address() then
        return
    end
    log.info("-------------------------------------------------")
    log.info("onEquipWeaponChanged")
    log.info(tostring(sdk.to_int64(args[3])))
    weaponID = sdk.to_int64(args[3])
    log.info(tostring(sdk.to_managed_object(args[2]):get_field("<IsPartnerCover>k__BackingField")))
    log.info(tostring(sdk.to_managed_object(args[2]):get_field("<IsPartnerCover>k__BackingField")))
    log.info(tostring(sdk.to_managed_object(args[2]):get_address()))
    log.info(tostring(sdk.to_managed_object(args[2]):call("checkPlayerEqualStage")))
    
end

function onChangeCrouch(args)
    if playerID ~= sdk.to_managed_object(args[2]):get_address() then
        return
    end
    log.info("-------------------------------------------------")
    log.info("onChangeCrouch")
    OutputMessage("Crouch")
    log.info(tostring(args[3]))
end

function onChangeNature(args)
    if playerID ~= sdk.to_managed_object(args[2]):get_address() then
        return
    end
    log.info("-------------------------------------------------")
    log.info("onChangeNature")
    log.info("now :" .. tostring( sdk.to_managed_object(args[3]):get_field("value__")))
    log.info("next :" .. tostring( sdk.to_managed_object(args[4]):get_field("value__")))
end


function requestParry()
    log.info("-------------------------------------------------")
    log.info("Parry")
    OutputMessage("Parry")
end

function pickupItem()
    log.info("-------------------------------------------------")
    log.info("pickupItem")
    OutputMessage("PickupItem")
end

function onHitDamage(args)
    if playerID ~= sdk.to_managed_object(args[2]):get_address() then
        return
    end
    log.info("-------------------------------------------------")
    log.info("onHitDamage")
    local damageInfo = sdk.to_managed_object(args[3])
    local damage = damageInfo:get_field("<Damage>k__BackingField")
    if damage < 15 then
        log.info("LowDamage")
        OutputMessage("LowDamage")
        return
    end
    local damDir = damageInfo:get_field("<DamageDir>k__BackingField")
    local AttDir = damageInfo:call("get_AttackDir")
    log.info("onCalculateDamage")
    OutputMessage("DefaultDamage," .. calculateBeta(damDir) .. ",0")
    log.info(damage)
    log.info("angle :" .. calculateBeta(damDir))
    log.info("damDirX :" .. damDir.x ..",damDirY :" .. damDir.y .. ",damDirZ :" .. damDir.z)
    log.info("AttDirX :" .. AttDir.x ..",AttDirY :" .. AttDir.y .. ",AttDirZ :" .. AttDir.z)
end

local lastItemTime = 0
-- local itemCount = 0
local lastItemID = 0
function setItemCount(args)
    log.info("-------------------------------------------------")
    log.info("setItemCount")    
    log.info(tostring(lastItemID))
    log.info(tostring(os.clock()))
    log.info(tostring(lastItemTime))
    local item = sdk.to_managed_object(args[2])
    local value = item:get_field("_ItemId")    
    lastItemID = value
    local _CurrentItemCount = item:get_field("_CurrentItemCount")
    local _LastItemCount = sdk.to_int64(args[3])
    if _CurrentItemCount > _LastItemCount then
        if value == 114416000 or value == 114408000 or value == 114404800 or value == 114406400 or value == 114409600 or value == 114412800 or value == 114414400 or value == 114400000 then
            if os.clock() - lastItemTime < 0.1 then
                log.info("clear1")
                OutputMessage("StopHealing")
                return
            end
            lastItemTime = os.clock()
            log.info("Healing")     
            OutputMessage("Healing")
        elseif value == 277078656 or value == 112800000 or value == 277075456 or value == 277077056 then
            log.info("RightHandThrowItem")     
            OutputMessage("RightHandThrowItem")
        end        
    end

    log.info("ItemID :" .. tostring(value))
    log.info("_CurrentItemCount :" .. tostring(_CurrentItemCount) .. " , _LastItemCount :" .. tostring(_LastItemCount))
    log.info("HasUseResult :" .. tostring(item:call("get_HasUseResult")))
end




function onDead(args)
    if playerID ~= sdk.to_managed_object(args[2]):get_address() then
        return
    end
    log.info("-------------------------------------------------")
    log.info("onDead")
    OutputMessage("PlayerDead")
end




function MeleeHit(args)
    local isPlayerDamage = sdk.to_managed_object(args[4]):call("get_IsPlayerDamage")
    if isPlayerDamage then
        return
    end
    log.info("-------------------------------------------------")
    log.info("MeleeHit")
    OutputMessage("RightHandMeleeHit")
    log.info(weaponID)
    -- local isPlayerDamage = sdk.to_managed_object(args[4]):call("get_IsPlayerDamage")
    -- log.info(tostring(isPlayerDamage))
end

function calculateBeta(damDir)
    -- 计算 alpha 角度
    local alpha = math.acos(damDir.y)
    
    -- 计算 sin(alpha)
    local sinAlpha = math.sin(alpha)
    
    -- 计算 beta 角度
    local beta = math.acos(-damDir.x / sinAlpha)
    
    return beta
end

function onCalculateDamage(args)
    local damageInfo = sdk.to_managed_object(args[4])
    local damage = sdk.to_int64(args[3])
    if damage <= 0 then
        return
    end
    log.info("-------------------------------------------------")
    log.info("111111111111111Damage")
    if damage < 5 then
        log.info("LowDamage")
        OutputMessage("LowDamage")
        return
    end
    local damageInfo = sdk.to_managed_object(args[4])
    local isPlayerDamage = damageInfo:call("get_IsPlayerDamage")
    local isEnemyDamage = damageInfo:call("get_IsEnemyDamage")
    local hitPos = damageInfo:get_field("<HitPos>k__BackingField")
    local damDir = damageInfo:get_field("<DamageDir>k__BackingField")
    log.info("onCalculateDamage")
    OutputMessage("DefaultDamage," .. calculateBeta(damDir) .. ",0")
    log.info(damage)
    log.info("angle :" .. calculateBeta(damDir))
    log.info("isPlayerDamage :" .. tostring(isPlayerDamage))
    log.info("isEnemyDamage :" .. toostring(isEnemyDamage))
end



RegisterHooks()