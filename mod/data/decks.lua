-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--            DECKS
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-

SMODS.Back {
    key = 'herbalist',
    loc_txt =
    {
        name = "Herbalist's Deck",
        text = {
            "Start run with the",
            "{C:tarot,T:v_ReduxArcanum_mortar_and_pestle}Mortar and Pestle{} voucher,",
            "Gain an {C:alchemical}Alchemical{} card before",
            "each boss blind"
        },
        unlock = {
            'Win a run with the',
            '{C:attention}Redux Arcanum{} mod',
            'enabled'
        },
    },

    config = { vouchers = { 'v_ReduxArcanum_mortar_and_pestle' } },

    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'win_stake' then
            unlock_card(self)
        end
    end,

    apply = function(self)
    end,
    trigger_effect = function(self, context)
        if context.setting_blind and context.blind.boss and ((#G.consumeables.cards + G.GAME.consumeable_buffer) < G.consumeables.config.card_limit) then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('timpani')
                    local card = create_alchemical(G.deck)
                    card:add_to_deck()
                    G.consumeables:emplace(card)
                    G.GAME.consumeable_buffer = 0
                    return true
                end
            }))
        end
        -- sendDebugMessage(tprint(G.GAME.last_blind), "ReduxArcanumDebugLogger")
    end,

    pos = { x = 1, y = 0 },
    atlas = 'arcanum_decks'
}

SMODS.Back {
    key = 'philosopher',
    loc_txt = {
        name = "Philosopher's Deck",
        text = {
            "Start run with the",
            "{C:tarot,T:v_ReduxArcanum_alchemical_merchant}Alchemical Merchant{} voucher",
            "and a copy of {C:tarot,T:c_ReduxArcanum_seeker}The Seeker{}"
        },
        unlock = {
            'Discover every',
            '{E:1,C:spectral}Spectral{} card'
        },
    },

    config = { vouchers = { 'v_ReduxArcanum_alchemical_merchant' }, consumables = { 'c_ReduxArcanum_seeker' } },

    unlocked = false,
    check_for_unlock = function(self, args)
        if args.type == 'discover_amount' and G.DISCOVER_TALLIES.spectrals.tally / G.DISCOVER_TALLIES.spectrals.of >= 1 then -- self.unlock_condition.extra then
            unlock_card(self)
        end
    end,


    pos = { x = 0, y = 0 },
    atlas = 'arcanum_decks'
}

-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--         CARD SLEEVES
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
-- https://github.com/larswijn/CardSleeves

if (SMODS.Mods["CardSleeves"] and SMODS.Mods["CardSleeves"].can_load) and CardSleeves then
    SMODS.Atlas({ key = 'arcanum_sleeves', path = 'ra_sleeves_atlas.png', px = 73, py = 95 })

    CardSleeves.Sleeve {
        key = "herbalist",
        -- loc text in localization/default.lua
        atlas = "arcanum_sleeves",
        pos = { x = 1, y = 0 },
        -- config = { vouchers = { "v_ReduxArcanum_mortar_and_pestle" } },
        unlocked = false,
        unlock_condition = { deck = "b_ReduxArcanum_herbalist", stake = 2 },

        loc_vars = function(self)
            local key
            if self.get_current_deck_key() ~= "b_ReduxArcanum_herbalist" then
                sendDebugMessage("Setting mortar and pestle", "ReduxArcanumDebugLogger")
                key = self.key
                self.config = { vouchers = { "v_ReduxArcanum_mortar_and_pestle" } }
            else
                sendDebugMessage("Setting cauldron", "ReduxArcanumDebugLogger")
                key = self.key .. "_alt"
                self.config = { vouchers = { "v_ReduxArcanum_cauldron" } }
            end
            return { key = key, vars = {} }
        end,

        apply = function(self, args)
            if self.get_current_deck_key() ~= "b_ReduxArcanum_herbalist" then
                self.config = { vouchers = { "v_ReduxArcanum_mortar_and_pestle" } }
            else
                self.config = { vouchers = { "v_ReduxArcanum_cauldron" } }
            end
            CardSleeves.Sleeve.apply(self)
        end,
        trigger_effect = SMODS.Back.obj_table["b_ReduxArcanum_herbalist"].trigger_effect,
    }
    CardSleeves.Sleeve {
        key = "philosopher",
        -- loc text in localization/default.lua
        atlas = "arcanum_sleeves",
        pos = { x = 0, y = 0 },
        -- config = { vouchers = { "v_ReduxArcanum_alchemical_merchant" }, alchemical_more_options = 0 },
        unlocked = false,
        unlock_condition = { deck = "b_ReduxArcanum_philosopher", stake = 2 },

        loc_vars = function(self)
            local key
            local vars = {}
            if self.get_current_deck_key() ~= "b_ReduxArcanum_philosopher" then
                sendDebugMessage("Setting merchant voucher", "ReduxArcanumDebugLogger")
                self.config = { vouchers = { "v_ReduxArcanum_alchemical_merchant" }, alchemical_more_options = 0 }
            else
                sendDebugMessage("Setting tycoon voucher", "ReduxArcanumDebugLogger")
                key = self.key .. "_alt"
                self.config = { vouchers = { "v_ReduxArcanum_alchemical_tycoon" }, alchemical_more_options = 2 }
                vars[#vars + 1] = self.config.alchemical_more_options
            end
            return { key = key, vars = vars }
        end,

        apply = function(self, args)
            if self.get_current_deck_key() ~= "b_ReduxArcanum_philosopher" then
                self.config = { vouchers = { "v_ReduxArcanum_alchemical_merchant" }, alchemical_more_options = 0 }
            else
                self.config = { vouchers = { "v_ReduxArcanum_alchemical_tycoon" }, alchemical_more_options = 2 }
            end
            CardSleeves.Sleeve.apply(self)
        end,

        trigger_effect = function(self, args)
            if args.context.create_card and args.context.card then
                local card = args.context.card
                local is_booster_pack = card.ability.set == "Booster"
                local is_alchemical_pack = is_booster_pack and card.ability.name:find("Alchemical")
                if is_alchemical_pack and self.config.alchemical_more_options then
                    card.ability.extra = card.ability.extra + self.config.alchemical_more_options
                end
            end
        end,
    }
end
