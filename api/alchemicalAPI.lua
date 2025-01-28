-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--      ALCHEMICAL CLASSES
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-

SMODS.ConsumableType {
    key = 'Alchemical',
    primary_colour = HEX('FFFFFF'),
    secondary_colour = HEX('C09D75'),
    -- loc_txt = {
    --     name = 'Alchemical',
    --     collection = 'Alchemical Cards',
    --     text = {
    --         "Can only be used",
    --         "during a {C:attention}blind{}"
    --     },
    --     undiscovered = {
    --         name = 'Not Discovered',
    --         text = {
    --             [1] = 'Purchase or use',
    --             [2] = 'this card in an',
    --             [3] = 'unseeded run to',
    --             [4] = 'learn what it does'
    --         }
    --     }
    -- },
    collection_rows = { 4, 4 },
    shop_rate = 0
}

SMODS.UndiscoveredSprite {
    key = 'Alchemical',
    atlas = 'arcanum_alchemical_undiscovered',
    pos = { x = 0, y = 0 }
}

-- Standard function used to define when an alchemy card can be used
-- (Typically, during a blind or in a booster pack)
function alchemical_can_use(self, card)
    
    -- Two different use cases here:
    -- 1) If the alchemy card is owned by the player, it should only be useable during a blind.
    -- 2) If the alchemy card is part of a booster pack, it should be useable if there is an empty consumable slot.
    -- Secnario 2 has been ported over to overriden functions at the bottom of this file

    -- Secret third scenario: debuffed alchemical cards (via new boss blind) should not be useable either

    if G.STATE == G.STATES.SELECTING_HAND and not card.debuff then
        return true
    else
        return false
    end
end

function alchemical_use(func)
    return function(self, card)
        G.deck.config.played_alchemicals = G.deck.config.played_alchemicals or {}
        table.insert(G.deck.config.played_alchemicals, {self, card})
        check_for_unlock({ type = 'used_alchemical' })
        if card.edition and card.edition.polychrome and card.ability.extra then
            card.ability.extra = math.ceil(card.ability.extra * card.edition.x_mult)
        end
        func(self, card)
    end
end

function ra_reset_played_alchemicals()
    -- sendDebugMessage("Resetting played alchemicals", "ReduxArcanumDebugLogger")
    if G.deck.config.played_alchemicals then
        for _, alchemical in ipairs(G.deck.config.played_alchemicals) do
            sendDebugMessage(alchemical[1].key, "ReduxArcanumDebugLogger")
            if alchemical[1].end_blind then
                alchemical[1].end_blind(alchemical[1], alchemical[2])
            end
        end
        G.deck.config.played_alchemicals = {}
    end
end

function alchemical_get_x_mult(card)
    if card.edition and card.edition.polychrome and card.ability.extra then
        return card.edition.x_mult
    else
        return 1
    end
end

function alchemical_loc_vars(self, info_queue, center)
    local vars

    if center.edition and center.edition.polychrome and center.ability.extra then
        vars = { math.ceil(center.ability.extra * center.edition.x_mult) }
    else
        vars = { center.ability.extra }
    end

    return { vars = vars }
end