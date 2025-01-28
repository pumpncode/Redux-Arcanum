-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--            JOKERS
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-

studious_joker = { -- Studious Joker
    key = "studious_joker",
    -- loc_txt = {
    --     name = "Studious Joker",
    --     text = {
    --         "{C:mult}+#1#{} Mult. Sell this",
    --         "joker to get one",
    --         "{C:alchemical} Alchemical{} card"
    --     }
    -- },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.mult } }
    end,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = false,
    rarity = 1,
    cost = 5,
    effect = "",
    config = {
        mult = 4
    },
    atlas = "arcanum_joker_atlas",
    pos = { x = 0, y = 0 },

    calculate = function(self, card, context)
        if context.selling_self then -- and not context.blueprint then
            add_random_alchemical(card)
            card_eval_status_text(card, 'extra', nil, nil, nil,
                { message = localize('p_plus_alchemical'), colour = G.C.SECONDARY_SET.Alchemy })
            return {
                card = card
            }
        end

        if context.joker_main then
            return {
                message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.mult } },
                mult_mod = card.ability.mult
            }
        end
    end
}
if ReduxArcanumMod.config.new_content then
    studious_joker.config.mult = 3
end
SMODS.Joker(studious_joker)

SMODS.Joker { -- Bottled Buffoon
    key = "bottled_buffoon",
    -- loc_txt = {
    --     name = "Bottled Buffoon",
    --     text = {
    --         "Create an {C:alchemical}Alchemical{} card",
    --         "every {C:attention}#1#{} hands played",
    --         "{C:inactive}#2#"
    --     }
    -- },
    loc_vars = function(self, info_queue, center)
        local loyalty
        if center.ability.loyalty_remaining == 0 then
            loyalty = 'loyalty_active'
        else
            loyalty = 'loyalty_inactive'
            if not center.ability.loyalty_remaining then
                center.ability.loyalty_remaining = 3
            end
        end
        return { vars = { center.ability.extra.every + 1, localize { type = 'variable', key = loyalty, vars = { center.ability.loyalty_remaining } } } }
    end,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
    rarity = 1,
    cost = 5,
    effect = "",
    config = {
        extra = {
            every = 3
        }
    },
    atlas = "arcanum_joker_atlas",
    pos = { x = 1, y = 0 },

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.after then
            card.ability.loyalty_remaining = (card.ability.extra.every - 1 - (G.GAME.hands_played - card.ability.hands_played_at_create)) %
                (card.ability.extra.every + 1)
            if context.blueprint then
                if card.ability.loyalty_remaining == card.ability.extra.every then
                    add_random_alchemical(card)
                    card.ability.loyalty_remaining = card.ability.extra.every
                    return {
                        message = localize('p_plus_alchemical')
                    }
                end
            else
                if card.ability.loyalty_remaining == 0 then
                    local eval = function(_card) return (_card.ability.loyalty_remaining == 0) end
                    juice_card_until(card, eval, true)
                elseif card.ability.loyalty_remaining == card.ability.extra.every then
                    add_random_alchemical(card)
                    card.ability.loyalty_remaining = card.ability.extra.every
                    return {
                        message = localize('p_plus_alchemical')
                    }
                end
            end
        end
    end
}

SMODS.Joker { -- Mutated Joker
    key = "mutated_joker",
    -- loc_txt = {
    --     name = "Mutated Joker",
    --     text = {
    --         "{C:chips}+#1#{} Chips for each",
    --         "unique {C:alchemical}Alchemical{} card",
    --         "used this run",
    --         "{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips)"
    --     }
    -- },
    loc_vars = function(self, info_queue, center)
        local alchemical_tally = 1
        for k, v in pairs(G.GAME.consumeable_usage) do
            if v.set == 'Alchemical' then alchemical_tally = alchemical_tally + 1 end
        end

        local expected_total_chips = alchemical_tally * center.ability.extra.chips

        return { vars = { center.ability.extra.chips, expected_total_chips } }
    end,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
    rarity = 1,
    cost = 5,
    effect = "",
    config = {
        extra = {
            chips = 10,
            total_chips = 10
        }
    },
    atlas = "arcanum_joker_atlas",
    pos = { x = 1, y = 2 },

    add_to_deck = function(self, card, context)
        local alchemical_tally = 1
        for k, v in pairs(G.GAME.consumeable_usage) do
            if v.set == 'Alchemical' then alchemical_tally = alchemical_tally + 1 end
        end

        local expected_total_chips = alchemical_tally * card.ability.extra.chips

        card.ability.extra.total_chips = expected_total_chips
    end,

    calculate = function(self, card, context)
        if context.using_consumeable and context.consumeable.ability.set == 'Alchemical' and not context.blueprint then
            local alchemical_tally = 1
            for k, v in pairs(G.GAME.consumeable_usage) do
                if v.set == 'Alchemical' then alchemical_tally = alchemical_tally + 1 end
            end

            local expected_total_chips = alchemical_tally * card.ability.extra.chips

            if card.ability.extra.total_chips ~= expected_total_chips then
                card.ability.extra.total_chips = expected_total_chips

                G.E_MANAGER:add_event(Event({
                    func = function()
                        card_eval_status_text(card, 'extra', nil, nil, nil,
                            { message = localize { type = 'variable', key = 'a_chips', vars = { expected_total_chips } } }); return true
                    end
                }))
            end
            return
        end

        if context.joker_main then
            local alchemical_tally = 1
            for k, v in pairs(G.GAME.consumeable_usage) do
                if v.set == 'Alchemical' then alchemical_tally = alchemical_tally + 1 end
            end

            local expected_total_chips = alchemical_tally * card.ability.extra.chips

            return {
                message = localize { type = 'variable', key = 'a_chips', vars = { expected_total_chips } },
                chip_mod = expected_total_chips
            }
        end
    end
}

SMODS.Joker { -- Essence of Comedy
    key = "essence_of_comedy",
    -- loc_txt = {
    --     name = "Essence of Comedy",
    --     text = {
    --         "Gains {X:mult,C:white} X#1# {} Mult",
    --         "per {C:alchemical}Alchemical{} card used",
    --         "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)"
    --     }
    -- },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra, center.ability.x_mult } }
    end,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
    rarity = 2,
    cost = 6,
    effect = "",
    config = {
        extra = 0.1,
        Xmult = 1.0
    },
    atlas = "arcanum_joker_atlas",
    pos = { x = 0, y = 1 },

    calculate = function(self, card, context)
        if context.using_consumeable and context.consumeable.ability.set == 'Alchemical' and not context.blueprint then
            card.ability.x_mult = card.ability.x_mult + card.ability.extra
            G.E_MANAGER:add_event(Event({
                func = function()
                    card_eval_status_text(card, 'extra', nil, nil, nil,
                        { message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.x_mult } } }); return true
                end
            }))
            return
        end
    end
}

SMODS.Joker { -- Shock Humor
    key = "shock_humor",
    -- loc_txt = {
    --     name = "Shock Humor",
    --     text = {
    --         "{C:green}#1# in #2#{} chance to",
    --         "create an {C:alchemical}Alchemical{} card",
    --         "when you discard a {C:attention}Gold{},",
    --         "{C:attention}Steel{} or {C:attention}Stone{} card"
    --     }
    -- },
    loc_vars = function(self, info_queue, center)
        local first_var
        if G.GAME and G.GAME.probabilities.normal then
            first_var = G.GAME.probabilities.normal
        else
            first_var = 1
        end
        return { vars = { '' .. (first_var), center.ability.extra.odds } }
    end,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
    rarity = 2,
    cost = 5,
    effect = "",
    config = {
        extra = { odds = 5 }
    },
    atlas = "arcanum_joker_atlas",
    pos = { x = 1, y = 1 },

    calculate = function(self, card, context)
        if context.discard and not context.other_card.debuff then
            if context.other_card.config.center == G.P_CENTERS.m_steel or context.other_card.config.center == G.P_CENTERS.m_gold or
                context.other_card.config.center == G.P_CENTERS.m_stone then
                if pseudorandom('shock_humor') < G.GAME.probabilities.normal / card.ability.extra.odds then
                    add_random_alchemical(card)
                    card_eval_status_text(card, 'extra', nil, nil, nil,
                        { message = localize('p_plus_alchemical'), colour = G.C.SECONDARY_SET.Alchemy })
                end
            end
        end
    end
}

SMODS.Joker { -- Breaking Bozo
    key = "breaking_bozo",
    -- loc_txt = {
    --     name = "Breaking Bozo",
    --     text = {
    --         "After you use an {C:alchemical}Alchemical{}",
    --         "card, do one at random: ",
    --         "- Reduce blind by {C:attention}10%{}",
    --         "- Draw {C:attention}2{} cards",
    --         "- Earn {C:attention}$5{}"
    --     },
    --     unlock = {
    --         "Use {C:attention}#1#",
    --         "{E:1,C:alchemical}Alchemical{} cards in",
    --         "the same run"
    --     }
    -- },
    locked_loc_vars = function(self, info_queue)
        return { vars = { self.unlock_condition.extra } }
    end,

    unlocked = false,
    unlock_condition = { extra = 5 },

    discovered = false,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = true,
    rarity = 2,
    cost = 7,
    effect = "",
    config = {},
    atlas = "arcanum_joker_atlas",
    pos = { x = 2, y = 1 },

    check_for_unlock = function(self, args)
        if args.type == 'used_alchemical' then
            local alchemicals_count = 0
            for k, v in pairs(G.GAME.consumeable_usage) do
                if v.set == 'Alchemical' then alchemicals_count = alchemicals_count + 1 end
            end
            if alchemicals_count >= self.unlock_condition.extra then -- self.unlock_condition.extra then
                unlock_card(self)
            end
        end
    end,

    calculate = function(self, card, context)
        if context.using_consumeable and context.consumeable.ability.set == 'Alchemical' then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    local choice = math.random(1, 3)
                    if choice == 1 then
                        G.FUNCS.draw_from_deck_to_hand(2)
                        card_eval_status_text(card, 'extra', nil, nil, nil,
                            { message = localize('p_alchemy_plus_card'), colour = G.C.SECONDARY_SET.Alchemy })
                    elseif choice == 2 then
                        ease_dollars(5, true)
                        card_eval_status_text(card, 'extra', nil, nil, nil,
                            { message = localize('p_alchemy_plus_money'), colour = G.C.SECONDARY_SET.Alchemy })
                    else
                        G.GAME.blind.chips = math.floor(G.GAME.blind.chips * 0.90)
                        G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)

                        local chips_UI = G.hand_text_area.blind_chips
                        G.FUNCS.blind_chip_UI_scale(G.hand_text_area.blind_chips)
                        G.HUD_blind:recalculate()
                        chips_UI:juice_up()

                        if not silent then play_sound('chips2') end
                        card_eval_status_text(card, 'extra', nil, nil, nil,
                            { message = localize('p_alchemy_reduce_blind'), colour = G.C.SECONDARY_SET.Alchemy })
                    end
                    return true
                end
            }))
        end
    end
}

-- This joker overlaps with Doodle in Bunco, so leave it out if Bunco is present
if (not SMODS.Mods["Bunco"] or not SMODS.Mods["Bunco"].can_load) or
    ReduxArcanumMod.config.overlapping_cards ~= 1 then
    chain_reaction = { -- Chain Reaction
        key = "chain_reaction",
        -- loc_txt = {
        --     name = "Chain Reaction",
        --     text = {
        --         "Create a {C:dark_edition}Negative{} {C:attention}Copy{}",
        --         "of the first {C:alchemical}Alchemical{} ",
        --         "card used each blind"
        --     },
        --     unlock = {
        --         "Discover every",
        --         "{E:1,C:alchemical}Alchemical{} card"
        --     }
        -- },
        loc_vars = function(self, info_queue)
            if not ReduxArcanumMod.config.new_content then
                return { key = self.key .. "_classic"}
            end
        end,

        unlocked = false,
        discovered = false,
        blueprint_compat = true,
        perishable_compat = true,
        eternal_compat = true,
        rarity = 2,
        cost = 5,
        effect = "",
        config = {
            extra = {
                used = false
            }
        },
        atlas = "arcanum_joker_atlas",
        pos = { x = 2, y = 0 },

        check_for_unlock = function(self, args)
            if args.type == 'discover_amount' then
                if G.DISCOVER_TALLIES.alchemicals.tally / G.DISCOVER_TALLIES.alchemicals.of >= 1 then -- self.unlock_condition.extra then
                    unlock_card(self)
                end
            end
        end,

        calculate = function(self, card, context)
            -- if not card.ability.extra.used then
            --     card.ability.extra.used = false
            -- end

            if context.using_consumeable and context.consumeable.ability.set == 'Alchemical' then
                if not card.ability.extra.used then
                    if (not ReduxArcanumMod.config.new_content) or (#G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit) then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local _card = copy_card(context.consumeable, nil, nil, nil)
                                if not ReduxArcanumMod.config.new_content then
                                    _card:set_edition({ negative = true }, true)
                                end
                                _card:set_ability(context.consumeable.config.center) -- To handle polychrome
                                _card:add_to_deck()
                                G.consumeables:emplace(_card)
                                G.GAME.consumeable_buffer = 0
                                return true
                            end
                        }))
                        card_eval_status_text(card, 'extra', nil, nil, nil,
                            { message = localize("k_copied_ex"), colour = G.C.SECONDARY_SET.Alchemy })
                    end
                    if not context.blueprint then
                        card.ability.extra.used = true
                    end
                    return
                end
            end

            -- if context.first_hand_drawn then
            --     if card.ability.extra.used then
            --         card.ability.extra.used = false
            --         local eval = function() return not card.ability.extra.used end
            --         juice_card_until(card, eval, true)
            --     end
            -- end

            if context.first_hand_drawn then
                card.ability.extra.used = false
                local eval = function() return not card.ability.extra.used end
                juice_card_until(card, eval, true)
            end

            if context.end_of_round then
                card.ability.extra.used = true
            end
        end
    }
    if ReduxArcanumMod.config.new_content then
        -- chain_reaction.loc_txt.text = {
        --     "Create a {C:attention}Copy{} of",
        --     "the first {C:alchemical}Alchemical{} card",
        --     "used each blind",
        --     "{C:inactive}(Must have room){}"
        -- }
        chain_reaction.rarity = 3
    end
    SMODS.Joker(chain_reaction)
end

SMODS.Joker { -- Catalyst Joker
    key = "catalyst_joker",
    -- loc_txt = {
    --     name = "Catalyst Joker",
    --     text = {
    --         "{C:attention}+1{} consumable slots.",
    --         "Gains {X:mult,C:white} X#1# {} Mult for",
    --         "every {C:attention}Consumable Card{} held",
    --         "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)"
    --     },
    --     unlock = {
    --         "Hold #1# {E:1,C:attention}Consumable{}",
    --         "{E:1,C:attention}Cards{} at once"
    --     }
    -- },
    loc_vars = function(self, info_queue, center)
        local current_value = 1
        -- Check to prevent doing calculations on nill variables
        if G.consumeables then
            current_value = center.ability.extra.slots + center.ability.extra.bonus * (#G.consumeables.cards or 0)
        end
        return { vars = { center.ability.extra.bonus, current_value } }
    end,
    locked_loc_vars = function(self, info_queue)
        return { vars = { self.unlock_condition.extra } }
    end,
    unlocked = false,
    unlock_condition = { extra = 4 },

    discovered = false,
    blueprint_compat = true,
    perishable_compat = true,
    eternal_compat = false,
    rarity = 3,
    cost = 5,
    effect = "",
    config = {
        extra = {
            slots = 1,
            bonus = 0.5
        }
    },
    atlas = "arcanum_joker_atlas",
    pos = { x = 0, y = 2 },

    check_for_unlock = function(self, args)
        if args.type == "ReduxArcanum_modify_cards" and G.consumeables then
            if (#G.consumeables.cards or 0) >= self.unlock_condition.extra then
                unlock_card(self)
            end
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        G.consumeables.config.card_limit = G.consumeables.config.card_limit + 1
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.consumeables.config.card_limit = G.consumeables.config.card_limit - 1
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                message = localize { type = 'variable', key = 'a_xmult', vars = { 1 + card.ability.extra.bonus * (#G.consumeables.cards or 0) } },
                Xmult_mod = 1 + card.ability.extra.bonus * (#G.consumeables.cards or 0),
                colour = G.C.MULT
            }
        end
    end
}

-- -- Changed Vanilla Jokers

-- SMODS.Joker:take_ownership('ring_master', { -- Showman
--     loc_txt = {
--         name = "Showman",
--         text = {
--             "{C:attention}Joker{} and {C:attention}consumable{} cards",
--             "may appear multiple times",
--         },
--         unlock = {
--             "Reach Ante",
--             "level {E:1,C:attention}#1#",
--         },
--     }
-- })


-- Mod Compat

-- Bunco

if SMODS.Mods["Bunco"] and SMODS.Mods["Bunco"].can_load and
    ReduxArcanumMod.config.overlapping_cards == 2 then
    SMODS.Joker:take_ownership('bunc_doodle', {})
end
