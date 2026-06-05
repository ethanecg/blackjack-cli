local playerModule = require("player")
local gameModule = require("game")

local johnRisk
local currentGame

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
    print("How much money do you want to start with ? | (x) exit")
    local playerTotalCash = io.read()
    if string.gsub(string.lower(playerTotalCash), " ", "") == "x" then
        os.exit()
    elseif tonumber(playerTotalCash) ~= nil then
        local playerTotalCashInt = tonumber(playerTotalCash)
        valid, johnRisk = pcall(playerModule.Player, "John risk", playerTotalCashInt) -- first value is bool and second is either string or player object
        if not valid then
            print("\27[31m" .. tostring(johnRisk) .. "\27[0m" .. "\n")                -- bassiaclly the color
        end
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

-- create new game
currentGame = gameModule.Game(johnRisk)

for i = 1, 1, 0 do -- infinite loop
    -- place bet
    repeat
        local startGame = false
        print("PLACE A BET | (x) exit | (i) info")
        local betOrInfo = io.read()
        if tonumber(betOrInfo) ~= nil then
            local betOrInfoInt = tonumber(betOrInfo) -- well its always a bet
            local addBetValid, johnRisk = pcall(johnRisk.AddBet, johnRisk, betOrInfoInt)
            if addBetValid == true then
                startGame = true
            else
                print("you need to enter a valid number")
            end
        elseif string.gsub(string.lower(betOrInfo), " ", "") == "i" then
            print("this table play with 2 packs ~ the minimum bet to play is 1 $")
        elseif string.gsub(string.lower(betOrInfo), " ", "") == "x" then
            os.exit() -- quit the game
        end
    until startGame == true

    -- game start
    repeat
        local finishGame = false
        if #currentGame:AllCards() < 32 then -- restock cards at aproximatly 30% of 104 cards
            print("shuffling cards..")
            currentGame:RestockCards()
        end

        print("distibuting cards..")
        currentGame:FirstCardDistribution()

        print("press enter")
        local _ = io.read()

        -- check for potential blackjack
        if currentGame:CheckOutcome(currentGame:DealerCurrentCards()) == "blackjack" then
            if currentGame:CheckOutcome(currentGame:PlayerCurrentCards()) == "blackjack" then
                finishGame = true
            else
                print("you lost !")
                johnRisk.totalCash = johnRisk.totalCash - johnRisk.bet
                finishGame = true
            end
        end

        -- playersTurn
        if finishGame ~= true then
            repeat
                local forceFinish = false
                os.execute("cls")
                currentGame:ShowTable()
                if currentGame:CheckOutcome(currentGame:PlayerCurrentCardsCurrentCards()) == "blackjack" then
                    print("$ BlackJack $")
                    johnRisk.totalCash = johnRisk.totalCash +
                        johnRisk.bet *
                        3 -- * 3 cuz 2.5 would cause it to be a float number (need fix)
                    forceFinish = true
                elseif currentGame:CheckOutcome() == "canplay" then
                    repeat
                        local finishChoice = false
                        io.write("(H) hit or (S) stand : ")
                        local choice = io.read()
                        if string.gsub(string.lower(choice), " ", "") == "h" then
                            currentGame:SecondCardDistribution()
                            finishChoice = true
                        elseif string.gsub(string.lower(choice), " ", "") == "s" then
                            finishChoice = true
                            forceFinish = true
                        else
                            print("\27[31m" .. "please select a valid option" .. "\27[0m" .. "\n")
                        end
                    until finishChoice == true
                else
                    forceFinish = true
                end
            until forceFinish == true

            -- dealersTurn
            currentGame:SecondDealerCardShown(true)
            currentGame:ShowTable()
            currentGame:FinalCardDistribution()
            currentGame:ShowTable()

            -- check result
            if currentGame:CheckOutcome(currentGame:PlayerCurrentCards()) == "" then

            end
        end
    until finishGame == true
end
