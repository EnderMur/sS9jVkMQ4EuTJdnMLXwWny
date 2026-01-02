Hooks:PostHook(EconomyTweakData, "_init_armor_skins_armor_safe", "armorskinfixTHANKSHOPPIP", function(self)

    self.armor_skins.tam.sticker = {
        [2] = Idstring("units/pd2_dlc_tam/base_gradient/tam_basegradient_001_armor_df"),
        [3] = Idstring("units/pd2_dlc_tam/sticker/tam_sticker_003_armor_df")
    }

end)

-- Fixes an issue with the sticker appearing on the Ballistc Vest in-game if you have the immortal python armour skin equipped. Zero clue how no-one at Starbreeze thought it was ok.
-- Code from Hoppip.