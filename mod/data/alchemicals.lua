-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--       HELPER FUNCTIONS
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-

function check_alchemical_prev_enhancement(given_card)
    sendDebugMessage(given_card.config.center.name, "ReduxArcanumDebugLogger")
    if G.deck.config.ra_manganese then
        for _, manganesed_card in ipairs(G.deck.config.ra_manganese) do
            if given_card.unique_val == manganesed_card.card_id and given_card.config.center == G.P_CENTERS.m_steel then
                return manganesed_card.prev_enhancement
            end
        end
    end
    if G.deck.config.ra_glass then
        for _, glassed_card in ipairs(G.deck.config.ra_glass) do
            if given_card.unique_val == glassed_card.card_id and given_card.config.center == G.P_CENTERS.m_glass then
                return glassed_card.prev_enhancement
            end
        end
    end
    if G.deck.config.ra_gold then
        for _, golded_card in ipairs(G.deck.config.ra_gold) do
            if given_card.unique_val == golded_card.card_id and given_card.config.center == G.P_CENTERS.m_gold then
                return golded_card.prev_enhancement
            end
        end
    end
    if G.deck.config.ra_silver then
        for _, silvered_card in ipairs(G.deck.config.ra_silver) do
            if given_card.unique_val == silvered_card.card_id and given_card.config.center == G.P_CENTERS.m_lucky then
                return silvered_card.prev_enhancement
            end
        end
    end

    return given_card.config.center
end

function check_alchemical_prev_edition(given_card)
    if G.deck.config.ra_bismuth then
        for _, bismuthed_card in ipairs(G.deck.config.ra_bismuth) do
            if given_card.unique_val == bismuthed_card.card_id and given_card.edition and given_card.edition.polychrome then
                return bismuthed_card.prev_edition
            end
        end
    end
    if G.deck.config.ra_uranium then
        for _, uraniumed_card in ipairs(G.deck.config.ra_uranium) do
            if given_card.unique_val == uraniumed_card.card_id then
                return uraniumed_card.prev_edition
            end
        end
    end

    return given_card.edition
end

function get_most_common_suit()
    -- This gets all suits defined in Steammodded to account for modded suits
    local suit_to_card_counter = {}
    for _, v in pairs(SMODS.Suits) do
        if not v.disabled then
            suit_to_card_counter[v.name] = 0
        end
    end


    if G.playing_cards then
        for _, v in pairs(G.playing_cards) do
            suit_to_card_counter[v.base.suit] = suit_to_card_counter[v.base.suit] + 1
        end
    end

    local top_suit = "";
    local top_count = -1;
    for suit, count in pairs(suit_to_card_counter) do
        if top_count < count then
            top_suit = suit
            top_count = count
        end
    end

    return top_suit
end

-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--      ALCHEMICAL CARDS
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-

SMODS.Consumable { -- Ignis
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "ignis",
    loc_txt = {
        name = 'Ignis',
        text = {
            "Gain {C:attention}+#1#{} discard",
            "for this blind"
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra } }
    end,
    unlocked = true,
    discovered = false,
    config = { extra = 1 },
    cost = 3,
    pos = { x = 0, y = 0 },

    can_use = alchemical_can_use,

    use = alchemical_use(function(self, card)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                ease_discard(card.ability.extra)
                return true
            end
        }))
    end),
}

SMODS.Consumable { -- Aqua
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "aqua",
    loc_txt = {
        name = 'Aqua',
        text = {
            "Gain {C:attention}+#1#{} hand",
            "for this blind"
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra } }
    end,
    unlocked = true,
    discovered = false,
    config = { extra = 1 },
    cost = 3,
    pos = { x = 1, y = 0 },

    can_use = alchemical_can_use,

    use = alchemical_use(function(self, card)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                ease_hands_played(card.ability.extra)
                return true
            end
        }))
    end),
}

SMODS.Consumable { -- Terra
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "terra",
    loc_txt = {
        name = 'Terra',
        text = { "Reduce blind by {C:attention}#1#%{}" }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra } }
    end,
    unlocked = true,
    discovered = false,
    config = { extra = 15 },
    cost = 3,
    pos = { x = 2, y = 0 },

    can_use = alchemical_can_use,

    use = alchemical_use(function(self, card)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.GAME.blind.chips = math.floor(G.GAME.blind.chips * (1 - card.ability.extra / 100))
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)

                local chips_UI = G.hand_text_area.blind_chips
                G.FUNCS.blind_chip_UI_scale(G.hand_text_area.blind_chips)
                G.HUD_blind:recalculate()
                chips_UI:juice_up()

                if not silent then play_sound('chips2') end
                return true
            end
        }))
    end),
}

SMODS.Consumable { -- Aero
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "aero",
    loc_txt = {
        name = 'Aero',
        text = { "Draw {C:attention}#1#{} cards" }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra } }
    end,
    unlocked = true,
    discovered = false,
    config = { extra = 4 },
    cost = 3,
    pos = { x = 3, y = 0 },

    can_use = alchemical_can_use,

    use = alchemical_use(function(self, card)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                G.FUNCS.draw_from_deck_to_hand(card.ability.extra)
                return true
            end
        }))
    end),
}

SMODS.Consumable { -- Quicksilver
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "quicksilver",
    loc_txt = {
        name = 'Quicksilver',
        text = {
            "{C:attention}+#1#{} hand size",
            "for this blind"
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra } }
    end,
    unlocked = true,
    discovered = false,
    config = { extra = 2 },
    cost = 3,
    pos = { x = 4, y = 0 },

    can_use = alchemical_can_use,

    use = alchemical_use(function(self, card)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                G.hand:change_size(card.ability.extra)
                if not G.deck.config.quicksilver then G.deck.config.quicksilver = 0 end
                G.deck.config.quicksilver = G.deck.config.quicksilver + card.ability.extra
                return true
            end
        }))
    end),

    end_blind = function(self, card)
        sendDebugMessage("Resetting quicksilver", "ReduxArcanumDebugLogger")
        G.hand:change_size(-card.ability.extra)
        if G.deck.config.quicksilver then
            G.deck.config.quicksilver = G.deck.config.quicksilver - card.ability.extra
        end
        return true
    end,

}

SMODS.Consumable { -- Salt
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "salt",
    loc_txt = {
        name = 'Salt',
        text = { "Gain {C:attention}#1#{} tag" }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra } }
    end,
    unlocked = true,
    discovered = false,
    config = { extra = 1 },
    cost = 3,
    pos = { x = 5, y = 0 },

    can_use = alchemical_can_use,

    use = alchemical_use(function(self, card)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                local _tag_name
                if G.FORCE_TAG then 
                    _tag_name = G.FORCE_TAG 
                else 
                    local _pool, _pool_key = get_current_pool('Tag', nil, nil, nil)
                    _tag_name = pseudorandom_element(_pool, pseudoseed(_pool_key))
                    local it = 1
                    while _tag_name == 'UNAVAILABLE' or
                        _tag_name == "tag_double" or
                        _tag_name == "tag_orbital" or
                        _tag_name == "tag_bunc_arcade" -- Bunco compat for now, otherwise draws entire deck
                    do
                        it = it + 1
                        _tag_name = pseudorandom_element(_pool, pseudoseed(_pool_key .. '_resample' .. it))
                    end
                end

                G.GAME.round_resets.blind_tags = G.GAME.round_resets.blind_tags or {}
                local _tag = Tag(_tag_name, nil, G.GAME.blind)
                add_tag(_tag)
                -- Trigger immediate tags and booster tags
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        for i = 1, #G.GAME.tags do
                            G.GAME.tags[i]:apply_to_run({ type = 'immediate' })
                        end
                        for i = 1, #G.GAME.tags do
                          if G.GAME.tags[i].key == "tag_boss" then
                          else
                            if G.GAME.tags[i]:apply_to_run({type = 'new_blind_choice'}) then break end
                          end
                        end
                        return true
                    end
                }))
                return true
            end
        }))
    end),
}

SMODS.Consumable { -- Sulfur
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "sulfur",
    loc_txt = {
        name = 'Sulfur',
        text = {
            "Reduce hands to {C:attention}1",
            "Gain {C:attention}$#1#{} for each",
            "hand removed"
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra } }
    end,
    unlocked = true,
    discovered = false,
    config = { extra = 4 },
    cost = 3,
    pos = { x = 0, y = 1 },

    can_use = alchemical_can_use,

    use = alchemical_use(function(self, card)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.5,
            func = function()
                local prev_hands = G.GAME.current_round.hands_left
                ease_hands_played(-(prev_hands - 1))
                delay(0.5)
                ease_dollars(card.ability.extra * (prev_hands - 1), true)
                delay(0.5)
                return true
            end
        }))
    end),
}

SMODS.Consumable { -- Phosphorus
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "phosphorus",
    loc_txt = {
        name = 'Phosphorus',
        text = {
            "Return {C:attention}all{} discarded",
            "cards to deck"
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = {} }
    end,
    unlocked = true,
    discovered = false,
    config = { extra = 4 },
    cost = 3,
    pos = { x = 1, y = 1 },

    can_use = alchemical_can_use,

    use = alchemical_use(function(self, card)
        local take_cards_from_discard = function(count)
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    for i = 1, count do --draw cards from deck
                        draw_card(G.discard, G.deck, i * 100 / count, 'up', nil, nil, 0.005, i % 2 == 0, nil,
                            math.max((21 - i) / 20, 0.7))
                    end
                    return true
                end
            }))
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                take_cards_from_discard(#G.discard.cards)
                return true
            end
        }))
    end),
}

SMODS.Consumable { -- Bismuth
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "bismuth",
    loc_txt = {
        name = 'Bismuth',
        text = {
            "Converts up to",
            "{C:attention}#1#{} selected cards",
            "to {C:dark_edition}Polychrome",
            "for one blind"
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra } }
    end,
    unlocked = true,
    discovered = false,
    config = { extra = 2 },
    cost = 3,
    pos = { x = 2, y = 1 },

    can_use = function(self, card)
        if alchemical_can_use(self, card) then
            if #G.hand.highlighted <= card.ability.extra and #G.hand.highlighted >= 1 then return true else return false end
        else
            return false
        end
    end,

    use = alchemical_use(function(self, used_card)
        G.deck.config.ra_bismuth = G.deck.config.ra_bismuth or {}
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                play_sound('polychrome1', 1.2, 0.7)
                for k, card in ipairs(G.hand.highlighted) do
                    local prev_edition = check_alchemical_prev_edition(card)
                    card:set_edition({ polychrome = true }, true, true)
                    used_card:juice_up(0.3, 0.5)
                    table.insert(G.deck.config.ra_bismuth, { card_id = card.unique_val, prev_edition = prev_edition })
                end
                return true
            end
        }))
    end),

    end_blind = function(self, card)
        if G.deck.config.ra_bismuth then
            for _, bismuthed_card in ipairs(G.deck.config.ra_bismuth) do
                for k, card in ipairs(G.playing_cards) do
                    if card.unique_val == bismuthed_card.card_id and card.edition and card.edition.polychrome then
                        card:set_edition(bismuthed_card.prev_edition, true, true)
                    end
                end
            end
            G.deck.config.ra_bismuth = {}
        end
        return true
    end,
}

SMODS.Consumable { -- Cobalt
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "cobalt",
    loc_txt = {
        name = 'Cobalt',
        text = {
            "Upgrade currently",
            "selected {C:attention}poker hand",
            "by {C:attention}#1#{} levels for one blind"
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra } }
    end,
    unlocked = true,
    discovered = false,
    config = { extra = 2 },
    cost = 3,
    pos = { x = 3, y = 1 },

    can_use = function(self, card)
        if alchemical_can_use(self, card) then
            if #G.hand.highlighted >= 1 then return true else return false end
        else
            return false
        end
    end,

    use = alchemical_use(function(self, card)
        G.deck.config.cobalt = G.deck.config.cobalt or {}
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                local text, disp_text = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
                table.insert(G.deck.config.cobalt, text)
                update_hand_text({ sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3 },
                    {
                        handname = localize(text, 'poker_hands'),
                        chips = G.GAME.hands[text].chips,
                        mult = G.GAME.hands
                            [text].mult,
                        level = G.GAME.hands[text].level
                    })
                level_up_hand(card, text, nil, card.ability.extra)
                -- update_hand_text({ sound = 'button', volume = 0.7, pitch = 1.1, delay = 0 },
                --     { mult = 0, chips = 0, handname = '', level = '' })

                return true
            end
        }))
    end),

    end_blind = function(self, card)
        for _, text in ipairs(G.deck.config.cobalt) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    update_hand_text({ sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3 },
                        {
                            handname = localize(text, 'poker_hands'),
                            chips = G.GAME.hands[text].chips,
                            mult = G
                                .GAME.hands[text].mult,
                            level = G.GAME.hands[text].level
                        })
                    level_up_hand(nil, text, nil, -card.ability.extra)
                    update_hand_text({ sound = 'button', volume = 0.7, pitch = 1.1, delay = 0 },
                        { mult = 0, chips = 0, handname = '', level = '' })
                    return true
                end
            }))
        end
        G.deck.config.cobalt = {}
        return true
    end,
}

SMODS.Consumable { -- Arsenic
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "arsenic",
    loc_txt = {
        name = 'Arsenic',
        text = {
            "{C:attention}Swap{} your current",
            "hands and discards"
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = {} }
    end,
    unlocked = true,
    discovered = false,
    config = { extra = 2 },
    cost = 3,
    pos = { x = 4, y = 1 },

    can_use = function(self, card)
        if alchemical_can_use(self, card) then
            if G.GAME.current_round.discards_left > 0 then return true else return false end
        else
            return false
        end
    end,

    use = alchemical_use(function(self, card)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                local temp_hands = G.GAME.current_round.hands_left
                local temp_discards = G.GAME.current_round.discards_left
                local change_discard = temp_hands - temp_discards
                local change_hands = -change_discard
                -- G.GAME.current_round.hands_left = 0
                -- G.GAME.current_round.discards_left = 0
                ease_hands_played(change_hands)
                ease_discard(change_discard)
                return true
            end
        }))
    end),
}

SMODS.Consumable { -- Antimony
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "antimony",
    loc_txt = {
        name = 'Antimony',
        text = {
            "Create a {C:dark_edition}Negative{} {C:eternal}0-cost{}",
            "{C:attention}copy{} of a random",
            "joker for one blind"
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = {} }
    end,
    unlocked = true,
    discovered = false,
    config = { extra = 2 },
    cost = 3,
    pos = { x = 5, y = 1 },

    can_use = alchemical_can_use,

    use = alchemical_use(function(self, card)
        G.jokers.config.antimony = G.jokers.config.antimony or {}
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                if #G.jokers.cards > 0 then
                    local chosen_joker = pseudorandom_element(G.jokers.cards, pseudoseed('invisible'))
                    local card = copy_card(chosen_joker, nil, nil, nil,
                        chosen_joker.edition and chosen_joker.edition.negative)
                    card:set_edition({ negative = true }, true)
                    card.cost = 0
                    card.sell_cost = 0
                    -- card:set_eternal(true)
                    if card.ability.invis_rounds then card.ability.invis_rounds = 0 end
                    card:add_to_deck()
                    G.jokers:emplace(card)
                    table.insert(G.jokers.config.antimony, card.unique_val)
                    return true
                end
            end
        }))
    end),

    end_blind = function(self, card)
        for _, poly_id in ipairs(G.jokers.config.antimony) do
            for k, joker in ipairs(G.jokers.cards) do
                if joker.unique_val == poly_id then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.3,
                        blockable = false,
                        func = function()
                            play_sound('tarot1')
                            joker.T.r = -0.2
                            joker:juice_up(0.3, 0.4)
                            joker.states.drag.is = true
                            joker.children.center.pinch.x = true
                            G.E_MANAGER:add_event(Event({
                                trigger = 'after',
                                delay = 0.3,
                                blockable = false,
                                func = function()
                                    G.jokers:remove_card(joker)
                                    joker:remove()
                                    joker = nil
                                    return true;
                                end
                            }))
                            return true;
                        end
                    }))
                end
            end
        end
        G.jokers.config.antimony = {}
        return true
    end,
}

SMODS.Consumable { -- Soap
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "soap",
    loc_txt = {
        name = 'Soap',
        text = {
            "Replace up to {C:attention}#1#{}",
            "selected cards with cards",
            "from your deck"
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra } }
    end,
    unlocked = true,
    discovered = false,
    config = { extra = 3 },
    cost = 3,
    pos = { x = 0, y = 2 },

    can_use = function(self, card)
        if alchemical_can_use(self, card) then
            if #G.hand.highlighted <= card.ability.extra and #G.hand.highlighted >= 1 then return true else return false end
        else
            return false
        end
    end,

    use = alchemical_use(function(self, card)
        local return_to_deck = function(card)
            if not (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and
                G.hand.config.card_limit <= 0 and #G.hand.cards == 0 then
                G.STATE = G.STATES.GAME_OVER; G.STATE_COMPLETE = false
                return true
            end

            delay(0.05)
            draw_card(G.hand, G.deck, 100, 'up', false, card)
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                for k, _card in ipairs(G.hand.highlighted) do
                    return_to_deck(_card)
                end
                G.FUNCS.draw_from_deck_to_hand(card.ability.extra)
                return true
            end
        }))
    end),
}

SMODS.Consumable { -- Manganese
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "manganese",
    loc_txt = {
        name = 'Manganese',
        text = {
            "Enhances up to",
            "{C:attention}#1#{} selected cards",
            "into {C:attention}Steel Cards",
            "for one blind"
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra } }
    end,
    unlocked = true,
    discovered = false,
    config = { extra = 4 },
    cost = 3,
    pos = { x = 1, y = 2 },

    can_use = function(self, card)
        if alchemical_can_use(self, card) then
            if #G.hand.highlighted <= card.ability.extra and #G.hand.highlighted >= 1 then return true else return false end
        else
            return false
        end
    end,

    use = alchemical_use(function(self, used_card)
        G.deck.config.ra_manganese = G.deck.config.ra_manganese or {}
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                play_sound('tarot1')
                for k, card in ipairs(G.hand.highlighted) do
                    local prev_enhancement = check_alchemical_prev_enhancement(card)
                    card:set_ability(G.P_CENTERS.m_steel)
                    card:juice_up(1, 0.5)
                    used_card:juice_up(0.3, 0.5)
                    table.insert(G.deck.config.ra_manganese,
                        { card_id = card.unique_val, prev_enhancement = prev_enhancement })
                end
                return true
            end
        }))
    end),

    end_blind = function(self, card)
        if G.deck.config.ra_manganese then
            for _, manganesed_card in ipairs(G.deck.config.ra_manganese) do
                for k, card in ipairs(G.playing_cards) do
                    if card.unique_val == manganesed_card.card_id and card.config.center == G.P_CENTERS.m_steel then
                        card:set_ability(manganesed_card.prev_enhancement)
                    end
                end
            end
            G.deck.config.ra_manganese = {}
        end
        return true
    end,
}

SMODS.Consumable { -- Wax
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "wax",
    loc_txt = {
        name = 'Wax',
        text = {
            "Create {C:attention}#1#{} temporary",
            "copies of the selected card",
            "for one blind"
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra } }
    end,
    unlocked = true,
    discovered = false,
    config = { extra = 2 },
    cost = 3,
    pos = { x = 2, y = 2 },

    can_use = function(self, card)
        if alchemical_can_use(self, card) then
            if #G.hand.highlighted == 1 then return true else return false end
        else
            return false
        end
    end,

    use = alchemical_use(function(self, used_card)
        G.deck.config.ra_wax = G.deck.config.ra_wax or {}
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                for i = 1, 2 do
                    G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                    local _card = copy_card(G.hand.highlighted[1], nil, nil, G.playing_card)
                    _card:add_to_deck()
                    G.deck.config.card_limit = G.deck.config.card_limit + 1
                    table.insert(G.playing_cards, _card)
                    G.hand:emplace(_card)
                    _card:start_materialize(nil, _first_dissolve)
                    table.insert(G.deck.config.ra_wax, { card_id = _card.unique_val })
                end
                playing_card_joker_effects(new_cards)
                return true
            end
        }))
    end),

    end_blind = function(self, card)
        if G.deck.config.ra_wax then
            local _first_dissolve = false
            for _, waxed_card in ipairs(G.deck.config.ra_wax) do
                for k, card in ipairs(G.playing_cards) do
                    if card.unique_val == waxed_card.card_id then
                        card:start_dissolve(nil, _first_dissolve)
                        _first_dissolve = true
                    end
                end
            end
            G.deck.config.ra_wax = {}
        end
        return true
    end,
}

SMODS.Consumable { -- Borax
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "borax",
    loc_txt = {
        name = 'Borax',
        text = {
            "Converts up to",
            "{C:attention}#1#{} selected cards",
            "into most common {C:attention}suit",
            "for one blind",
            "{C:inactive}Current suit: {V:1}#2#{}"
        }
    },
    loc_vars = function(self, info_queue, center)
        local top_suit = get_most_common_suit()
        return { vars = { center.ability.extra, top_suit, colours = { G.C.SUITS[top_suit] } } }
    end,
    unlocked = true,
    discovered = false,
    config = { extra = 4 },
    cost = 3,
    pos = { x = 3, y = 2 },

    can_use = function(self, card)
        if alchemical_can_use(self, card) then
            if #G.hand.highlighted <= card.ability.extra and #G.hand.highlighted >= 1 then return true else return false end
        else
            return false
        end
    end,

    use = alchemical_use(function(self, used_card)
        G.deck.config.ra_borax = G.deck.config.ra_borax or {}
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                local top_suit = get_most_common_suit();

                play_sound('tarot1')
                for k, card in ipairs(G.hand.highlighted) do
                    delay(0.05)
                    card:juice_up(1, 0.5)
                    local prev_suit = card.base.suit
                    card:change_suit(top_suit)
                    table.insert(G.deck.config.ra_borax, { card_id = card.unique_val, prev_suit = prev_suit })
                end
                return true
            end
        }))
    end),

    end_blind = function(self, card)
        if G.deck.config.ra_borax then
            local _first_dissolve = false
            for _, boraxed_card in ipairs(G.deck.config.ra_borax) do
                for k, card in ipairs(G.playing_cards) do
                    if card.unique_val == boraxed_card.card_id then
                        delay(0.05)
                        card:juice_up(1, 0.5)
                        card:change_suit(boraxed_card.prev_suit)
                    end
                end
            end
            G.deck.config.ra_borax = {}
        end
        return true
    end,
}

SMODS.Consumable { -- Glass
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "glass",
    loc_txt = {
        name = 'Glass',
        text = {
            "Enhances up to",
            "{C:attention}#1#{} selected cards",
            "into {C:attention}Glass Cards",
            "for one blind",
            "{C:inactive}Destroyed glass cards",
            "{C:inactive}will not return"
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra } }
    end,
    unlocked = true,
    discovered = false,
    config = { extra = 4 },
    cost = 3,
    pos = { x = 4, y = 2 },

    can_use = function(self, card)
        if alchemical_can_use(self, card) then
            if #G.hand.highlighted <= card.ability.extra and #G.hand.highlighted >= 1 then return true else return false end
        else
            return false
        end
    end,

    use = alchemical_use(function(self, used_card)
        G.deck.config.ra_glass = G.deck.config.ra_glass or {}
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                play_sound('tarot1')
                for k, card in ipairs(G.hand.highlighted) do
                    local prev_enhancement = check_alchemical_prev_enhancement(card)
                    card:set_ability(G.P_CENTERS.m_glass)
                    card:juice_up(1, 0.5)
                    used_card:juice_up(0.3, 0.5)
                    table.insert(G.deck.config.ra_glass,
                        { card_id = card.unique_val, prev_enhancement = prev_enhancement })
                end
                return true
            end
        }))
    end),

    end_blind = function(self, card)
        if G.deck.config.ra_glass then
            for _, glassed_card in ipairs(G.deck.config.ra_glass) do
                for k, card in ipairs(G.playing_cards) do
                    if card.unique_val == glassed_card.card_id and card.config.center == G.P_CENTERS.m_glass then
                        card:set_ability(glassed_card.prev_enhancement)
                    end
                end
            end
            G.deck.config.ra_glass = {}
        end
        return true
    end,
}

SMODS.Consumable { -- Magnet
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "magnet",
    loc_txt = {
        name = 'Magnet',
        text = {
            "Draw {C:attention}#1#{} cards",
            "of the same rank",
            "as the selected card"
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra } }
    end,
    unlocked = true,
    discovered = false,
    config = { extra = 2 },
    cost = 3,
    pos = { x = 5, y = 2 },

    can_use = function(self, card)
        if alchemical_can_use(self, card) then
            if #G.hand.highlighted == 1 then return true else return false end
        else
            return false
        end
    end,

    use = alchemical_use(function(self, used_card)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                local cur_rank = G.hand.highlighted[1].base.id
                local count = 2
                for _, v in pairs(G.deck.cards) do
                    if v.base.id == cur_rank and count > 0 then
                        delay(0.05)
                        draw_card(G.deck, G.hand, 100, 'up', true, v)
                        count = count - 1
                    end
                end
                return true
            end
        }))
    end),
}

SMODS.Consumable { -- Gold
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "gold",
    loc_txt = {
        name = 'Gold',
        text = {
            "Enhances up to",
            "{C:attention}#1#{} selected cards",
            "into {C:attention}Gold Cards",
            "for one blind"
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra } }
    end,
    unlocked = true,
    discovered = false,
    config = { extra = 4 },
    cost = 3,
    pos = { x = 0, y = 3 },

    can_use = function(self, card)
        if alchemical_can_use(self, card) then
            if #G.hand.highlighted <= card.ability.extra and #G.hand.highlighted >= 1 then return true else return false end
        else
            return false
        end
    end,

    use = alchemical_use(function(self, used_card)
        G.deck.config.ra_gold = G.deck.config.ra_gold or {}
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                play_sound('tarot1')
                for k, card in ipairs(G.hand.highlighted) do
                    local prev_enhancement = check_alchemical_prev_enhancement(card)
                    card:set_ability(G.P_CENTERS.m_gold)
                    card:juice_up(1, 0.5)
                    used_card:juice_up(0.3, 0.5)
                    table.insert(G.deck.config.ra_gold,
                        { card_id = card.unique_val, prev_enhancement = prev_enhancement })
                end
                return true
            end
        }))
    end),

    end_blind = function(self, card)
        if G.deck.config.ra_gold then
            for _, golded_card in ipairs(G.deck.config.ra_gold) do
                for k, card in ipairs(G.playing_cards) do
                    if card.unique_val == golded_card.card_id and card.config.center == G.P_CENTERS.m_gold then
                        card:set_ability(golded_card.prev_enhancement)
                    end
                end
            end
            G.deck.config.ra_gold = {}
        end
        return true
    end,
}

SMODS.Consumable { -- Silver
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "silver",
    loc_txt = {
        name = 'Silver',
        text = {
            "Enhances up to",
            "{C:attention}#1#{} selected cards",
            "into {C:attention}Lucky Cards",
            "for one blind"
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra } }
    end,
    unlocked = true,
    discovered = false,
    config = { extra = 4 },
    cost = 3,
    pos = { x = 1, y = 3 },

    can_use = function(self, card)
        if alchemical_can_use(self, card) then
            if #G.hand.highlighted <= card.ability.extra and #G.hand.highlighted >= 1 then return true else return false end
        else
            return false
        end
    end,

    use = alchemical_use(function(self, used_card)
        G.deck.config.ra_silver = G.deck.config.ra_silver or {}
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                play_sound('tarot1')
                for k, card in ipairs(G.hand.highlighted) do
                    local prev_enhancement = check_alchemical_prev_enhancement(card)
                    card:set_ability(G.P_CENTERS.m_lucky)
                    card:juice_up(1, 0.5)
                    used_card:juice_up(0.3, 0.5)
                    table.insert(G.deck.config.ra_silver,
                        { card_id = card.unique_val, prev_enhancement = prev_enhancement })
                end
                return true
            end
        }))
    end),

    end_blind = function(self, card)
        if G.deck.config.ra_silver then
            for _, silvered_card in ipairs(G.deck.config.ra_silver) do
                for k, card in ipairs(G.playing_cards) do
                    if card.unique_val == silvered_card.card_id and card.config.center == G.P_CENTERS.m_lucky then
                        card:set_ability(silvered_card.prev_enhancement)
                    end
                end
            end
            G.deck.config.ra_silver = {}
        end
        return true
    end,
}

SMODS.Consumable { -- Oil
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "oil",
    loc_txt = {
        name = 'Oil',
        text = {
            "Removes {C:attention}debuffs{}",
            "from all cards in",
            "hand for this blind"
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = {} }
    end,
    unlocked = true,
    discovered = false,
    config = {},
    cost = 3,
    pos = { x = 2, y = 3 },

    can_use = alchemical_can_use,

    use = alchemical_use(function(self, used_card)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                for k, v in ipairs(G.hand.cards) do
                    delay(0.05)
                    v:juice_up(1, 0.5)
                    v.ability = v.ability or {}
                    v.ability.debuff_sources = v.ability.debuff_sources or {}
                    table.insert(v.ability.debuff_sources, 'prevent_debuff') -- steammodded thing
                    v.ability.ra_oil = #v.ability.debuff_sources
                    v:set_debuff(false)
                    if v.facing == 'back' then
                        v:flip()
                    end
                end
                return true
            end
        }))

        --     -- This will keep oiled cards non-debuffed.
        --     -- There is a "condition" trigger I found, but it doesn't seem to do anything special. Simply returning false has the same effect
        --     G.E_MANAGER:add_event(Event({
        --         blocking = false,
        --         func = function()
        --             if G.STATE == G.STATES.SELECTING_HAND or G.STATE == G.STATES.HAND_PLAYED then
        --                 for k, card in ipairs(G.hand.cards) do
        --                     if card.config.ra_oil then
        --                         card:set_debuff(false)
        --                         if card.facing == 'back' then
        --                             card:flip()
        --                         end
        --                     end
        --                 end
        --                 return false
        --             elseif G.STATE == G.STATES.ROUND_EVAL then
        --                 for k, card in ipairs(G.playing_cards) do
        --                     if card.config.ra_oil then
        --                         card.config.ra_oil = false
        --                     end
        --                 end
        --                 return true
        --             else
        --                 return false
        --             end
        --         end
        --     }))
    end),

    end_blind = function(self, card)
        sendDebugMessage("Resetting Oil", "ReduxArcanumDebugLogger")
        for k, card in ipairs(G.playing_cards) do
            if card.ability and card.ability.ra_oil then
                card.ability.debuff_sources[card.ability.ra_oil] = false -- steammodded thing
                card.ability.ra_oil = false
            end
        end
        return true
    end,
}

SMODS.Consumable { -- Acid
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "acid",
    loc_txt = {
        name = 'Acid',
        text = {
            "{C:attention}Destroy{} all cards of the ",
            "same rank as selected",
            "card. All cards {C:attention}returned",
            "after this blind"
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = {} }
    end,
    unlocked = true,
    discovered = false,
    config = {},
    cost = 3,
    pos = { x = 3, y = 3 },

    can_use = function(self, card)
        if alchemical_can_use(self, card) then
            if #G.hand.highlighted == 1 then return true else return false end
        else
            return false
        end
    end,

    use = alchemical_use(function(self, used_card)
        G.deck.config.ra_acid = G.deck.config.ra_acid or {}
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                for k, v in ipairs(G.playing_cards) do
                    if v:get_id() == G.hand.highlighted[1]:get_id() then
                        table.insert(G.deck.config.ra_acid, v)
                        if v.ability.name == 'Glass Card' then
                            v:shatter()
                        else
                            v:start_dissolve({ HEX("E3FF37") }, nil, 1.6)
                        end
                    end
                end
                for j = 1, #G.jokers.cards do
                    eval_card(G.jokers.cards[j],
                        { cardarea = G.jokers, remove_playing_cards = true, removed = G.deck.config.ra_acid })
                end
                return true
            end
        }))
    end),

    end_blind = function(self, card)
        if G.deck.config.ra_acid then
            for _, acided_card in ipairs(G.deck.config.ra_acid) do
                G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                local _card = copy_card(acided_card, nil, nil, G.playing_card)
                G.deck:emplace(_card)
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                table.insert(G.playing_cards, _card)
                playing_card_joker_effects({ true })
            end
            G.deck.config.ra_acid = {}
        end
        return true
    end,
}

SMODS.Consumable { -- Brimstone
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "brimstone",
    loc_txt = {
        name = 'Brimstone',
        text = {
            "{C:attention}+#1#{} hands, {C:attention}+#1#{} discards",
            "Debuff the leftmost",
            "non-debuffed joker",
            "for one blind"
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra } }
    end,
    unlocked = true,
    discovered = false,
    config = { extra = 2 },
    cost = 3,
    pos = { x = 4, y = 3 },

    can_use = alchemical_can_use,

    use = alchemical_use(function(self, used_card)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                ease_discard(used_card.ability.extra)
                ease_hands_played(used_card.ability.extra)
                for i = 1, #G.jokers.cards do
                    if not G.jokers.cards[i].debuff then
                        G.jokers.cards[i]:set_debuff(true)
                        G.jokers.cards[i]:juice_up()
                        break
                    end
                end
                return true
            end
        }))
    end),
}

SMODS.Consumable { -- Uranium
    set = "Alchemical",
    atlas = "arcanum_alchemical",
    key = "Uranium",
    loc_txt = {
        name = 'Uranium',
        text = {
            "Copy the selected card's",
            "{C:attention}enhancement{}, {C:attention}seal{}, and {C:attention}edition",
            "to {C:attention}#1#{} random unenhanced cards",
            "in hand for one blind"
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra } }
    end,
    unlocked = true,
    discovered = false,
    config = { extra = 3 },
    cost = 3,
    pos = { x = 5, y = 3 },

    can_use = function(self, card)
        if alchemical_can_use(self, card) then
            if #G.hand.highlighted == 1 then return true else return false end
        else
            return false
        end
    end,

    use = alchemical_use(function(self, used_card)
        G.deck.config.ra_uranium = G.deck.config.ra_uranium or {}
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                for i = 1, used_card.ability.extra do
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.5,
                        func = function()
                            local eligible_cards = {}
                            for _, v in ipairs(G.hand.cards) do
                                if v.config.center == G.P_CENTERS.c_base and not (v.edition) and not (v.seal) then
                                    table.insert(eligible_cards, v)
                                end
                            end

                            if #eligible_cards > 0 then
                                local conv_card = pseudorandom_element(eligible_cards, pseudoseed(used_card.ability.name))

                                conv_card:juice_up(1, 0.5)

                                if i == 1 then
                                    local copied_edition = G.hand.highlighted[1].edition
                                    if copied_edition then
                                        if copied_edition.holo then
                                            play_sound('holo1', 1.2 * 1.58, 0.4)
                                        elseif copied_edition.polychrome then
                                            play_sound('polychrome1', 1.2, 0.7)
                                        elseif copied_edition.negative then
                                            play_sound('negative', 1.5, 0.4)
                                        else
                                            play_sound('foil1', 1.2, 0.4)
                                        end
                                    else
                                        play_sound('tarot1')
                                    end
                                end

                                local prev_enhancement = check_alchemical_prev_enhancement(conv_card)
                                local prev_edition = check_alchemical_prev_edition(conv_card)
                                local prev_seal = conv_card:get_seal(true)
                                conv_card:set_ability(G.hand.highlighted[1].config.center)
                                conv_card:set_seal(G.hand.highlighted[1]:get_seal(true), true)
                                conv_card:set_edition(G.hand.highlighted[1].edition, true)

                                table.insert(G.deck.config.ra_uranium,
                                    {
                                        card_id = conv_card.unique_val,
                                        prev_enhancement = prev_enhancement,
                                        prev_edition =
                                            prev_edition,
                                        prev_seal = prev_seal
                                    })
                            end

                            return true
                        end
                    }))
                end
                return true
            end
        }))
    end),

    end_blind = function(self, card)
        if G.deck.config.ra_uranium then
            for _, uranium_card in ipairs(G.deck.config.ra_uranium) do
                for k, card in ipairs(G.playing_cards) do
                    if card.unique_val == uranium_card.card_id then
                        card:set_ability(uranium_card.prev_enhancement, nil, true)
                        card:set_edition(uranium_card.prev_edition, nil, true)
                        card:set_seal(uranium_card.prev_seal, true, nil)
                    end
                end
            end
            G.deck.config.ra_uranium = {}
        end
        return true
    end,
}
