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

while true do -- infinite loop
    -- place bet
    repeat
        local startGame = false
        print("PLACE A BET " .. "(" .. johnRisk.totalCash .. "$ total)" .. " | (x) exit | (i) info")
        local betOrInfo = io.read()
        if tonumber(betOrInfo) ~= nil then           -- if its a int
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
        -- before game start check if the game need shuffling
        currentGame:SecondDealerCardShown(true)
        local finishGame = false
        if #currentGame:Deck() < 32 then -- restock cards at aproximatly 30% of 104 cards to avoid running out of card
            print("shuffling cards..")
            currentGame:RestockCards()
        end

        print("distibuting cards..")
        currentGame:FirstCardDistribution()
        currentGame:ShowTable()

        print("press enter")

        local _ = io.read()

        -- check for potential blackjack for the dealer (end the game immediatly)
        if currentGame:CheckOutcome(currentGame:DealersHand()) == "blackjack" then
            finishGame = true
            if currentGame:CheckOutcome(currentGame:PlayersHand()) == "blackjack" then
                print("push !")
                johnRisk.totalCash = johnRisk.totalCash + johnRisk.bet
            else
                print("dealer blackjack ! -" .. johnRisk.bet .. "$")
            end
        end

        -- playersTurn
        if finishGame == false then
            local stand = false
            while true do
                if stand then
                    break
                end
                currentGame:ShowTable()
                if currentGame:CheckOutcome(currentGame:PlayersHand()) == "blackjack" then
                    print("$ BlackJack $ +" .. johnRisk.bet * 3 .. "$")
                    johnRisk.totalCash = johnRisk.totalCash +
                        johnRisk.bet *
                        3 -- * 3 cuz 2.5 would cause it to be a float number (need fix)
                    break
                elseif currentGame:CheckOutcome(currentGame:PlayersHand()) == "canplay" then
                    repeat
                        local finishChoice = false
                        io.write("(H) hit or (S) stand : ")
                        local choice = io.read()
                        if string.gsub(string.lower(choice), " ", "") == "h" then
                            currentGame:SecondCardDistribution()
                            finishChoice = true
                        elseif string.gsub(string.lower(choice), " ", "") == "s" then
                            finishChoice = true
                            stand = true
                            break
                        else
                            print("\27[31m" .. "please select a valid option" .. "\27[0m" .. "\n")
                        end
                        os.execute("cls")
                        currentGame:ShowTable()
                    until finishChoice == true
                else
                    -- bust but outcome is checcked later
                    break
                end
            end

            -- dealersTurn
            if finishGame == false then
                currentGame:SecondDealerCardShown(false)
                currentGame:ShowTable()
                currentGame:FinalCardDistribution()
            end

            os.execute("cls")
            currentGame:ShowTable()

            finishGame = true
            -- check results
            if currentGame:CheckOutcome(currentGame:PlayersHand()) == "bust" then
                print("bust ! -" .. johnRisk.bet .. "$")
            elseif currentGame:CheckOutcome(currentGame:DealersHand()) == "bust" then
                print("dealer bust ! +" .. johnRisk.bet * 2 .. "$")
                johnRisk.totalCash = johnRisk.totalCash + johnRisk.bet * 2
            elseif currentGame:ReturnTotalHandValue(currentGame:PlayersHand()) > currentGame:ReturnTotalHandValue(currentGame:DealersHand()) then
                print("win ! +" .. johnRisk.bet * 2 .. "$")
                johnRisk.totalCash = johnRisk.totalCash + johnRisk.bet * 2
            elseif currentGame:ReturnTotalHandValue(currentGame:PlayersHand()) < currentGame:ReturnTotalHandValue(currentGame:DealersHand()) then
                print("lose ! -" .. johnRisk.bet .. "$")
            else
                print("push !")
                johnRisk.totalCash = johnRisk.totalCash + johnRisk.bet
            end
        end
    until finishGame == true
    print("\n")
    currentGame:ResetHand()
    johnRisk.bet = 0
end
