local Module = {}

-- constructor
function Module.Player(name, totalCash)
    local player = {}

    -- methods
    if name == nil or string.gsub(name, " ", "") == "" then
        error("error : the name cannot be empty", 0)
    else
        player.name = name
    end

    if totalCash == nil or totalCash < 5 then
        error("error : you cannot play without atleast 5$", 0)
    else
        player.totalCash = totalCash
    end

    player.bet = 0

    -- methods
    function player:AddBet(betToAdd)
        if betToAdd <= 0 then
            error("error : the bet cannot be negative or equal to 0", 0)
        elseif betToAdd > self.totalCash then
            error("error : you don't have enough money for this bet", 0)
        else
            self.bet = betToAdd
            self.totalCash = self.totalCash - betToAdd
        end
    end

    return player
end

return Module
