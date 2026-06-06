os.execute("cls")

local playerModule = require("player")
local gameModule = require("game")

local johnRisk    -- the player
local currentGame -- the game

--- Print an ASCII logo that show "BJ".
function BlackJackLogo()
    print(" ____       _")
    print("|  _ \\     | |")
    print("| |_) |    | |")
    print("|  _ <  _  | |")
    print("| |_) || |_| |")
    print("|____/  \\___/")
    print("==============")
end

--- Print "enter to continue" and wait for the user to enter anything then clear the console.
function PressToContinue()
    io.write("enter to continue..")
    local _ = io.read()
    os.execute("cls")
end

--#region Choose the total cash you have and create a player object.
repeat
    BlackJackLogo()
    local valid
    print("How much money do you want to start with ? | (x) exit")
    local playerTotalCash = io.read()
    -- Exit option.
    if string.gsub(string.lower(playerTotalCash), " ", "") == "x" then
        os.exit()
        -- Place a bet option and round the bet.
    elseif tonumber(playerTotalCash) ~= nil then
        local playerTotalCashInt = tonumber(math.floor(playerTotalCash))
        valid, johnRisk = pcall(playerModule.Player, "John risk", playerTotalCashInt) -- try to create a new player (object)
        if not valid then
            print("\27[31m" .. tostring(johnRisk) .. "\27[0m")
            PressToContinue()
        else
            print("\27[32m" .. "success!" .. "\27[0m")
            PressToContinue()
        end
    else
        print("\27[31m" .. "Fail to convert the input into a number." .. "\27[0m")
        PressToContinue()
    end
until valid == true
--#endregion

os.execute("cls")
currentGame = gameModule.Game(johnRisk) -- Create a new game game object.

while johnRisk.totalCash ~= 0 do
    --#region Place a bet to start a game.
    repeat
        BlackJackLogo()
        local startGame = false
        print("PLACE A BET " .. "(" .. johnRisk.totalCash .. "$ total)" .. " | (x) exit | (i) info")
        local betOrInfo = io.read()
        if tonumber(betOrInfo) ~= nil then
            local bet = tonumber(math.floor(betOrInfo))
            local addBetValid, johnRisk = pcall(johnRisk.AddBet, johnRisk, bet)
            if addBetValid == true then
                startGame = true
            else
                print("\27[31m" .. "You need to enter a number of atleast 1 and below you total cash" .. "\27[0m")
                PressToContinue()
            end
        elseif string.gsub(string.lower(betOrInfo), " ", "") == "i" then
            print("This table have a shoe with 2 decks. ~ The minimum bet to play is 1$. ~ No split. ~ No double.")
            PressToContinue()
        elseif string.gsub(string.lower(betOrInfo), " ", "") == "x" then
            os.exit()
        else
            print("\27[31m" .. "Enter a valid choice." .. "\27[0m")
            PressToContinue()
        end
    until startGame == true
    --#endregion

    --#region Start the game.
    repeat
        -- before game start check if the game need shuffling
        os.execute("cls")
        currentGame:SecondDealerCardNotShown(true)
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
        local cardMap = {
            "A",
            10,
            "Q",
            "J",
            "K"
        }
        for i = 1, #cardMap, 1 do
            if currentGame:DealersHand()[1] == cardMap[i] then
                print("checking for blackjack.. \n")
                currentGame:ShowTable()
                os.execute("timeout /t 1 /nobreak >nul")
                if currentGame:CheckOutcome(currentGame:DealersHand()) == "blackjack" then
                    finishGame = true
                end
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
                    -- Bust but outcome is checked later.
                    finishGame = true
                    break
                end
            end

            -- Dealer's turn.
            if finishGame == false then
                currentGame:FinalCardDistribution()
            end

            os.execute("cls")
            currentGame:ShowTable()

            finishGame = true
            -- check results
            if currentGame:CheckOutcome(currentGame:DealersHand()) == "blackjack" and currentGame:CheckOutcome(currentGame:PlayersHand()) ~= "blackjack" then     -- Dealer blackjack.
                print("\27[31m" .. "Dealer blackjack ! -" .. johnRisk.bet .. "$" .. "\27[0m")
            elseif currentGame:CheckOutcome(currentGame:DealersHand()) ~= "blackjack" and currentGame:CheckOutcome(currentGame:PlayersHand()) == "blackjack" then -- Player blackjack.
                print("\27[32m" .. "$ BlackJack $ +" .. johnRisk.bet * 3 .. "$" .. "\27[0m")
                johnRisk.totalCash = johnRisk.totalCash +
                    johnRisk.bet *
                    3                                                                                                                                             -- Multiple by 3 to avoid having to round and potentialy losing gain.
                break
            elseif currentGame:CheckOutcome(currentGame:DealersHand()) == "blackjack" and currentGame:CheckOutcome(currentGame:PlayersHand()) ~= "blackjack" then -- Dealer and player blackjack.
                print("\27[33m" .. "Push !" .. "\27[0m")
                johnRisk.totalCash = johnRisk.totalCash + johnRisk.bet
            elseif currentGame:CheckOutcome(currentGame:PlayersHand()) == "bust" then -- Player bust.
                print("\27[31m" .. "Bust ! -" .. johnRisk.bet .. "$" .. "\27[0m")
            elseif currentGame:CheckOutcome(currentGame:DealersHand()) == "bust" then -- Dealer bust
                print("\27[32m" .. "Dealer bust ! +" .. johnRisk.bet .. "$" .. "\27[0m")
                johnRisk.totalCash = johnRisk.totalCash + johnRisk.bet * 2
            elseif currentGame:ReturnTotalHandValue(currentGame:PlayersHand()) > currentGame:ReturnTotalHandValue(currentGame:DealersHand()) then -- Player have a stronger hand.
                print("\27[32m" .. "Win ! +" .. johnRisk.bet .. "$" .. "\27[0m")
                johnRisk.totalCash = johnRisk.totalCash + johnRisk.bet * 2
            elseif currentGame:ReturnTotalHandValue(currentGame:PlayersHand()) < currentGame:ReturnTotalHandValue(currentGame:DealersHand()) then -- Dealer have a stronger hand.
                print("\27[31m" .. "Lose ! -" .. johnRisk.bet .. "$" .. "\27[0m")
            else                                                                                                                                  -- Player and the dealer have the same hand value.
                print("\27[33m" .. "Push !" .. "\27[0m")
                johnRisk.totalCash = johnRisk.totalCash + johnRisk.bet
            end
        end
    until finishGame == true
    --#endregion
    PressToContinue()
    currentGame:ResetHand()
    johnRisk.bet = 0
end

print("You lost everything, was it worth it?")
