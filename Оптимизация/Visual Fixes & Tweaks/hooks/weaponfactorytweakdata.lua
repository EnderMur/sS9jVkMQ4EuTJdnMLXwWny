Hooks:PostHook(WeaponFactoryTweakData, "init", "visualfixweaponfactorytweakdata", function(self)

	-- Adds back the unique Golden Bolt the Golden AK.762 used to have.

	self.parts.wpn_fps_ass_ak_body_lowerreceiver_gold.override = {
		wpn_fps_ak_bolt = {unit="units/mods/weapons/wpn_fps_ass_ak_gold_pts/wpn_fps_ak_bolt_gold"}
	}
	
	-- let's add back the irons on the northstar when we equip certain sights.
	
	self.wpn_fps_snp_victor.adds = {
		wpn_fps_upg_o_health = { "wpn_fps_snp_victor_o_down" },
		wpn_fps_upg_o_fc1 = { "wpn_fps_snp_victor_o_down" },
		wpn_fps_upg_o_northtac = { "wpn_fps_snp_victor_o_down" },
		wpn_fps_upg_o_schmidt = { "wpn_fps_snp_victor_o_down" }
	}
	
	-- Better orthogon parts. SHAMELESSLY copied from Tangerine's mod. Though you're a real G.
	
    self.parts.wpn_fps_m4_uupg_upper_radian.override = self.parts.wpn_fps_m4_uupg_upper_radian.override or {}
    self.parts.wpn_fps_m4_uupg_upper_radian.override.wpn_fps_amcar_bolt_standard = {
        unit = "units/pd2_mod_mxm/weapons/wpn_fps_upg_mxm_m4/wpn_fps_m4_uupg_bolt_radian",
        third_unit = "units/payday2/weapons/wpn_fps_smg_mp9_pts/wpn_fps_smg_mp9_b_dummy"
    }
	self.parts.wpn_fps_m4_uupg_upper_radian.visibility = {
		{
			objects = {
				g_reciever = false
			}
		}
	}

    self.parts.wpn_fps_uupg_fg_radian.override = self.parts.wpn_fps_uupg_fg_radian.override or {}
    self.parts.wpn_fps_uupg_fg_radian.override.wpn_fps_m4_uupg_o_flipup = {
        unit = "units/payday2/weapons/wpn_fps_ass_m4_pts/wpn_fps_m4_uupg_o_flipup_emo",
        third_unit = "units/payday2/weapons/wpn_third_ass_m4_pts/wpn_third_m4_uupg_o_flipup_emo"
    }
	self.parts.wpn_fps_uupg_fg_radian.override.wpn_fps_ass_m16_o_handle_sight = {
		third_unit = "units/pd2_dlc_savi/weapons/wpn_third_snp_victor_pts/wpn_third_snp_victor_o_hera",
		unit = "units/pd2_dlc_savi/weapons/wpn_fps_snp_victor_pts/wpn_fps_snp_victor_o_hera",
		stance_mod = {
			wpn_fps_ass_m16 = {
				translation = Vector3(0,-4,0.16)
			}
		}
	}

	-- AMCAR stuff

	self.parts.wpn_fps_m4_uupg_upper_radian.override.wpn_fps_amcar_uupg_body_upperreciever = {
		unit = "units/payday2/weapons/wpn_fps_ass_m16_pts/wpn_fps_ass_m16_o_handle_sight",
		third_unit = "units/payday2/weapons/wpn_third_ass_m16_pts/wpn_third_ass_m16_o_handle_sight",
		a_obj = "a_o"
	}	

	self.parts.wpn_fps_m4_uupg_upper_radian.override.wpn_fps_m4_upper_reciever_round_vanilla = {
		unit = "units/payday2/weapons/wpn_fps_smg_mp9_pts/wpn_fps_smg_mp9_b_dummy",
		third_unit = "units/payday2/weapons/wpn_fps_smg_mp9_pts/wpn_fps_smg_mp9_b_dummy"
	}	

	self.wpn_fps_ass_amcar.adds.wpn_fps_m4_uupg_upper_radian = {
		"wpn_fps_m4_uupg_draghandle",
		"wpn_fps_m4_uupg_fg_rail_ext"
	}

	-- AMCAR stuff ends

	self.parts.wpn_fps_uupg_fg_radian_gasblock = deep_clone(self.parts.wpn_fps_m4_uupg_fg_rail_ext)
	self.parts.wpn_fps_uupg_fg_radian_gasblock.unit = "units/pd2_dlc_chico/weapons/wpn_fps_ass_contraband_pts/wpn_fps_ass_contraband_b_standard"
	self.parts.wpn_fps_uupg_fg_radian_gasblock.third_unit = "units/pd2_dlc_chico/weapons/wpn_third_ass_contraband_pts/wpn_third_ass_contraband_b_standard"
	self.parts.wpn_fps_uupg_fg_radian_gasblock.visibility = {
		{
			objects = {
				g_barrel = false,
			}
		}
	}

	self.parts.wpn_fps_uupg_fg_radian.adds = { "wpn_fps_uupg_fg_radian_gasblock" }	

	if self.parts.wpn_fps_upg_m4_b_victor then
	
		self.parts.wpn_fps_upg_m4_b_victor.override = self.parts.wpn_fps_upg_m4_b_victor.override or {}
		self.parts.wpn_fps_upg_m4_b_victor.override.wpn_fps_uupg_fg_radian_gasblock = {
			unit = "units/payday2/weapons/wpn_fps_smg_mp9_pts/wpn_fps_smg_mp9_b_dummy",
			third_unit = "units/payday2/weapons/wpn_fps_smg_mp9_pts/wpn_fps_smg_mp9_b_dummy"
		}
		
	end

	if self.parts.wpn_fps_upg_m4_b_victor_short then

		self.parts.wpn_fps_upg_m4_b_victor_short.override = self.parts.wpn_fps_upg_m4_b_victor_short.override or {}
		self.parts.wpn_fps_upg_m4_b_victor_short.override.wpn_fps_uupg_fg_radian_gasblock = {
			unit = "units/payday2/weapons/wpn_fps_smg_mp9_pts/wpn_fps_smg_mp9_b_dummy",
			third_unit = "units/payday2/weapons/wpn_fps_smg_mp9_pts/wpn_fps_smg_mp9_b_dummy"
		}
	
	end

	if self.parts.wpn_fps_upg_victor_b_fluted then

		self.parts.wpn_fps_upg_victor_b_fluted.override = self.parts.wpn_fps_upg_victor_b_fluted.override or {}
		self.parts.wpn_fps_upg_victor_b_fluted.override.wpn_fps_uupg_fg_radian_gasblock = {
			unit = "units/payday2/weapons/wpn_fps_smg_mp9_pts/wpn_fps_smg_mp9_b_dummy",
			third_unit = "units/payday2/weapons/wpn_fps_smg_mp9_pts/wpn_fps_smg_mp9_b_dummy"
		}

	end

	-- Fixes some issues with some sights and gadgets not having rails when applying them to the R700 in-game.
	
	self.parts.wpn_fps_upg_o_poe.forbids = {}
	self.wpn_fps_snp_r700.adds.wpn_fps_upg_o_poe = { "wpn_fps_snp_r700_o_rail" }
	
	-- Fixes the new tatinka stock removing gadget rails for some reason.(SBZ might've used a foregrip as a base?)
	
	table.delete(self.parts.wpn_fps_upg_ak_s_zenitco.forbids, "wpn_fps_addon_ris")
	
	-- KSP 58 has an tiny issue where it never accurately displays the correct amount of bullets when almost empty, this should fix this
	
	self.parts.wpn_fps_lmg_par_m_standard.bullet_objects = {
		amount = 5,
		prefix = "g_bullet_"
		
	}
	
	
	-- A fix for the cavity where the rear sight never lowers if you have a sight equipped
	
	self.wpn_fps_ass_sub2000.override.wpn_fps_ass_sub2000_b_std = self.wpn_fps_ass_sub2000.override.wpn_fps_ass_sub2000_b_std or {}
	self.wpn_fps_ass_sub2000.override.wpn_fps_ass_sub2000_b_std.adds = { "wpn_fps_ass_sub2000_o_back" }

	for i, part_id in pairs(self.wpn_fps_ass_sub2000.uses_parts) do
		if self.parts[part_id] and self.parts[part_id].type == "sight" and part_id ~= "wpn_fps_ass_sub2000_o_back" then
			self.parts[part_id].forbids = self.parts[part_id].forbids or {}
			table.insert(self.parts[part_id].forbids, "wpn_fps_ass_sub2000_o_back")
		end
	end

	self.wpn_fps_ass_sub2000.override.wpn_fps_ass_sub2000_o_adapter = self.wpn_fps_ass_sub2000.override.wpn_fps_ass_sub2000_o_adapter or {}
	self.wpn_fps_ass_sub2000.override.wpn_fps_ass_sub2000_o_adapter.adds = { "wpn_fps_ass_sub2000_o_back_down" }


	-- self.parts.wpn_fps_lmg_hcar_m_ck.third_unit = "units/pd2_dlc_pxp3/weapons/wpn_fps_lmg_hcar_pts/wpn_third_lmg_hcar_m_ck"

	
	-- McShay CAR mods refer to base parts (All of the CAR parts of this DLC do not have wpn_third parts at all, so a dirty fix is to make them refer to vanilla modparts as a workaround.)
	
	self.parts.wpn_fps_m4_uupg_upper_radian.third_unit = "units/payday2/weapons/wpn_third_ass_m4_pts/wpn_third_m4_upper_reciever_round"
	self.parts.wpn_fps_m4_uupg_lower_radian.third_unit = "units/payday2/weapons/wpn_third_ass_m4_pts/wpn_third_m4_lower_reciever"
	self.parts.wpn_fps_uupg_fg_radian.third_unit = "units/payday2/weapons/wpn_third_ass_m16_pts/wpn_third_m16_fg_railed"
	self.parts.wpn_fps_m4_uupg_g_billet.third_unit = "units/payday2/weapons/wpn_third_upg_m4_reusable/wpn_third_upg_m4_g_standard"
	self.parts.wpn_fps_m4_uupg_m_strike.third_unit = "units/payday2/weapons/wpn_third_ass_m4_pts/wpn_third_m4_uupg_m_std"
	
	-- Additional fix for the North Star's Tiwaz Silencer missing a wpn_third part. If you know the filepath for a suppressor model replace it with anything you want by the way.
	
	self.parts.wpn_fps_snp_victor_ns_omega.third_unit = "units/payday2/weapons/wpn_third_upg_ns_ass_smg_medium/wpn_third_upg_ns_ass_smg_medium"
	
	-- All this does is stop the upper orthogon reciever refer to the contractor 308's foregirp in third person. I don't fucking know why they did this.
	
	if self.parts.wpn_fps_m4_uupg_upper_radian.override and self.parts.wpn_fps_m4_uupg_upper_radian.override.wpn_fps_m4_uupg_draghandle then
    self.parts.wpn_fps_m4_uupg_upper_radian.override.wpn_fps_m4_uupg_draghandle.third_unit = nil
	end
	
	-- Same with the MG42 (Buzzsaw LMG)
	
	self.parts.wpn_fps_lmg_mg42_reciever.bullet_objects = {
		amount = 5,
		prefix = "g_bullet_"
	}		
	
	
end)

-- Some minor weapon visual tweaks
-- Code from Tangerine Paint, Hinaomi and Hoppip.