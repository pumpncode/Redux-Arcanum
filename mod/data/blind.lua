SMODS.Atlas({ key = 'arcanum_blinds', path = 'ra_blind_atlas.png', px = 34, py = 34, frames = 21, atlas_table =
'ANIMATION_ATLAS' })

SMODS.Blind { -- The Hex
    key = 'hex',
    loc_txt = {
        name = 'The Hex',
        text = { 'All Consumables', 'are debuffed' },
    },
    boss = { min = 2 },

    drawn_to_hand = function(self)
        sendDebugMessage("Blind Activated", "ReduxArcanumDebugLogger")
        -- Only activate once
        if G.GAME.current_round.hands_played == 0 and G.GAME.current_round.discards_used == 0 then
            G.E_MANAGER:add_event(Event({
                blocking = false,
                trigger = 'after',
                delay = 0.1,
                func = function()
                    if G.STATE == G.STATES.ROUND_EVAL then
                        for i = 1, #G.consumeables.cards do
                            G.consumeables.cards[i]:set_debuff(false)
                        end
                        return true
                    else
                        if not G.GAME.blind.disabled then
                            for i = 1, #G.consumeables.cards do
                                G.consumeables.cards[i]:set_debuff(true)
                            end
                        end
                        return false
                    end
                end
            }))
        end
    end,

    disable = function()
        for i = 1, #G.consumeables.cards do
            G.consumeables.cards[i]:set_debuff(false)
        end
    end,

    boss_colour = HEX('5D757A'),

    pos = { y = 0 },
    atlas = 'arcanum_blinds'
}
