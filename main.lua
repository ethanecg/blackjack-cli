local playerModule = require("player")
local gameModule = require("game")

local johnRisk -- the player
local currentGame



--- print a beautiful logo (the logo is not made by me)
function BlackJackLogo()
    print(" ____       _")
    print("|  _ \\     | |")
    print("| |_) |    | |")
    print("|  _ <  _  | |")
    print("| |_) || |_| |")
    print("|____/  \\___/")
    print("==============")
end

BlackJackLogo()

-- create new player
repeat
    local valid
    print("How much money do you want to start with ? | (x) exit")
    local playerTotalCash = io.read()
    if string.gsub(string.lower(playerTotalCash), " ", "") == "x" then
        os.exit()
    elseif tonumber(playerTotalCash) ~= nil then
        local playerTotalCashInt = tonumber(playerTotalCash)
        valid, johnRisk = pcall(playerModule.Player, "John risk", playerTotalCashInt) -- first value is bool and second is either string or player object
        if not valid then
            print("\27[31m" .. tostring(johnRisk) .. "\27[0m")
            io.write("enter to continue..")
            local _ = io.read()
            os.execute("cls")
        end
    end
until valid == true


os.execute("cls")

BlackJackLogo()

-- create new game
currentGame = gameModule.Game(johnRisk)

while johnRisk.totalCash ~= 0 do -- infinite loop
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
                print("\27[31m" .. "you need to enter a number above 0 and below you total cash" .. "\27[0m")
                io.write("enter to continue..")
                local _ = io.read()
            end
        elseif string.gsub(string.lower(betOrInfo), " ", "") == "i" then
            print("this table play with 2 packs ~ the minimum bet to play is 1 $")
        elseif string.gsub(string.lower(betOrInfo), " ", "") == "x" then
            os.exit() -- quit the game
        end
        os.execute("cls")
    until startGame == true

    -- game start
    repeat
        -- before game start check if the game need shuffling
        currentGame:SecondDealerCardShown(true)
        local finishGame = false
        if #currentGame:Deck() < 32 then -- restock cards at aproximatly 30% of 104 cards to avoid running out of card
            print("shuffling cards..")
            currentGame:RestockCards()
            os.execute("timeout /t 2 /nobreak >null")
        end

        currentGame:FirstCardDistribution()
        os.execute("cls")
        currentGame:ShowTable()

        -- check for potential blackjack for the dealer (end the game immediatly)
        os.execute("cls")
        print("checking for blackjack.. \n")
        currentGame:ShowTable()
        os.execute("timeout /t 1 /nobreak >nul")
        if currentGame:CheckOutcome(currentGame:DealersHand()) == "blackjack" then
            finishGame = true
            if currentGame:CheckOutcome(currentGame:PlayersHand()) == "blackjack" then
                finishGame = true
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
                os.execute("cls")
                currentGame:ShowTable()
                if stand then
                    break
                end
                if currentGame:CheckOutcome(currentGame:PlayersHand()) == "blackjack" then
                    finishGame = true
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
                    until finishChoice == true
                else
                    -- bust but outcome is checked later
                    finishGame = true
                    break
                end
            end

            -- dealersTurn
            if finishGame == false then
                currentGame:SecondDealerCardShown(false)
                currentGame:FinalCardDistribution()
            end

            os.execute("cls")
            currentGame:ShowTable()

            finishGame = true
            -- check results
            if currentGame:CheckOutcome(currentGame:PlayersHand()) == "bust" then
                print("bust ! -" .. johnRisk.bet .. "$")
            elseif currentGame:CheckOutcome(currentGame:DealersHand()) == "bust" then
                print("dealer bust ! +" .. johnRisk.bet .. "$")
                johnRisk.totalCash = johnRisk.totalCash + johnRisk.bet * 2
            elseif currentGame:ReturnTotalHandValue(currentGame:PlayersHand()) > currentGame:ReturnTotalHandValue(currentGame:DealersHand()) then
                print("win ! +" .. johnRisk.bet .. "$")
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
    io.write("enter to continue..")
    local _ = io.read()
    os.execute("cls")
    currentGame:ResetHand()
    johnRisk.bet = 0
end

print("you lost everything, was it worth it?")
