local _setup_color_skin_weapons = WeaponColorTemplates._setup_color_skin_weapons
function WeaponColorTemplates._setup_color_skin_weapons(tweak_data, ...)
  local weapons = _setup_color_skin_weapons(tweak_data, ...)

	weapons.type54.parts = {
		wpn_fps_pis_type54_body = {
			[Idstring("mtr_frame"):key()] = {
				pattern_tweak = Vector3(0.888888, 0, 1)
			},
			[Idstring("mtr_grip"):key()] = {
				pattern_tweak = Vector3(0.888888, 0, 1)
			}
		},
		wpn_fps_pis_type54_body_akimbo = {
			[Idstring("mtr_frame"):key()] = {
				pattern_tweak = Vector3(0.888888, 0, 1)
			},
			[Idstring("mtr_grip"):key()] = {
				pattern_tweak = Vector3(0.888888, 0, 1)
			}
		},
		wpn_fps_pis_type54_underbarrel = {
			[Idstring("mtr_shotty"):key()] = {
				pattern_tweak = Vector3(0.888888, 0, 1)
			}
		},
		wpn_fps_pis_type54_m_standard = {
			[Idstring("mtr_m_std"):key()] = {
				pattern_tweak = Vector3(0.888888, 0, 1)
			}
		},
		wpn_fps_pis_type54_m_ext = {
			[Idstring("mtr_m_ext"):key()] = {
				pattern_tweak = Vector3(0.888888, 0, 1)
			},
			[Idstring("mtr_m_std"):key()] = {
				pattern_tweak = Vector3(0.888888, 0, 1)
			}
		},
		wpn_fps_pis_type54_b_standard = {
			[Idstring("mtr_b_std"):key()] = {
				pattern_tweak = Vector3(0.888888, 0, 1)
			}
		},
		wpn_fps_pis_type54_b_long = {
			[Idstring("mtr_b_long"):key()] = {
				pattern_tweak = Vector3(0.888888, 0, 1)
			},
			[Idstring("mtr_b_std"):key()] = {
				pattern_tweak = Vector3(0.888888, 0, 1)
			}
		},
		wpn_fps_pis_type54_fl_rail = {
			[Idstring("mtr_rail"):key()] = {
				pattern_tweak = Vector3(0.888888, 0, 1)
			}
		},
		wpn_fps_pis_type54_sl_standard = {
			[Idstring("mtr_slide"):key()] = {
				pattern_tweak = Vector3(0.888888, 0, 1)
			}
		}
	}
	weapons.rsh12.pattern_tweak = Vector3(1, 0, 0)
	weapons.rsh12.parts = {
		wpn_fps_pis_rsh12_g_standard = {
			[Idstring("mtr_grip"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_pis_rsh12_g_wood = {
			[Idstring("mtr_grip"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_pis_rsh12_body_standard = {
			[Idstring("mtr_body"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			},
			[Idstring("mtr_mag"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_pis_rsh12_b_short = {
			[Idstring("mtr_b_short"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_pis_rsh12_b_standard = {
			[Idstring("mtr_b_std"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_pis_rsh12_b_comp = {
			[Idstring("mtr_b_std"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			},
			[Idstring("mtr_comp"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		}
	}
		weapons.ultima.parts = {
		wpn_fps_sho_ultima_body_standard = {
			[Idstring("mtr_body"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			},
			[Idstring("mtr_base"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_sho_ultima_body_kit = {
			[Idstring("mtr_body"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			},
			[Idstring("mtr_base"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_sho_ultima_body_rack = {
			[Idstring("mtr_mods"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			},
			[Idstring("mtr_slug"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_sho_ultima_fl_kit = {
			[Idstring("mtr_kit"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_sho_ultima_m_standard = {
			[Idstring("mtr_slug"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_sho_ultima_fg_standard = {
			[Idstring("mtr_camera"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			},
			[Idstring("mtr_foregrip"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_sho_ultima_fg_kit = {
			[Idstring("mtr_camera"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			},
			[Idstring("mtr_foregrip"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_sho_ultima_b_standard = {
			[Idstring("mtr_barrel"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			},
			[Idstring("mtr_upper"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_sho_ultima_b_kit = {
			[Idstring("mtr_barrel"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			},
			[Idstring("mtr_upper"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_sho_ultima_ns_comp = {
			[Idstring("mtr_mods"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_sho_ultima_s_light = {
			[Idstring("mtr_mods"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_sho_ultima_s_standard = {
			[Idstring("mtr_stock"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		}
	}
		weapons.groza.parts = {
		wpn_fps_ass_groza_gl_gp25 = {
			[Idstring("mtr_gp25"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_ass_groza_m_speed = {
			[Idstring("mtr_mag_speed"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_ass_groza_body_standard = {
			[Idstring("mtr_trunnion"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			},
			[Idstring("mtr_lower"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			},
			[Idstring("mtr_upper"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_ass_groza_o_adapter = {
			[Idstring("mtr_mount"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_ass_groza_b_supressor = {
			[Idstring("mtr_b_suppressed"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_ass_groza_bolt_standard = {
			[Idstring("mtr_upper"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_ass_groza_m_standard = {
			[Idstring("mtr_mag"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_ass_groza_g_standard = {
			[Idstring("mtr_grip"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_ass_groza_b_standard = {
			[Idstring("mtr_barrel"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		},
		wpn_fps_ass_groza_fl_adapter = {
			[Idstring("mtr_adapter"):key()] = {
				pattern_tweak = Vector3(1.444444, 0, 1)
			}
		}
	}
		weapons.maxim9.parts = {
		wpn_fps_pis_maxim9_body_lower = {
			[Idstring("mtr_body"):key()] = {
				pattern_tweak = Vector3(2.000000, 0, 1)
			},
			[Idstring("mtr_slide"):key()] = {
				pattern_tweak = Vector3(2.000000, 0, 1)
			}
		},
		wpn_fps_pis_maxim9_body_upper = {
			[Idstring("mtr_sight"):key()] = {
				pattern_tweak = Vector3(2.000000, 0, 1)
			},
			[Idstring("mtr_slide"):key()] = {
				pattern_tweak = Vector3(2.000000, 0, 1)
			}
		},
		wpn_fps_pis_maxim9_m_standard = {
			[Idstring("mtr_bullet"):key()] = {
				pattern_tweak = Vector3(2.000000, 0, 1)
			},
			[Idstring("mtr_mag"):key()] = {
				pattern_tweak = Vector3(2.000000, 0, 1)
			}
		},
		wpn_fps_pis_maxim9_m_ext = {
			[Idstring("mtr_bullet"):key()] = {
				pattern_tweak = Vector3(2.000000, 0, 1)
			},
			[Idstring("mtr_m_ext"):key()] = {
				pattern_tweak = Vector3(2.000000, 0, 1)
			},
			[Idstring("mtr_mag"):key()] = {
				pattern_tweak = Vector3(2.000000, 0, 1)
			}
		},
		wpn_fps_pis_maxim9_b_standard = {
			[Idstring("mtr_barrel"):key()] = {
				pattern_tweak = Vector3(2.000000, 0, 1)
			},
			[Idstring("mtr_sight"):key()] = {
				pattern_tweak = Vector3(2.000000, 0, 1)
			}
		},
		wpn_fps_pis_maxim9_b_long = {
			[Idstring("mtr_b_long"):key()] = {
				pattern_tweak = Vector3(2.000000, 0, 1)
			},
			[Idstring("mtr_barrel"):key()] = {
				pattern_tweak = Vector3(2.000000, 0, 1)
			},
			[Idstring("mtr_sight"):key()] = {
				pattern_tweak = Vector3(2.000000, 0, 1)
			}
		},
		wpn_fps_pis_maxim9_b_marksman = {
			[Idstring("mtr_b_comp"):key()] = {
				pattern_tweak = Vector3(2.000000, 0, 1)
			},
			[Idstring("mtr_barrel"):key()] = {
				pattern_tweak = Vector3(2.000000, 0, 1)
			},
			[Idstring("mtr_sight"):key()] = {
				pattern_tweak = Vector3(2.000000, 0, 1)
			}
		}
	}
	
	
  return weapons
end

-- Fixes some pattern scales on weapons being tiny when they were set to medium/large scales.
-- Code from Dorpenka.