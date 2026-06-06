local Module = {}

function Module.Game(player)
    local game = {}

    -- parameter
    local needSHuffle = false
    local deck = {}
    function game:Deck()
        return deck
    end

    local playerHand = {}
    function game:PlayersHand()
        return playerHand
    end

    local dealersHand = {}
    function game:DealersHand()
        return dealersHand
    end

    local secondDealerCardNotShown
    --- set the second delaer card to be shown or now this is usefull well you call the function show table
    function game:SecondDealerCardNotShown(value)
        secondDealerCardNotShown = value
    end

    --- remove the cards from the global cards and add cards in it again
    function game:RestockCards()
        deck = {} -- make the deck of cards empty

        local cardMap = {
            [1] = "A",
            [11] = "Q",
            [12] = "J",
            [13] = "K"
        }

        for p = 1, 2, 1 do      -- pack
            for v = 1, 13, 1 do -- card value
                local cardValue = cardMap[v] or v
                for n = 1, 4 do -- number of similar card value
                    table.insert(deck, cardValue)
                end
            end
        end
    end

    --- get the value of a hand (also if the value < 21 and you have a ace make the value 1)
    --- @param hand integer[] an array of card (e.g., {10, 12, 13})
    --- @return integer totalValue return the total value of the hand
    function game:ReturnTotalHandValue(hand)
        local totalValue = 0
        local numberOfAce = 0
        -- initial count assuming all ace value 11
        for i = 1, #hand, 1 do
            if (hand[i] == "A") then
                numberOfAce = numberOfAce + 1
            end
            totalValue = totalValue + game:SpecialCardValue(hand[i], 11, hand)
        end

        -- change the number of ace to try to be below 21
        if totalValue > 21 and numberOfAce > 0 then
            totalValue = 0
            for a = 1, numberOfAce, 1 do
                local count = 0
                local lessThanTwentyOne = false
                for i = 1, #hand, 1 do
                    if lessThanTwentyOne == false then
                        if count <= a then
                            totalValue = totalValue + game:SpecialCardValue(hand[i], 1, hand)
                        else
                            totalValue = totalValue + game:SpecialCardValue(hand[i], 11, hand)
                        end

                        if i == #hand and totalValue <= 21 then
                            lessThanTwentyOne = true
                        end
                    end
                end
            end
        end

        return totalValue
    end

    --- check if a card have a special value and return the real value (number)
    --- @param value integer the value of the card
    --- @param AceValue integer the value of the ace
    --- @param hand integer[] the array of card in your hand
    --- @return integer cardValue retrun the value of the card
    function game:SpecialCardValue(value, AceValue, hand)
        local cardMap = {
            ["A"] = AceValue,
            ["Q"] = 10,
            ["J"] = 10,
            ["K"] = 10,
        }

        local cardValue = cardMap[value] or value
        return cardValue
    end

    --- return the different outcome based on your hand ("blackjack", "flop", "canplay")
    ---@param hand (number|string)[] the hand that contain the cards
    function game:CheckOutcome(hand)
        if #hand == 2 and game:ReturnTotalHandValue(hand) == 21 then
            return "blackjack"
        elseif game:ReturnTotalHandValue(hand) > 21 then
            return "bust"
        elseif game:ReturnTotalHandValue(hand) < 21 then
            return "canplay" -- means you have choice like hit or stand
        end
    end

    --- randomly take a card from the deck and put it in the hand of the dealer and the player (2 for each) also use ShowTable()
    function game:FirstCardDistribution()
        for i = 1, 2, 1 do
            if i == 1 then
                os.execute("cls")
                print("distibuting.. \n")
                game:ShowTable()
                os.execute("timeout /t 1 /nobreak >nul")
            end

            local playerCardIndex = math.random(1, #deck)
            table.insert(playerHand, deck[playerCardIndex])
            table.remove(deck, playerCardIndex)

            os.execute("cls")
            print("distibuting.. \n")
            game:ShowTable()
            os.execute("timeout /t 1 /nobreak >nul")

            local dealerCardIndex = math.random(1, #deck)
            table.insert(dealersHand, deck[dealerCardIndex])
            table.remove(deck, dealerCardIndex)

            os.execute("cls")
            print("distibuting.. \n")
            game:ShowTable()
            os.execute("timeout /t 1 /nobreak >nul")
        end
    end

    --- add a card to the players hand
    function game:SecondCardDistribution()
        os.execute("cls")
        print("distibuting.. \n")
        game:ShowTable()
        os.execute("timeout /t 1 /nobreak >nul")

        local playerCardIndex = math.random(1, #deck)
        table.insert(playerHand, deck[playerCardIndex])
        table.remove(deck, playerCardIndex)

        os.execute("cls")
        print("distibuting.. \n")
        game:ShowTable()
        os.execute("timeout /t 1 /nobreak >nul")
    end

    --- Show the hidden card and add cards to the dealers hand until he his hand value >= 17 and show table for each time add a card is added.
    function game:FinalCardDistribution()
        -- Reveal the card.
        os.execute("cls")
        print("Revealing the hidden card.. \n")
        game:ShowTable()
        os.execute("timeout /t 1 /nobreak >nul")
        os.execute("cls")
        game:SecondDealerCardNotShown(false)
        game:ShowTable()

        if not (game:ReturnTotalHandValue(dealersHand) >= 17) then
            repeat
                os.execute("cls")
                print("distibuting.. \n")
                game:ShowTable()
                os.execute("timeout /t 1 /nobreak >nul")

                local dealerCardIndex = math.random(1, #deck)
                table.insert(dealersHand, deck[dealerCardIndex])
                table.remove(deck, dealerCardIndex)

                os.execute("cls")
                print("distibuting.. \n")
                game:ShowTable()
                os.execute("timeout /t 1 /nobreak >nul")
            until game:ReturnTotalHandValue(dealersHand) >= 17
        end
    end

    --- print the cards of both the ddealer and the player in the console
    function game:ShowTable()
        print("")
        for i = 1, #dealersHand, 1 do
            if secondDealerCardNotShown and i == 2 then
                io.write(" | " .. "?" .. " | ")
            else
                io.write(" | " .. dealersHand[i] .. " | ")
            end
        end
        print("\n")
        for i = 1, #playerHand, 1 do
            io.write(" | " .. playerHand[i] .. " | ")
        end
        print("\n")
    end

    --- remove all cards from the dealersHand and the playersHand
    function game:ResetHand()
        playerHand = {}
        dealersHand = {}
    end

    return game
end

return Module
