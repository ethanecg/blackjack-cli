local Module = {}

function Module.Game(player)
    local game = {}

    -- parameter
    local needSHuffle = false
    local allCards = {}
    function game:AllCards()
        return allCards
    end

    local playerCurrentCards = {}
    function game:PlayerCurrentCards()
        return playerCurrentCards
    end

    local dealerCurrentCards = {}
    function game:DealerCurrentCards()
        return dealerCurrentCards
    end

    local secondDealerCardShown
    function game:SecondDealerCardShown(value)
        secondDealerCardShown = value
    end

    --- remove the cards from the global cards and add cards in it again
    function game:RestockCards()
        allCards = {} -- make the deck of cards empty

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
                    table.insert(allCards, v)
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

    --- randomly take a card from the deck and put it in the hand of the dealer and the player (2 for each)
    function game:FirstCardDistribution()
        for i = 1, 2, 1 do
            local playerCardIndex = math.random(1, #allCards)
            table.insert(playerCurrentCards, allCards(playerCardIndex))
            table.remove(allCards, playerCardIndex)

            local dealerCardIndex = math.random(1, #allCards)
            table.insert(dealerCurrentCards, allCards(dealerCardIndex))
            table.remove(allCards, dealerCardIndex)

            local dealerCardsIndex = math.random(1, #allCards)
        end
    end

    --- return the different outcome based on your hand ("blackjack", "flop", "canplay")
    function game:CheckOutcome(hand)
        if #hand == 2 and game:ReturnTotalHandValue(hand) == 21 and game:ReturnTotalHandValue(dealerCurrentCards) ~= 21 then
            return "blackjack"
        elseif game:ReturnTotalHandValue(hand) > 21 then
            return "flop"
        elseif game:ReturnTotalHandValue(hand) < 21 then
            return "canplay" -- means you have choice like hit or stand
        end
    end

    --- add a card to players hand
    function game:SecondCardDistribution()
        local playerCardIndex = math.random(1, #allCards)
        table.insert(playerCurrentCards, allCards(playerCardIndex))
        table.remove(allCards, playerCardIndex)
    end

    function game:FinalCardDistribution()
        repeat
            local dealerCardIndex = math.random(1, #allCards)
            table.insert(dealerCurrentCards, allCards(dealerCardIndex))
            table.remove(allCards, dealerCardIndex)
        until game:ReturnTotalHandValue(dealerCurrentCards) >= 17
    end

    function game:ShowTable()
        print("")
        for i = 1, #dealerCurrentCards, 1 do
            io.write(" | " .. dealerCurrentCards[i] .. " | ")
        end
        print("")
        for i = 1, #dealerCurrentCards, 1 do
            io.write(" | " .. playerCurrentCards[i] .. " | ")
        end
        print("")
    end

    return game
end

return Module
