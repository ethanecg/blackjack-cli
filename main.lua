local playerModule = require("player")
local gameModule = require("game")

local johnRisk
local valid

print("=====================")
print("= =====     ======= =")
print("= =    ==      =    =")
print("= =    ==      =    =")
print("= =====        =    =")
print("= =====   ==   =    =")
print("= =     = ==   =    =")
print("= =     =  =  ==    =")
print("= =====     ==      =")
print("=====================")

-- create new player
repeat
    print("How much money do you want to start with ?")
    local playerTotalCash = tonumber(io.read())
    valid, johnRisk = pcall(playerModule.Player, "John risk", playerTotalCash) -- first value is bool and second is either string or player object
    if not valid then
        print("\27[31m" .. tostring(johnRisk) .. "\27[0m" .. "\n")
    end
until valid == true

os.execute("cls")

print("=====================")
print("= =====     ======= =")
print("= =    ==      =    =")
print("= =    ==      =    =")
print("= =====        =    =")
print("= =====   ==   =    =")
print("= =     = ==   =    =")
print("= =     =  =  ==    =")
print("= =====     ==      =")
print("=====================")

gameModule.Game(johnRisk)

-- create new game
--[[
repeat
    local quit = false
    print("PLACE A BET | (x) exit | (i) info")
    local betOrInfo = io.read()
    if type(betOrInfo) == "number" then
        local addBetValid, johnRisk = pcall(johnRisk.AddBet, betOrInfo)
        if addBetValid == true then
            gameModule.Game(johnRisk)
        else

        end
    elseif string.gsub(string.lower(betOrInfo), " ", "") == "I" then
        print("this table play with 2 packs ~ the minimum bet to play is 1 $")
    elseif string.gsub(string.lower(betOrInfo), " ", "") == "X" then
        quit = true
    else
        -- do nothing
    end
until quit == true
--]]
