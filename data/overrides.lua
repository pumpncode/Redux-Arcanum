local alias__G_UIDEF_use_and_sell_buttons = G.UIDEF.use_and_sell_buttons;
function G.UIDEF.use_and_sell_buttons(card)
    if (card.ability.set == "Alchemical" or card.ability.name == "c_ReduxArcanum_philosopher_stone") and (G.STATE == G.STATES.SMODS_BOOSTER_OPENED or G.STATE == G.STATES.SPECTRAL_PACK) and (card.area == G.pack_cards and G.pack_cards) then
        return {
            n = G.UIT.ROOT,
            config = { padding = 0, colour = G.C.CLEAR },
            nodes = {
                { n = G.UIT.R, config = { mid = true }, nodes = {} },
                {
                    n = G.UIT.R,
                    config = { ref_table = card, r = 0.08, padding = 0.1, align = "bm", minw = 0.5 * card.T.w - 0.15, minh = 0.8 * card.T.h, maxw = 0.7 * card.T.w - 0.15, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'select_alchemical', func = 'can_select_alchemical' },
                    nodes = {
                        { n = G.UIT.T, config = { text = localize("b_select"), colour = G.C.UI.TEXT_LIGHT, scale = 0.55, shadow = true } }
                    }
                },
            }
        }
    end

    local ret = alias__G_UIDEF_use_and_sell_buttons(card)
    return ret
end

G.FUNCS.can_select_alchemical = function(e)
    if (e.config.ref_table.edition and e.config.ref_table.edition.negative) or #G.consumeables.cards < G.consumeables.config.card_limit then
        e.config.colour = G.C.GREEN
        e.config.button = 'select_alchemical'
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end

G.FUNCS.select_alchemical = function(e, mute, nosave)
    e.config.button = nil
    local card = e.config.ref_table
    local area = card.area
    local prev_state = G.STATE
    local dont_dissolve = nil
    local delay_fac = 1

    -- G.TAROT_INTERRUPT = G.STATE
    if card.ability.set == 'Booster' then G.GAME.PACK_INTERRUPT = G.STATE end

    G.CONTROLLER.locks.use = true
    if G.booster_pack and not G.booster_pack.alignment.offset.py and (G.GAME.pack_choices and G.GAME.pack_choices < 2) then
        inc_career_stat('c_ReduxArcanum_alchemy_pack_used', 1)
        check_for_unlock({type = 'career_stat', statname = 'c_ReduxArcanum_alchemy_pack_used'})
        G.booster_pack.alignment.offset.py = G.booster_pack.alignment.offset.y
        G.booster_pack.alignment.offset.y = G.ROOM.T.y + 29
    end
    if G.shop and not G.shop.alignment.offset.py then
        inc_career_stat('c_ReduxArcanum_alchemicals_bought', 1)
        check_for_unlock({type = 'career_stat', statname = 'c_ReduxArcanum_alchemicals_bought'})
        G.shop.alignment.offset.py = G.shop.alignment.offset.y
        G.shop.alignment.offset.y = G.ROOM.T.y + 29
    end
    if G.blind_select and not G.blind_select.alignment.offset.py then
        G.blind_select.alignment.offset.py = G.blind_select.alignment.offset.y
        G.blind_select.alignment.offset.y = G.ROOM.T.y + 39
    end
    if G.round_eval and not G.round_eval.alignment.offset.py then
        G.round_eval.alignment.offset.py = G.round_eval.alignment.offset.y
        G.round_eval.alignment.offset.y = G.ROOM.T.y + 29
    end

    if card.children.use_button then
        card.children.use_button:remove(); card.children.use_button = nil
    end
    if card.children.sell_button then
        card.children.sell_button:remove(); card.children.sell_button = nil
    end
    if card.children.price then
        card.children.price:remove(); card.children.price = nil
    end

    if card.area then card.area:remove_card(card) end

    if (card.ability.set == "Alchemical" or card.ability.name == "c_ReduxArcanum_philosopher_stone") then
        card:add_to_deck()
        G.consumeables:emplace(card)
        play_sound('card1', 0.8, 0.6)
        play_sound('generic1')
        dont_dissolve = true
        delay_fac = 0.2
    end
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.2,
        func = function()
            if not dont_dissolve then card:start_dissolve() end
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.STATE = prev_state
                    -- G.TAROT_INTERRUPT = nil
                    G.CONTROLLER.locks.use = false

                    if (prev_state == G.STATES.SMODS_BOOSTER_OPENED) and G.booster_pack then
                        if area == G.consumeables then
                            G.booster_pack.alignment.offset.y = G.booster_pack.alignment.offset.py
                            G.booster_pack.alignment.offset.py = nil
                        elseif G.GAME.pack_choices and G.GAME.pack_choices > 1 then
                            if G.booster_pack.alignment.offset.py then
                                G.booster_pack.alignment.offset.y = G.booster_pack.alignment.offset.py
                                G.booster_pack.alignment.offset.py = nil
                            end
                            G.GAME.pack_choices = G.GAME.pack_choices - 1
                            inc_career_stat('c_ReduxArcanum_alchemy_pack_used', 1)
                            check_for_unlock({type = 'career_stat', statname = 'c_ReduxArcanum_alchemy_pack_used'})
                        else
                            G.CONTROLLER.interrupt.focus = true

                            G.FUNCS.end_consumeable(nil, delay_fac) -- Will reset G.GAME.PACK_INTERRUPT
                        end
                    else
                        if G.shop then
                            check_for_unlock({type = 'career_stat', statname = 'c_ReduxArcanum_alchemicals_bought'})
                            G.shop.alignment.offset.y = G.shop.alignment.offset.py
                            G.shop.alignment.offset.py = nil
                        end
                        if G.blind_select then
                            G.blind_select.alignment.offset.y = G.blind_select.alignment.offset.py
                            G.blind_select.alignment.offset.py = nil
                        end
                        if G.round_eval then
                            G.round_eval.alignment.offset.y = G.round_eval.alignment.offset.py
                            G.round_eval.alignment.offset.py = nil
                        end
                        if area and area.cards[1] then
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    G.E_MANAGER:add_event(Event({
                                        func = function()
                                            G.CONTROLLER.interrupt.focus = nil
                                            if card.ability.set == 'Voucher' then
                                                G.CONTROLLER:snap_to({ node = G.shop:get_UIE_by_ID('next_round_button') })
                                            elseif area then
                                                G.CONTROLLER:recall_cardarea_focus(area)
                                            end
                                            return true
                                        end
                                    }))
                                    return true
                                end
                            }))
                        end
                    end
                    return true
                end
            }))
            return true
        end
    }))
end