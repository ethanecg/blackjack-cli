local Module = {}

function Module.Game(player)
    local game = {}

    -- parameter
    local needSHuffle = false
    local allCards = {}
    local playerCurrentCards = {}
    local dealerCurrentCards = {}

    function game:RestockCards()
        -- restock cards
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

    function game:ReturnTotalHandValue(hand)
        local totalValue
        for i = 1, #hand, 1 do
            totalValue = totalValue + hand[i]
        end
    end

    function game:SpecialCardValue(value)

    end

    function game:FirstCardDistribution()
        -- this only work with 1 player
        for i = 1, 2, 1 do
            local playerCardIndex = math.random(1, #allCards)
            table.insert(playerCurrentCards, allCards(playerCardIndex))
            table.remove(allCards, playerCardIndex)

            local dealerCardIndex = math.random(1, #allCards)
            table.insert(dealerCurrentCards, allCards(playerCardIndex))
            table.remove(allCards, dealerCardIndex)

            local dealerCardsIndex = math.random(1, #allCards)
        end
    end

    function game:SecondCardDistribution()
        local choice
    end

    return game
end

return Module
