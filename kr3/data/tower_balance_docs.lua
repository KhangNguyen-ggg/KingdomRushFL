-- Generated from 说明文档/防御塔移植说明及防御塔增强模式.docx.
-- mode = "auto" follows screen_map.user_data.liuhui.balance; use "standard", "enhanced", or "game" to force a copy source.

local M = {
	mode = "auto",
	status_text = {
		standard = "Tăng cường: tắt",
		enhanced = "Tăng cường: bật",
		game = "Thông số trong game"
	},
	skill_ranks = {
		tower_ranger = {
			poison = 1,
			thorn = 2
		},
		tower_musketeer = {
			sniper = 1,
			shrapnel = 2
		},
		tower_paladin = {
			healing = 1,
			shield = 2,
			holystrike = 3
		},
		tower_barbarian = {
			dual = 1,
			twister = 2,
			throwing = 3
		},
		tower_arcane_wizard = {
			disintegrate = 1,
			teleport = 2
		},
		tower_sorcerer = {
			polymorph = 1,
			elemental = 2
		},
		tower_bfg = {
			missile = 1,
			cluster = 2
		},
		tower_tesla = {
			bolt = 1,
			overcharge = 2
		},
		tower_totem = {
			weakness = 1,
			silence = 2
		},
		tower_crossbow = {
			multishot = 1,
			eagle = 2
		},
		tower_assassin = {
			sneak = 1,
			counter = 2,
			pickpocket = 3
		},
		tower_templar = {
			extralife = 1,
			blood = 2,
			holygrail = 3
		},
		tower_necromancer = {
			rider = 1,
			pestilence = 2
		},
		tower_archmage = {
			twister = 1,
			blast = 2
		},
		tower_dwaarp = {
			drill = 1,
			lava = 2
		},
		tower_mech = {
			missile = 1,
			oil = 2
		},
		tower_arcane = {
			burst = 1,
			slumber = 2
		},
		tower_silver = {
			sentence = 1,
			mark = 2
		},
		tower_blade = {
			perfect_parry = 1,
			blade_dance = 3,
			swirling = 2
		},
		tower_forest = {
			circle = 1,
			eerie = 2,
			oak = 3
		},
		tower_wild_magus = {
			eldritch = 1,
			ward = 2
		},
		tower_high_elven = {
			timelapse = 1,
			sentinel = 2
		},
		tower_druid = {
			sylvan = 1,
			nature = 2
		},
		tower_entwood = {
			fiery_nuts = 1,
			clobber = 2
		},
		tower_orc_shaman_lvl4 = {
			vines = 1,
			meteor = 2,
			shock = 3
		},
		tower_orc_warriors_den_lvl4 = {
			bloodlust = 1,
			promotion = 2,
			seal = 3
		},
		tower_goblirang_lvl4 = {
			big = 1,
			stun = 2,
			bees = 3
		},
		tower_rocket_riders_lvl4 = {
			mine = 1,
			nitro = 2,
			engine = 3
		},
		tower_balloon_lvl4 = {
			oil = 1,
			watcher = 2,
			bomber = 3
		},
		tower_infernal_mage_lvl4 = {
			curse = 1,
			fissure = 2,
			teleport = 3
		},
		tower_shadow_archer_lvl4 = {
			mark = 1,
			blade = 2,
			crow = 3
		},
		tower_spirit_mausoleum_lvl4 = {
			gargoyles = 1,
			spectral_communion = 2,
			possession = 3
		},
		tower_melting_furnace_lvl4 = {
			coal = 1,
			heat = 2,
			fuel = 3
		},
		tower_dark_knights_lvl4 = {
			instakill = 1,
			spike = 2,
			shield = 3
		},
		tower_grim_cemetery_lvl4 = {
			hands = 1,
			big = 2,
			pestilence = 3
		},
		tower_bone_flingers_lvl4 = {
			skeleton = 1,
			milk = 2,
			golem = 3
		},
		tower_blazing_watcher_lvl4 = {
			charging = 1,
			disintegrate = 2,
			explosion = 3
		},
		tower_rotten_forest_lvl4 = {
			tree = 1,
			warp = 2,
			fog = 3
		},
		tower_wicked_sisters_lvl4 = {
			frog = 1,
			silent = 2,
			range = 3
		},
		tower_twilight_elves_barrack_lvl4 = {
			backstab = 1,
			arrow_storm = 2,
			last_breath = 3
		},
		tower_deep_devils_lvl4 = {
			amph = 1,
			net = 2,
			storm = 3
		},
		tower_shaolin_lvl4 = {
			lion = 2,
			dragon = 1,
			total = 3
		},
		tower_swamp_monster_lvl4 = {
			instakill = 1,
			stun = 2,
			eat = 3
		},
		tower_ignis_altar_lvl4 = {
			golemstone = 1,
			firewheel = 2,
			stickylava = 3
		},
		tower_sandworm_lvl4 = {
			worm = 1,
			eat = 2,
			slime = 3
		},
		tower_ogre_shipwreck_lvl4 = {
			enhance = 1,
			multishoot = 2,
			goblin = 3
		},
		tower_paladin_covenant_lvl4 = {
			lead = 1,
			healing_prayer = 2
		},
		tower_royal_archers_lvl4 = {
			armor_piercer = 1,
			rapacious_hunter = 2
		},
		tower_arcane_wizard_lvl4 = {
			disintegrate = 1,
			empowerment = 2
		},
		tower_tricannon_lvl4 = {
			bombardment = 1,
			overheat = 2
		},
		tower_arborean_emissary_lvl4 = {
			gift_of_nature = 1,
			wave_of_roots = 2
		},
		tower_demon_pit_lvl4 = {
			master_exploders = 1,
			big_guy = 2
		},
		tower_elven_stargazers_lvl4 = {
			teleport = 1,
			stars_death = 2
		},
		tower_rocket_gunners_lvl4 = {
			sting_missiles = 1,
			phosphoric = 2
		},
		tower_ballista_lvl4 = {
			skill_final_shot = 1,
			skill_bomb = 2
		},
		tower_necromancer_lvl4 = {
			skill_debuff = 1,
			skill_rider = 2
		},
		tower_flamespitter_lvl4 = {
			skill_bomb = 2,
			skill_columns = 1
		},
		tower_sand_lvl4 = {
			skill_gold = 1,
			skill_big_blade = 2
		},
		tower_ghost_lvl4 = {
			extra_damage = 1,
			soul_attack = 2
		},
		tower_barrel_lvl4 = {
			skill_warrior = 1,
			skill_barrel = 2
		},
		tower_ray_lvl4 = {
			chain = 1,
			sheep = 2
		},
		tower_dark_elf_lvl4 = {
			skill_soldiers = 1,
			skill_buff = 2
		},
		tower_hermit_toad_lvl4 = {
			jump = 1,
			instakill = 2
		},
		tower_dwarf_lvl4 = {
			formation = 1,
			incendiary_ammo = 2
		},
		tower_sparking_geode_lvl4 = {
			crystalize = 1,
			spike_burst = 2
		},
		tower_pandas_lvl4 = {
			thunder = 2,
			hat = 1,
			teleport = 3
		},
		tower_dragons_lvl4 = {
			dragon_split = 1,
			massive_fear = 2
		},
		tower_archers_lvl4 = { skill_a = 1, skill_b = 2, skill_c = 3, ultimate = 4 },
		tower_knights_lvl4 = { skill_a = 1, skill_b = 2, skill_c = 3, ultimate = 4 },
		tower_wizard_lvl4 = { skill_a = 1, skill_b = 2, skill_c = 3, ultimate = 4 },
		tower_catapult_lvl4 = { skill_a = 1, skill_b = 2, skill_c = 3, ultimate = 4 },
		tower_ranger_lvl4 = { skill_a = 1, skill_b = 2, skill_c = 3, ultimate = 4 },
		tower_culverine_lvl4 = { skill_a = 1, skill_b = 2, skill_c = 3, ultimate = 4 },
		tower_sunray_master_lvl4 = { skill_a = 1, skill_b = 2, skill_c = 3, ultimate = 4 },
		tower_light_priestess_lvl4 = { skill_a = 1, skill_b = 2, skill_c = 3, ultimate = 4 },
		tower_tree_lvl4 = { skill_a = 1, skill_b = 2, skill_c = 3, ultimate = 4 },
		tower_wildcat_lvl4 = { skill_a = 1, skill_b = 2, skill_c = 3, ultimate = 4 },
		tower_alchemist_lvl4 = { skill_a = 1, skill_b = 2, skill_c = 3, ultimate = 4 },
		tower_forger_lvl4 = { skill_a = 1, skill_b = 2, skill_c = 3, ultimate = 4 },
		tower_crossbows_lvl4 = { skill_a = 1, skill_b = 2, skill_c = 3, ultimate = 4 },
		tower_miners_lvl4 = { skill_a = 1, skill_b = 2, skill_c = 3, ultimate = 4 },
		tower_sniper_lvl4 = { skill_a = 1, skill_b = 2, skill_c = 3, ultimate = 4 }
	},
	entries = {
		["tower_ranger"] = {
			doc_id = "",
			title = "Nơi trú ẩn cung thủ rừng",
			attack = {
				standard = "Bắn một mũi tên mỗi 0.4 giây, gây sát thương vật lý.",
				enhanced = "Bắn một mũi tên mỗi 0.4 giây, gây sát thương vật lý; tên ít bị trượt hơn."
			},
			change_note = "Nhận xét: Sức mạnh chủ yếu nằm ở kỹ năng 2. Đòn đánh thường hay trượt nhưng tháp vẫn hữu ích ở giai đoạn chuyển tiếp và ít lãng phí sát thương. Mũi tên độc bản gốc không đáng tiền, nâng cấp 2/3 ít có ý nghĩa, trong khi Dây leo trói đã đủ mạnh. Tăng số lần trói giúp việc xây nhiều tháp hiệu quả hơn.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Mũi tên độc",
					standard = "Đòn đánh gây độc, gây 5 sát thương độc mỗi giây trong 3 giây.",
					enhanced = "Đòn đánh gây độc, gây 16 sát thương độc mỗi giây trong 3 giây.",
					levels_standard = { "Đòn đánh gây độc, gây 5 sát thương độc mỗi giây trong 3 giây.", "Đòn đánh gây độc, gây 10 sát thương độc mỗi giây trong 3 giây.", "Đòn đánh gây độc, gây 15 sát thương độc mỗi giây trong 3 giây." },
					levels_enhanced = { "Đòn đánh gây độc, gây 16 sát thương độc mỗi giây trong 3 giây.", "Đòn đánh gây độc, gây 28 sát thương độc mỗi giây trong 3 giây.", "Đòn đánh gây độc, gây 40 sát thương độc mỗi giây trong 3 giây." },
					prices_standard = { "250", "250", "250" },
					prices_enhanced = { "250", "125", "125" }
				},
				{
					name = "Dây leo trói",
					standard = "Pháp sư dưới tháp gọi dây leo trói 2-4 kẻ địch trong tầm phép suốt 1.7 giây. Mục tiêu không thể hành động và chịu 40 sát thương vật lý mỗi giây. CD: 8 giây.\nMỗi kẻ địch bị trói tối đa 3 lần.",
					enhanced = "Pháp sư dưới tháp gọi dây leo trói 2-4 kẻ địch trong tầm phép suốt 1.7 giây. Mục tiêu không thể hành động và chịu 40 sát thương vật lý mỗi giây. CD: 8 giây.\nMỗi kẻ địch bị trói tối đa 99 lần.",
					levels_standard = { "Pháp sư dưới tháp gọi dây leo trói 2-4 kẻ địch trong tầm phép suốt 1.7 giây. Mục tiêu không thể hành động và chịu 40 sát thương vật lý mỗi giây. CD: 8 giây.\nMỗi kẻ địch bị trói tối đa 3 lần.", "Pháp sư dưới tháp gọi dây leo trói 2-6 kẻ địch trong tầm phép suốt 2.7 giây. Mục tiêu không thể hành động và chịu 40 sát thương vật lý mỗi giây. CD: 8 giây.\nMỗi kẻ địch bị trói tối đa 3 lần.", "Pháp sư dưới tháp gọi dây leo trói 2-8 kẻ địch trong tầm phép suốt 3.7 giây. Mục tiêu không thể hành động và chịu 40 sát thương vật lý mỗi giây. CD: 8 giây.\nMỗi kẻ địch bị trói tối đa 3 lần." },
					levels_enhanced = { "Pháp sư dưới tháp gọi dây leo trói 2-4 kẻ địch trong tầm phép suốt 1.7 giây. Mục tiêu không thể hành động và chịu 60 sát thương vật lý mỗi giây. CD: 8 giây.\nMỗi kẻ địch bị trói tối đa 99 lần.", "Pháp sư dưới tháp gọi dây leo trói 2-7 kẻ địch trong tầm phép suốt 2.7 giây. Mục tiêu không thể hành động và chịu 60 sát thương vật lý mỗi giây. CD: 8 giây.\nMỗi kẻ địch bị trói tối đa 99 lần.", "Pháp sư dưới tháp gọi dây leo trói 2-10 kẻ địch trong tầm phép suốt 3.7 giây. Mục tiêu không thể hành động và chịu 60 sát thương vật lý mỗi giây. CD: 8 giây.\nMỗi kẻ địch bị trói tối đa 99 lần." },
					prices_standard = { "300", "150", "150" },
					prices_enhanced = { "300", "150", "150" }
				},
			}
		},
		["tower_musketeer"] = {
			doc_id = "",
			title = "Đồn lính súng",
			attack = {
				standard = "Bắn súng mỗi 1.5 giây, gây sát thương vật lý.",
				enhanced = "Bắn súng mỗi 1.5 giây, gây sát thương vật lý."
			},
			change_note = "Nhận xét: Kỹ năng biến tháp thành pháo truyền thống cỡ lớn, sát thương cao nhưng tầm ngắn. Ở bản gốc, đòn đánh thường thuộc nhóm tháp cung đơn mục tiêu yếu nhất và tốc độ bắn chậm; bắn tỉa phụ thuộc may rủi. Trúng kẻ địch giáp cao mà không kích hoạt tiêu diệt ngay gần như đem lại 0 hiệu quả. Kỹ năng 2 mạnh nhưng nâng cấp đột ngột và tầm ngắn. Các điểm này được cải thiện, song kỹ năng của cả hai tháp cung phần 1 vốn rất mạnh nên không thể tăng quá nhiều sức mạnh ban đầu.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Bắn tỉa",
					standard = "Bắn tỉa từ rất xa, gây sát thương vật lý bằng [sát thương đòn đánh thường] + 20% máu tối đa của mục tiêu; có 20% cơ hội tiêu diệt ngay. Tầm bắn gấp 1.5 lần chỉ số hiển thị (852). CD: 14 giây.",
					enhanced = "Bắn tỉa từ rất xa, gây sát thương chuẩn bằng [sát thương đòn đánh thường] + 20% máu tối đa của mục tiêu; có 20% cơ hội tiêu diệt ngay. Tầm bắn gấp 1.5 lần chỉ số hiển thị (852). CD: 14 giây.",
					levels_standard = { "Bắn tỉa từ rất xa, gây sát thương vật lý bằng [sát thương đòn đánh thường] + 20% máu tối đa của mục tiêu; có 20% cơ hội tiêu diệt ngay. Tầm bắn gấp 1.5 lần chỉ số hiển thị (852). CD: 14 giây.", "Bắn tỉa từ rất xa, gây sát thương vật lý bằng [sát thương đòn đánh thường] + 40% máu tối đa của mục tiêu; có 40% cơ hội tiêu diệt ngay. Tầm bắn gấp 1.5 lần chỉ số hiển thị (852). CD: 14 giây.", "Bắn tỉa từ rất xa, gây sát thương vật lý bằng [sát thương đòn đánh thường] + 60% máu tối đa của mục tiêu; có 60% cơ hội tiêu diệt ngay. Tầm bắn gấp 1.5 lần chỉ số hiển thị (852). CD: 14 giây." },
					levels_enhanced = { "Bắn tỉa từ rất xa, gây sát thương chuẩn bằng [sát thương đòn đánh thường] + 20% máu tối đa của mục tiêu; có 20% cơ hội tiêu diệt ngay. Tầm bắn gấp 1.5 lần chỉ số hiển thị (852). CD: 14 giây.", "Bắn tỉa từ rất xa, gây sát thương chuẩn bằng [sát thương đòn đánh thường] + 40% máu tối đa của mục tiêu; có 40% cơ hội tiêu diệt ngay. Tầm bắn gấp 1.5 lần chỉ số hiển thị (852). CD: 14 giây.", "Bắn tỉa từ rất xa, gây sát thương chuẩn bằng [sát thương đòn đánh thường] + 60% máu tối đa của mục tiêu; có 60% cơ hội tiêu diệt ngay. Tầm bắn gấp 1.5 lần chỉ số hiển thị (852). CD: 14 giây." },
					prices_standard = { "250", "250", "250" },
					prices_enhanced = { "250", "175", "175" }
				},
				{
					name = "Đạn chùm",
					standard = "Bắn 6 quả lựu đạn vào một vùng. Mỗi quả gây 10-40 (40) sát thương pháo trong bán kính 96; khoảng cách bố trí mảnh đạn: 12.5-32.5. CD: 9 giây. Tầm bắn gấp 0.5 lần đòn đánh thường (284).",
					enhanced = "Bắn 6 quả lựu đạn vào một vùng. Mỗi quả gây 12-32 (32) sát thương pháo trong bán kính 96; khoảng cách bố trí mảnh đạn: 12.5-32.5. CD: 6 giây. Tầm bắn gấp 0.625 lần đòn đánh thường (355).",
					levels_standard = { "Bắn 6 quả lựu đạn vào một vùng. Mỗi quả gây 10-40 (40) sát thương pháo trong bán kính 96; khoảng cách bố trí mảnh đạn: 12.5-32.5. CD: 9 giây. Tầm bắn gấp 0.5 lần đòn đánh thường (284).", "Bắn 6 quả lựu đạn vào một vùng. Mỗi quả gây 20-80 (80) sát thương pháo trong bán kính 96; khoảng cách bố trí mảnh đạn: 12.5-32.5. CD: 9 giây. Tầm bắn gấp 0.5 lần đòn đánh thường (284).", "Bắn 6 quả lựu đạn vào một vùng. Mỗi quả gây 30-120 (120) sát thương pháo trong bán kính 96; khoảng cách bố trí mảnh đạn: 12.5-32.5. CD: 9 giây. Tầm bắn gấp 0.5 lần đòn đánh thường (284)." },
					levels_enhanced = { "Bắn 6 quả lựu đạn vào một vùng. Mỗi quả gây 12-32 (32) sát thương pháo trong bán kính 96; khoảng cách bố trí mảnh đạn: 12.5-32.5. CD: 6 giây. Tầm bắn gấp 0.625 lần đòn đánh thường (355).", "Bắn 6 quả lựu đạn vào một vùng. Mỗi quả gây 24-64 (64) sát thương pháo trong bán kính 96; khoảng cách bố trí mảnh đạn: 12.5-32.5. CD: 6 giây. Tầm bắn gấp 0.625 lần đòn đánh thường (355).", "Bắn 6 quả lựu đạn vào một vùng. Mỗi quả gây 36-96 (96) sát thương pháo trong bán kính 96; khoảng cách bố trí mảnh đạn: 12.5-32.5. CD: 6 giây. Tầm bắn gấp 0.625 lần đòn đánh thường (355)." },
					prices_standard = { "300", "300", "300" },
					prices_enhanced = { "325", "325", "325" }
				},
			}
		},
		["tower_paladin"] = {
			doc_id = "",
			title = "Thánh đường hiệp sĩ",
			attack = {
				standard = "Tấn công cận chiến, gây sát thương vật lý.",
				enhanced = "Tấn công cận chiến, gây sát thương vật lý."
			},
			change_note = "Nhận xét: Tăng nhẹ khả năng gây sát thương; kỹ năng 3 của thánh kỵ sĩ bản Flash cũng gây sát thương chuẩn. Doanh trại chỉ dựa vào chỉ số để chống chịu, thiếu cơ chế đặc biệt, chưa xứng đáng với mức giá này.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Ánh sáng thánh",
					standard = "Khi máu dưới 70%, thánh kỵ sĩ tự hồi 40-60 máu. Không xóa hiệu ứng bất lợi như cháy hoặc độc. CD: 10 giây.",
					enhanced = "Khi máu dưới 70%, thánh kỵ sĩ tự hồi 40-60 máu. Không xóa hiệu ứng bất lợi như cháy hoặc độc. CD: 10 giây.",
					levels_standard = { "Khi máu dưới 70%, thánh kỵ sĩ tự hồi 40-60 máu. Không xóa hiệu ứng bất lợi như cháy hoặc độc. CD: 10 giây.", "Khi máu dưới 70%, thánh kỵ sĩ tự hồi 80-120 máu. Không xóa hiệu ứng bất lợi như cháy hoặc độc. CD: 10 giây.", "Khi máu dưới 70%, thánh kỵ sĩ tự hồi 120-180 máu. Không xóa hiệu ứng bất lợi như cháy hoặc độc. CD: 10 giây." },
					levels_enhanced = { "Khi máu dưới 70%, thánh kỵ sĩ tự hồi 40-60 máu. Không xóa hiệu ứng bất lợi như cháy hoặc độc. CD: 10 giây.", "Khi máu dưới 70%, thánh kỵ sĩ tự hồi 80-120 máu. Không xóa hiệu ứng bất lợi như cháy hoặc độc. CD: 10 giây.", "Khi máu dưới 70%, thánh kỵ sĩ tự hồi 120-180 máu. Không xóa hiệu ứng bất lợi như cháy hoặc độc. CD: 10 giây." },
					prices_standard = { "150", "150", "150" },
					prices_enhanced = { "80", "80", "80" }
				},
				{
					name = "Khiên dũng khí",
					standard = "Tăng 15 giáp cho thánh kỵ sĩ.",
					enhanced = "Tăng 15 giáp cho thánh kỵ sĩ.",
					levels_standard = { "Tăng 15 giáp cho thánh kỵ sĩ." },
					levels_enhanced = { "Tăng 15 giáp cho thánh kỵ sĩ." },
					prices_standard = { "250" },
					prices_enhanced = { "110" }
				},
				{
					name = "Đòn đánh thánh",
					standard = "Mỗi đòn đánh có 10% cơ hội gây 25-45 sát thương vật lý diện rộng trong bán kính 100.",
					enhanced = "Mỗi đòn đánh có 20% cơ hội gây 25-45 sát thương chuẩn diện rộng trong bán kính 150.",
					levels_standard = { "Mỗi đòn đánh có 10% cơ hội gây 25-45 sát thương vật lý diện rộng trong bán kính 100.", "Mỗi đòn đánh có 10% cơ hội gây 50-90 sát thương vật lý diện rộng trong bán kính 100.", "Mỗi đòn đánh có 10% cơ hội gây 75-135 sát thương vật lý diện rộng trong bán kính 100." },
					levels_enhanced = { "Mỗi đòn đánh có 30% cơ hội gây 25-45 sát thương chuẩn diện rộng trong bán kính 150.", "Mỗi đòn đánh có 30% cơ hội gây 50-90 sát thương chuẩn diện rộng trong bán kính 150.", "Mỗi đòn đánh có 30% cơ hội gây 75-135 sát thương chuẩn diện rộng trong bán kính 150." },
					prices_standard = { "220", "150", "150" },
					prices_enhanced = { "145", "100", "100" }
				},
			}
		},
		["tower_barbarian"] = {
			doc_id = "",
			title = "Đại sảnh man tộc",
			attack = {
				standard = "Tấn công cận chiến, gây sát thương vật lý.",
				enhanced = "Tấn công cận chiến, gây sát thương vật lý."
			},
			change_note = "Cải thiện toàn diện khả năng đánh xa.",
			port_note = "",
			notes = "Cải thiện toàn diện khả năng đánh xa.",
			skills = {
				{
					name = "Song rìu",
					standard = "Tăng 10 sát thương cận chiến thường cho chiến binh man tộc.",
					enhanced = "Tăng 16 sát thương cận chiến thường cho chiến binh man tộc.",
					levels_standard = { "Tăng 10 sát thương cận chiến thường cho chiến binh man tộc.", "Tăng 20 sát thương cận chiến thường cho chiến binh man tộc.", "Tăng 30 sát thương cận chiến thường cho chiến binh man tộc." },
					levels_enhanced = { "Tăng 16 sát thương cận chiến thường cho chiến binh man tộc.", "Tăng 32 sát thương cận chiến thường cho chiến binh man tộc.", "Tăng 48 sát thương cận chiến thường cho chiến binh man tộc." },
					prices_standard = { "300", "100", "100" },
					prices_enhanced = { "100", "100", "100" }
				},
				{
					name = "Chém lốc xoáy",
					standard = "Mỗi lần tấn công hoặc nhận sát thương, trừ sát thương định kỳ từ hiệu ứng bất lợi, có 15% cơ hội gây 25-45 sát thương vật lý diện rộng trong bán kính 80.",
					enhanced = "Mỗi lần tấn công hoặc nhận sát thương, trừ sát thương định kỳ từ hiệu ứng bất lợi, có 18% cơ hội gây 25-45 sát thương vật lý diện rộng trong bán kính 130.",
					levels_standard = { "Mỗi lần tấn công hoặc nhận sát thương, trừ sát thương định kỳ từ hiệu ứng bất lợi, có 15% cơ hội gây 25-45 sát thương vật lý diện rộng trong bán kính 80.", "Mỗi lần tấn công hoặc nhận sát thương, trừ sát thương định kỳ từ hiệu ứng bất lợi, có 20% cơ hội gây 40-60 sát thương vật lý diện rộng trong bán kính 80.", "Mỗi lần tấn công hoặc nhận sát thương, trừ sát thương định kỳ từ hiệu ứng bất lợi, có 25% cơ hội gây 55-75 sát thương vật lý diện rộng trong bán kính 80." },
					levels_enhanced = { "Mỗi lần tấn công hoặc nhận sát thương, trừ sát thương định kỳ từ hiệu ứng bất lợi, có 20% cơ hội gây 25-45 sát thương vật lý diện rộng trong bán kính 130.", "Mỗi lần tấn công hoặc nhận sát thương, trừ sát thương định kỳ từ hiệu ứng bất lợi, có 30% cơ hội gây 40-60 sát thương vật lý diện rộng trong bán kính 130.", "Mỗi lần tấn công hoặc nhận sát thương, trừ sát thương định kỳ từ hiệu ứng bất lợi, có 40% cơ hội gây 55-75 sát thương vật lý diện rộng trong bán kính 130." },
					prices_standard = { "150", "100", "100" },
					prices_enhanced = { "150", "100", "100" }
				},
				{
					name = "Ném rìu",
					standard = "Ném rìu mỗi 3.5 giây,\ngây 34-42 sát thương vật lý.",
					enhanced = "Ném rìu mỗi 2 giây,\ngây 34-42 sát thương vật lý.",
					levels_standard = { "Ném rìu mỗi 3.5 giây,\ngây 34-42 sát thương vật lý.", "Ném rìu mỗi 3.5 giây,\ngây 44-52 sát thương vật lý.", "Ném rìu mỗi 3.5 giây,\ngây 54-62 sát thương vật lý." },
					levels_enhanced = { "Ném rìu mỗi 2 giây,\ngây 34-42 sát thương vật lý.", "Ném rìu mỗi 2 giây,\ngây 44-52 sát thương vật lý.", "Ném rìu mỗi 2 giây,\ngây 54-62 sát thương vật lý." },
					prices_standard = { "200", "100", "100" },
					prices_enhanced = { "200", "75", "75" }
				},
			}
		},
		["tower_arcane_wizard"] = {
			doc_id = "",
			title = "Pháp sư bí thuật",
			attack = {
				standard = "Phóng tia phép mỗi 2 giây, gây sát thương phép.",
				enhanced = "Phóng tia phép mỗi 2 giây, gây sát thương phép."
			},
			change_note = "Nhận xét: Tháp phép đánh chậm, là tháp duy nhất ở phần 1 không có khả năng đánh nhiều mục tiêu và cũng thuộc nhóm hiếm gặp trong toàn bộ các phần. Tháp thiên về sát thương cần hỏa lực cao hơn. Sau tăng cường, đây là kỹ năng tiêu diệt ngay thông minh duy nhất trong 17 kỹ năng của 65 tháp thông thường; đồng thời sửa tình trạng phép dịch chuyển không bắt được mục tiêu.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Tia tử thần",
					standard = "Phóng tia tiêu diệt ngay kẻ địch thường đi đầu trong tầm; không tác động lên trùm. CD: 20 giây.",
					enhanced = "Phóng tia tiêu diệt ngay kẻ địch thường còn nhiều máu nhất trong tầm; không tác động lên trùm. CD: 24 giây.",
					levels_standard = { "Phóng tia tiêu diệt ngay kẻ địch thường đi đầu trong tầm; không tác động lên trùm. CD: 20 giây.", "Phóng tia tiêu diệt ngay kẻ địch thường đi đầu trong tầm; không tác động lên trùm. CD: 18 giây.", "Phóng tia tiêu diệt ngay kẻ địch thường đi đầu trong tầm; không tác động lên trùm. CD: 16 giây." },
					levels_enhanced = { "Phóng tia tiêu diệt ngay kẻ địch thường còn nhiều máu nhất trong tầm; không tác động lên trùm. CD: 24 giây.", "Phóng tia tiêu diệt ngay kẻ địch thường còn nhiều máu nhất trong tầm; không tác động lên trùm. CD: 20 giây.", "Phóng tia tiêu diệt ngay kẻ địch thường còn nhiều máu nhất trong tầm; không tác động lên trùm. CD: 16 giây." },
					prices_standard = { "350", "200", "200" },
					prices_enhanced = { "375", "100", "100" }
				},
				{
					name = "Dịch chuyển",
					standard = "Tạo vòng phép dịch chuyển tối đa 4 kẻ địch lùi 21-30 nút đường đi, bán kính 65. Mỗi kẻ địch bị dịch chuyển tối đa 3 lần. CD: 10 giây.",
					enhanced = "Tạo vòng phép dịch chuyển tối đa 4 kẻ địch lùi 26-35 nút đường đi, bán kính 100. Mỗi kẻ địch bị dịch chuyển tối đa 5 lần. CD: 10 giây.",
					levels_standard = { "Tạo vòng phép dịch chuyển tối đa 4 kẻ địch lùi 21-30 nút đường đi, bán kính 65. Mỗi kẻ địch bị dịch chuyển tối đa 3 lần. CD: 10 giây.", "Tạo vòng phép dịch chuyển tối đa 5 kẻ địch lùi 26-35 nút đường đi, bán kính 65. Mỗi kẻ địch bị dịch chuyển tối đa 3 lần. CD: 10 giây.", "Tạo vòng phép dịch chuyển tối đa 6 kẻ địch lùi 31-40 nút đường đi, bán kính 65. Mỗi kẻ địch bị dịch chuyển tối đa 3 lần. CD: 10 giây." },
					levels_enhanced = { "Tạo vòng phép dịch chuyển tối đa 4 kẻ địch lùi 26-35 nút đường đi, bán kính 100. Mỗi kẻ địch bị dịch chuyển tối đa 5 lần. CD: 10 giây.", "Tạo vòng phép dịch chuyển tối đa 5 kẻ địch lùi 31-40 nút đường đi, bán kính 100. Mỗi kẻ địch bị dịch chuyển tối đa 5 lần. CD: 10 giây.", "Tạo vòng phép dịch chuyển tối đa 6 kẻ địch lùi 36-45 nút đường đi, bán kính 100. Mỗi kẻ địch bị dịch chuyển tối đa 5 lần. CD: 10 giây." },
					prices_standard = { "300", "100", "100" },
					prices_enhanced = { "300", "100", "100" }
				},
			}
		},
		["tower_sorcerer"] = {
			doc_id = "",
			title = "Pháp sư phù phép",
			attack = {
				standard = "Phóng tia phép mỗi 1.5 giây, kèm lời nguyền giáp kéo dài 4.9 giây: giảm 50% giáp và gây 10 sát thương chuẩn mỗi 1.25 giây, tổng cộng 40 sát thương từ lời nguyền.",
				enhanced = "Phóng tia phép mỗi 1.5 giây, kèm lời nguyền giáp kéo dài 7.0 giây: giảm 50% giáp và 50% kháng phép; gây 11 sát thương chuẩn mỗi 1.25 giây, tổng cộng 66 sát thương từ lời nguyền."
			},
			change_note = "Nhận xét: Tăng khả năng hỗ trợ phá giáp của pháp sư vàng và tránh các tình huống biến kẻ địch thành cừu nhưng vô tình khiến chúng nguy hiểm hơn. Kỹ năng 2 trông như có thể tiêu diệt hàng loạt 7 mục tiêu, nhưng tác giả thấy khó sử dụng: đôi lúc vừa biến một kẻ địch hơn 10 máu thành cừu thì nó đã bị giết trước khi kịp nhấn cho nổ. Sẽ điều chỉnh theo tình hình thực tế.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Biến cừu",
					standard = "Biến một kẻ địch thành cừu không thể chặn; kẻ địch bay thành cừu có cánh. Mục tiêu mất toàn bộ sức tấn công và kháng, chỉ còn 50% máu ban đầu. Nhấn 8 lần để giết. CD: 20 giây.",
					enhanced = "Biến một kẻ địch thành cừu béo gần như đứng yên, không còn nguy hiểm. Nhấn 3 lần để giết. Khi chết, nó biến tối đa 1 kẻ địch gần đó thành cừu gầy có thể chạy. CD: 20 giây.",
					levels_standard = { "Biến một kẻ địch thành cừu không thể chặn; kẻ địch bay thành cừu có cánh. Mục tiêu mất toàn bộ sức tấn công và kháng, chỉ còn 50% máu ban đầu. Nhấn 8 lần để giết. CD: 20 giây.", "Biến một kẻ địch thành cừu không thể chặn; kẻ địch bay thành cừu có cánh. Mục tiêu mất toàn bộ sức tấn công và kháng, chỉ còn 50% máu ban đầu. Nhấn 8 lần để giết. CD: 18 giây.", "Biến một kẻ địch thành cừu không thể chặn; kẻ địch bay thành cừu có cánh. Mục tiêu mất toàn bộ sức tấn công và kháng, chỉ còn 50% máu ban đầu. Nhấn 8 lần để giết. CD: 16 giây." },
					levels_enhanced = { "Biến một kẻ địch thành cừu béo gần như đứng yên, không còn nguy hiểm. Nhấn 3 lần để giết. Khi chết, nó biến tối đa 1 kẻ địch gần đó thành cừu gầy có thể chạy. CD: 20 giây.", "Biến một kẻ địch thành cừu béo gần như đứng yên, không còn nguy hiểm. Nhấn 3 lần để giết. Khi chết, nó biến tối đa 3 kẻ địch gần đó thành cừu gầy có thể chạy. CD: 18 giây.", "Biến một kẻ địch thành cừu béo gần như đứng yên, không còn nguy hiểm. Nhấn 3 lần để giết. Khi chết, nó biến tối đa 6 kẻ địch gần đó thành cừu gầy có thể chạy. CD: 16 giây." },
					prices_standard = { "300", "150", "150" },
					prices_enhanced = { "350", "200", "200" }
				},
				{
					name = "Tinh linh đất",
					standard = "Triệu hồi Tinh linh đất chặn và đánh kẻ địch. Đòn đánh gây sát thương cho tối đa 4 mục tiêu trong bán kính 65. Giáp: 40; máu: 600.",
					enhanced = "Triệu hồi Tinh linh đất chặn và đánh kẻ địch. Đòn đánh gây sát thương cho tối đa 4 mục tiêu trong bán kính 65. Giáp: 40; máu: 600.",
					levels_standard = { "Triệu hồi Tinh linh đất chặn và đánh kẻ địch. Đòn đánh gây sát thương cho tối đa 4 mục tiêu trong bán kính 65. Giáp: 40; máu: 600.", "Triệu hồi Tinh linh đất chặn và đánh kẻ địch. Đòn đánh gây sát thương cho tối đa 4 mục tiêu trong bán kính 65. Giáp: 50; máu: 700.", "Triệu hồi Tinh linh đất chặn và đánh kẻ địch. Đòn đánh gây sát thương cho tối đa 4 mục tiêu trong bán kính 65. Giáp: 60; máu: 800." },
					levels_enhanced = { "Triệu hồi Tinh linh đất chặn và đánh kẻ địch. Đòn đánh gây sát thương cho tối đa 4 mục tiêu trong bán kính 65. Giáp: 40; máu: 600.", "Triệu hồi Tinh linh đất chặn và đánh kẻ địch. Đòn đánh gây sát thương cho tối đa 4 mục tiêu trong bán kính 65. Giáp: 50; máu: 700.", "Triệu hồi Tinh linh đất chặn và đánh kẻ địch. Đòn đánh gây sát thương cho tối đa 4 mục tiêu trong bán kính 65. Giáp: 60; máu: 800." },
					prices_standard = { "350", "150", "150" },
					prices_enhanced = { "350", "150", "150" }
				},
			}
		},
		["tower_bfg"] = {
			doc_id = "",
			title = "Big Bertha 500MM",
			attack = {
				standard = "Bắn đạn pháo mỗi 3.5 giây, gây sát thương trong bán kính 150.",
				enhanced = "Bắn đạn pháo mỗi 3.5 giây, gây sát thương trong bán kính 150."
			},
			change_note = "Nhận xét: Pháo lớn của bản Flash.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Tên lửa hơi thở rồng",
					standard = "Bắn tên lửa vào kẻ địch mặt đất hoặc trên không gần lối thoát nhất, gây 100-140 sát thương pháo trong bán kính 82.5. CD: 13.5 giây.",
					enhanced = "Bắn tên lửa vào kẻ địch mặt đất hoặc trên không gần lối thoát nhất, gây 140-180 sát thương pháo trong bán kính 150. CD: 7 giây.",
					levels_standard = { "Bắn tên lửa vào kẻ địch mặt đất hoặc trên không gần lối thoát nhất, gây 100-140 sát thương pháo trong bán kính 82.5. CD: 13.5 giây.", "Bắn tên lửa vào kẻ địch mặt đất hoặc trên không gần lối thoát nhất, gây 140-180 sát thương pháo trong bán kính 82.5. CD: 13.5 giây.", "Bắn tên lửa vào kẻ địch mặt đất hoặc trên không gần lối thoát nhất, gây 180-220 sát thương pháo trong bán kính 82.5. CD: 13.5 giây." },
					levels_enhanced = { "Bắn tên lửa vào kẻ địch mặt đất hoặc trên không gần lối thoát nhất, gây 140-180 sát thương pháo trong bán kính 150. CD: 7 giây.", "Bắn tên lửa vào kẻ địch mặt đất hoặc trên không gần lối thoát nhất, gây 180-220 sát thương pháo trong bán kính 150. CD: 7 giây.", "Bắn tên lửa vào kẻ địch mặt đất hoặc trên không gần lối thoát nhất, gây 220-260 sát thương pháo trong bán kính 150. CD: 7 giây." },
					prices_standard = { "187", "75", "75" },
					prices_enhanced = { "187", "112", "112" }
				},
				{
					name = "Oanh tạc bom chùm",
					standard = "Bắn bom đặc biệt nổ trên không, thả 3 bom nhỏ phủ dọc một đường đi. Mỗi bom gây 60-80 sát thương pháo diện rộng trong bán kính 82.5; một kẻ địch có thể trúng nhiều bom. CD: 17.5 giây.",
					enhanced = "Bắn bom đặc biệt nổ trên không, thả 3 bom nhỏ phủ dọc một đường đi. Mỗi bom gây sát thương pháo diện rộng bằng 60-80 cộng một nửa sát thương đòn đánh thường (126-146), trong bán kính 82.5. Một kẻ địch có thể trúng nhiều bom. CD: 17.5 giây.",
					levels_standard = { "Bắn bom đặc biệt nổ trên không, thả 3 bom nhỏ phủ dọc một đường đi. Mỗi bom gây 60-80 sát thương pháo diện rộng trong bán kính 82.5; một kẻ địch có thể trúng nhiều bom. CD: 17.5 giây.", "Bắn bom đặc biệt nổ trên không, thả 5 bom nhỏ phủ dọc một đường đi. Mỗi bom gây 60-80 sát thương pháo diện rộng trong bán kính 82.5; một kẻ địch có thể trúng nhiều bom. CD: 17.5 giây.", "Bắn bom đặc biệt nổ trên không, thả 7 bom nhỏ phủ dọc một đường đi. Mỗi bom gây 60-80 sát thương pháo diện rộng trong bán kính 82.5; một kẻ địch có thể trúng nhiều bom. CD: 17.5 giây." },
					levels_enhanced = { "Bắn bom đặc biệt nổ trên không, thả 3 bom nhỏ phủ dọc một đường đi. Mỗi bom gây sát thương pháo diện rộng bằng 60-80 cộng một nửa sát thương đòn đánh thường (126-146), trong bán kính 82.5. Một kẻ địch có thể trúng nhiều bom. CD: 17.5 giây.", "Bắn bom đặc biệt nổ trên không, thả 5 bom nhỏ phủ dọc một đường đi. Mỗi bom gây sát thương pháo diện rộng bằng 60-80 cộng một nửa sát thương đòn đánh thường (126-146), trong bán kính 82.5. Một kẻ địch có thể trúng nhiều bom. CD: 17.5 giây.", "Bắn bom đặc biệt nổ trên không, thả 7 bom nhỏ phủ dọc một đường đi. Mỗi bom gây sát thương pháo diện rộng bằng 60-80 cộng một nửa sát thương đòn đánh thường (126-146), trong bán kính 82.5. Một kẻ địch có thể trúng nhiều bom. CD: 17.5 giây." },
					prices_standard = { "187", "112", "112" },
					prices_enhanced = { "187", "112", "112" }
				},
			}
		},
		["tower_tesla"] = {
			doc_id = "",
			title = "Tesla X104",
			attack = {
				standard = "Chủ động đánh được mục tiêu bay. Phóng điện mỗi 2.2 giây; điện lan sang kẻ địch khác trong bán kính 190, tối đa 3 mục tiêu.\nMỗi mục tiêu chịu sát thương điện, lấy bội số nguyên của 13 trong các khoảng 26-39 (26-52) (52-104). Nhiều Tesla không cộng dồn sát thương.\n※ Sát thương điện và pháo đều bỏ qua một nửa giáp; một số kẻ địch miễn nhiễm pháo nhưng vẫn chịu sát thương điện.",
				enhanced = "Chủ động đánh được mục tiêu bay. Phóng điện mỗi 2.2 giây; điện lan sang kẻ địch khác trong bán kính 250, tối đa 3 mục tiêu.\nMỗi mục tiêu chịu sát thương điện, lấy bội số nguyên của 15 trong các khoảng 30-45 (30-60) (60-120). Nhiều Tesla có thể cộng dồn sát thương.\n※ Sát thương điện và pháo đều bỏ qua một nửa giáp; một số kẻ địch miễn nhiễm pháo nhưng vẫn chịu sát thương điện."
			},
			change_note = "Nhận xét: Tesla bản Legacy.",
			port_note = "",
			notes = "Tháp phần 2",
			skills = {
				{
					name = "Sét liên hoàn",
					standard = "Cho phép Tesla đánh lan tới tối đa 4 mục tiêu.",
					enhanced = "Cho phép Tesla đánh lan tới tối đa 4 mục tiêu.",
					levels_standard = { "Cho phép Tesla đánh lan tới tối đa 4 mục tiêu.", "Cho phép Tesla đánh lan tới tối đa 5 mục tiêu." },
					levels_enhanced = { "Cho phép Tesla đánh lan tới tối đa 4 mục tiêu.", "Cho phép Tesla đánh lan tới tối đa 5 mục tiêu." },
					prices_standard = { "187", "187" },
					prices_enhanced = { "187", "187" }
				},
				{
					name = "Trường tĩnh điện",
					standard = "Sau mỗi đòn đánh, phóng tĩnh điện gây 10-20 sát thương điện lên tất cả kẻ địch trong bán kính 330.",
					enhanced = "Sau mỗi đòn đánh, phóng tĩnh điện gây 10-20 sát thương điện lên tất cả kẻ địch trong bán kính 363.",
					levels_standard = { "Sau mỗi đòn đánh, phóng tĩnh điện gây 10-20 sát thương điện lên tất cả kẻ địch trong bán kính 330.", "Sau mỗi đòn đánh, phóng tĩnh điện gây 20-30 sát thương điện lên tất cả kẻ địch trong bán kính 330.", "Sau mỗi đòn đánh, phóng tĩnh điện gây 30-40 sát thương điện lên tất cả kẻ địch trong bán kính 330." },
					levels_enhanced = { "Sau mỗi đòn đánh, phóng tĩnh điện gây 10-20 sát thương điện lên tất cả kẻ địch trong bán kính 363.", "Sau mỗi đòn đánh, phóng tĩnh điện gây 20-30 sát thương điện lên tất cả kẻ địch trong bán kính 363.", "Sau mỗi đòn đánh, phóng tĩnh điện gây 30-40 sát thương điện lên tất cả kẻ địch trong bán kính 363." },
					prices_standard = { "187", "93", "93" },
					prices_enhanced = { "187", "93", "93" }
				},
			}
		},
		["tower_totem"] = {
			doc_id = "",
			title = "Lính ném rìu bộ tộc",
			attack = {
				standard = "Ném rìu mỗi 0.8 giây, gây sát thương vật lý.",
				enhanced = "Ném rìu mỗi 0.8 giây, gây sát thương vật lý."
			},
			change_note = "Nhận xét: Tăng phạm vi tác dụng của vật tổ; một tháp thuần hỗ trợ chưa xứng đáng với mức giá cao như vậy. Vật tổ câm lặng cần duy trì hiệu ứng liên tục.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Vật tổ suy yếu",
					standard = "Triệu hồi vật tổ đỏ tồn tại 3 giây, giảm 50% sát thương cận chiến của kẻ địch trong bán kính 154 và tăng 40% sát thương chúng nhận. CD: 10 giây.",
					enhanced = "Triệu hồi vật tổ đỏ tồn tại 3 giây, giảm 50% sát thương cận chiến của kẻ địch trong bán kính 231 và tăng 65% sát thương chúng nhận. CD: 10 giây.",
					levels_standard = { "Triệu hồi vật tổ đỏ tồn tại 3 giây, giảm 50% sát thương cận chiến của kẻ địch trong bán kính 154 và tăng 40% sát thương chúng nhận. CD: 10 giây.", "Triệu hồi vật tổ đỏ tồn tại 6 giây, giảm 50% sát thương cận chiến của kẻ địch trong bán kính 154 và tăng 40% sát thương chúng nhận. CD: 10 giây.", "Triệu hồi vật tổ đỏ tồn tại 9 giây, giảm 50% sát thương cận chiến của kẻ địch trong bán kính 154 và tăng 40% sát thương chúng nhận. CD: 10 giây." },
					levels_enhanced = { "Triệu hồi vật tổ đỏ tồn tại 3 giây, giảm 50% sát thương cận chiến của kẻ địch trong bán kính 231 và tăng 75% sát thương chúng nhận. CD: 10 giây.", "Triệu hồi vật tổ đỏ tồn tại 6 giây, giảm 50% sát thương cận chiến của kẻ địch trong bán kính 231 và tăng 75% sát thương chúng nhận. CD: 10 giây.", "Triệu hồi vật tổ đỏ tồn tại 9 giây, giảm 50% sát thương cận chiến của kẻ địch trong bán kính 231 và tăng 75% sát thương chúng nhận. CD: 10 giây." },
					prices_standard = { "250", "200", "200" },
					prices_enhanced = { "225", "100", "100" }
				},
				{
					name = "Vật tổ câm lặng",
					standard = "Triệu hồi vật tổ tím, câm lặng kẻ địch trong bán kính 154 suốt 4 giây, ngăn chúng dùng năng lực phép. CD: 9 giây.",
					enhanced = "Triệu hồi vật tổ tím, câm lặng kẻ địch trong bán kính 231 suốt 5 giây, ngăn chúng dùng năng lực phép. CD: 9 giây.",
					levels_standard = { "Triệu hồi vật tổ tím, câm lặng kẻ địch trong bán kính 154 suốt 4 giây, ngăn chúng dùng năng lực phép. CD: 9 giây.", "Triệu hồi vật tổ tím, câm lặng kẻ địch trong bán kính 154 suốt 6 giây, ngăn chúng dùng năng lực phép. CD: 9 giây.", "Triệu hồi vật tổ tím, câm lặng kẻ địch trong bán kính 154 suốt 8 giây, ngăn chúng dùng năng lực phép. CD: 9 giây." },
					levels_enhanced = { "Triệu hồi vật tổ tím, câm lặng kẻ địch trong bán kính 231 suốt 5 giây, ngăn chúng dùng năng lực phép. CD: 9 giây.", "Triệu hồi vật tổ tím, câm lặng kẻ địch trong bán kính 231 suốt 9 giây, ngăn chúng dùng năng lực phép. CD: 9 giây.", "Triệu hồi vật tổ tím, câm lặng kẻ địch trong bán kính 231 suốt 13 giây, ngăn chúng dùng năng lực phép. CD: 9 giây." },
					prices_standard = { "150", "150", "150" },
					prices_enhanced = { "120", "70", "70" }
				},
			}
		},
		["tower_crossbow"] = {
			doc_id = "",
			title = "Pháo đài lính nỏ",
			attack = {
				standard = "Bắn 1 mũi tên mỗi 0.5 giây, gây sát thương vật lý.",
				enhanced = "Bắn 1 mũi tên mỗi 0.5 giây, gây sát thương vật lý."
			},
			change_note = "Nhận xét: Tháp cung thuần sát thương. Cải thiện hiệu quả nâng Liên xạ cấp 2/3. Mắt đại bàng nên giúp săn mục tiêu bay hiệu quả hơn.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Liên xạ",
					standard = "Bắn liên tiếp 6 mũi tên trong 1.0 giây, mỗi mũi gây 30-40 sát thương vật lý, tổng cộng 180-240. CD: 6 giây.",
					enhanced = "Bắn liên tiếp 14 mũi tên trong 1.8 giây, mỗi mũi gây 30-40 sát thương. Khi bắn cùng một mục tiêu, mũi sau gây thêm 8% sát thương so với mũi trước. CD: 6.8 giây.",
					levels_standard = { "Bắn liên tiếp 6 mũi tên trong 1.0 giây, mỗi mũi gây 30-40 sát thương vật lý, tổng cộng 180-240. CD: 6 giây.", "Bắn liên tiếp 8 mũi tên trong 1.4 giây, mỗi mũi gây 30-40 sát thương vật lý, tổng cộng 240-320. CD: 6 giây.", "Bắn liên tiếp 10 mũi tên trong 1.8 giây, mỗi mũi gây 30-40 sát thương vật lý, tổng cộng 300-400. CD: 6 giây." },
					levels_enhanced = { "Bắn liên tiếp 6 mũi tên trong 1.0 giây, mỗi mũi gây 30-40 sát thương. Khi bắn cùng một mục tiêu, mũi sau gây thêm 8% sát thương so với mũi trước. CD: 6 giây.", "Bắn liên tiếp 10 mũi tên trong 1.4 giây, mỗi mũi gây 30-40 sát thương. Khi bắn cùng một mục tiêu, mũi sau gây thêm 8% sát thương so với mũi trước. CD: 6.4 giây.", "Bắn liên tiếp 14 mũi tên trong 1.8 giây, mỗi mũi gây 30-40 sát thương. Khi bắn cùng một mục tiêu, mũi sau gây thêm 8% sát thương so với mũi trước. CD: 6.8 giây." },
					prices_standard = { "250", "150", "150" },
					prices_enhanced = { "250", "150", "150" }
				},
				{
					name = "Mắt đại bàng",
					standard = "Tăng 10% tầm đánh cho bản thân và các tháp khác trong bán kính 320.\nĐòn đánh thường có 10% cơ hội chí mạng, gây 200% sát thương của đòn đó.",
					enhanced = "Tăng 10% tầm đánh cho bản thân và các tháp khác trong bán kính 320.\nĐòn đánh thường có 40% cơ hội chí mạng, gây 200% sát thương của đòn đó.",
					levels_standard = { "Tăng 10% tầm đánh cho bản thân và các tháp khác trong bán kính 320.\nĐòn đánh thường có 10% cơ hội chí mạng, gây 200% sát thương của đòn đó.", "Tăng 15% tầm đánh cho bản thân và các tháp khác trong bán kính 384.\nĐòn đánh thường có 15% cơ hội chí mạng, gây 200% sát thương của đòn đó.", "Tăng 20% tầm đánh cho bản thân và các tháp khác trong bán kính 448.\nĐòn đánh thường có 20% cơ hội chí mạng, gây 200% sát thương của đòn đó." },
					levels_enhanced = { "Đòn đánh thường và Liên xạ có 30% cơ hội chí mạng. Tạo vùng Mắt đại bàng bán kính 420: tháp đồng minh trong vùng tăng 10% tầm đánh, còn kẻ địch bay nhận thêm 20% sát thương.", "Đòn đánh thường và Liên xạ có 50% cơ hội chí mạng. Tạo vùng Mắt đại bàng bán kính 490: tháp đồng minh trong vùng tăng 15% tầm đánh, còn kẻ địch bay nhận thêm 50% sát thương.", "Đòn đánh thường và Liên xạ có 70% cơ hội chí mạng. Tạo vùng Mắt đại bàng bán kính 560: tháp đồng minh trong vùng tăng 20% tầm đánh, còn kẻ địch bay nhận thêm 80% sát thương." },
					prices_standard = { "200", "200", "200" },
					prices_enhanced = { "250", "200", "200" }
				},
			}
		},
		["tower_assassin"] = {
			doc_id = "",
			title = "Hội sát thủ",
			attack = {
				standard = "Tấn công cận chiến, gây sát thương vật lý. Có 40% cơ hội né đòn.",
				enhanced = "Tấn công cận chiến, gây sát thương vật lý. Có 40% cơ hội né đòn."
			},
			change_note = "Nhận xét: Cải thiện các chỉ số của sát thủ trên nhiều mặt.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Đánh lén",
					standard = "Mỗi đòn đánh có 10% cơ hội đánh lén gây 20-40 sát thương vật lý; đồng thời có 3% cơ hội đánh lén tiêu diệt ngay mục tiêu.",
					enhanced = "Mỗi đòn đánh có 10% cơ hội đánh lén gây 20-40 sát thương vật lý; đồng thời có 3% cơ hội đánh lén tiêu diệt ngay mục tiêu.",
					levels_standard = { "Mỗi đòn đánh có 10% cơ hội đánh lén gây 20-40 sát thương vật lý; đồng thời có 3% cơ hội đánh lén tiêu diệt ngay mục tiêu.", "Mỗi đòn đánh có 15% cơ hội đánh lén gây 30-50 sát thương vật lý; đồng thời có 4% cơ hội đánh lén tiêu diệt ngay mục tiêu.", "Mỗi đòn đánh có 20% cơ hội đánh lén gây 40-60 sát thương vật lý; đồng thời có 5% cơ hội đánh lén tiêu diệt ngay mục tiêu." },
					levels_enhanced = { "Mỗi đòn đánh có 10% cơ hội đánh lén gây 20-40 sát thương vật lý; đồng thời có 3% cơ hội đánh lén tiêu diệt ngay mục tiêu.", "Mỗi đòn đánh có 15% cơ hội đánh lén gây 30-50 sát thương vật lý; đồng thời có 5% cơ hội đánh lén tiêu diệt ngay mục tiêu.", "Mỗi đòn đánh có 20% cơ hội đánh lén gây 40-60 sát thương vật lý; đồng thời có 7% cơ hội đánh lén tiêu diệt ngay mục tiêu." },
					prices_standard = { "225", "150", "150" },
					prices_enhanced = { "225", "150", "150" }
				},
				{
					name = "Né đòn phản kích",
					standard = "Tăng cơ hội né đòn lên 50%; phản kích gây 20-24 sát thương vật lý.",
					enhanced = "Tăng cơ hội né đòn lên 50%; phản kích gây 20-24 sát thương vật lý.",
					levels_standard = { "Tăng cơ hội né đòn lên 50%; phản kích gây 20-24 sát thương vật lý.", "Tăng cơ hội né đòn lên 60%; phản kích gây 30-34 sát thương vật lý.", "Tăng cơ hội né đòn lên 70%; phản kích gây 40-44 sát thương vật lý." },
					levels_enhanced = { "Tăng cơ hội né đòn lên 50%; phản kích gây 20-24 sát thương vật lý.", "Tăng cơ hội né đòn lên 60%; phản kích gây 30-34 sát thương vật lý.", "Tăng cơ hội né đòn lên 70%; phản kích gây 40-44 sát thương vật lý." },
					prices_standard = { "150", "100", "100" },
					prices_enhanced = { "150", "100", "100" }
				},
				{
					name = "Móc túi",
					standard = "Mỗi đòn đánh có 20% cơ hội lấy 1-3 vàng từ mục tiêu. Mỗi kẻ địch bị lấy tối đa 30% tiền thưởng của nó.",
					enhanced = "Mỗi đòn đánh có 30% cơ hội lấy 1-6 vàng từ mục tiêu. Mỗi kẻ địch bị lấy tối đa 30% tiền thưởng của nó.",
					levels_standard = { "Mỗi đòn đánh có 20% cơ hội lấy 1-3 vàng từ mục tiêu. Mỗi kẻ địch bị lấy tối đa 30% tiền thưởng của nó.", "Mỗi đòn đánh có 30% cơ hội lấy 1-3 vàng từ mục tiêu. Mỗi kẻ địch bị lấy tối đa 30% tiền thưởng của nó." },
					levels_enhanced = { "Mỗi đòn đánh có 30% cơ hội lấy 1-6 vàng từ mục tiêu. Mỗi kẻ địch bị lấy tối đa 30% tiền thưởng của nó.", "Mỗi đòn đánh có 60% cơ hội lấy 1-6 vàng từ mục tiêu. Mỗi kẻ địch bị lấy tối đa 30% tiền thưởng của nó." },
					prices_standard = { "100", "100" },
					prices_enhanced = { "100", "100" }
				},
			}
		},
		["tower_templar"] = {
			doc_id = "",
			title = "Hiệp sĩ Đền thánh",
			attack = {
				standard = "Tấn công cận chiến, gây sát thương vật lý.",
				enhanced = "Tấn công cận chiến, gây sát thương vật lý."
			},
			change_note = "Nhận xét: Chuyển sang doanh trại chống chịu không giáp, tăng khả năng chống sát thương chuẩn. Doanh trại chỉ dựa vào chỉ số để đỡ đòn chưa xứng đáng với mức giá; tăng tính may rủi của Chén thánh.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Bền bỉ",
					standard = "Tăng 50 máu tối đa cho Hiệp sĩ Đền thánh.",
					enhanced = "Tăng 110 máu tối đa cho Hiệp sĩ Đền thánh.",
					levels_standard = { "Tăng 50 máu tối đa cho Hiệp sĩ Đền thánh.", "Tăng 100 máu tối đa cho Hiệp sĩ Đền thánh.", "Tăng 150 máu tối đa cho Hiệp sĩ Đền thánh." },
					levels_enhanced = { "Tăng 110 máu tối đa cho Hiệp sĩ Đền thánh.", "Tăng 220 máu tối đa cho Hiệp sĩ Đền thánh.", "Tăng 330 máu tối đa cho Hiệp sĩ Đền thánh." },
					prices_standard = { "200", "200", "200" },
					prices_enhanced = { "75", "75", "75" }
				},
				{
					name = "Chém động mạch",
					standard = "Mỗi đòn đánh có 10% cơ hội gây chảy máu trong 3 giây, gây 25 sát thương chuẩn mỗi giây, tổng cộng 75.",
					enhanced = "Mỗi đòn đánh có 50% cơ hội gây chảy máu trong 3 giây, gây 25 sát thương chuẩn mỗi giây, tổng cộng 75.",
					levels_standard = { "Mỗi đòn đánh có 10% cơ hội gây chảy máu trong 3 giây, gây 25 sát thương chuẩn mỗi giây, tổng cộng 75.", "Mỗi đòn đánh có 10% cơ hội gây chảy máu trong 3 giây, gây 40 sát thương chuẩn mỗi giây, tổng cộng 120.", "Mỗi đòn đánh có 10% cơ hội gây chảy máu trong 3 giây, gây 55 sát thương chuẩn mỗi giây, tổng cộng 165." },
					levels_enhanced = { "Mỗi đòn đánh có 50% cơ hội gây chảy máu trong 3 giây, gây 25 sát thương chuẩn mỗi giây.", "Mỗi đòn đánh có 50% cơ hội tung chuỗi kiếm Chém động mạch - Đòn nặng - Trung hòa. Gây chảy máu, dễ tổn thương và suy yếu trong 3 giây: chịu 40 sát thương chuẩn mỗi giây, nhận thêm 50% sát thương và giảm 25% sát thương gây ra.", "Mỗi đòn đánh có 50% cơ hội tung chuỗi kiếm Chém động mạch - Phá kích - Áp chế. Gây chảy máu trong 3 giây và dễ tổn thương/suy yếu được ếch giấy hoặc hạc giấy tăng cường trong 6 giây: chịu 55 sát thương chuẩn mỗi giây, nhận thêm 75% sát thương và giảm 40% sát thương gây ra." },
					prices_standard = { "250", "150", "150" },
					prices_enhanced = { "250", "150", "150" }
				},
				{
					name = "Chén thánh",
					standard = "Khi nhận đòn chí tử, có 20% cơ hội hồi sinh ngay tại chỗ với 20% máu tối đa.",
					enhanced = "Khi nhận đòn chí tử, có 20% cơ hội hồi sinh ngay tại chỗ với 30% máu tối đa.",
					levels_standard = { "Khi nhận đòn chí tử, có 20% cơ hội hồi sinh ngay tại chỗ với 20% máu tối đa.", "Khi nhận đòn chí tử, có 30% cơ hội hồi sinh ngay tại chỗ với 30% máu tối đa.", "Khi nhận đòn chí tử, có 40% cơ hội hồi sinh ngay tại chỗ với 40% máu tối đa." },
					levels_enhanced = { "Khi nhận đòn chí tử, có 20% cơ hội hồi sinh ngay tại chỗ với 30% máu tối đa.", "Khi nhận đòn chí tử, có 40% cơ hội hồi sinh ngay tại chỗ với 55% máu tối đa.", "Khi nhận đòn chí tử, có 60% cơ hội hồi sinh ngay tại chỗ với 80% máu tối đa." },
					prices_standard = { "250", "150", "150" },
					prices_enhanced = { "250", "150", "150" }
				},
			}
		},
		["tower_necromancer"] = {
			doc_id = "",
			title = "Pháp sư chiêu hồn",
			attack = {
				standard = "Bắn đạn phép mỗi 1 giây. Kẻ địch chết gần tháp tạo bộ xương nhỏ nếu máu dưới 500, hoặc bộ xương lớn nếu máu trên 500. Tối đa 8 bộ xương mỗi tháp và 30 trên toàn bản đồ.",
				enhanced = "Bắn đạn phép mỗi 1 giây. Kẻ địch chết gần tháp tạo bộ xương nhỏ nếu máu dưới 500, hoặc bộ xương lớn nếu máu trên 500. Tối đa 8 bộ xương mỗi tháp và 30 trên toàn bản đồ."
			},
			change_note = "Nhận xét: Tháp phép có khả năng chặn đường. Cải thiện hiệu quả nâng Mây dịch bệnh và Kỵ sĩ xác sống cấp 23.",
			port_note = "Thay đổi khi chuyển sang mod: Kỵ sĩ xác sống có thể tăng cường cả đồng đội dạng bộ xương của phần 5.",
			notes = "",
			skills = {
				{
					name = "Kỵ sĩ xác sống",
					standard = "Triệu hồi Kỵ sĩ xác sống. Tăng 30 giáp cho Vua Cát và đồng đội dạng bộ xương gần đó: bộ xương của pháp sư chiêu hồn phần 2, phần 5, và rồng xương phần 2/5.",
					enhanced = "Triệu hồi Kỵ sĩ xác sống. Tăng 30 giáp cho Vua Cát và đồng đội dạng bộ xương gần đó: bộ xương của pháp sư chiêu hồn phần 2, phần 5, và rồng xương phần 2/5.",
					levels_standard = { "Triệu hồi Kỵ sĩ xác sống. Tăng 30 giáp cho Vua Cát và đồng đội dạng bộ xương gần đó: bộ xương của pháp sư chiêu hồn phần 2, phần 5, và rồng xương phần 2/5.", "Triệu hồi Kỵ sĩ xác sống. Tăng 30 giáp cho Vua Cát và đồng đội dạng bộ xương gần đó: bộ xương của pháp sư chiêu hồn phần 2, phần 5, và rồng xương phần 2/5.", "Triệu hồi Kỵ sĩ xác sống. Tăng 30 giáp cho Vua Cát và đồng đội dạng bộ xương gần đó: bộ xương của pháp sư chiêu hồn phần 2, phần 5, và rồng xương phần 2/5." },
					levels_enhanced = { "Triệu hồi Kỵ sĩ xác sống. Tăng 30 giáp cho Vua Cát và đồng đội dạng bộ xương gần đó: bộ xương của pháp sư chiêu hồn phần 2, phần 5, và rồng xương phần 2/5.", "Triệu hồi Kỵ sĩ xác sống. Tăng 30 giáp cho Vua Cát và đồng đội dạng bộ xương gần đó: bộ xương của pháp sư chiêu hồn phần 2, phần 5, và rồng xương phần 2/5.", "Triệu hồi Kỵ sĩ xác sống. Tăng 30 giáp cho Vua Cát và đồng đội dạng bộ xương gần đó: bộ xương của pháp sư chiêu hồn phần 2, phần 5, và rồng xương phần 2/5." },
					prices_standard = { "270", "135", "135" },
					prices_enhanced = { "270", "90", "90" }
				},
				{
					name = "Dịch bệnh",
					standard = "Tạo 1 đám mây độc tồn tại 4 giây. Mỗi đám gây độc cho kẻ địch trong bán kính 93, gây 20 sát thương chuẩn mỗi giây. Sát thương không cộng dồn; độc hết ngay khi mục tiêu rời vùng mây.",
					enhanced = "Tạo 1 đám mây độc tồn tại 4 giây. Mỗi đám gây độc cho kẻ địch trong bán kính 93, gây 50 sát thương chuẩn mỗi giây. Sát thương không cộng dồn; độc hết ngay khi mục tiêu rời vùng mây.",
					levels_standard = { "Tạo 1 đám mây độc tồn tại 4 giây. Mỗi đám gây độc cho kẻ địch trong bán kính 93, gây 20 sát thương chuẩn mỗi giây. Sát thương không cộng dồn; độc hết ngay khi mục tiêu rời vùng mây. CD: 12 giây.", "Tạo 2 đám mây độc tồn tại 5 giây. Mỗi đám gây độc cho kẻ địch trong bán kính 93, gây 20 sát thương chuẩn mỗi giây. Sát thương không cộng dồn; độc hết ngay khi mục tiêu rời vùng mây. CD: 12 giây.", "Tạo 3 đám mây độc tồn tại 6 giây. Mỗi đám gây độc cho kẻ địch trong bán kính 93, gây 20 sát thương chuẩn mỗi giây. Sát thương không cộng dồn; độc hết ngay khi mục tiêu rời vùng mây. CD: 12 giây." },
					levels_enhanced = { "Tạo 1 đám mây độc tồn tại 4 giây. Mỗi đám gây độc cho kẻ địch trong bán kính 93, gây 50 sát thương chuẩn mỗi giây. Sát thương không cộng dồn; độc hết ngay khi mục tiêu rời vùng mây. CD: 9 giây.", "Tạo 2 đám mây độc tồn tại 5 giây. Mỗi đám gây độc cho kẻ địch trong bán kính 93, gây 50 sát thương chuẩn mỗi giây. Sát thương không cộng dồn; độc hết ngay khi mục tiêu rời vùng mây. CD: 9 giây.", "Tạo 3 đám mây độc tồn tại 6 giây. Mỗi đám gây độc cho kẻ địch trong bán kính 93, gây 50 sát thương chuẩn mỗi giây. Sát thương không cộng dồn; độc hết ngay khi mục tiêu rời vùng mây. CD: 9 giây." },
					prices_standard = { "292", "180", "180" },
					prices_enhanced = { "225", "117", "117" }
				},
			}
		},
		["tower_archmage"] = {
			doc_id = "",
			title = "Đại pháp sư",
			attack = {
				standard = "Bắn đạn phép mỗi 1.5 giây. Khi không có kẻ địch, tích trữ tối đa 3 đạn.",
				enhanced = "Bắn đạn phép mỗi 1.5 giây. Khi không có kẻ địch, tích trữ tối đa 3 đạn."
			},
			change_note = "Nhận xét: Tháp phép có sát thương diện rộng ổn định, cần cân nhắc khi tăng sức mạnh nên giá kỹ năng 2 được tăng đáng kể. Chỉ vụ nổ xuyên kháng phép; sát thương đơn mục tiêu của đòn đánh thường không có hiệu ứng này.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Lốc xoáy",
					standard = "Triệu hồi lốc xoáy đi về điểm xuất hiện quái với tốc độ 46, cuốn tối đa 5 kẻ địch trong bán kính 64. Tồn tại 5 giây, đẩy chúng lùi tối đa 200 khoảng cách và gây 40 sát thương phép. CD: 22.5 giây. Mỗi kẻ địch bị dịch chuyển tối đa 3 lần.",
					enhanced = "Triệu hồi lốc xoáy đi về điểm xuất hiện quái với tốc độ 46, cuốn tối đa 5 kẻ địch trong bán kính 64. Tồn tại 5 giây, đẩy chúng lùi tối đa 200 khoảng cách và gây 200 sát thương phép. CD: 22.5 giây. Mỗi kẻ địch bị dịch chuyển tối đa 3 lần.",
					levels_standard = { "Triệu hồi lốc xoáy đi về điểm xuất hiện quái với tốc độ 46, cuốn tối đa 5 kẻ địch trong bán kính 64. Tồn tại 5 giây, đẩy chúng lùi tối đa 200 khoảng cách và gây 40 sát thương phép. CD: 22.5 giây. Mỗi kẻ địch bị dịch chuyển tối đa 3 lần.", "Triệu hồi lốc xoáy đi về điểm xuất hiện quái với tốc độ 46, cuốn tối đa 6 kẻ địch trong bán kính 64. Tồn tại 6.25 giây, đẩy chúng lùi tối đa 250 khoảng cách và gây 60 sát thương phép. CD: 22.5 giây. Mỗi kẻ địch bị dịch chuyển tối đa 3 lần.", "Triệu hồi lốc xoáy đi về điểm xuất hiện quái với tốc độ 46, cuốn tối đa 7 kẻ địch trong bán kính 64. Tồn tại 7.5 giây, đẩy chúng lùi tối đa 300 khoảng cách và gây 80 sát thương phép. CD: 22.5 giây. Mỗi kẻ địch bị dịch chuyển tối đa 3 lần." },
					levels_enhanced = { "Triệu hồi lốc xoáy đi về điểm xuất hiện quái với tốc độ 46, cuốn tối đa 5 kẻ địch trong bán kính 64. Tồn tại 5 giây, đẩy chúng lùi tối đa 200 khoảng cách và gây 220 sát thương phép. CD: 22.5 giây. Mỗi kẻ địch bị dịch chuyển tối đa 3 lần.", "Triệu hồi lốc xoáy đi về điểm xuất hiện quái với tốc độ 46, cuốn tối đa 6 kẻ địch trong bán kính 64. Tồn tại 6.25 giây, đẩy chúng lùi tối đa 250 khoảng cách và gây 310 sát thương phép. CD: 22.5 giây. Mỗi kẻ địch bị dịch chuyển tối đa 3 lần.", "Triệu hồi lốc xoáy đi về điểm xuất hiện quái với tốc độ 46, cuốn tối đa 7 kẻ địch trong bán kính 64. Tồn tại 7.5 giây, đẩy chúng lùi tối đa 300 khoảng cách và gây 400 sát thương phép. CD: 22.5 giây. Mỗi kẻ địch bị dịch chuyển tối đa 3 lần." },
					prices_standard = { "315", "225", "225" },
					prices_enhanced = { "315", "225", "225" }
				},
				{
					name = "Bùng nổ năng lượng",
					standard = "Sau mỗi đòn đánh thường, có 35% cơ hội gây vụ nổ, gây 30 sát thương phép diện rộng trong bán kính 83.",
					enhanced = "Sau mỗi đòn đánh thường, có 100% cơ hội gây vụ nổ, gây 30 sát thương phép diện rộng trong bán kính 120 và bỏ qua 50% kháng phép.",
					levels_standard = { "Sau mỗi đòn đánh thường, có 35% cơ hội gây vụ nổ, gây 30 sát thương phép diện rộng trong bán kính 83.", "Sau mỗi đòn đánh thường, có 35% cơ hội gây vụ nổ, gây 60 sát thương phép diện rộng trong bán kính 90.", "Sau mỗi đòn đánh thường, có 35% cơ hội gây vụ nổ, gây 90 sát thương phép diện rộng trong bán kính 96." },
					levels_enhanced = { "Sau mỗi đòn đánh thường, có 100% cơ hội gây vụ nổ, gây 30 sát thương phép trong bán kính 110 và bỏ qua 40% kháng phép.", "Sau mỗi đòn đánh thường, có 100% cơ hội gây vụ nổ, gây 60 sát thương phép trong bán kính 120 và bỏ qua 40% kháng phép.", "Sau mỗi đòn đánh thường, có 100% cơ hội gây vụ nổ, gây 90 sát thương phép trong bán kính 130 và bỏ qua 40% kháng phép." },
					prices_standard = { "180", "180", "180" },
					prices_enhanced = { "315", "315", "315" }
				},
			}
		},
		["tower_dwaarp"] = {
			doc_id = "",
			title = "Dàn khoan chiến đấu",
			attack = {
				standard = "Đập xuống đất mỗi 3 giây, gây sát thương cho tất cả kẻ địch trong tầm và làm chậm 60% trong 0.4 giây.",
				enhanced = "Đập xuống đất mỗi 3 giây, gây sát thương cho tất cả kẻ địch trong tầm và làm chậm 60% trong 1.67 giây. Hiệu ứng cộng dồn với làm chậm từ kỹ năng 2; khi kết hợp kỹ năng 2 tối đa, đòn đánh thường và nâng cấp làm choáng, tạo chu kỳ 12 giây với mức làm chậm 51%."
			},
			change_note = "Nhận xét: Giải quyết tình trạng sát thương bùng nổ kém pháo thường, còn đòn đánh vòng tròn bị Rừng mục rữa/Tesla/Lò nung đa dụng hơn thay thế. Tính đủ nâng cấp, mức làm chậm trung bình của tháp chưa mua kỹ năng là 40%. Hiệu quả sát thương và làm chậm hơi kém Rừng mục rữa nhưng gây sát thương pháo. Rừng mục rữa dùng được ở cấp 1 và hoàn thiện ở cấp 3; Dàn khoan có tầm đánh và tiềm năng nâng cấp lớn hơn.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Mũi khoan lõi đá",
					standard = "Tiêu diệt ngay một kẻ địch, không chiếm thời gian đánh thường. CD: 26 (23.4) giây.",
					enhanced = "Tiêu diệt ngay một kẻ địch, không chiếm thời gian đánh thường. CD: 26 (23.4) giây. Ưu tiên mục tiêu có máu tối đa >= 800.",
					levels_standard = { "Tiêu diệt ngay một kẻ địch, không chiếm thời gian đánh thường. CD: 26 (23.4) giây.", "Tiêu diệt ngay một kẻ địch, không chiếm thời gian đánh thường. CD: 23 (20.7) giây.", "Tiêu diệt ngay một kẻ địch, không chiếm thời gian đánh thường. CD: 20 (18.0) giây." },
					levels_enhanced = { "Tiêu diệt ngay một kẻ địch, không chiếm thời gian đánh thường. CD: 26 (23.4) giây. Ưu tiên mục tiêu có máu tối đa >= 800.", "Tiêu diệt ngay một kẻ địch, không chiếm thời gian đánh thường. CD: 23 (20.7) giây. Ưu tiên mục tiêu có máu tối đa >= 800.", "Tiêu diệt ngay một kẻ địch, không chiếm thời gian đánh thường. CD: 20 (18.0) giây. Ưu tiên mục tiêu có máu tối đa >= 800." },
					prices_standard = { "400", "200", "200" },
					prices_enhanced = { "400", "80", "80" }
				},
				{
					name = "Nổ lò hơi",
					standard = "Sau đòn đánh thường, đốt vùng đất bán kính 345 trong 3 giây. Kẻ địch đi qua bị cháy 2 giây, chịu 4 sát thương chuẩn mỗi 0.2 giây, tối đa 100 sát thương chuẩn. CD: 15 giây.",
					enhanced = "Sau đòn đánh thường, đốt vùng đất bán kính 394 trong 3 giây. Kẻ địch đi qua bị cháy 2 giây, chịu 4 sát thương chuẩn mỗi 0.2 giây và bị làm chậm, tối đa 125 sát thương chuẩn. CD: 12 giây.",
					levels_standard = { "Sau đòn đánh thường, đốt vùng đất bán kính 345 trong 3 giây. Kẻ địch đi qua bị cháy 2 giây, chịu 4 sát thương chuẩn mỗi 0.2 giây, tối đa 100 sát thương chuẩn. CD: 15 giây.", "Sau đòn đánh thường, đốt vùng đất bán kính 345 trong 3 giây. Kẻ địch đi qua bị cháy 2 giây, chịu 7 sát thương chuẩn mỗi 0.2 giây, tối đa 175 sát thương chuẩn. CD: 15 giây.", "Sau đòn đánh thường, đốt vùng đất bán kính 345 trong 3 giây. Kẻ địch đi qua bị cháy 2 giây, chịu 10 sát thương chuẩn mỗi 0.2 giây, tối đa 250 sát thương chuẩn. CD: 15 giây." },
					levels_enhanced = { "Sau đòn đánh thường, đốt vùng đất bán kính 394 trong 3 giây. Kẻ địch đi qua bị cháy 2 giây, giảm 20% tốc độ và chịu 5 sát thương chuẩn mỗi 0.2 giây. CD: 12 giây.", "Sau đòn đánh thường, đốt vùng đất bán kính 394 trong 3 giây. Kẻ địch đi qua bị cháy 2 giây, giảm 30% tốc độ và chịu 8 sát thương chuẩn mỗi 0.2 giây. CD: 12 giây.", "Sau đòn đánh thường, đốt vùng đất bán kính 394 trong 3 giây. Kẻ địch đi qua bị cháy 2 giây, giảm 40% tốc độ và chịu 11 sát thương chuẩn mỗi 0.2 giây. CD: 12 giây." },
					prices_standard = { "300", "250", "250" },
					prices_enhanced = { "380", "280", "280" }
				},
			}
		},
		["tower_mech"] = {
			doc_id = "",
			title = "Cỗ máy chiến đấu T200",
			attack = {
				standard = "Ném một đạn pháo mỗi giây, gây sát thương trong bán kính 115.2. Có thể tập kết trong phạm vi 350.",
				enhanced = "Ném một đạn pháo mỗi giây, gây sát thương trong bán kính 128. Có thể tập kết trong phạm vi 350."
			},
			change_note = "Nhận xét: Tăng độ ổn định sát thương và hiệu quả khi mật độ quái gấp 3 lần. Trong thực chiến chưa chắc đủ tiền nâng tên lửa cấp 3 lên tối đa.",
			port_note = "Hoạt ảnh rò dầu có 37 khung hình và đã được tính vào thời gian hồi; thời gian hồi thực là 10 (9) giây. Con số 11.4 (10.4) được chia sẻ trên mạng còn tính việc hoạt ảnh bị ngắt. 5.4 giây của tên lửa là khoảng cách giữa các lần bắn, không phải thời gian hồi; tính cả hoạt ảnh thì hồi 7.3 giây. Nếu cỗ máy di chuyển mỗi 5 giây và tính độ trễ hoạt ảnh, mức làm chậm trung bình là 34.5% khi chưa mua kỹ năng, 75.6% khi tối đa 2 và 78.4% khi tối đa 12.",
			notes = "",
			skills = {
				{
					name = "Tên lửa Wasp",
					standard = "Chủ động đánh được mục tiêu bay. Bắn 2 tên lửa gây 20-80 sát thương pháo trong bán kính 115; tầm bắn 448. Khoảng cách giữa hai lần bắn: 6 (5.4) giây.",
					enhanced = "Chủ động đánh được mục tiêu bay. Bắn 2 tên lửa gây 20-80 sát thương pháo trong bán kính 115; tầm bắn 448. Khoảng cách giữa hai lần bắn: 6 (5.4) giây.",
					levels_standard = { "Bắn 2 tên lửa gây 20-80 sát thương pháo trong bán kính 115; tầm bắn 448. Khoảng cách giữa hai lần bắn: 6 (5.4) giây.", "Bắn 4 tên lửa gây 20-80 sát thương pháo trong bán kính 115; tầm bắn 448. Khoảng cách giữa hai lần bắn: 6 (5.4) giây.", "Bắn 6 tên lửa gây 20-80 sát thương pháo trong bán kính 115; tầm bắn 448. Khoảng cách giữa hai lần bắn: 6 (5.4) giây. Khi bật tăng cường, hiệu ứng chỉ có từ cấp 3." },
					levels_enhanced = { "Bắn 2 tên lửa gây 20-80 sát thương pháo trong bán kính 115; tầm bắn 448. Khoảng cách giữa hai lần bắn: 6 (5.4) giây.", "Bắn 4 tên lửa gây 20-80 sát thương pháo trong bán kính 115; tầm bắn 448. Khoảng cách giữa hai lần bắn: 6 (5.4) giây.", "Bắn 8 tên lửa gây 20-80 sát thương pháo trong bán kính 115; tầm bắn 448. Khoảng cách giữa hai lần bắn: 6 (5.4) giây." },
					prices_standard = { "300", "250" },
					prices_enhanced = { "250", "250", "250" }
				},
				{
					name = "Xả dầu thải",
					standard = "Khi có kẻ địch trong bán kính 115, cỗ máy đổ dầu dưới chân, giảm 75% tốc độ của kẻ địch trong bán kính 102.4. Hết làm chậm khi rời vùng dầu. Dầu tồn tại 4 giây. CD: 10 (9) giây.",
					enhanced = "Khi có kẻ địch trong bán kính 115, cỗ máy đổ dầu dưới chân, giảm 75% tốc độ của kẻ địch trong bán kính 102.4. Hết làm chậm khi rời vùng dầu. Dầu tồn tại 4 giây. CD: 10 (9) giây.",
					levels_standard = { "Khi có kẻ địch trong bán kính 115, cỗ máy đổ dầu dưới chân, giảm 75% tốc độ của kẻ địch trong bán kính 102.4. Hết làm chậm khi rời vùng dầu. Dầu tồn tại 4 giây. CD: 10 (9) giây.", "Khi có kẻ địch trong bán kính 115, cỗ máy đổ dầu dưới chân, giảm 75% tốc độ của kẻ địch trong bán kính 102.4. Hết làm chậm khi rời vùng dầu. Dầu tồn tại 6 giây. CD: 10 (9) giây.", "Khi có kẻ địch trong bán kính 115, cỗ máy đổ dầu dưới chân, giảm 75% tốc độ của kẻ địch trong bán kính 102.4. Hết làm chậm khi rời vùng dầu. Dầu tồn tại 8 giây. CD: 10 (9) giây." },
					levels_enhanced = { "Khi có kẻ địch trong bán kính 115, cỗ máy đổ dầu dưới chân, giảm 75% tốc độ của kẻ địch trong bán kính 102.4. Hết làm chậm khi rời vùng dầu. Dầu tồn tại 4 giây. CD: 10 (9) giây.", "Khi có kẻ địch trong bán kính 115, cỗ máy đổ dầu dưới chân, giảm 75% tốc độ của kẻ địch trong bán kính 128. Hết làm chậm khi rời vùng dầu. Dầu tồn tại 6 giây. CD: 10 (9) giây.", "Khi có kẻ địch trong bán kính 115, cỗ máy đổ dầu dưới chân, giảm 75% tốc độ của kẻ địch trong bán kính 128. Hết làm chậm khi rời vùng dầu. Dầu tồn tại 8 giây. CD: 10 (9) giây." },
					prices_standard = { "250", "200", "200" },
					prices_enhanced = { "250", "200", "200" }
				},
			}
		},
		["tower_arcane"] = {
			doc_id = "",
			title = "Cung thủ bí thuật",
			attack = {
				standard = "Bắn 2 mũi tên mỗi 0.8 giây, gây sát thương vật lý và giảm 3 kháng phép của mục tiêu với mỗi mũi. Chỉ số hiển thị là tổng sát thương của 2 mũi.",
				enhanced = "Bắn 2 mũi tên mỗi 0.8 giây, gây sát thương vật lý và giảm 10 kháng phép của mục tiêu với mỗi mũi. Chỉ số hiển thị là tổng sát thương của 2 mũi."
			},
			change_note = "Nhận xét: Sát thương đánh thường đã đủ. Tương tự khả năng phá giáp của pháp sư vàng phần 1, tháp được tăng khả năng giảm kháng phép.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Mũi tên nổ",
					standard = "Bắn mũi tên phép nổ, gây 80 (88) sát thương phép lên mục tiêu và kẻ địch trong bán kính 115. CD: 12 giây.",
					enhanced = "Bắn mũi tên phép nổ, gây 135 (149) sát thương phép lên mục tiêu và kẻ địch trong bán kính 115. CD: 12 giây.",
					levels_standard = { "Bắn mũi tên phép nổ, gây 80 (88) sát thương phép lên mục tiêu và kẻ địch trong bán kính 115. CD: 12 giây.", "Bắn mũi tên phép nổ, gây 160 (176) sát thương phép lên mục tiêu và kẻ địch trong bán kính 115. CD: 12 giây.", "Bắn mũi tên phép nổ, gây 240 (264) sát thương phép lên mục tiêu và kẻ địch trong bán kính 115. CD: 12 giây." },
					levels_enhanced = { "Bắn mũi tên phép nổ, gây 125 (138) sát thương phép lên mục tiêu và kẻ địch trong bán kính 115. CD: 12 giây.", "Bắn mũi tên phép nổ, gây 250 (275) sát thương phép lên mục tiêu và kẻ địch trong bán kính 115. CD: 12 giây.", "Bắn mũi tên phép nổ, gây 375 (413) sát thương phép lên mục tiêu và kẻ địch trong bán kính 115. CD: 12 giây." },
					prices_standard = { "200", "200", "200" },
					prices_enhanced = { "200", "200", "200" }
				},
				{
					name = "Mũi tên ru ngủ",
					standard = "Bắn 1 mũi tên gây ngủ 4 (4.4) giây lên một mục tiêu. CD: 20 giây.",
					enhanced = "Bắn 1 mũi tên gây ngủ 4 (4.4) giây lên một mục tiêu. Nếu có kẻ địch khác trong bán kính 300 quanh mục tiêu, bắn thêm một mũi vào mỗi kẻ địch, tối đa 2 mục tiêu phụ. CD: 20 giây.",
					levels_standard = { "Bắn 1 mũi tên gây ngủ 4 (4.4) giây lên một mục tiêu. CD: 20 giây.", "Bắn 1 mũi tên gây ngủ 4 (4.4) giây lên một mục tiêu. CD: 16 giây.", "Bắn 1 mũi tên gây ngủ 4 (4.4) giây lên một mục tiêu. CD: 12 giây." },
					levels_enhanced = { "Bắn 1 mũi tên gây ngủ 4 (4.4) giây lên một mục tiêu. Nếu có kẻ địch khác trong bán kính 300 quanh mục tiêu, bắn thêm một mũi vào mỗi kẻ địch, tối đa 2 mục tiêu phụ. CD: 20 giây.", "Bắn 1 mũi tên gây ngủ 4 (4.4) giây lên một mục tiêu. Nếu có kẻ địch khác trong bán kính 300 quanh mục tiêu, bắn thêm một mũi vào mỗi kẻ địch, tối đa 4 mục tiêu phụ. CD: 16 giây.", "Bắn 1 mũi tên gây ngủ 4 (4.4) giây lên một mục tiêu. Nếu có kẻ địch khác trong bán kính 300 quanh mục tiêu, bắn thêm một mũi vào mỗi kẻ địch, tối đa 6 mục tiêu phụ. CD: 12 giây." },
					prices_standard = { "180", "180", "180" },
					prices_enhanced = { "180", "135", "135" }
				},
			}
		},
		["tower_silver"] = {
			doc_id = "",
			title = "Cung dài vàng",
			attack = {
				standard = "Ở khoảng cách xa (325 đến tầm tối đa), bắn mỗi 1.5 giây và có 6% cơ hội chí mạng. Ở gần (trong 325), bắn mỗi 0.7 giây và có 1% cơ hội chí mạng. Gây sát thương vật lý; sát thương bắn gần bằng 33% bắn xa.",
				enhanced = "Ở khoảng cách xa (400 đến tầm tối đa), bắn mỗi 1.5 giây và có 6% cơ hội chí mạng. Ở gần (trong 400), bắn mỗi 0.7 giây và có 1% cơ hội chí mạng. Gây sát thương vật lý; sát thương bắn gần bằng 45% bắn xa."
			},
			change_note = "Nhận xét: Kế thừa chỉ số và khả năng diệt mục tiêu không giáp của tháp cung cấp 3, đồng thời giữ vai trò săn quái lớn. Tháp cung cấp 3 mạnh với mục tiêu không giáp vì sát thương chảy máu làm tròn lên: đòn đánh gây 12 sát thương thì chảy máu làm tròn thành 2, chỉ cần kích hoạt một lần đã gây 46 sát thương. Sau tăng cường, tháp cần vị trí bắn gần hơn vì sát thương gần và xa gần tương đương, trong khi bắn xa dễ trượt hơn.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Phán quyết đẫm máu",
					standard = "Bắn xa có 3 (3.3)% cơ hội tiêu diệt ngay; bắn gần có một nửa cơ hội đó.",
					enhanced = "Bắn xa có 3.63 (4)% cơ hội tiêu diệt ngay; bắn gần có một nửa cơ hội đó. Khi nhắm kẻ địch có máu tối đa >= 1200 hoặc kích thước vừa/lớn, dùng sức tấn công gấp 2 lần và bỏ qua 40 giáp của mục tiêu.",
					levels_standard = { "Bắn xa có 3 (3.3)% cơ hội tiêu diệt ngay; bắn gần có một nửa cơ hội đó.", "Bắn xa có 6 (6.6)% cơ hội tiêu diệt ngay; bắn gần có một nửa cơ hội đó.", "Bắn xa có 9 (9.9)% cơ hội tiêu diệt ngay; bắn gần có một nửa cơ hội đó." },
					levels_enhanced = { "Bắn xa có 3.63 (4)% cơ hội tiêu diệt ngay; bắn gần có một nửa cơ hội đó. Khi nhắm kẻ địch có máu tối đa >= 1200 hoặc kích thước vừa/lớn, gây sát thương gấp 2 lần và bỏ qua 40 giáp.", "Bắn xa có 7.26 (8)% cơ hội tiêu diệt ngay; bắn gần có một nửa cơ hội đó. Khi nhắm kẻ địch có máu tối đa >= 1200 hoặc kích thước vừa/lớn, gây sát thương gấp 3 lần và bỏ qua 40 giáp.", "Bắn xa có 10.89 (12)% cơ hội tiêu diệt ngay; bắn gần có một nửa cơ hội đó. Khi nhắm kẻ địch có máu tối đa >= 1200 hoặc kích thước vừa/lớn, gây sát thương gấp 4 lần và bỏ qua 40 giáp." },
					prices_standard = { "300", "300", "300" },
					prices_enhanced = { "300", "300", "300" }
				},
				{
					name = "Dấu ấn thợ săn",
					standard = "Đánh dấu mục tiêu, khiến sát thương nó nhận thành 200% (220%) ban đầu trong 5 giây.\nKhông dùng được lên trùm. CD: 12 giây.",
					enhanced = "Đánh dấu mục tiêu, khiến sát thương nó nhận thành 250% (275%) ban đầu trong 5 giây.\nDùng được lên trùm. CD: 12 giây.",
					levels_standard = { "Đánh dấu mục tiêu, khiến sát thương nó nhận thành 200% (220%) ban đầu trong 5 giây.\nKhông dùng được lên trùm. CD: 12 giây.", "Đánh dấu mục tiêu, khiến sát thương nó nhận thành 200% (220%) ban đầu trong 10 giây.\nKhông dùng được lên trùm. CD: 12 giây.", "Đánh dấu mục tiêu, khiến sát thương nó nhận thành 200% (220%) ban đầu trong 15 giây.\nKhông dùng được lên trùm. CD: 12 giây." },
					levels_enhanced = { "Đánh dấu mục tiêu, khiến sát thương nó nhận thành 250% (275%) ban đầu trong 5 giây.\nDùng được lên trùm. CD: 12 giây.", "Đánh dấu mục tiêu, khiến sát thương nó nhận thành 250% (275%) ban đầu trong 10 giây.\nDùng được lên trùm. CD: 12 giây.", "Đánh dấu mục tiêu, khiến sát thương nó nhận thành 250% (275%) ban đầu trong 15 giây.\nDùng được lên trùm. CD: 12 giây." },
					prices_standard = { "225", "225", "225" },
					prices_enhanced = { "225", "150", "150" }
				},
			}
		},
		["tower_blade"] = {
			doc_id = "",
			title = "Đại sảnh kiếm vũ",
			attack = {
				standard = "Tấn công cận chiến, gây sát thương vật lý.",
				enhanced = "Tấn công cận chiến, gây sát thương vật lý."
			},
			change_note = "Nhận xét: Cơ chế chống chịu đã đủ mạnh. Kỹ năng 2 bản gốc tăng sát thương trên lý thuyết, nhưng thời gian chặn cận chiến thường ngắn hơn nhiều so với thời gian tung kỹ năng 1 hoặc 3. Vì vậy, bản tăng cường liên kết kỹ năng 2 với 1/3.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Né đòn hoàn hảo",
					standard = "Khi nhận sát thương, trừ cháy, độc, pháo tầm xa, sát thương chuẩn tầm xa và các hiệu ứng tương tự, có 10% cơ hội miễn nhiễm đòn đó và bất tử 2 giây; nếu là sát thương vật lý hoặc phép cận chiến, cơ hội là 19%. Đồng thời tung đòn xoay, gây 4 sát thương chuẩn trong bán kính 100 mỗi 1/6 giây.",
					enhanced = "Khi nhận sát thương, trừ cháy, độc, pháo tầm xa, sát thương chuẩn tầm xa và các hiệu ứng tương tự, có 12.5% cơ hội miễn nhiễm đòn đó và bất tử 2 giây; nếu là sát thương vật lý hoặc phép cận chiến, cơ hội là 23.5%. Đồng thời tung đòn xoay, gây 4 sát thương chuẩn (kỹ năng 2 + 6) trong bán kính 100 mỗi 1/6 giây.",
					levels_standard = { "Khi nhận sát thương, trừ cháy, độc, pháo tầm xa, sát thương chuẩn tầm xa và các hiệu ứng tương tự, có 10% cơ hội miễn nhiễm đòn đó và bất tử 2 giây; nếu là sát thương vật lý hoặc phép cận chiến, cơ hội là 19%. Đồng thời tung đòn xoay, gây 3 sát thương chuẩn trong bán kính 100 mỗi 1/6 giây.", "Khi nhận sát thương, trừ cháy, độc, pháo tầm xa, sát thương chuẩn tầm xa và các hiệu ứng tương tự, có 20% cơ hội miễn nhiễm đòn đó và bất tử 2 giây; nếu là sát thương vật lý hoặc phép cận chiến, cơ hội là 36%. Đồng thời tung đòn xoay, gây 3 sát thương chuẩn trong bán kính 100 mỗi 1/6 giây.", "Khi nhận sát thương, trừ cháy, độc, pháo tầm xa, sát thương chuẩn tầm xa và các hiệu ứng tương tự, có 30% cơ hội miễn nhiễm đòn đó và bất tử 2 giây; nếu là sát thương vật lý hoặc phép cận chiến, cơ hội là 51%. Đồng thời tung đòn xoay, gây 3 sát thương chuẩn trong bán kính 100 mỗi 1/6 giây." },
					levels_enhanced = { "Khi nhận sát thương, trừ cháy, độc, pháo tầm xa, sát thương chuẩn tầm xa và các hiệu ứng tương tự, có 12.5% cơ hội miễn nhiễm đòn đó và bất tử 2 giây; nếu là sát thương vật lý hoặc phép cận chiến, cơ hội là 23.5%. Đồng thời tung đòn xoay, gây 4 sát thương chuẩn (kỹ năng 2 + 6) trong bán kính 100 mỗi 1/6 giây.", "Khi nhận sát thương, trừ cháy, độc, pháo tầm xa, sát thương chuẩn tầm xa và các hiệu ứng tương tự, có 25% cơ hội miễn nhiễm đòn đó và bất tử 2 giây; nếu là sát thương vật lý hoặc phép cận chiến, cơ hội là 43.7%. Đồng thời tung đòn xoay, gây 4 sát thương chuẩn (kỹ năng 2 + 6) trong bán kính 100 mỗi 1/6 giây.", "Khi nhận sát thương, trừ cháy, độc, pháo tầm xa, sát thương chuẩn tầm xa và các hiệu ứng tương tự, có 37.5% cơ hội miễn nhiễm đòn đó và bất tử 2 giây; nếu là sát thương vật lý hoặc phép cận chiến, cơ hội là 61%. Đồng thời tung đòn xoay, gây 4 sát thương chuẩn (kỹ năng 2 + 6) trong bán kính 100 mỗi 1/6 giây." },
					prices_standard = { "175", "175", "175" },
					prices_enhanced = { "50", "200", "200" }
				},
				{
					name = "Bậc thầy kiếm thuật",
					standard = "Tăng 5 sát thương đòn đánh và 20% tốc độ đánh cho kiếm vũ sĩ.",
					enhanced = "Tăng 5 sát thương đòn đánh, 20% tốc độ đánh, 3 sát thương Né đòn hoàn hảo và 30 sát thương Đột kích ảo ảnh.",
					levels_standard = { "Tăng 5 sát thương đòn đánh và 20% tốc độ đánh cho kiếm vũ sĩ." },
					levels_enhanced = { "Tăng 5 sát thương đòn đánh, 20% tốc độ đánh, 6 sát thương Né đòn hoàn hảo và 50 sát thương Đột kích ảo ảnh." },
					prices_standard = { "300" },
					prices_enhanced = { "300" }
				},
				{
					name = "Đột kích ảo ảnh",
					standard = "Mỗi kiếm vũ sĩ dịch chuyển đến trước kẻ địch mặt đất trong bán kính 250, đánh 2 lần. Mỗi lần gây 20-35 sát thương chuẩn lên một mục tiêu và giữ chân 1 giây. CD: 10 giây.",
					enhanced = "Mỗi kiếm vũ sĩ dịch chuyển đến trước kẻ địch mặt đất hoặc trên không trong bán kính 250, đánh 2 lần. Mỗi lần gây 20-50 sát thương chuẩn (kỹ năng 2 + 50) và giữ chân 1 giây. CD: 10 giây.",
					levels_standard = { "Mỗi kiếm vũ sĩ dịch chuyển đến trước kẻ địch mặt đất trong bán kính 250, đánh 2 lần. Mỗi lần gây 20-35 sát thương chuẩn lên một mục tiêu và giữ chân 1 giây. CD: 10 giây.", "Mỗi kiếm vũ sĩ dịch chuyển đến trước kẻ địch mặt đất trong bán kính 250, đánh 3 lần. Mỗi lần gây 35-47 sát thương chuẩn lên một mục tiêu và giữ chân 1 giây. CD: 10 giây.", "Mỗi kiếm vũ sĩ dịch chuyển đến trước kẻ địch mặt đất trong bán kính 250, đánh 4 lần. Mỗi lần gây 40-56 sát thương chuẩn lên một mục tiêu và giữ chân 1 giây. CD: 10 giây." },
					levels_enhanced = { "Mỗi kiếm vũ sĩ dịch chuyển đến trước kẻ địch mặt đất hoặc trên không trong bán kính 250, đánh 2 lần. Mỗi lần gây 20-50 sát thương chuẩn (kỹ năng 2 + 50) và giữ chân 1 giây. CD: 10 giây.", "Mỗi kiếm vũ sĩ dịch chuyển đến trước kẻ địch mặt đất hoặc trên không trong bán kính 250, đánh 3 lần. Mỗi lần gây 35-75 sát thương chuẩn (kỹ năng 2 + 50) và giữ chân 1 giây. CD: 10 giây.", "Mỗi kiếm vũ sĩ dịch chuyển đến trước kẻ địch mặt đất hoặc trên không trong bán kính 250, đánh 4 lần. Mỗi lần gây 50-100 sát thương chuẩn (kỹ năng 2 + 50) và giữ chân 1 giây. CD: 10 giây." },
					prices_standard = { "250", "250", "250" },
					prices_enhanced = { "250", "250", "250" }
				},
			}
		},
		["tower_forest"] = {
			doc_id = "",
			title = "Vệ binh rừng",
			attack = {
				standard = "Doanh trại có 2 lính. Đánh cận chiến gây sát thương vật lý; đánh xa khi có kẻ địch trong phạm vi 350.",
				enhanced = "Doanh trại có 3 lính. Đánh cận chiến gây sát thương vật lý; đánh xa khi có kẻ địch trong phạm vi 350."
			},
			change_note = "Nhận xét: Chuyển thành doanh trại 3 lính, khắc phục việc ném giáo quá chậm của doanh trại 2 lính bản gốc. Kỹ năng 1 cấp 2/3 và kỹ năng 2 gần như không gây sát thương chưa xứng đáng với giá cao.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Vòng đời",
					standard = "Khi máu dưới 80%, tự hồi và hồi cho đồng đội trong bán kính 200: 4 máu mỗi 0.2 giây, đồng thời xóa hiệu ứng gây sát thương. Tổng cộng hồi 80 máu trong 4 giây. Miễn nhiễm các hiệu ứng gây sát thương khi hào quang tồn tại. CD: 10 giây.",
					enhanced = "Khi máu dưới 80%, tự hồi và hồi cho đồng đội trong bán kính 200: 4 máu mỗi 0.2 giây, đồng thời xóa hiệu ứng gây sát thương. Tổng cộng hồi 80 máu trong 4 giây. Miễn nhiễm các hiệu ứng gây sát thương khi hào quang tồn tại. CD: 10 giây.",
					levels_standard = { "Khi máu dưới 80%, tự hồi và hồi cho đồng đội trong bán kính 200: 4 máu mỗi 0.2 giây, đồng thời xóa hiệu ứng gây sát thương. Tổng cộng hồi 80 máu trong 4 giây. Miễn nhiễm các hiệu ứng gây sát thương khi hào quang tồn tại. CD: 10 giây.", "Khi máu dưới 80%, tự hồi và hồi cho đồng đội trong bán kính 200: 8 máu mỗi 0.2 giây, đồng thời xóa hiệu ứng gây sát thương. Tổng cộng hồi 160 máu trong 4 giây. Miễn nhiễm các hiệu ứng gây sát thương khi hào quang tồn tại. CD: 10 giây.", "Khi máu dưới 80%, tự hồi và hồi cho đồng đội trong bán kính 200: 12 máu mỗi 0.2 giây, đồng thời xóa hiệu ứng gây sát thương. Tổng cộng hồi 240 máu trong 4 giây. Miễn nhiễm các hiệu ứng gây sát thương khi hào quang tồn tại. CD: 10 giây." },
					levels_enhanced = { "Khi máu dưới 80%, tự hồi và hồi cho đồng đội trong bán kính 200: 4 máu mỗi 0.2 giây, đồng thời xóa hiệu ứng gây sát thương. Tổng cộng hồi 120 máu trong 6 giây. Miễn nhiễm các hiệu ứng gây sát thương khi hào quang tồn tại. CD: 10 giây.", "Khi máu dưới 80%, tự hồi và hồi cho đồng đội trong bán kính 200: 8 máu mỗi 0.2 giây, đồng thời xóa hiệu ứng gây sát thương. Tổng cộng hồi 240 máu trong 6 giây. Miễn nhiễm các hiệu ứng gây sát thương khi hào quang tồn tại. CD: 10 giây.", "Khi máu dưới 80%, tự hồi và hồi cho đồng đội trong bán kính 200: 12 máu mỗi 0.2 giây, đồng thời xóa hiệu ứng gây sát thương. Tổng cộng hồi 360 máu trong 6 giây. Miễn nhiễm các hiệu ứng gây sát thương khi hào quang tồn tại. CD: 10 giây." },
					prices_standard = { "185", "185", "185" },
					prices_enhanced = { "185", "120", "120" }
				},
				{
					name = "Người làm vườn kỳ lạ",
					standard = "Tạo vùng dây leo bán kính 250, làm chậm kẻ địch 50% trong 4 giây. Gây 3 sát thương vật lý mỗi 0.167 giây cho mục tiêu trong vùng. CD: 10 giây.",
					enhanced = "Tạo vùng dây leo bán kính 250, làm chậm kẻ địch 50% trong 4 giây. Gây 3 sát thương vật lý mỗi 0.167 giây cho mục tiêu trong vùng. CD: 10 giây.",
					levels_standard = { "Tạo vùng dây leo bán kính 250, làm chậm kẻ địch 50% trong 4 giây. Gây 3 sát thương vật lý mỗi 0.167 giây cho mục tiêu trong vùng. CD: 10 giây.", "Tạo vùng dây leo bán kính 280, làm chậm kẻ địch 50% trong 6 giây. Gây 4 sát thương vật lý mỗi 0.167 giây cho mục tiêu trong vùng. CD: 10 giây." },
					levels_enhanced = { "Tạo vùng dây leo bán kính 250, làm chậm kẻ địch 50% trong 4 giây. Gây 3 sát thương vật lý mỗi 0.167 giây cho mục tiêu trong vùng. CD: 10 giây.", "Tạo vùng dây leo bán kính 280, làm chậm kẻ địch 50% trong 6 giây. Gây 4 sát thương vật lý mỗi 0.167 giây cho mục tiêu trong vùng. CD: 10 giây." },
					prices_standard = { "285", "285" },
					prices_enhanced = { "135", "105" }
				},
				{
					name = "Giáo sồi",
					standard = "Tăng sát thương đánh xa của Vệ binh rừng thành 90 sát thương chuẩn; tầm đánh 350.",
					enhanced = "Tăng sát thương đánh xa của Vệ binh rừng thành 80 sát thương chuẩn; tầm đánh 350.",
					levels_standard = { "Tăng sát thương đánh xa của Vệ binh rừng thành 90 sát thương chuẩn; tầm đánh 350.", "Tăng sát thương đánh xa của Vệ binh rừng thành 125 sát thương chuẩn; tầm đánh 350.", "Tăng sát thương đánh xa của Vệ binh rừng thành 160 sát thương chuẩn; tầm đánh 350." },
					levels_enhanced = { "Tăng sát thương đánh xa của 3 Vệ binh rừng thành 70 sát thương chuẩn; tầm đánh 350.", "Tăng sát thương đánh xa của 3 Vệ binh rừng thành 115 sát thương chuẩn; tầm đánh 350.", "Tăng sát thương đánh xa của 3 Vệ binh rừng thành 160 sát thương chuẩn; tầm đánh 350." },
					prices_standard = { "250", "250", "250" },
					prices_enhanced = { "250", "250", "250" }
				},
			}
		},
		["tower_wild_magus"] = {
			doc_id = "",
			title = "Pháp sư hoang dã",
			attack = {
				standard = "Khi đánh cùng một mục tiêu, cứ 1 đòn tăng 0.5 sát thương; tối đa tăng 24.",
				enhanced = "Đánh liên tiếp cùng một mục tiêu tích lũy chiến ý. Mỗi tầng tăng 1 sức tấn công, tối đa 36 tầng. Đổi mục tiêu hoặc không đánh trong 6 giây sẽ mất 6 tầng. Đủ tầng kích hoạt huyết mạch hoang dã, tăng vĩnh viễn 1 sức tấn công, tối đa 10."
			},
			change_note = "Nhận xét: Khắc phục việc mất sát thương do thường xuyên đổi mục tiêu.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Tai ương kỳ dị",
					standard = "Cho nổ một kẻ địch và gây 80 sát thương phép cho mục tiêu trong bán kính 175. CD: 28 giây.",
					enhanced = "Cho nổ một kẻ địch và gây 144 sát thương phép cho mục tiêu trong bán kính 175. CD: 28 giây.",
					levels_standard = { "Cho nổ một kẻ địch và gây 80 sát thương phép cho mục tiêu trong bán kính 175. CD: 28 giây.", "Cho nổ một kẻ địch và gây 180 sát thương phép cho mục tiêu trong bán kính 175. CD: 24 giây.", "Cho nổ một kẻ địch và gây 260 sát thương phép cho mục tiêu trong bán kính 175. CD: 20 giây." },
					levels_enhanced = { "Cho nổ một kẻ địch và gây 144 sát thương phép cho mục tiêu trong bán kính 175. CD: 28 giây.", "Cho nổ một kẻ địch và gây 324 sát thương phép cho mục tiêu trong bán kính 175. CD: 22.5 giây.", "Cho nổ một kẻ địch và gây 468 sát thương phép cho mục tiêu trong bán kính 175. CD: 17 giây." },
					prices_standard = { "325", "185", "185" },
					prices_enhanced = { "325", "185", "185" }
				},
				{
					name = "Ấn phá phép",
					standard = "Câm lặng 1 kẻ địch có khả năng dùng phép trong tầm suốt 10 giây. CD: 11 giây.",
					enhanced = "Câm lặng 1 kẻ địch có khả năng dùng phép trong tầm suốt 10 giây. CD: 10 giây.",
					levels_standard = { "Câm lặng 1 kẻ địch có khả năng dùng phép trong tầm suốt 10 giây. CD: 11 giây.", "Câm lặng 3 kẻ địch có khả năng dùng phép trong tầm suốt 10 giây. CD: 11 giây.", "Câm lặng 6 kẻ địch có khả năng dùng phép trong tầm suốt 10 giây. CD: 11 giây." },
					levels_enhanced = { "Câm lặng vĩnh viễn 1 kẻ địch có khả năng dùng phép trong tầm. CD: 10 giây.", "Câm lặng vĩnh viễn 3 kẻ địch có khả năng dùng phép trong tầm. CD: 10 giây.", "Câm lặng vĩnh viễn 6 kẻ địch có khả năng dùng phép trong tầm. CD: 10 giây." },
					prices_standard = { "225", "225", "225" },
					prices_enhanced = { "275", "200", "200" }
				},
			}
		},
		["tower_high_elven"] = {
			doc_id = "",
			title = "Pháp sư tinh linh cao cấp",
			attack = {
				standard = "Mỗi 1.5 giây bắn 1 cầu lớn và 2 cầu nhỏ. Cầu lớn gây 31-54 (36-63) sát thương phép; cầu nhỏ gây 5-10.\nNếu có hơn 2 kẻ địch trong tầm, các cầu sẽ chọn mục tiêu riêng.",
				enhanced = "Mỗi 1.5 giây bắn 1 cầu lớn và 2 cầu nhỏ. Cầu lớn gây 31-54 (36-63) sát thương phép; cầu nhỏ gây 21-42.\nNếu có hơn 2 kẻ địch trong tầm, các cầu sẽ chọn mục tiêu riêng."
			},
			change_note = "Nhận xét: Chỉ số tháp phép phần 3 bản gốc có vấn đề. Đòn đánh chia mục tiêu cần tổng chỉ số cao hơn chuẩn, nhưng tháp phép phần 3 lại thấp hơn. Trong phần 3 có nhiều nguồn sát thương chuẩn và hỗn hợp, khiến tháp thuần phép khó nổi bật. Xét xuyên các phần, tháp tinh linh là cấp 4, giá cấp 4 nhưng chỉ số chỉ tương đương tháp cấp 3 của phần 1/2/4/5. Vì vậy cần làm lại toàn diện chỉ số tháp phép phần 3.",
			port_note = "Về Vệ tinh bí thuật: Thử nghiệm cho thấy mỗi 0.75 giây mới đánh một lần; mã nguồn có 0.25 giây tìm mục tiêu ngoài khoảng đánh 0.5. Chu kỳ nạp và đánh đầy đủ của bản gốc mất khoảng 12-13 giây.\nVề nâng cấp: Bản gốc chỉ cầu lớn nhận nâng cấp tăng 15% sát thương pháp sư; cầu nhỏ không nhận.",
			notes = "",
			skills = {
				{
					name = "Giam cầm không gian",
					standard = "Mỗi 16 giây, giam tối đa 2 kẻ địch trong tầm suốt 5 giây và gây 100 sát thương phép.",
					enhanced = "Tạo trường lực bán kính 360. Cấp 1: hấp thụ mọi đạn của địch. Cấp 2: phản đạn chạm trường lực về kẻ địch ngẫu nhiên. Cấp 3: phản đạn với sát thương gấp 3 lần.",
					levels_standard = { "Mỗi 16 giây, giam tối đa 2 kẻ địch trong tầm suốt 5 giây và gây 100 sát thương phép.", "Mỗi 16 giây, giam tối đa 3 kẻ địch trong tầm suốt 5 giây và gây 135 sát thương phép.", "Mỗi 16 giây, giam tối đa 4 kẻ địch trong tầm suốt 5 giây và gây 150 sát thương phép." },
					levels_enhanced = { "Tạo trường lực bán kính 360, hấp thụ mọi đạn của địch chạm vào.", "Tạo trường lực bán kính 360, phản đạn chạm vào về kẻ địch ngẫu nhiên.", "Tạo trường lực bán kính 360, phản đạn chạm vào về kẻ địch ngẫu nhiên với sát thương gấp 3 lần." },
					prices_standard = { "225", "225", "225" },
					prices_enhanced = { "400", "240", "240" }
				},
				{
					name = "Vệ tinh bí thuật",
					standard = "Triệu hồi 1 vệ tinh tìm và đánh kẻ địch từ xa. Mỗi đòn gây 16-32 sát thương phép; khoảng đánh 0.5 giây, thời gian tìm mục tiêu 0.25 giây. Sau 10 đòn, trở về tháp nạp 5 giây. Tầm tìm mục tiêu 600.",
					enhanced = "Triệu hồi 1 vệ tinh tìm và đánh kẻ địch từ xa. Mỗi đòn gây 22-44 sát thương phép; khoảng đánh 0.5 giây, thời gian tìm mục tiêu 0.25 giây. Sau 20 đòn, trở về tháp nạp 5 giây. Tầm tìm mục tiêu 600.",
					levels_standard = { "Triệu hồi 1 vệ tinh tìm và đánh kẻ địch từ xa. Mỗi đòn gây 16-32 sát thương phép; khoảng đánh 0.5 giây, thời gian tìm mục tiêu 0.25 giây. Sau 10 đòn, trở về tháp nạp 5 giây. Tầm tìm mục tiêu 600.", "Triệu hồi 2 vệ tinh tìm và đánh kẻ địch từ xa. Mỗi đòn gây 16-32 sát thương phép; khoảng đánh 0.5 giây, thời gian tìm mục tiêu 0.25 giây. Sau 10 đòn, trở về tháp nạp 5 giây. Tầm tìm mục tiêu 600." },
					levels_enhanced = { "Triệu hồi 1 vệ tinh tìm và đánh kẻ địch từ xa. Mỗi đòn gây 22-44 sát thương phép; khoảng đánh 0.5 giây, thời gian tìm mục tiêu 0.25 giây. Sau 20 đòn, trở về tháp nạp 5 giây. Tầm tìm mục tiêu 600.", "Triệu hồi 2 vệ tinh tìm và đánh kẻ địch từ xa. Mỗi đòn gây 22-44 sát thương phép; khoảng đánh 0.5 giây, thời gian tìm mục tiêu 0.25 giây. Sau 20 đòn, trở về tháp nạp 5 giây. Tầm tìm mục tiêu 600." },
					prices_standard = { "300", "300" },
					prices_enhanced = { "300", "300" }
				},
			}
		},
		["tower_druid"] = {
			doc_id = "",
			title = "Vòng đá đại Druid",
			attack = {
				standard = "Ném đá mỗi 1.7 giây, gây sát thương pháo (chuẩn) trong bán kính 100 (110). Khi không có kẻ địch, tích trữ tối đa 3 viên.",
				enhanced = "Ném đá mỗi 1.7 giây, gây sát thương pháo (chuẩn) trong bán kính 113 (125). Khi không có kẻ địch, tích trữ tối đa 3 viên."
			},
			change_note = "Nhận xét: Chỉ số tháp pháo phần 3 cũng có vấn đề. Không nên giảm quá mạnh sức tấn công chỉ vì gây sát thương chuẩn; tác giả cho rằng Ironhide đã điều chỉnh quá tay sau vài tháp pháo quá mạnh của phần 1/2. Tuy nhiên, vì sát thương chuẩn và tốc độ đánh đã chiếm phần lớn sức mạnh, chỉ số sau làm lại vẫn cần thấp hơn pháo các phần trước. Kỹ năng 1 chỉ mạnh khi khóa quái lớn; do có cách thao tác dùng hai lời nguyền, không thể giảm giá hoặc tăng thêm ở chỗ khác. Kỹ năng 2 cần điều chỉnh gấu cho xứng với giá 350 vàng.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Lời nguyền rừng",
					standard = "Nguyền rủa một kẻ địch trong tầm suốt 5 giây. 35% sát thương nó nhận lan thành sát thương chuẩn đến kẻ địch trong bán kính 200. CD: 15 giây.",
					enhanced = "Nguyền rủa kẻ địch còn nhiều máu nhất trong tầm suốt 10 giây. 35% sát thương nó nhận lan thành sát thương chuẩn đến kẻ địch trong bán kính 200. CD: 15 giây.",
					levels_standard = { "Nguyền rủa một kẻ địch trong tầm suốt 5 giây. 35% sát thương nó nhận lan thành sát thương chuẩn đến kẻ địch trong bán kính 200. CD: 15 giây.", "Nguyền rủa một kẻ địch trong tầm suốt 5 giây. 70% sát thương nó nhận lan thành sát thương chuẩn đến kẻ địch trong bán kính 200. CD: 15 giây.", "Nguyền rủa một kẻ địch trong tầm suốt 5 giây. 100% sát thương nó nhận lan thành sát thương chuẩn đến kẻ địch trong bán kính 200. CD: 15 giây." },
					levels_enhanced = { "Nguyền rủa kẻ địch còn nhiều máu nhất trong tầm suốt 15 giây. 35% sát thương nó nhận lan thành sát thương chuẩn đến kẻ địch trong bán kính 200. CD: 15 giây.", "Nguyền rủa kẻ địch còn nhiều máu nhất trong tầm suốt 15 giây. 70% sát thương nó nhận lan thành sát thương chuẩn đến kẻ địch trong bán kính 200. CD: 15 giây.", "Nguyền rủa kẻ địch còn nhiều máu nhất trong tầm suốt 15 giây. 100% sát thương nó nhận lan thành sát thương chuẩn đến kẻ địch trong bán kính 200. CD: 15 giây." },
					prices_standard = { "250", "250", "250" },
					prices_enhanced = { "250", "250", "250" }
				},
				{
					name = "Gấu chiến cổ ngữ",
					standard = "Triệu hồi 1 gấu chặn và đánh kẻ địch. Máu 250; giáp 20; sức tấn công 20-40; hồi sinh 20; hồi máu ngoài giao tranh 25.",
					enhanced = "Triệu hồi 1 gấu chặn và đánh kẻ địch. Máu 700; giáp 20; sức tấn công 20-40; hồi sinh 10; hồi máu ngoài giao tranh 35.",
					levels_standard = { "Triệu hồi 1 gấu chặn và đánh kẻ địch. Máu 250; giáp 20; sức tấn công 20-40; hồi sinh 20; hồi máu ngoài giao tranh 25.", "Triệu hồi 2 gấu chặn và đánh kẻ địch. Máu 250; giáp 20; sức tấn công 1.0; hồi sinh 20; hồi máu ngoài giao tranh 25." },
					levels_enhanced = { "Triệu hồi 1 gấu chặn và đánh kẻ địch. Máu 700; giáp 20; sức tấn công 20-40; hồi sinh 10; hồi máu ngoài giao tranh 35.", "Triệu hồi 2 gấu chặn và đánh kẻ địch. Máu 700; giáp 20; sức tấn công 1.0; hồi sinh 10; hồi máu ngoài giao tranh 35." },
					prices_standard = { "350", "350" },
					prices_enhanced = { "350", "350" }
				},
			}
		},
		["tower_entwood"] = {
			doc_id = "",
			title = "Thụ nhân kỳ dị",
			attack = {
				standard = "Ném hạt mỗi 3.5 giây, gây sát thương pháo (chuẩn) trong bán kính 110 (121).",
				enhanced = "Ném hạt mỗi 3.5 giây, gây sát thương pháo (chuẩn) trong bán kính 128 (141)."
			},
			change_note = "Nhận xét: Gợi nhắc nhân vật Thẩm Mộng Khê.",
			port_note = "",
			notes = "Tháp phần 4\nTất cả tháp phần 4 mặc định có đủ nâng cấp, không cần mua trong cây nâng cấp.\nNâng cấp liên quan đến tháp phần 1 và 4:\n(1) Máu tất cả lính đồng minh +30%.\n(2) Sức tấn công tất cả đơn vị đồng minh +10%.\n(3) Bán kính nổ của tên lửa, khí cầu và tàu đắm +20%. Sát thương nổ tính theo khoảng cách đến tâm như 3 phần trước, thay vì lấy ngẫu nhiên trong vùng nổ như phần 4.\n(4) Tầm đánh của Cung thủ bóng tối, Boomerang, Lính ném xương, Thiếu Lâm Tự và dạng tháp cung của Quái vật đầm lầy +5%.\n(5) Giá kỹ năng của mọi tháp -15%, làm tròn xuống.\n(6) Nâng cấp chí mạng pháp sư đổi thành +10% sức tấn công hiển thị, tổng cộng +21%.\n2. Khác biệt với bản gốc\n(1) Tầm tháp phần 4 thường nhỏ: tháp không tập kết được điều chỉnh theo chuẩn 450 (tháp cung/phép > pháo thường > pháo toàn vùng); phạm vi tập kết của tháp có thể di chuyển +10%.\n※ Muốn dùng tầm gốc, tắt tùy chọn tầm phần 4 ở trang chọn tháp. Khi đó mọi tháp phần 4 dùng tầm gốc đã cộng nâng cấp.\n(2) Nâng cấp chí mạng pháp sư đổi thành +10% sức tấn công hiển thị, tổng cộng +21%.\n(3) Phần 4 dùng engine khác, phải viết lại từ 0; tác giả không thể tái hiện mọi cơ chế. Khác biệt của từng tháp được ghi trong mô tả.\n3. Nâng cấp khác\nAnh hùng: đã chuyển đầy đủ.\nViện quân: chưa chuyển, dùng viện quân phần 1.\nPhép tấn công: chưa chuyển, dùng phép phần 1.",
			skills = {
				{
					name = "Hạt cháy",
					standard = "Ném hạt đang cháy gây 135 sát thương pháo, bán kính nổ 130. Để lại vùng lửa bán kính 130 tồn tại 5 giây. Kẻ địch đi qua bị cháy 6 giây, chịu 1 sát thương chuẩn mỗi 0.1 giây. CD: 25.5 giây.",
					enhanced = "Ném hạt lớn đang cháy gây 120 sát thương chuẩn trong bán kính 160, rồi tách thành 3 hạt nhỏ, mỗi hạt gây 40 sát thương chuẩn. Hạt lớn và nhỏ đều để lại vùng lửa tồn tại 5 giây; kẻ địch đi qua bị cháy 6 giây, chịu 1 sát thương chuẩn mỗi 0.1 giây. CD: 16 giây.",
					levels_standard = { "Ném hạt đang cháy gây 135 sát thương pháo, bán kính nổ 130. Để lại vùng lửa bán kính 130 tồn tại 5 giây. Kẻ địch đi qua bị cháy 6 giây, chịu 1 sát thương chuẩn mỗi 0.1 giây. CD: 25.5 giây.", "Ném hạt đang cháy gây 270 sát thương pháo, bán kính nổ 130. Để lại vùng lửa bán kính 130 tồn tại 5 giây. Kẻ địch đi qua bị cháy 6 giây, chịu 2 sát thương chuẩn mỗi 0.1 giây. CD: 25.5 giây.", "Ném hạt đang cháy gây 405 sát thương pháo, bán kính nổ 130. Để lại vùng lửa bán kính 130 tồn tại 5 giây. Kẻ địch đi qua bị cháy 6 giây, chịu 3 sát thương chuẩn mỗi 0.1 giây. CD: 25.5 giây." },
					levels_enhanced = { "Ném hạt lớn đang cháy gây 111 sát thương chuẩn trong bán kính 160, rồi tách thành 3 hạt nhỏ, mỗi hạt gây 44 sát thương chuẩn. Hạt lớn và nhỏ đều để lại vùng lửa tồn tại 5 giây; kẻ địch đi qua bị cháy 6 giây, chịu 1 sát thương chuẩn mỗi 0.1 giây. CD: 16 giây.", "Ném hạt lớn đang cháy gây 222 sát thương chuẩn trong bán kính 160, rồi tách thành 4 hạt nhỏ, mỗi hạt gây 66 sát thương chuẩn. Hạt lớn và nhỏ đều để lại vùng lửa tồn tại 5 giây; kẻ địch đi qua bị cháy 6 giây, chịu 2 sát thương chuẩn mỗi 0.1 giây. CD: 16 giây.", "Ném hạt lớn đang cháy gây 333 sát thương chuẩn trong bán kính 160, rồi tách thành 5 hạt nhỏ, mỗi hạt gây 88 sát thương chuẩn. Hạt lớn và nhỏ đều để lại vùng lửa tồn tại 5 giây; kẻ địch đi qua bị cháy 6 giây, chịu 3 sát thương chuẩn mỗi 0.1 giây. CD: 16 giây." },
					prices_standard = { "330", "330", "330" },
					prices_enhanced = { "330", "330", "330" }
				},
				{
					name = "Chấn động mặt đất",
					standard = "Đập xuống đất, gây 75 sát thương chuẩn cho toàn bộ kẻ địch mặt đất trong bán kính 450. 2 mục tiêu đầu chắc chắn bị choáng; mục tiêu thứ 3 có 75% cơ hội bị choáng; từ mục tiêu thứ 4 trở đi có 50% cơ hội. Choáng 1 giây. CD: 14 giây.",
					enhanced = "Đập xuống đất, gây 75 sát thương chuẩn cho toàn bộ kẻ địch mặt đất trong bán kính 450. 2 mục tiêu đầu chắc chắn bị choáng; mục tiêu thứ 3 có 75% cơ hội bị choáng; từ mục tiêu thứ 4 trở đi có 50% cơ hội. Choáng 1 giây. CD: 14 giây.",
					levels_standard = { "Đập xuống đất, gây 75 sát thương chuẩn cho toàn bộ kẻ địch mặt đất trong bán kính 450. 2 mục tiêu đầu chắc chắn bị choáng; mục tiêu thứ 3 có 75% cơ hội bị choáng; từ mục tiêu thứ 4 trở đi có 50% cơ hội. Choáng 1 giây. CD: 14 giây.", "Đập xuống đất, gây 100 sát thương chuẩn cho toàn bộ kẻ địch mặt đất trong bán kính 450. 2 mục tiêu đầu chắc chắn bị choáng; mục tiêu thứ 3 có 75% cơ hội bị choáng; từ mục tiêu thứ 4 trở đi có 50% cơ hội. Choáng 2 giây. CD: 14 giây.", "Đập xuống đất, gây 125 sát thương chuẩn cho toàn bộ kẻ địch mặt đất trong bán kính 450. 2 mục tiêu đầu chắc chắn bị choáng; mục tiêu thứ 3 có 75% cơ hội bị choáng; từ mục tiêu thứ 4 trở đi có 50% cơ hội. Choáng 3 giây. CD: 14 giây." },
					levels_enhanced = { "Đập xuống đất, gây 75 sát thương chuẩn cho toàn bộ kẻ địch mặt đất trong bán kính 450. 2 mục tiêu đầu chắc chắn bị choáng; mục tiêu thứ 3 có 75% cơ hội bị choáng; từ mục tiêu thứ 4 trở đi có 50% cơ hội. Choáng 1 giây. CD: 14 giây.", "Đập xuống đất, gây 135 sát thương chuẩn cho toàn bộ kẻ địch mặt đất trong bán kính 450. 2 mục tiêu đầu chắc chắn bị choáng; mục tiêu thứ 3 có 75% cơ hội bị choáng; từ mục tiêu thứ 4 trở đi có 50% cơ hội. Choáng 2 giây. CD: 14 giây.", "Đập xuống đất, gây 195 sát thương chuẩn cho toàn bộ kẻ địch mặt đất trong bán kính 450. 2 mục tiêu đầu chắc chắn bị choáng; mục tiêu thứ 3 có 75% cơ hội bị choáng; từ mục tiêu thứ 4 trở đi có 50% cơ hội. Choáng 3 giây. CD: 14 giây." },
					prices_standard = { "225", "225", "225" },
					prices_enhanced = { "225", "225", "225" }
				},
			}
		},
		["tower_orc_shaman_lvl4"] = {
			doc_id = "",
			title = "Pháp sư orc",
			attack = {
				standard = "Phóng sét mỗi 2.3 giây, gây sát thương phép và làm choáng 0.66 giây.",
				enhanced = "Phóng sét mỗi 2.3 giây, gây sát thương phép và làm choáng 0.66 giây."
			},
			change_note = "Nhận xét: Pháp sư orc phần 4 cũ được gọi là phép thử vận may, với sát thương 4-20/10-55/20-110/35-190. Bản tăng cường tiếp tục phong cách này. Bạn có dám cược mỗi tia sét đều gây hơn 300 sát thương?",
			port_note = "Thay đổi khi chuyển sang mod: Tầm gốc của mọi cấp là 370. Nâng cấp chí mạng đã được tính vào chỉ số.",
			notes = "",
			skills = {
				{
					name = "Rễ hồi phục",
					standard = "Tạo vùng rễ hồi phục, hồi tổng cộng 60 máu trong 6 giây cho đồng đội trong bán kính 120, tức 1 máu mỗi 0.1 giây. Chỉ kích hoạt khi có ít nhất 2 đồng đội trong vùng có máu dưới 50%. CD: 16 giây.",
					enhanced = "Tạo vùng rễ hồi phục, hồi tổng cộng 120 máu trong 6 giây cho đồng đội trong bán kính 175, tức 2 máu mỗi 0.1 giây. Chỉ kích hoạt khi có ít nhất 2 đồng đội trong vùng có máu dưới 50%. CD: 16 giây.",
					levels_standard = { "Tạo vùng rễ hồi phục, hồi tổng cộng 60 máu trong 6 giây cho đồng đội trong bán kính 120, tức 1 máu mỗi 0.1 giây. Chỉ kích hoạt khi có ít nhất 2 đồng đội trong vùng có máu dưới 50%. CD: 16 giây.", "Tạo vùng rễ hồi phục, hồi tổng cộng 120 máu trong 6 giây cho đồng đội trong bán kính 120, tức 2 máu mỗi 0.1 giây. Chỉ kích hoạt khi có ít nhất 2 đồng đội trong vùng có máu dưới 50%. CD: 16 giây.", "Tạo vùng rễ hồi phục, hồi tổng cộng 180 máu trong 6 giây cho đồng đội trong bán kính 120, tức 3 máu mỗi 0.1 giây. Chỉ kích hoạt khi có ít nhất 2 đồng đội trong vùng có máu dưới 50%. CD: 16 giây." },
					levels_enhanced = { "Tạo vùng rễ hồi phục, hồi tổng cộng 120 máu trong 6 giây cho đồng đội trong bán kính 210, tức 2 máu mỗi 0.1 giây. Chỉ kích hoạt khi có ít nhất 2 đồng đội trong vùng có máu dưới 50%. CD: 16 giây.", "Tạo vùng rễ hồi phục, hồi tổng cộng 240 máu trong 6 giây cho đồng đội trong bán kính 210, tức 4 máu mỗi 0.1 giây. Chỉ kích hoạt khi có ít nhất 2 đồng đội trong vùng có máu dưới 50%. CD: 16 giây.", "Tạo vùng rễ hồi phục, hồi tổng cộng 360 máu trong 6 giây cho đồng đội trong bán kính 210, tức 6 máu mỗi 0.1 giây. Chỉ kích hoạt khi có ít nhất 2 đồng đội trong vùng có máu dưới 50%. CD: 16 giây." },
					prices_standard = { "110", "110", "110" },
					prices_enhanced = { "110", "110", "110" }
				},
				{
					name = "Thiên thạch",
					standard = "Gọi 4 thiên thạch, mỗi viên gây 30-50 sát thương phép trong bán kính 100. Chủ động đánh được mục tiêu bay. CD: 20 giây.",
					enhanced = "Gọi 4 thiên thạch, mỗi viên gây 21-90 sát thương phép trong bán kính 110. Chủ động đánh được mục tiêu bay. CD: 18.4 giây.",
					levels_standard = { "Gọi 4 thiên thạch, mỗi viên gây 30-50 sát thương phép trong bán kính 100. Chủ động đánh được mục tiêu bay. CD: 20 giây.", "Gọi 5 thiên thạch, mỗi viên gây 50-70 sát thương phép trong bán kính 100. Chủ động đánh được mục tiêu bay. CD: 20 giây.", "Gọi 6 thiên thạch, mỗi viên gây 70-90 sát thương phép trong bán kính 100. Chủ động đánh được mục tiêu bay. CD: 20 giây." },
					levels_enhanced = { "Gọi 4 thiên thạch, mỗi viên gây 21-90 sát thương phép trong bán kính 110. Chủ động đánh được mục tiêu bay. CD: 18.4 giây.", "Gọi 5 thiên thạch, mỗi viên gây 35-126 sát thương phép trong bán kính 110. Chủ động đánh được mục tiêu bay. CD: 18.4 giây.", "Gọi 6 thiên thạch, mỗi viên gây 49-162 sát thương phép trong bán kính 110. Chủ động đánh được mục tiêu bay. CD: 18.4 giây." },
					prices_standard = { "153", "153", "153" },
					prices_enhanced = { "153", "153", "153" }
				},
				{
					name = "Xung kích tĩnh điện",
					standard = "Mỗi đòn đánh tạo thêm xung kích trong bán kính 120 quanh mục tiêu, gây 8-16 sát thương phép.",
					enhanced = "Mỗi đòn đánh tạo thêm xung kích trong bán kính 120 quanh mục tiêu, gây 4-38 sát thương điện.",
					levels_standard = { "Mỗi đòn đánh tạo thêm xung kích trong bán kính 120 quanh mục tiêu, gây 8-16 sát thương.", "Mỗi đòn đánh tạo thêm xung kích trong bán kính 120 quanh mục tiêu, gây 18-32 sát thương phép.", "Mỗi đòn đánh tạo thêm xung kích trong bán kính 120 quanh mục tiêu, gây 26-48 sát thương phép." },
					levels_enhanced = { "Mỗi đòn đánh tạo thêm xung kích trong bán kính 120 quanh mục tiêu, gây 4-38 sát thương điện.", "Mỗi đòn đánh tạo thêm xung kích trong bán kính 120 quanh mục tiêu, gây 9-76 sát thương điện.", "Mỗi đòn đánh tạo thêm xung kích trong bán kính 120 quanh mục tiêu, gây 14-114 sát thương điện." },
					prices_standard = { "153", "153", "153" },
					prices_enhanced = { "153", "153", "153" }
				},
			}
		},
		["tower_orc_warriors_den_lvl4"] = {
			doc_id = "",
			title = "Hang chiến binh orc",
			attack = {
				standard = "Tấn công cận chiến, gây sát thương vật lý.",
				enhanced = "Tấn công cận chiến, gây sát thương vật lý."
			},
			change_note = "Nhận xét: Kết hợp kỹ năng 1 để thử hướng doanh trại cận chiến gây sát thương. Máu và giáp thấp, nhưng vẫn hữu ích nếu gây sát thương cao trong khoảng thời gian còn đứng vững.",
			port_note = "Thay đổi khi chuyển sang mod: Tầm gốc của mọi cấp là 290.",
			notes = "",
			skills = {
				{
					name = "Khát chiến",
					standard = "Tăng 40% sức tấn công cho orc.",
					enhanced = "Tăng 40% sức tấn công cho orc.",
					levels_standard = { "Tăng 40% sức tấn công cho orc.", "Tăng 80% sức tấn công cho orc." },
					levels_enhanced = { "Tăng 40% sức tấn công cho orc.", "Tăng 80% sức tấn công cho orc." },
					prices_standard = { "153", "153" },
					prices_enhanced = { "153", "153" }
				},
				{
					name = "Đội trưởng orc",
					standard = "Thăng chức một lính thành đội trưởng: 300 (390) máu, 50 giáp;\nsức tấn công 16-23 (17-25).",
					enhanced = "Thăng chức một lính thành đội trưởng: 300 (390) máu, 50 giáp;\nsức tấn công 37-54 (40-60).",
					levels_standard = { "Thăng chức một lính thành đội trưởng: 300 (390) máu, 50 giáp;\nsức tấn công 16-23 (17-25)." },
					levels_enhanced = { "Thăng chức một lính thành đội trưởng: 300 (390) máu, 50 giáp;\nsức tấn công 37-54 (40-60)." },
					prices_standard = { "127" },
					prices_enhanced = { "127" }
				},
				{
					name = "Khế ước máu",
					standard = "Orc hồi 5 máu mỗi giây.",
					enhanced = "Orc hồi 10 máu mỗi giây.",
					levels_standard = { "Orc hồi 5 máu mỗi giây.", "Orc hồi 10 máu mỗi giây." },
					levels_enhanced = { "Orc hồi 12 máu mỗi giây.", "Orc hồi 25 máu mỗi giây." },
					prices_standard = { "102", "102" },
					prices_enhanced = { "102", "102" }
				},
			}
		},
		["tower_goblirang_lvl4"] = {
			doc_id = "",
			title = "Goblin boomerang",
			attack = {
				standard = "Ném boomerang mỗi 1.4 giây, gây sát thương vật lý theo chỉ số cho kẻ địch trong phạm vi 40/40/40/46. Lượt đi và về gây tối đa 1 lần sát thương mỗi lượt. Khi trúng đòn, mục tiêu bị giảm 50% tốc độ trong 0.1 giây.",
				enhanced = "Ném boomerang mỗi 1.4 giây, gây sát thương vật lý theo chỉ số cho kẻ địch trong phạm vi 40/44/48/52. Lượt đi và về gây tối đa 1 lần sát thương mỗi lượt. Khi trúng đòn, mục tiêu bị giảm 50% tốc độ trong 0.1 giây."
			},
			change_note = "Nhận xét: Chỉ số đánh thường đã đủ, nhưng boomerang lượt về đôi lúc trượt quái; tăng độ rộng đường bay của boomerang thường và lớn.",
			port_note = "Thay đổi khi chuyển sang mod: Tầm gốc mọi cấp 350 (+5%). Kỹ năng 1 bản gốc chiếm một đòn đánh thường; bản mod không chiếm.",
			notes = "",
			skills = {
				{
					name = "Boomerang lớn",
					standard = "Ném boomerang lớn gây 57-85 sát thương vật lý; đường bay rộng 70. Trúng đòn làm chậm 50% trong 0.1 giây. Không chiếm đòn đánh thường và nhận hiệu ứng tăng sát thương. CD: 12 giây.",
					enhanced = "Ném boomerang lớn gây 57-85 sát thương vật lý; đường bay rộng 84. Trúng đòn làm chậm 50% trong 0.1 giây. Không chiếm đòn đánh thường và nhận hiệu ứng tăng sát thương. CD: 8.4 giây.",
					levels_standard = { "Ném boomerang lớn gây 57-85 sát thương vật lý; đường bay rộng 70. Trúng đòn làm chậm 50% trong 0.1 giây. Không chiếm đòn đánh thường và nhận hiệu ứng tăng sát thương. CD: 12 giây.", "Ném boomerang lớn gây 69-100 sát thương vật lý; đường bay rộng 70. Trúng đòn làm chậm 50% trong 0.1 giây. Không chiếm đòn đánh thường và nhận hiệu ứng tăng sát thương. CD: 12 giây.", "Ném boomerang lớn gây 96-115 sát thương vật lý; đường bay rộng 70. Trúng đòn làm chậm 50% trong 0.1 giây. Không chiếm đòn đánh thường và nhận hiệu ứng tăng sát thương. CD: 12 giây." },
					levels_enhanced = { "Ném boomerang lớn gây 57-85 sát thương vật lý; đường bay rộng 84. Trúng đòn làm chậm 50% trong 0.1 giây. Không chiếm đòn đánh thường và nhận hiệu ứng tăng sát thương. CD: 8.4 giây.", "Ném boomerang lớn gây 69-100 sát thương vật lý; đường bay rộng 84. Trúng đòn làm chậm 50% trong 0.1 giây. Không chiếm đòn đánh thường và nhận hiệu ứng tăng sát thương. CD: 8.4 giây.", "Ném boomerang lớn gây 96-115 sát thương vật lý; đường bay rộng 84. Trúng đòn làm chậm 50% trong 0.1 giây. Không chiếm đòn đánh thường và nhận hiệu ứng tăng sát thương. CD: 8.4 giây." },
					prices_standard = { "170", "85", "85" },
					prices_enhanced = { "170", "85", "85" }
				},
				{
					name = "Đòn vào đầu",
					standard = "Mỗi đòn đánh có 5% cơ hội làm choáng 1.0 giây.",
					enhanced = "Mỗi đòn đánh có 7% cơ hội làm choáng 1.0 giây.",
					levels_standard = { "Mỗi đòn đánh có 5% cơ hội làm choáng 1.0 giây.", "Mỗi đòn đánh có 10% cơ hội làm choáng 1.0 giây.", "Mỗi đòn đánh có 15% cơ hội làm choáng 1.0 giây." },
					levels_enhanced = { "Mỗi đòn đánh có 7% cơ hội làm choáng 1.0 giây.", "Mỗi đòn đánh có 14% cơ hội làm choáng 1.0 giây.", "Mỗi đòn đánh có 20% cơ hội làm choáng 1.0 giây." },
					prices_standard = { "110", "110", "110" },
					prices_enhanced = { "110", "110", "110" }
				},
				{
					name = "Tổ ong vò vẽ",
					standard = "Ném tổ ong tồn tại 7 giây, gây 5 sát thương vật lý mỗi 0.3 giây cho mục tiêu và kẻ địch trong bán kính 80. Tổng cộng 100 sát thương trong 7 giây.\nThời gian hồi chưa được ghi trong mô tả gốc.",
					enhanced = "Ném tổ ong tồn tại 7 giây, gây 5 sát thương vật lý mỗi 0.3 giây cho mục tiêu và kẻ địch trong bán kính 80. Tổng cộng 100 sát thương trong 7 giây.\nCD: 1814 giây.",
					levels_standard = { "Ném tổ ong tồn tại 7 giây, gây 5 sát thương vật lý mỗi 0.3 giây cho mục tiêu và kẻ địch trong bán kính 80. Tổng cộng 100 sát thương trong 7 giây.\nCD: 18 giây.", "Ném tổ ong tồn tại 7 giây, gây 10 sát thương vật lý mỗi 0.3 giây cho mục tiêu và kẻ địch trong bán kính 80. Tổng cộng 200 sát thương trong 7 giây.\nCD: 18 giây.", "Ném tổ ong tồn tại 7 giây, gây 15 sát thương vật lý mỗi 0.3 giây cho mục tiêu và kẻ địch trong bán kính 80. Tổng cộng 300 sát thương trong 7 giây.\nCD: 18 giây." },
					levels_enhanced = { "Ném tổ ong tồn tại 7 giây, gây 5 sát thương vật lý mỗi 0.3 giây cho mục tiêu và kẻ địch trong bán kính 80. Tổng cộng 100 sát thương trong 7 giây.\nCD: 14 giây.", "Ném tổ ong tồn tại 7 giây, gây 10 sát thương vật lý mỗi 0.3 giây cho mục tiêu và kẻ địch trong bán kính 80. Tổng cộng 200 sát thương trong 7 giây.\nCD: 14 giây.", "Ném tổ ong tồn tại 7 giây, gây 15 sát thương vật lý mỗi 0.3 giây cho mục tiêu và kẻ địch trong bán kính 80. Tổng cộng 300 sát thương trong 7 giây.\nCD: 14 giây." },
					prices_standard = { "170", "170", "170" },
					prices_enhanced = { "170", "170", "170" }
				},
			}
		},
		["tower_rocket_riders_lvl4"] = {
			doc_id = "",
			title = "Goblin cưỡi tên lửa",
			attack = {
				standard = "Bắn đạn pháo mỗi 3/3/3/2.8 giây, gây sát thương pháo trong bán kính 90 (108).",
				enhanced = "Mỗi 3/3/3/2.8 giây, một goblin cưỡi tên lửa lao xuống đất, nổ gây sát thương pháo trong bán kính 112.5 (135). Sau vụ nổ, goblin hạ đất và chặn đường: máu 1, khoảng đánh 0.8, sát thương pháo, sức tấn công 8-14/25-36/50-74/81-114. Kịp chém trước khi quái ra tay thì thành anh hùng; không thì chỉ là bia đỡ đạn."
			},
			change_note = "Nhận xét: Tên lửa trong Vengeance đời đầu rất kém hiệu quả: tháp 1010 vàng đổi lấy đòn 64-92 (70-101)/2.8; nâng đủ lên tới 2453 vàng. Sau một lần tăng vẫn yếu, còn 3 kỹ năng đều khó dùng. Vì vậy, đòn đánh tạo thêm vật chặn dùng một lần. Trong 3 kỹ năng: 1 có chỉ số thấp và dễ ném vào đường trống; 2 nâng cấp 1 không đáng; 3 còn làm giảm sát thương. Do chỉ số quá thấp, tăng toàn diện 3 kỹ năng.",
			port_note = "Thay đổi khi chuyển sang mod: Tầm gốc mọi cấp 330/350/380/400.",
			notes = "",
			skills = {
				{
					name = "Bãi mìn",
					standard = "Đặt mìn trên đường, nổ gây 60 sát thương pháo diện rộng cho tối đa 5 kẻ địch. CD: 8 giây. Mìn tồn tại tối đa 50 giây.",
					enhanced = "Đặt mìn trên đường, nổ gây 95 sát thương pháo diện rộng cho tối đa 5 kẻ địch. CD: 8 giây. Mìn tồn tại tối đa 50 giây.",
					levels_standard = { "Đặt mìn trên đường, nổ gây 60 sát thương pháo diện rộng cho tối đa 5 kẻ địch. CD: 8 giây. Mìn tồn tại tối đa 50 giây.", "Đặt mìn trên đường, nổ gây 125 sát thương pháo diện rộng cho tối đa 5 kẻ địch. CD: 8 giây. Mìn tồn tại tối đa 50 giây.", "Đặt mìn trên đường, nổ gây 190 sát thương pháo diện rộng cho tối đa 5 kẻ địch. CD: 8 giây. Mìn tồn tại tối đa 50 giây."},
					levels_enhanced = { "Đặt mìn trên đường, nổ gây 95 sát thương pháo diện rộng cho tối đa 5 kẻ địch. CD: 8 giây. Mìn tồn tại tối đa 50 giây.", "Đặt mìn trên đường, nổ gây 190 sát thương pháo diện rộng cho tối đa 5 kẻ địch. CD: 8 giây. Mìn tồn tại tối đa 50 giây.", "Đặt mìn trên đường, nổ gây 285 sát thương pháo diện rộng cho tối đa 5 kẻ địch. CD: 8 giây. Mìn tồn tại tối đa 50 giây."},
					prices_standard = { "191", "191", "191" },
					prices_enhanced = { "161", "161", "161" }
				},
				{
					name = "Tên lửa Nitro",
					standard = "Thay một đòn đánh thường bằng tên lửa cường hóa, gây 100 (110) sát thương pháo diện rộng. Tầm dùng 500, bán kính nổ 100 (120). CD: 12 giây.",
					enhanced = "Thay một đòn đánh thường bằng tên lửa cường hóa, gây 100 (110) sát thương pháo diện rộng. Tầm dùng 500, bán kính nổ 200 (240). CD: 12 giây.",
					levels_standard = { "Thay một đòn đánh thường bằng tên lửa cường hóa, gây 100 (110) sát thương pháo diện rộng. Tầm dùng 500, bán kính nổ 100 (120). CD: 12 giây.", "Thay một đòn đánh thường bằng tên lửa cường hóa, gây 180 (198) sát thương pháo diện rộng. Tầm dùng 500, bán kính nổ 100 (120). CD: 12 giây." },
					levels_enhanced = { "Thay một đòn đánh thường bằng tên lửa cường hóa, gây 208 (228) sát thương pháo diện rộng. Tầm dùng 500, bán kính nổ 200 (240). CD: 12 giây.", "Thay một đòn đánh thường bằng tên lửa cường hóa, gây 311 (342) sát thương pháo diện rộng. Tầm dùng 500, bán kính nổ 200 (240). CD: 12 giây." },
					prices_standard = { "127", "127" },
					prices_enhanced = { "127", "127" }
				},
				{
					name = "Động cơ lỗi",
					standard = "Bắn tên lửa lỗi nổ giữa trời, tạo 5 mảnh phủ một đoạn đường. Mỗi mảnh gây 22 sát thương pháo diện rộng, bán kính 140 (168). Thay một đòn đánh thường, chủ động đánh được mục tiêu bay; một kẻ địch có thể trúng nhiều mảnh. CD: 20 giây.",
					enhanced = "Bắn tên lửa lỗi nổ giữa trời, tạo 5 mảnh phủ một đoạn đường. Mỗi mảnh gây 44 sát thương pháo diện rộng, bán kính 140 (168). Thay một đòn đánh thường, chủ động đánh được mục tiêu bay; một kẻ địch có thể trúng nhiều mảnh. CD: 20 giây.",
					levels_standard = { "Bắn tên lửa lỗi nổ giữa trời, tạo 5 mảnh phủ một đoạn đường. Mỗi mảnh gây 22 sát thương pháo diện rộng, bán kính 140 (168). Thay một đòn đánh thường, chủ động đánh được mục tiêu bay; một kẻ địch có thể trúng nhiều mảnh. CD: 20 giây.", "Bắn tên lửa lỗi nổ giữa trời, tạo 7 mảnh phủ một đoạn đường. Mỗi mảnh gây 32 sát thương pháo diện rộng, bán kính 140 (168). Thay một đòn đánh thường, chủ động đánh được mục tiêu bay; một kẻ địch có thể trúng nhiều mảnh. CD: 20 giây." },
					levels_enhanced = { "Bắn tên lửa lỗi nổ giữa trời, tạo 5 mảnh phủ một đoạn đường. Mỗi mảnh gây 44 sát thương pháo diện rộng, bán kính 140 (168). Thay một đòn đánh thường, chủ động đánh được mục tiêu bay; một kẻ địch có thể trúng nhiều mảnh. CD: 20 giây.", "Bắn tên lửa lỗi nổ giữa trời, tạo 7 mảnh phủ một đoạn đường. Mỗi mảnh gây 64 sát thương pháo diện rộng, bán kính 140 (168). Thay một đòn đánh thường, chủ động đánh được mục tiêu bay; một kẻ địch có thể trúng nhiều mảnh. CD: 20 giây." },
					prices_standard = { "127", "127" },
					prices_enhanced = { "127", "127" }
				},
			}
		},
		["tower_balloon_lvl4"] = {
			doc_id = "",
			title = "Khí cầu chiến tranh goblin",
			attack = {
				standard = "Có thể tập kết khí cầu trong phạm vi cho phép. Ném bom vào kẻ địch trong bán kính 210 quanh khí cầu; bom gây sát thương pháo trong bán kính 70 (84).",
				enhanced = "Có thể tập kết khí cầu trong phạm vi cho phép. Ném bom vào kẻ địch trong bán kính 256 quanh khí cầu; bom gây sát thương pháo trong bán kính 85 (102)."
			},
			change_note = "Nhận xét: Sát thương theo thời gian đã đủ, nhưng tầm đánh 210 và bán kính nổ 84 quá nhỏ. Khoảng trống giữa các lần dùng kỹ năng 1 cũng quá dài.",
			port_note = "Thay đổi khi chuyển sang mod: Phạm vi tập kết cấp 4 bản gốc là 380.\nKỹ năng 2 tăng tầm cho tháp quanh khí cầu, không phải quanh bệ tháp. Khi khí cầu bắt đầu di chuyển, hiệu ứng ở vị trí cũ mất ngay; không tăng tầm khi đang bay, đến vị trí mới mới áp dụng lại. Kỹ năng 3 bản gốc thả lính xuống chậm hơn.",
			notes = "",
			skills = {
				{
					name = "Thùng nhựa đường",
					standard = "Ném thùng nhựa đường xuống đường đi, làm chậm 20% kẻ địch trong bán kính 120 suốt 6 giây. CD: 15 giây.",
					enhanced = "Ném thùng nhựa đường xuống đường đi, làm chậm 20% kẻ địch trong bán kính 120 suốt 12 giây. CD: 15 giây.",
					levels_standard = { "Ném thùng nhựa đường xuống đường đi, làm chậm 20% kẻ địch trong bán kính 120 suốt 6 giây. CD: 15 giây.", "Ném thùng nhựa đường xuống đường đi, làm chậm 40% kẻ địch trong bán kính 120 suốt 6 giây. CD: 15 giây.", "Ném thùng nhựa đường xuống đường đi, làm chậm 60% kẻ địch trong bán kính 120 suốt 6 giây. CD: 15 giây." },
					levels_enhanced = { "Ném thùng nhựa đường xuống đường đi, làm chậm 20% kẻ địch trong bán kính 120 suốt 12 giây. CD: 15 giây.", "Ném thùng nhựa đường xuống đường đi, làm chậm 40% kẻ địch trong bán kính 120 suốt 12 giây. CD: 15 giây.", "Ném thùng nhựa đường xuống đường đi, làm chậm 60% kẻ địch trong bán kính 120 suốt 12 giây. CD: 15 giây." },
					prices_standard = { "68", "68", "68" },
					prices_enhanced = { "136", "136", "136" }
				},
				{
					name = "Trinh sát goblin",
					standard = "Tăng 20% tầm đánh cho các tháp khác trong bán kính 400 quanh khí cầu. Khi khí cầu di chuyển, hiệu ứng mất ngay và được tính lại khi tới vị trí mới.",
					enhanced = "Tăng 20% tầm đánh cho các tháp khác trong bán kính 400 quanh khí cầu. Khi khí cầu di chuyển, hiệu ứng mất ngay và được tính lại khi tới vị trí mới.",
					levels_standard = { "Tăng 20% tầm đánh cho các tháp khác trong bán kính 400 quanh khí cầu. Khi khí cầu di chuyển, hiệu ứng mất ngay và được tính lại khi tới vị trí mới." },
					levels_enhanced = { "Tăng 20% tầm đánh cho các tháp khác trong bán kính 400 quanh khí cầu. Khi khí cầu di chuyển, hiệu ứng mất ngay và được tính lại khi tới vị trí mới." },
					prices_standard = { "212" },
					prices_enhanced = { "212" }
				},
				{
					name = "Lính đổ bộ",
					standard = "Thả lính ném bom chiến đấu 12 giây. Máu 60, không đánh cận chiến và không bị kẻ địch cận chiến tấn công. Ném bom mỗi 1 giây, gây 16-24 sát thương trong bán kính 72. CD: 12 giây.",
					enhanced = "Thả lính ném bom chiến đấu 12 giây. Máu 60, không đánh cận chiến và không bị kẻ địch cận chiến tấn công. Ném bom mỗi 1 giây, gây 16-24 sát thương trong bán kính 72. CD: 12 giây.",
					levels_standard = { "Thả lính ném bom chiến đấu 12 giây. Máu 60, không đánh cận chiến. Ném bom mỗi 1 giây, gây 16-24 sát thương trong bán kính 72. CD: 12 giây." },
					levels_enhanced = { "Thả lính ném bom chiến đấu 12 giây. Máu 60, không đánh cận chiến. Ném bom mỗi 1 giây, gây 16-24 sát thương trong bán kính 72. CD: 12 giây." },
					prices_standard = { "136" },
					prices_enhanced = { "136" }
				},
			}
		},
		["tower_infernal_mage_lvl4"] = {
			doc_id = "",
			title = "Pháp sư địa ngục",
			attack = {
				standard = "Bắn đạn phép mỗi 1.8, gây sát thương phép.",
				enhanced = "Bắn đạn phép mỗi 1.75, gây sát thương phép. Nội tại: đòn đánh thường và kỹ năng gây cháy có thể lan truyền, gây 4/8/13/18 sát thương chuẩn mỗi 0.4 giây trong 1.5 giây. Kẻ địch chết khi đang cháy phát nổ, gây 12/24/39/54 sát thương phép trong bán kính 84 và lây hiệu ứng cháy kéo dài 1.5 giây."
			},
			change_note = "Nhận xét: Đòn đánh thường đã khá mạnh cả trong bản gốc lẫn xuyên các phần, nhưng ba kỹ năng có phạm vi nhỏ, dịch chuyển ngắn và vai trò chưa rõ. Pháp sư orc hệ điện gây choáng điện, trong khi pháp sư hệ lửa lại không gây cháy, điều này chưa hợp lý.",
			port_note = "Thay đổi khi chuyển sang mod: Tầm gốc của mọi cấp là 350. Nâng cấp chí mạng đã được tính vào chỉ số.",
			notes = "",
			skills = {
				{
					name = "Cổ ngữ thiêu giáp",
					standard = "Tạo cổ ngữ lửa bán kính 120, tác động tối đa 5 kẻ địch đi qua: giảm 25 giáp và 30 kháng phép trong 5 giây. CD: 12 giây.",
					enhanced = "Tạo cổ ngữ lửa bán kính 160, tác động tối đa 99 kẻ địch đi qua: giảm 25 giáp và 30 kháng phép trong 15 giây. CD: 12 giây.",
					levels_standard = { "Tạo cổ ngữ lửa bán kính 120, tác động tối đa 5 kẻ địch đi qua: giảm 25 giáp và 30 kháng phép. CD: 12 giây. Mô tả gốc chưa ghi thời lượng giảm kháng.", "Tạo cổ ngữ lửa bán kính 120, tác động tối đa 5 kẻ địch đi qua: giảm 50 giáp và 60 kháng phép trong 5 giây. CD: 12 giây." },
					levels_enhanced = { "Tạo cổ ngữ lửa bán kính 160, tác động tối đa 99 kẻ địch đi qua: giảm 25 giáp và 30 kháng phép trong 15 giây. CD: 12 giây.", "Tạo cổ ngữ lửa bán kính 200, tác động tối đa 99 kẻ địch đi qua: giảm 50 giáp và 60 kháng phép trong 15 giây. CD: 12 giây." },
					prices_standard = { "102", "102" },
					prices_enhanced = { "102", "102" }
				},
				{
					name = "Khe nứt dung nham",
					standard = "Tạo 8 khe dung nham trong vùng 180, cách nhau 45. Mỗi khe gây 33-56 sát thương phép trong bán kính 60. Không chủ động đánh mục tiêu bay. CD: 20 giây.",
					enhanced = "Tạo 8 khe dung nham trong vùng 180, cách nhau 60. Mỗi khe gây 33-56 sát thương phép trong bán kính 90. Chủ động đánh được mục tiêu bay. CD: 17.5 giây.",
					levels_standard = { "Tạo 8 khe dung nham trong vùng 180, cách nhau 45. Mỗi khe gây 33-56 sát thương phép trong vùng. Không chủ động đánh mục tiêu bay. CD: 20 giây.", "Tạo 8 khe dung nham trong vùng 180, cách nhau 45. Mỗi khe gây 66-98 sát thương phép trong vùng. Không chủ động đánh mục tiêu bay. CD: 20 giây.", "Tạo 8 khe dung nham trong vùng 180, cách nhau 45. Mỗi khe gây 100-130 sát thương phép trong vùng. Không chủ động đánh mục tiêu bay. CD: 20 giây." },
					levels_enhanced = { "Tạo 8 khe dung nham trong vùng 180, cách nhau 60. Mỗi khe gây 33-56 sát thương phép trong bán kính 60120. Chủ động đánh được mục tiêu bay. CD: 17.5 giây.", "Tạo 8 khe dung nham trong vùng 180, cách nhau 60. Mỗi khe gây 66-98 sát thương phép trong bán kính 60120. Chủ động đánh được mục tiêu bay. CD: 17.5 giây.", "Tạo 8 khe dung nham trong vùng 180, cách nhau 60. Mỗi khe gây 100-130 sát thương phép trong bán kính 60120. Chủ động đánh được mục tiêu bay. CD: 17.5 giây."},
					prices_standard = { "170", "170", "170" },
					prices_enhanced = { "170", "170", "170" }
				},
				{
					name = "Cổng địa ngục",
					standard = "Tạo vòng dịch chuyển bán kính 120, đẩy tối đa 4 kẻ địch lùi 200 khoảng cách. CD: 22 giây.",
					enhanced = "Tạo vòng dịch chuyển bán kính 160, đẩy tối đa 4 kẻ địch lùi 350 khoảng cách. CD: 17.5 giây.",
					levels_standard = { "Tạo vòng dịch chuyển bán kính 120, đẩy tối đa 4 kẻ địch lùi 200 khoảng cách. CD: 22 giây.", "Tạo vòng dịch chuyển bán kính 120, đẩy tối đa 6 kẻ địch lùi 200 khoảng cách. CD: 22 giây." },
					levels_enhanced = { "Tạo vòng dịch chuyển bán kính 120, đẩy tối đa 4 kẻ địch lùi 350 khoảng cách. CD: 14 giây.", "Tạo vòng dịch chuyển bán kính 120, đẩy tối đa 6 kẻ địch lùi 350 khoảng cách. CD: 14 giây." },
					prices_standard = { "187", "187" },
					prices_enhanced = { "187", "93" }
				},
			}
		},
		["tower_shadow_archer_lvl4"] = {
			doc_id = "",
			title = "Cung thủ bóng tối",
			attack = {
				standard = "Bắn một mũi tên mỗi 0.7 giây, gây sát thương vật lý.",
				enhanced = "Bắn một mũi tên mỗi 0.7 giây, gây sát thương vật lý và bỏ qua 75 giáp của địch."
			},
			change_note = "Nhận xét: Khôi phục lỗi xuyên giáp của Cung thủ bóng tối phiên bản cũ; điều chỉnh kỹ năng 2/3 cho hữu dụng hơn.",
			port_note = "Thay đổi khi chuyển sang mod: Tầm gốc mọi cấp 300/330/360/400 (+5%).",
			notes = "",
			skills = {
				{
					name = "Dấu ấn bóng tối",
					standard = "Mỗi 18 giây bắn tên đánh dấu, khiến mục tiêu nhận thêm 30% sát thương trong 5 giây.",
					enhanced = "Mỗi 10 giây bắn tên đánh dấu, khiến mục tiêu nhận thêm 30% sát thương trong 5 giây.",
					levels_standard = { "Mỗi 18 giây bắn tên đánh dấu, khiến mục tiêu nhận thêm 30% sát thương trong 5 giây.", "Mỗi 18 giây bắn tên đánh dấu, khiến mục tiêu nhận thêm 60% sát thương trong 5 giây.", "Mỗi 18 giây bắn tên đánh dấu, khiến mục tiêu nhận thêm 100% sát thương trong 5 giây." },
					levels_enhanced = { "Mỗi 12 giây bắn tên đánh dấu, khiến mục tiêu nhận thêm 30% sát thương trong 6 giây.", "Mỗi 12 giây bắn tên đánh dấu, khiến mục tiêu nhận thêm 60% sát thương trong 7.5 giây.", "Mỗi 12 giây bắn tên đánh dấu, khiến mục tiêu nhận thêm 100% sát thương trong 9 giây." },
					prices_standard = { "102", "102", "102" },
					prices_enhanced = { "102", "102", "102" }
				},
				{
					name = "Lưỡi kiếm tử thần",
					standard = "Dịch chuyển ra sau kẻ địch và tiêu diệt ngay. CD: 40 giây.",
					enhanced = "Dịch chuyển ra sau kẻ địch và tiêu diệt ngay. CD: 40 giây.",
					levels_standard = { "Dịch chuyển ra sau kẻ địch và tiêu diệt ngay. CD: 40 giây.", "Dịch chuyển ra sau kẻ địch và tiêu diệt ngay. CD: 32 giây.", "Dịch chuyển ra sau kẻ địch và tiêu diệt ngay. CD: 24 giây." },
					levels_enhanced = { "Dịch chuyển ra sau kẻ địch và tiêu diệt ngay. CD: 36 giây.", "Dịch chuyển ra sau kẻ địch và tiêu diệt ngay. CD: 29 giây.", "Dịch chuyển ra sau kẻ địch và tiêu diệt ngay. CD: 22 giây." },
					prices_standard = { "255", "85", "85" },
					prices_enhanced = { "170", "85", "85" }
				},
				{
					name = "Tổ quạ",
					standard = "Triệu hồi quạ gây 2 sát thương vật lý mỗi 0.5 giây.",
					enhanced = "Triệu hồi quạ gây 9 sát thương vật lý mỗi 0.5 giây.",
					levels_standard = { "Triệu hồi quạ gây 2 sát thương vật lý mỗi 0.5 giây.", "Triệu hồi quạ gây 4 sát thương vật lý mỗi 0.5 giây." },
					levels_enhanced = { "Triệu hồi quạ gây 9 sát thương vật lý mỗi 0.5 giây.", "Triệu hồi quạ gây 18 sát thương vật lý mỗi 0.5 giây." },
					prices_standard = { "170", "170" },
					prices_enhanced = { "170", "170" }
				},
			}
		},
		["tower_spirit_mausoleum_lvl4"] = {
			doc_id = "",
			title = "Lăng mộ linh hồn",
			attack = {
				standard = "Bắn linh hồn mỗi 1.45 giây, gây sát thương phép. Khi không có kẻ địch, tích trữ tối đa 3 linh hồn.",
				enhanced = "Bắn linh hồn mỗi 1.45 giây, gây sát thương phép. Khi không có kẻ địch, tích trữ tối đa 3 linh hồn."
			},
			change_note = "Nhận xét: Gargoyle trước khi bị giảm sức mạnh có 390 máu. Kỹ năng 2 được chỉnh để khắc phục sát thương đánh thường quá thấp và kỹ năng ít hữu ích.",
			port_note = "Thay đổi khi chuyển sang mod: Tầm gốc mọi cấp 350; nâng cấp chí mạng đã được tính vào chỉ số.\nCơ chế chiếm hữu không bảo đảm tái hiện 100% bản gốc, hoặc khớp 100% khi kết hợp tháp phần 4 khác. Đây là tháp phát sinh nhiều lỗi nhất khi chuyển phần 4; một số quái vẫn lỗi khi bị chiếm hữu. Cần phát hiện và xử lý từng trường hợp, hãy gửi phản hồi khi gặp lỗi.",
			notes = "",
			skills = {
				{
					name = "Vệ binh gargoyle",
					standard = "Triệu hồi 1 gargoyle có 180 (234) máu và 60 giáp.",
					enhanced = "Triệu hồi 1 gargoyle có 240 (312) máu và 60 giáp.",
					levels_standard = { "Triệu hồi 1 gargoyle có 180 (234) máu và 60 giáp.", "Triệu hồi 2 gargoyle có 180 (234) máu và 60 giáp." },
					levels_enhanced = { "Triệu hồi 1 gargoyle có 300 (390) máu và 60 giáp.", "Triệu hồi 2 gargoyle có 300 (390) máu và 60 giáp." },
					prices_standard = { "212", "212" },
					prices_enhanced = { "212", "212" }
				},
				{
					name = "Thông linh",
					standard = "Tăng số linh hồn tích trữ tối đa lên 4.",
					enhanced = "Tăng số linh hồn tích trữ tối đa lên 4; tăng sát thương mỗi linh hồn thành 57-93 (68-111).",
					levels_standard = { "Tăng số linh hồn tích trữ tối đa lên 4.", "Tăng số linh hồn tích trữ tối đa lên 5." },
					levels_enhanced = { "Tích trữ tối đa 4 linh hồn và hấp thụ sức mạnh người chết: kẻ địch càng mạnh, linh hồn càng mạnh. Kẻ địch chết trong bán kính 400 hóa hồn chiếm hữu mục tiêu khác, gây sát thương phép bằng [sát thương đánh thường × 50% + máu tối đa của kẻ địch đã chết × 3%].", "Tích trữ tối đa 5 linh hồn và hấp thụ sức mạnh người chết: kẻ địch càng mạnh, linh hồn càng mạnh. Kẻ địch chết trong bán kính 400 hóa hồn mạnh hơn chiếm hữu mục tiêu khác, gây sát thương phép bằng [sát thương đánh thường × 100% + máu tối đa của kẻ địch đã chết × 8%]."},
					prices_standard = { "127", "85" },
					prices_enhanced = { "357", "357" }
				},
				{
					name = "Chiếm hữu linh hồn",
					standard = "Chiếm hữu kẻ địch nhiều máu nhất trong tầm, tạm thời biến nó thành đồng minh. Điều khiển nó đi về điểm xuất hiện quái, chặn và đánh kẻ địch trên đường trong 10 giây. CD: 23 giây.",
					enhanced = "Chiếm hữu một kẻ địch, tạm thời biến nó thành đồng minh. Điều khiển nó đi về điểm xuất hiện quái, chặn và đánh kẻ địch trên đường trong 10 giây. CD: 23 giây.",
					levels_standard = { "Chiếm hữu kẻ địch nhiều máu nhất trong tầm, tạm thời biến nó thành đồng minh. Điều khiển nó đi về điểm xuất hiện quái, chặn và đánh kẻ địch trên đường trong 10 giây. CD: 23 giây.", "Chiếm hữu kẻ địch nhiều máu nhất trong tầm, tạm thời biến nó thành đồng minh. Điều khiển nó đi về điểm xuất hiện quái, chặn và đánh kẻ địch trên đường trong 10 giây. CD: 20 giây.", "Chiếm hữu kẻ địch nhiều máu nhất trong tầm, tạm thời biến nó thành đồng minh. Điều khiển nó đi về điểm xuất hiện quái, chặn và đánh kẻ địch trên đường trong 10 giây. CD: 17 giây."},
					levels_enhanced = { "Chiếm hữu kẻ địch nhiều máu nhất trong tầm, tạm thời biến nó thành đồng minh. Điều khiển nó đi về điểm xuất hiện quái, chặn và đánh kẻ địch trên đường trong 12 giây. CD: 25 giây.", "Chiếm hữu hai kẻ địch nhiều máu nhất trong tầm, tạm thời biến chúng thành đồng minh. Điều khiển chúng đi về điểm xuất hiện quái, chặn và đánh kẻ địch trên đường trong 13 giây. CD: 24 giây.", "Chiếm hữu ba kẻ địch nhiều máu nhất trong tầm, tạm thời biến chúng thành đồng minh. Điều khiển chúng đi về điểm xuất hiện quái, chặn và đánh kẻ địch trên đường trong 14 giây. CD: 23 giây." },
					prices_standard = { "170", "85", "85" },
					prices_enhanced = { "195", "195", "195" }
				},
			}
		},
		["tower_melting_furnace_lvl4"] = {
			doc_id = "",
			title = "Lò nung bùng nổ",
			attack = {
				standard = "Chấn động mặt đất mỗi 4.0 giây, gây sát thương vật lý bỏ qua 75% giáp cho mọi kẻ địch trong tầm và làm choáng 0.3/0.4/0.5/0.6 giây.",
				enhanced = "Chấn động mặt đất mỗi 3.5 giây, gây sát thương vật lý bỏ qua 75% giáp cho mọi kẻ địch trong tầm và làm choáng 0.8 giây."
			},
			change_note = "Nhận xét: Vị trí tháp ở 3 phần trước tập trung, nên Lò nung đã có thể kết hợp Pháp sư bí thuật thành trận địa tăng sát thương. Chỉ tăng nhẹ đòn đánh thường, không đổi các phần khác.",
			port_note = "Thay đổi khi chuyển sang mod: Tầm gốc mọi cấp 320. Vì đánh toàn vùng, tăng phạm vi ít hơn các tháp cùng loại tầm 320.",
			notes = "",
			skills = {
				{
					name = "Than cháy",
					standard = "Ném 3 cục than phủ một đoạn đường trong 6 giây. Kẻ địch đứng trên than chịu 5 sát thương vật lý mỗi 0.2 giây, tối đa 150 sát thương. Bán kính mỗi cục 75.",
					enhanced = "Ném 3 cục than phủ một đoạn đường trong 6 giây. Kẻ địch đứng trên than chịu 5 sát thương vật lý mỗi 0.2 giây, tối đa 150 sát thương. Bán kính mỗi cục 75.",
					levels_standard = { "Ném 3 cục than phủ một đoạn đường trong 6 giây. Kẻ địch đứng trên than chịu 5 sát thương vật lý mỗi 0.2 giây, tối đa 150 sát thương. Bán kính mỗi cục 75.", "Ném 5 cục than phủ một đoạn đường trong 6 giây. Kẻ địch đứng trên than chịu 8 sát thương vật lý mỗi 0.2 giây, tối đa 240 sát thương. Bán kính mỗi cục 75." },
					levels_enhanced = { "Ném 3 cục than phủ một đoạn đường trong 6 giây. Kẻ địch đứng trên than chịu 5 sát thương vật lý mỗi 0.2 giây, tối đa 150 sát thương. Bán kính mỗi cục 75.", "Ném 5 cục than phủ một đoạn đường trong 6 giây. Kẻ địch đứng trên than chịu 8 sát thương vật lý mỗi 0.2 giây, tối đa 240 sát thương. Bán kính mỗi cục 75." },
					prices_standard = { "119", "119" },
					prices_enhanced = { "119", "119" }
				},
				{
					name = "Nhiệt luyện",
					standard = "Tăng 15% sát thương cho tất cả tháp khác trong bán kính 530 quanh lò.",
					enhanced = "Tăng 15% sát thương cho tất cả tháp khác trong bán kính 530 quanh lò.",
					levels_standard = { "Tăng 15% sát thương cho tất cả tháp khác trong bán kính 530 quanh lò.", "Tăng 30% sát thương cho tất cả tháp khác trong bán kính 530 quanh lò." },
					levels_enhanced = { "Tăng 15% sát thương cho tất cả tháp khác trong bán kính 530 quanh lò.", "Tăng 30% sát thương cho tất cả tháp khác trong bán kính 530 quanh lò." },
					prices_standard = { "170", "170" },
					prices_enhanced = { "170", "170" }
				},
				{
					name = "Nhiên liệu tăng tốc",
					standard = "Nạp nhiên liệu mạnh, tăng tốc độ đánh thành 2.0 trong 10 giây. CD: 30 giây.",
					enhanced = "Nạp nhiên liệu mạnh, tăng tốc độ đánh thành 2.0 trong 10 giây. CD: 30 giây.",
					levels_standard = { "Nạp nhiên liệu mạnh, tăng tốc độ đánh thành 2.0 trong 10 giây. CD: 30 giây." },
					levels_enhanced = { "Nạp nhiên liệu mạnh, tăng tốc độ đánh thành 2.0 trong 10 giây. CD: 30 giây." },
					prices_standard = { "212" },
					prices_enhanced = { "212" }
				},
			}
		},
		["tower_dark_knights_lvl4"] = {
			doc_id = "",
			title = "Đại sảnh hắc kỵ sĩ",
			attack = {
				standard = "Doanh trại 2 lính, đánh cận chiến gây sát thương vật lý.",
				enhanced = "Cấp 1 có 2 lính; cấp 2-4 có 3 lính. Đánh cận chiến gây sát thương vật lý."
			},
			change_note = "Nhận xét: Hắc kỵ sĩ phần 4 đánh chậm và chỉ có 2 lính, nên điều chỉnh hai điểm này đồng thời giảm máu. Vì nhiều đơn vị xuyên các phần tăng giáp, giáp của đơn vị giáp cao chỉ nên tối đa 80; Hồn chiến binh cũng tương tự. Với kỹ năng 3, tác giả chưa tìm được hướng cải thiện.",
			port_note = "Thay đổi khi chuyển sang mod: Tầm gốc của mọi cấp là 290.",
			notes = "",
			skills = {
				{
					name = "Đòn đánh tàn bạo",
					standard = "Mỗi đòn đánh của hắc kỵ sĩ có 2% cơ hội tiêu diệt ngay mục tiêu.",
					enhanced = "Mỗi đòn đánh của hắc kỵ sĩ có 2.4% cơ hội tiêu diệt ngay mục tiêu.",
					levels_standard = { "Mỗi đòn đánh của hắc kỵ sĩ có 2% cơ hội tiêu diệt ngay mục tiêu.", "Mỗi đòn đánh của hắc kỵ sĩ có 4% cơ hội tiêu diệt ngay mục tiêu.", "Mỗi đòn đánh của hắc kỵ sĩ có 6% cơ hội tiêu diệt ngay mục tiêu." },
					levels_enhanced = { "Mỗi đòn đánh của hắc kỵ sĩ có 2.6% cơ hội tiêu diệt ngay mục tiêu.", "Mỗi đòn đánh của hắc kỵ sĩ có 5.2% cơ hội tiêu diệt ngay mục tiêu.", "Mỗi đòn đánh của hắc kỵ sĩ có 7.8% cơ hội tiêu diệt ngay mục tiêu." },
					prices_standard = { "238", "238", "238" },
					prices_enhanced = { "238", "238", "238" }
				},
				{
					name = "Giáp gai",
					standard = "Mỗi lần nhận sát thương, phản lại 15 sát thương vật lý.",
					enhanced = "Mỗi lần nhận sát thương, phản lại 15 sát thương chuẩn.",
					levels_standard = { "Mỗi lần nhận sát thương, phản lại 15 sát thương vật lý.", "Mỗi lần nhận sát thương, phản lại 30 sát thương vật lý.", "Mỗi lần nhận sát thương, phản lại 45 sát thương vật lý." },
					levels_enhanced = { "Mỗi lần nhận sát thương, phản lại 15 sát thương chuẩn.", "Mỗi lần nhận sát thương, phản lại 30 sát thương chuẩn.", "Mỗi lần nhận sát thương, phản lại 45 sát thương chuẩn." },
					prices_standard = { "127", "127", "127" },
					prices_enhanced = { "127", "127", "127" }
				},
				{
					name = "Bất khả phá",
					standard = "Khi giao chiến với kẻ địch thường, hắc kỵ sĩ giơ khiên và bất tử 6 giây; không thể tấn công trong thời gian này.",
					enhanced = "Khi giao chiến với kẻ địch thường, hắc kỵ sĩ giơ khiên và bất tử 6 giây; không thể tấn công trong thời gian này.",
					levels_standard = { "Khi giao chiến với kẻ địch thường, hắc kỵ sĩ giơ khiên và bất tử 6 giây; không thể tấn công trong thời gian này." },
					levels_enhanced = { "Khi giao chiến với kẻ địch thường, hắc kỵ sĩ giơ khiên và bất tử 6 giây; không thể tấn công trong thời gian này." },
					prices_standard = { "170" },
					prices_enhanced = { "85" }
				},
			}
		},
		["tower_grim_cemetery_lvl4"] = {
			doc_id = "",
			title = "Nghĩa địa rùng rợn",
			attack = {
				standard = "Đánh cận chiến gây sát thương vật lý. Cứ 12 giây tạo một zombie tại vị trí ngẫu nhiên trong bán kính 330; zombie không hồi máu ngoài giao tranh và không thể tập kết. Kẻ địch chết gần nghĩa địa có máu trên 500 tạo zombie cường hóa; dưới 500 chỉ tạo zombie thường. Tích trữ tối đa 5 zombie.",
				enhanced = "Đánh cận chiến gây sát thương vật lý. Cứ 12 giây tạo một zombie tại vị trí ngẫu nhiên trong bán kính 330; zombie không hồi máu ngoài giao tranh và không thể tập kết. Kẻ địch chết gần nghĩa địa có máu trên 500 tạo zombie cường hóa; dưới 500 chỉ tạo zombie thường. Tích trữ tối đa 5/6/7/8 zombie."
			},
			change_note = "Nhận xét: Bản gốc chỉ zombie cấp 1 đáng dùng; nâng cấp 2/3/4 không đáng tiền. Tham khảo pháp sư chiêu hồn phần 2: nếu tối đa 8 zombie, khả năng chặn đường sẽ tốt hơn. Vì vậy giảm giá, tăng quân số nhưng giữ vai trò khác biệt với tháp chiêu hồn.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Bàn tay lạnh",
					standard = "Tạo 10 bàn tay zombie trên đường, giảm 60% tốc độ của kẻ địch trong bán kính 70 quanh mỗi bàn tay. Tồn tại 4 giây.",
					enhanced = "Tạo 10 bàn tay zombie trên đường, giảm 60% tốc độ của kẻ địch trong bán kính 70 quanh mỗi bàn tay. Tồn tại 4 giây.",
					levels_standard = { "Tạo 10 bàn tay zombie trên đường, giảm 60% tốc độ của kẻ địch trong bán kính 70 quanh mỗi bàn tay. Tồn tại 4 giây.", "Tạo 15 bàn tay zombie trên đường, giảm 60% tốc độ của kẻ địch trong bán kính 70 quanh mỗi bàn tay. Tồn tại 6 giây." },
					levels_enhanced = { "Tạo 10 bàn tay zombie trên đường, giảm 60% tốc độ của kẻ địch trong bán kính 70 quanh mỗi bàn tay. Tồn tại 4 giây.", "Tạo 15 bàn tay zombie trên đường, giảm 60% tốc độ của kẻ địch trong bán kính 70 quanh mỗi bàn tay. Tồn tại 6 giây." },
					prices_standard = { "110", "110" },
					prices_enhanced = { "110", "110" }
				},
				{
					name = "Cường hóa zombie",
					standard = "Tăng chỉ số, biến mọi zombie thành dạng cường hóa.",
					enhanced = "Tăng chỉ số, biến mọi zombie thành dạng cường hóa.",
					levels_standard = { "Tăng chỉ số, biến mọi zombie thành dạng cường hóa." },
					levels_enhanced = { "Tăng chỉ số, biến mọi zombie thành dạng cường hóa." },
					prices_standard = { "127" },
					prices_enhanced = { "127" }
				},
				{
					name = "Zombie trương nổ",
					standard = "Cứ 3 giây, 1 zombie được tạo từ kẻ địch nhận khả năng tự nổ.\nKhi chết, gây 15 sát thương phép diện rộng trong bán kính 90 và gây độc, gây tổng cộng 27 sát thương phép trong 3 giây.",
					enhanced = "Cứ 3 giây, 1 zombie được tạo từ kẻ địch nhận khả năng tự nổ.\nKhi chết, gây 15 sát thương phép diện rộng trong bán kính 90 và gây độc, gây tổng cộng 27 sát thương phép trong 3 giây.",
					levels_standard = { "Cứ 3 giây, 1 zombie được tạo từ kẻ địch nhận khả năng tự nổ.\nKhi chết, gây 15 sát thương phép diện rộng trong bán kính 90 và gây độc, gây tổng cộng 27 sát thương phép trong 3 giây.", "Cứ 3 giây, 1 zombie được tạo từ kẻ địch nhận khả năng tự nổ.\nKhi chết, gây 60 sát thương phép diện rộng trong bán kính 90 và gây độc, gây tổng cộng 27 sát thương phép trong 3 giây." },
					levels_enhanced = { "Cứ 3 giây, 1 zombie được tạo từ kẻ địch nhận khả năng tự nổ.\nKhi chết, gây 15 sát thương phép diện rộng trong bán kính 90 và gây độc, gây tổng cộng 27 sát thương phép trong 3 giây.", "Cứ 3 giây, 1 zombie được tạo từ kẻ địch nhận khả năng tự nổ.\nKhi chết, gây 60 sát thương phép diện rộng trong bán kính 90 và gây độc, gây tổng cộng 27 sát thương phép trong 3 giây." },
					prices_standard = { "93", "93" },
					prices_enhanced = { "93", "93" }
				},
			}
		},
		["tower_bone_flingers_lvl4"] = {
			doc_id = "",
			title = "Lính ném xương",
			attack = {
				standard = "Ném một khúc xương mỗi 0.6 giây vào kẻ địch ngẫu nhiên trong tầm.",
				enhanced = "Ném một khúc xương mỗi 0.6 giây vào kẻ địch ngẫu nhiên trong tầm."
			},
			change_note = "Nhận xét: Tầm tháp xương bản gốc chỉ 315, tăng lên 373 vẫn nhỏ so với tháp cung phần 1/2/3/5. Vì 3 phần trước chưa có tháp cung tầm ngắn nhưng sát thương cao, tháp xương được chỉnh theo hướng này. Tương tự Bậc thầy kiếm thuật tăng kỹ năng 1/3 liên quan đến kiếm, Uống sữa cũng nên tăng sát thương đánh xa của bộ xương.",
			port_note = "Thay đổi khi chuyển sang mod: Tầm gốc mọi cấp 300 (+5%).",
			notes = "",
			skills = {
				{
					name = "Xương biết đi",
					standard = "Cứ 16 giây tạo một chiến binh/kỵ sĩ bộ xương đi hết đường, chặn và đánh kẻ địch.",
					enhanced = "Cứ 8 giây tạo một chiến binh/kỵ sĩ bộ xương đi hết đường, chặn và đánh kẻ địch.",
					levels_standard = { "Cứ 16 giây tạo một chiến binh/kỵ sĩ bộ xương đi hết đường, chặn và đánh kẻ địch.", "Cứ 12 giây tạo một chiến binh/kỵ sĩ bộ xương đi hết đường, chặn và đánh kẻ địch." },
					levels_enhanced = { "Cứ 8 giây tạo một chiến binh/kỵ sĩ bộ xương đi hết đường, chặn và đánh kẻ địch.", "Cứ 8 giây tạo một chiến binh/kỵ sĩ bộ xương đi hết đường, chặn và đánh kẻ địch." },
					prices_standard = { "153", "153" },
					prices_enhanced = { "153", "153" }
				},
				{
					name = "Uống sữa",
					standard = "Uống sữa giúp bộ xương đánh xa mạnh hơn. Tăng 5 sát thương đánh xa của tháp.",
					enhanced = "Uống sữa giúp bộ xương đánh xa mạnh hơn. Tăng 8 sát thương đánh xa của tháp và Bộ xương khổng lồ.",
					levels_standard = { "Uống sữa giúp bộ xương đánh xa mạnh hơn. Tăng sát thương đánh xa của tháp.", "Uống sữa giúp bộ xương đánh xa mạnh hơn. Tăng 10 sát thương đánh xa của tháp.", "Uống sữa giúp bộ xương đánh xa mạnh hơn. Tăng 15 sát thương đánh xa của tháp." },
					levels_enhanced = { "Uống sữa giúp bộ xương đánh xa mạnh hơn. Tăng 8 sát thương đánh xa của tháp và Bộ xương khổng lồ.", "Uống sữa giúp bộ xương đánh xa mạnh hơn. Tăng 18 sát thương đánh xa của tháp và Bộ xương khổng lồ.", "Uống sữa giúp bộ xương đánh xa mạnh hơn. Tăng 28 sát thương đánh xa của tháp và Bộ xương khổng lồ."},
					prices_standard = { "93", "93", "93" },
					prices_enhanced = { "93", "93", "93" }
				},
				{
					name = "Bộ xương khổng lồ",
					standard = "Triệu hồi Bộ xương khổng lồ: máu 390, giáp 0, hồi sinh 10 giây; đánh xa 17-31/1.0, tầm 300.",
					enhanced = "Triệu hồi Bộ xương khổng lồ: máu 390, giáp 0, hồi sinh 10 giây; đánh xa 17-31/1.0, tầm 373. Kỹ năng 2 tăng sát thương đánh xa thành 25-39.",
					levels_standard = { "Triệu hồi Bộ xương khổng lồ: máu 390, giáp 0, hồi sinh 10 giây; đánh xa 17-31/1.0, tầm 300.", "Triệu hồi Bộ xương khổng lồ: máu 390, giáp 0, hồi sinh 10 giây; đánh xa 17-31/1.0, tầm 300.", "Triệu hồi Bộ xương khổng lồ: máu 390, giáp 0, hồi sinh 10 giây; đánh xa 17-31/1.0, tầm 300." },
					levels_enhanced = { "Triệu hồi Bộ xương khổng lồ: máu 390, giáp 0, hồi sinh 10 giây; đánh xa 17-31/1.0, tầm 373. Kỹ năng 2 tăng sát thương đánh xa thành 25-39/35-49/45-59."},
					prices_standard = { "255" },
					prices_enhanced = { "255" }
				},
			}
		},
		["tower_blazing_watcher_lvl4"] = {
			doc_id = "",
			title = "Ngọc lửa",
			attack = {
				standard = "Khóa kẻ địch xa lối thoát nhất, đánh đến khi nó chết hoặc rời tầm. Khoảng cách giữa 2 lần khóa tối thiểu 1.5 giây. Đánh cùng mục tiêu 3 lần tăng sức tấn công lên 2 lần; sau 6 lần tăng lên 3 lần.",
				enhanced = "Khóa kẻ địch xa lối thoát nhất, đánh đến khi nó chết hoặc rời tầm. Khoảng cách giữa 2 lần khóa tối thiểu 1.5 giây. Đánh cùng mục tiêu 3 lần tăng sức tấn công lên 2 lần; sau 6 lần tăng lên 3 lần.\nMục tiêu chưa chết khi rời tầm vẫn bị đánh đến khi vượt thêm 60 khoảng cách, tương đương tầm tìm mục tiêu 440 bản gốc hoặc 495 sau tăng tầm."
			},
			change_note = "Nhận xét: Tháp chuyên biệt, khó chuyển thành tháp phép thông thường nên tăng thế mạnh sẵn có. Cải thiện kỹ năng 2 cấp 2/3 và giới hạn kỹ năng 1.",
			port_note = "Thay đổi khi chuyển sang mod: Dùng chỉ số Ngọc lửa phiên bản 2022.10. Bản mới giá 980, sức tấn công bị giảm. Tầm gốc mọi cấp 320.\nĐôi lúc đổi mục tiêu nhanh hơn 1.5 giây; lỗi đổi mục tiêu tức thì của bản 2.0 beta đầu đã sửa.",
			notes = "",
			skills = {
				{
					name = "Ngọc tích điện",
					standard = "Sau 9 đòn liên tiếp, sức tấn công tăng 4 lần. Nếu đã đánh cùng mục tiêu ít nhất 9 lần khi mua kỹ năng, hiệu ứng có ngay.",
					enhanced = "Sau 9 đòn liên tiếp, sức tấn công tăng 4 lần, tiếp tục tích điện với một nửa tốc độ, tối đa 10 lần.",
					levels_standard = { "Sau 9 đòn liên tiếp, sức tấn công tăng 4 lần. Nếu đã đánh cùng mục tiêu ít nhất 9 lần khi mua kỹ năng, hiệu ứng có ngay." },
					levels_enhanced = { "Sau 9 đòn liên tiếp, sức tấn công tăng 4 lần, tiếp tục tích điện với một nửa tốc độ, tối đa 10 lần." },
					prices_standard = { "170" },
					prices_enhanced = { "170" }
				},
				{
					name = "Tia hủy diệt",
					standard = "Tiêu diệt ngay một kẻ địch. CD: 25 giây. Chỉ kích hoạt khi đã hồi và tháp chưa khóa mục tiêu; không kích hoạt giữa lúc đang đánh.",
					enhanced = "Tiêu diệt ngay một kẻ địch. CD: 25 giây. Chỉ kích hoạt khi đã hồi và tháp chưa khóa mục tiêu; không kích hoạt giữa lúc đang đánh.",
					levels_standard = { "Tiêu diệt ngay một kẻ địch. CD: 25 giây. Chỉ kích hoạt khi đã hồi và tháp chưa khóa mục tiêu; không kích hoạt giữa lúc đang đánh.", "Tiêu diệt ngay một kẻ địch. CD: 23 giây. Chỉ kích hoạt khi đã hồi và tháp chưa khóa mục tiêu; không kích hoạt giữa lúc đang đánh.", "Tiêu diệt ngay một kẻ địch. CD: 20 giây. Chỉ kích hoạt khi đã hồi và tháp chưa khóa mục tiêu; không kích hoạt giữa lúc đang đánh." },
					levels_enhanced = { "Tiêu diệt ngay một kẻ địch. CD: 25 giây. Chỉ kích hoạt khi đã hồi và tháp chưa khóa mục tiêu; không kích hoạt giữa lúc đang đánh.", "Tiêu diệt ngay một kẻ địch. CD: 20 giây. Chỉ kích hoạt khi đã hồi và tháp chưa khóa mục tiêu; không kích hoạt giữa lúc đang đánh.", "Tiêu diệt ngay một kẻ địch. CD: 15 giây. Chỉ kích hoạt khi đã hồi và tháp chưa khóa mục tiêu; không kích hoạt giữa lúc đang đánh." },
					prices_standard = { "212", "148", "148" },
					prices_enhanced = { "212", "106", "106" }
				},
				{
					name = "Sức mạnh bất ổn",
					standard = "Khi giết mục tiêu, gây 32-38 × cấp kỹ năng × tầng tích điện sát thương phép trong bán kính 100.",
					enhanced = "Khi giết mục tiêu, gây 32-38 × cấp kỹ năng × tầng tích điện sát thương phép trong bán kính 100.",
					levels_standard = { "Khi giết mục tiêu, gây 32-38 × tầng tích điện sát thương phép trong bán kính 100.", "Khi giết mục tiêu, gây 64-76 × tầng tích điện sát thương phép trong bán kính 100." },
					levels_enhanced = { "Khi giết mục tiêu, gây 32-38 × tầng tích điện sát thương phép trong bán kính 100.", "Khi giết mục tiêu, gây 64-76 × tầng tích điện sát thương phép trong bán kính 100." },
					prices_standard = { "170", "170" },
					prices_enhanced = { "170", "170" }
				},
			}
		},
		["tower_rotten_forest_lvl4"] = {
			doc_id = "",
			title = "Rừng mục rữa",
			attack = {
				standard = "Gọi rễ trong tầm đánh. Kẻ địch đứng trên rễ bị giảm 20/20/30/30% tốc độ, chịu 3/4/5/7 sát thương vật lý mỗi 0.4 giây.",
				enhanced = "Gọi rễ trong tầm đánh. Kẻ địch đứng trên rễ bị giảm 20/20/30/30% tốc độ, chịu 3/4/5/7 sát thương vật lý mỗi 0.4 giây."
			},
			change_note = "Nhận xét: Đường đi phần 1/2/3/5 hẹp hơn phần 4 khoảng 10%; tầm tháp phần 4 cũng đã điều chỉnh khi chuyển sang mod. Rừng mục rữa vốn mạnh ở 3 phần trước, không cần tăng thêm.",
			port_note = "Thay đổi khi chuyển sang mod: Tầm gốc mọi cấp 320; tăng ít hơn tháp cùng loại tầm 320 vì đánh toàn vùng. Vengeance bản mới (2025.04) bỏ làm chậm từ sương nhưng bản mod giữ lại.\nThụ nhân kỹ năng 1 bản gốc tồn tại 10 giây, hồi máu -50.\nKỹ năng 3 bản gốc giảm 15/25% độ chính xác. Nhiều đòn đánh địch là sát thương chuẩn chí tử hoặc tiêu diệt ngay, nên giảm độ chính xác tốt hơn giảm sức tấn công: địch cầm roi vẫn có thể giết lính cấp 1 khi bị giảm sức đánh, nhưng có thể đánh trượt. Vì vậy mức giảm sức đánh được tăng thêm. Giải thích: https://www.bilibili.com/video/BV13y411i71p.",
			notes = "",
			skills = {
				{
					name = "Thụ nhân tà ác",
					standard = "Mỗi 18/13 giây triệu hồi 2 thụ nhân, máu 260, hồi máu 0, tồn tại tối đa 5.2 giây.",
					enhanced = "Mỗi 18/13 giây triệu hồi 2 thụ nhân, máu 260, hồi máu 0, tồn tại tối đa 5.2 giây.",
					levels_standard = { "Mỗi 18/13 giây triệu hồi 2 thụ nhân, máu 260, hồi máu 0, tồn tại tối đa 5.2 giây.", "Mỗi 18/13 giây triệu hồi 2 thụ nhân, máu 260, hồi máu 0, tồn tại tối đa 5.2 giây." },
					levels_enhanced = { "Mỗi 18/13 giây triệu hồi 2 thụ nhân, máu 260, hồi máu 0, tồn tại tối đa 5.2 giây.", "Mỗi 18/13 giây triệu hồi 2 thụ nhân, máu 260, hồi máu 0, tồn tại tối đa 5.2 giây." },
					prices_standard = { "170", "85" },
					prices_enhanced = { "170", "85" }
				},
				{
					name = "Rễ tà ác",
					standard = "Trói tối đa 5 kẻ địch trong tầm suốt 3 giây. CD: 15 giây.",
					enhanced = "Trói tối đa 5 kẻ địch trong tầm suốt 3 giây, gây 25 sát thương vật lý mỗi giây, tổng 75. CD: 15 giây.",
					levels_standard = { "Trói tối đa 5 kẻ địch trong tầm suốt 3 giây. CD: 15 giây.", "Trói tối đa 5 kẻ địch trong tầm suốt 6 giây. CD: 15 giây." },
					levels_enhanced = { "Trói tối đa 5 kẻ địch trong tầm suốt 3 giây, gây 25 sát thương vật lý mỗi giây, tổng 75. CD: 15 giây.", "Trói tối đa 5 kẻ địch trong tầm suốt 6 giây, gây 25 sát thương vật lý mỗi giây, tổng 150. CD: 15 giây." },
					prices_standard = { "136", "136" },
					prices_enhanced = { "136", "136" }
				},
				{
					name = "Sương mù",
					standard = "Tạo sương trong tầm đánh, tăng mức làm chậm lên 37% và giảm 18% sức tấn công của địch.",
					enhanced = "Tạo sương trong tầm đánh, tăng mức làm chậm lên 37% và giảm 18% sức tấn công của địch.",
					levels_standard = { "Tạo sương trong tầm đánh, tăng mức làm chậm lên 37% và giảm 18% sức tấn công của địch.", "Tạo sương trong tầm đánh, tăng mức làm chậm lên 37% và giảm 30% sức tấn công của địch." },
					levels_enhanced = { "Tạo sương trong tầm đánh, tăng mức làm chậm lên 37% và giảm 18% sức tấn công của địch.", "Tạo sương trong tầm đánh, tăng mức làm chậm lên 37% và giảm 30% sức tấn công của địch." },
					prices_standard = { "102", "102" },
					prices_enhanced = { "102", "102" }
				},
			}
		},
		["tower_wicked_sisters_lvl4"] = {
			doc_id = "",
			title = "Chị em phù thủy",
			attack = {
				standard = "Tập kết trong phạm vi 275, đổi giữa dạng độc và choáng.\nDạng choáng: bắn cầu tím mỗi 2.5 giây, gây 94-220 sát thương phép; có 40/40/50/60% cơ hội choáng 1.2/1.4/1.6/2 giây.\nDạng độc: bắn cầu xanh mỗi 2.5 giây, gây 0/0/1/2 sát thương độc; gây độc 2.4 giây, gây 12/30/51/84 sát thương độc mỗi 0.8 giây.",
				enhanced = "Tập kết trong phạm vi 275, đổi giữa dạng độc và choáng.\nDạng choáng: bắn cầu tím mỗi 2.5 giây, gây 176-220 sát thương phép; có 40/40/50/60% cơ hội choáng 1.2/1.4/1.6/2 giây.\nDạng độc: bắn cầu xanh mỗi 2.5 giây, gây 0/0/1/2 sát thương độc; gây độc 2.4 giây, gây 12/30/51/84 sát thương độc mỗi 0.8 giây."
			},
			change_note = "Nhận xét: Dù tìm mục tiêu còn nhiều vấn đề, dạng độc đã đứng thứ 1 vượt trội về sát thương mỗi giây, không thể tăng thêm. Chỉ tăng độ ổn định dạng choáng để vẫn hữu ích khi đánh nhện, tránh hiệu quả 0.",
			port_note = "Thay đổi khi chuyển sang mod: Dùng chỉ số phiên bản 2024.09, nhận cả chí mạng và tăng sát thương. Mỗi đòn trung bình 84.7×3=254.1; bản mod bỏ phần đuôi thành 84×3+2=254. Bản mới (2025.04) không nhận chí mạng hoặc nâng cấp tăng 10%, mỗi đòn chỉ 210 sát thương.\nTầm tập kết gốc 250; sau nâng kỹ năng 3 là 350/450.\nBản gốc nâng tháp thì phù thủy đứng nguyên và đánh tiếp; bản mod triệu hồi lại từ giữa tháp.\nẾch từ kỹ năng 1 bản gốc trở về dạng cũ nếu không nhấn giết trong 6 giây.\n(1) Đòn đánh thường và kỹ năng 1 bản gốc không tìm mục tiêu thông minh: khóa quái xuất hiện sớm nhất, không ưu tiên máu, tiền thưởng hay số mạng làm mất. Quái lớn kéo dài sang đợt sau hoặc xuất hiện trước quái nhỏ tạo cảm giác ưu tiên.\n(2) Bản gốc không nhận tăng sát thương từ Lò nung: chỉ số tăng nhưng sức đánh thực không đổi. Bản mod giữ nguyên cả hai.",
			notes = "",
			skills = {
				{
					name = "Biến ếch",
					standard = "Biến vĩnh viễn kẻ địch thành ếch vô hại, còn 75% máu, tốc độ 20. Nhấn 3 lần để giết. Ưu tiên quái xuất hiện sớm nhất. CD: 22 giây.",
					enhanced = "Biến vĩnh viễn kẻ địch thành ếch vô hại, còn 75% máu, tốc độ 20. Nhấn 3 lần để giết. Ưu tiên quái xuất hiện sớm nhất. CD: 22 giây.",
					levels_standard = { "Biến vĩnh viễn kẻ địch thành ếch vô hại, còn 75% máu, tốc độ 20. Nhấn 3 lần để giết. Ưu tiên quái xuất hiện sớm nhất. CD: 22 giây.", "Biến vĩnh viễn kẻ địch thành ếch vô hại, còn 75% máu, tốc độ 20. Nhấn 3 lần để giết. Ưu tiên quái xuất hiện sớm nhất. CD: 18 giây." },
					levels_enhanced = { "Biến vĩnh viễn kẻ địch thành ếch vô hại, còn 75% máu, tốc độ 20. Nhấn 3 lần để giết. Ưu tiên quái xuất hiện sớm nhất. CD: 22 giây.", "Biến vĩnh viễn kẻ địch thành ếch vô hại, còn 75% máu, tốc độ 20. Nhấn 3 lần để giết. Ưu tiên quái xuất hiện sớm nhất. CD: 18 giây." },
					prices_standard = { "195", "153" },
					prices_enhanced = { "195", "153" }
				},
				{
					name = "Vật tổ câm lặng",
					standard = "Phù thủy trên tháp đặt vật tổ trong tầm 280, bán kính 200, tồn tại 10 giây. Câm lặng kẻ địch, vô hiệu hóa cả kỹ năng lẫn hiệu ứng khi chết. CD: 15 giây. Không dùng được khi tháp bị khóa.",
					enhanced = "Phù thủy trên tháp đặt vật tổ trong tầm 280, bán kính 200, tồn tại 10 giây. Câm lặng kẻ địch, vô hiệu hóa cả kỹ năng lẫn hiệu ứng khi chết. CD: 15 giây. Không dùng được khi tháp bị khóa.",
					levels_standard = { "Phù thủy trên tháp đặt vật tổ trong tầm 280, bán kính 200, tồn tại 10 giây. Câm lặng kẻ địch, vô hiệu hóa cả kỹ năng lẫn hiệu ứng khi chết. CD: 15 giây. Không dùng được khi tháp bị khóa." },
					levels_enhanced = { "Phù thủy trên tháp đặt vật tổ trong tầm 280, bán kính 200, tồn tại 10 giây. Câm lặng kẻ địch, vô hiệu hóa cả kỹ năng lẫn hiệu ứng khi chết. CD: 15 giây. Không dùng được khi tháp bị khóa." },
					prices_standard = { "153" },
					prices_enhanced = { "153" }
				},
				{
					name = "Nimbus 4000",
					standard = "Tăng phạm vi tập kết lên 350 (385).",
					enhanced = "Tăng phạm vi tập kết lên 350 (385).",
					levels_standard = { "Tăng phạm vi tập kết lên 350 (385).", "Tăng phạm vi tập kết lên 450 (495)." },
					levels_enhanced = { "Tăng phạm vi tập kết lên 350 (385).", "Tăng phạm vi tập kết lên 450 (495)." },
					prices_standard = { "85", "85" },
					prices_enhanced = { "85", "85" }
				},
			}
		},
		["tower_twilight_elves_barrack_lvl4"] = {
			doc_id = "",
			title = "Lính quấy rối tinh nhuệ",
			attack = {
				standard = "Doanh trại 2 lính. Đánh xa khi địch trong tầm 360, chuyển cận chiến trong tầm 100.\nCận chiến có 30% cơ hội né đòn.",
				enhanced = "Doanh trại 3 lính. Đánh xa khi địch trong tầm 360, chuyển cận chiến trong tầm 100.\nCận chiến có 30% cơ hội né đòn."
			},
			change_note = "Nhận xét: Tăng quân số cấp 4 để giảm tổn thất khi lính chết. Từ 2 lên 3 lính, chỉ số mỗi lính giảm nhưng tổng sát thương gần như giữ nguyên; tăng sát thương kỹ năng 2.",
			port_note = "Thay đổi khi chuyển sang mod: Phạm vi tập kết gốc mọi cấp 350.",
			notes = "",
			skills = {
				{
					name = "Đâm sau lưng",
					standard = "Tăng né đòn lên 40%; phản kích gây 10-15 sát thương vật lý.",
					enhanced = "Tăng né đòn lên 40%; phản kích gây 10-15 sát thương vật lý.",
					levels_standard = { "Tăng né đòn lên 40%; phản kích gây 10-15 sát thương vật lý.", "Tăng né đòn lên 50%; phản kích gây 20-30 sát thương vật lý." },
					levels_enhanced = { "Tăng né đòn lên 40%; phản kích gây 10-15 sát thương vật lý.", "Tăng né đòn lên 50%; phản kích gây 20-30 sát thương vật lý." },
					prices_standard = { "153", "153" },
					prices_enhanced = { "153", "153" }
				},
				{
					name = "Bão tên",
					standard = "Bắn liên tiếp 5 mũi tên vào một mục tiêu, mỗi mũi gây 16-24 sát thương vật lý. CD: 12 giây.",
					enhanced = "Bắn liên tiếp 5 mũi tên vào một mục tiêu, mỗi mũi gây 16-24 sát thương vật lý. CD: 12 giây.",
					levels_standard = { "Bắn liên tiếp 5 mũi tên vào một mục tiêu, mỗi mũi gây 16-24 sát thương vật lý. CD: 12 giây.", "Bắn liên tiếp 5 mũi tên vào một mục tiêu, mỗi mũi gây 32-48 sát thương vật lý. CD: 12 giây.", "Bắn liên tiếp 5 mũi tên vào một mục tiêu, mỗi mũi gây 48-72 sát thương vật lý. CD: 12 giây." },
					levels_enhanced = { "Bắn liên tiếp 5 mũi tên vào một mục tiêu, mỗi mũi gây 16-24 sát thương vật lý. CD: 12 giây.", "Bắn liên tiếp 5 mũi tên vào một mục tiêu, mỗi mũi gây 32-48 sát thương vật lý. CD: 12 giây.", "Bắn liên tiếp 5 mũi tên vào một mục tiêu, mỗi mũi gây 48-72 sát thương vật lý. CD: 12 giây." },
					prices_standard = { "119", "119", "119" },
					prices_enhanced = { "119", "119", "119" }
				},
				{
					name = "Cuồng nộ Chạng vạng",
					standard = "Khi chết, có 75% cơ hội hóa lính cuồng nộ: 250 (325) máu, sức đánh 32-48, mất khả năng đánh xa. Chiến đấu đến khi bản thân hoặc mục tiêu chết, tồn tại ít nhất 6 giây. Không làm chậm hồi sinh lính thường.",
					enhanced = "Khi chết, có 100% cơ hội hóa lính cuồng nộ: 250 (325) máu, sức đánh 32-48, mất khả năng đánh xa. Chiến đấu đến khi bản thân hoặc mục tiêu chết, tồn tại ít nhất 6 giây. Không làm chậm hồi sinh lính thường.",
					levels_standard = { "Khi chết, có 75% cơ hội hóa lính cuồng nộ: 250 (325) máu, sức đánh 32-48, mất khả năng đánh xa. Chiến đấu đến khi bản thân hoặc mục tiêu chết, tồn tại ít nhất 6 giây. Không làm chậm hồi sinh lính thường.", "Khi chết, có 75 cơ hội hóa lính cuồng nộ: 250 (325) máu, sức đánh 0.5, mất khả năng đánh xa. Chiến đấu đến khi bản thân hoặc mục tiêu chết, tồn tại ít nhất 6 giây. Không làm chậm hồi sinh lính thường." },
					levels_enhanced = { "Khi chết, có 100% cơ hội hóa lính cuồng nộ: 250 (325) máu, sức đánh 32-48, mất khả năng đánh xa. Chiến đấu đến khi bản thân hoặc mục tiêu chết, tồn tại ít nhất 6 giây. Không làm chậm hồi sinh lính thường.", "Khi chết, có 100% cơ hội hóa lính cuồng nộ: 250 (325) máu, sức đánh 0.5, mất khả năng đánh xa. Chiến đấu đến khi bản thân hoặc mục tiêu chết, tồn tại ít nhất 6 giây. Không làm chậm hồi sinh lính thường." },
					prices_standard = { "187" },
					prices_enhanced = { "187" }
				},
			}
		},
		["tower_deep_devils_lvl4"] = {
			doc_id = "",
			title = "Rạn quỷ biển sâu",
			attack = {
				standard = "Bắn đạn phép mỗi 1.5 giây. Mỗi cấp triệu hồi 2 người cá: 50/90/135/180 (65/117/175/234) máu, hồi sinh 12 giây, tập kết 290. Người cá cấp 4 đánh xa 9-15/0.9.",
				enhanced = "Bắn đạn phép mỗi 1.5 giây. Mỗi cấp triệu hồi 2 người cá: 50/90/135/180 (65/117/175/234) máu, hồi sinh 12 giây, tập kết 290. Người cá cấp 4 đánh xa 9-15/0.9."
			},
			change_note = "Nhận xét: Đòn đánh thường, đơn vị triệu hồi và kỹ năng 1 không cần tăng thêm. Kỹ năng 3 chưa đáng tiền.",
			port_note = "Thay đổi khi chuyển sang mod: Tầm gốc mọi cấp 300; chí mạng đã tính vào chỉ số. Kỹ năng 2 bản gốc khiến mục tiêu trúng lưới không nhận sát thương.\nBão hoàn hảo dùng mã vệ tinh của tháp tinh linh cao cấp nên cơ chế hơi khác.",
			notes = "",
			skills = {
				{
					name = "Người được biển chọn",
					standard = "Tăng 50 máu, 15 giáp và 5 sức tấn công cho chiến binh thủy triều.",
					enhanced = "Tăng 50 máu, 15 giáp và 5 sức tấn công cho chiến binh thủy triều.",
					levels_standard = { "Tăng 50 máu, 15 giáp và 5 sức tấn công cho chiến binh thủy triều." },
					levels_enhanced = { "Tăng 50 máu, 15 giáp và 5 sức tấn công cho chiến binh thủy triều." },
					prices_standard = { "170" },
					prices_enhanced = { "170" }
				},
				{
					name = "Ném lưới",
					standard = "Mỗi 14/12 giây ném lưới giữ chân 2 giây.\nMục tiêu không thể hành động nhưng vẫn nhận sát thương bình thường.",
					enhanced = "Mỗi 14/12 giây ném lưới giữ chân 2 giây.\nMục tiêu không thể hành động nhưng vẫn nhận sát thương bình thường.",
					levels_standard = { "Mỗi 14/12 giây ném lưới giữ chân 2 giây.\nMục tiêu không thể hành động nhưng vẫn nhận sát thương bình thường.", "Mỗi 14/12 giây ném lưới giữ chân 4 giây.\nMục tiêu không thể hành động nhưng vẫn nhận sát thương bình thường." },
					levels_enhanced = { "Mỗi 14/12 giây ném lưới giữ chân 2 giây.\nMục tiêu không thể hành động nhưng vẫn nhận sát thương bình thường.", "Mỗi 14/12 giây ném lưới giữ chân 4 giây.\nMục tiêu không thể hành động nhưng vẫn nhận sát thương bình thường." },
					prices_standard = { "102", "102" },
					prices_enhanced = { "102", "102" }
				},
				{
					name = "Bão hoàn hảo",
					standard = "Gọi mây đen đánh một mục tiêu 5 lần trong 5 giây. Mỗi lần gây 25 sát thương phép và choáng 0.5 giây. CD: 20 giây.",
					enhanced = "Gọi mây đen đánh một mục tiêu 20 lần trong 20 giây. Mỗi lần gây 30 sát thương phép và choáng 0.66 giây. CD: 28 giây.",
					levels_standard = { "Gọi mây đen đánh một mục tiêu 5 lần trong 5 giây. Mỗi lần gây 25 sát thương phép và choáng 0.5 giây. CD: 20 giây.", "Gọi mây đen đánh một mục tiêu 5 lần trong 5 giây. Mỗi lần gây 50 sát thương phép và choáng 0.5 giây. CD: 20 giây.", "Gọi mây đen đánh một mục tiêu 5 lần trong 5 giây. Mỗi lần gây 75 sát thương phép và choáng 0.5 giây. CD: 20 giây.",  },
					levels_enhanced = { "Gọi mây đen đánh một mục tiêu 20 lần trong 20 giây. Mỗi lần gây 30 sát thương phép và choáng 0.66 giây. CD: 28 giây.", "Gọi mây đen đánh một mục tiêu 20 lần trong 20 giây. Mỗi lần gây 61 sát thương phép và choáng 0.66 giây. CD: 28 giây.", "Gọi mây đen đánh một mục tiêu 20 lần trong 20 giây. Mỗi lần gây 92 sát thương phép và choáng 0.66 giây. CD: 28 giây."},
					prices_standard = { "170", "170", "170" },
					prices_enhanced = { "170", "170", "170" }
				},
			}
		},
		["tower_shaolin_lvl4"] = {
			doc_id = "",
			title = "Thiếu Lâm Tự",
			attack = {
				standard = "Có 3/3/3/3 võ tăng, hoặc 4/5/6 khi nâng kỹ năng 3. Mỗi võ tăng dịch chuyển đến giữ chân và đánh địch mỗi 1.37 giây, gây sát thương vật lý. Mỗi mục tiêu bị võ tăng của cùng một tháp đánh cách nhau 1.37 giây.",
				enhanced = "Có 3/3/4/4 võ tăng, hoặc 5/6/8 khi nâng kỹ năng 3. Mỗi võ tăng dịch chuyển đến giữ chân và đánh địch mỗi 1.37 giây, gây sát thương vật lý. Mỗi mục tiêu bị võ tăng của cùng một tháp đánh cách nhau 1.37 giây."
			},
			change_note = "Nhận xét: Sức đánh thấp cả trong phần gốc lẫn xuyên các phần; ngoài phần 4, thường không còn mục tiêu bay để tháp xử lý. Nâng cấp 2/3/4 ít hiệu quả. Cần tăng đòn đánh thường và hiệu quả nâng cấp 2/3/4.",
			port_note = "Thay đổi khi chuyển sang mod: Tầm gốc mọi cấp 320 (+5%). Bản gốc có khoảng đánh biến động, tính hồi riêng từng võ tăng; bản mod tính chung thời gian hồi cố định 1.37.",
			notes = "",
			skills = {
				{
					name = "Thần Long Đại Hiệp",
					standard = "Triệu hồi Thần Long Đại Hiệp.\nMáu 400 (520), sức đánh 40-60, hồi sinh 13 giây, tập kết 350.",
					enhanced = "Triệu hồi Thần Long Đại Hiệp.\nMáu 400 (520), sức đánh 40-60, hồi sinh 13 giây, tập kết 350.",
					levels_standard = { "Triệu hồi Thần Long Đại Hiệp.\nMáu 400 (520), sức đánh 40-60, hồi sinh 13 giây, tập kết 350.", "Triệu hồi Thần Long Đại Hiệp.\nMáu 400 (520), sức đánh 1.0, hồi sinh 13 giây, tập kết 350." },
					levels_enhanced = { "Triệu hồi Thần Long Đại Hiệp.\nMáu 400 (520), sức đánh 40-60, hồi sinh 13 giây, tập kết 350.", "Triệu hồi Thần Long Đại Hiệp.\nMáu 400 (520), sức đánh 1.0, hồi sinh 13 giây, tập kết 350." },
					prices_standard = { "212" },
					prices_enhanced = { "212" }
				},
				{
					name = "Sư tử thịnh vượng",
					standard = "Triệu hồi tượng sư tử.\nKẻ địch chết trong bán kính 336 quanh tháp cho thêm 10% vàng, làm tròn xuống; nhiều hiệu ứng nhân dồn.",
					enhanced = "Triệu hồi tượng sư tử.\nKẻ địch chết trong bán kính 336 quanh tháp cho thêm 10% vàng, làm tròn xuống; nhiều hiệu ứng nhân dồn.",
					levels_standard = { "Triệu hồi tượng sư tử.\nKẻ địch chết trong bán kính 336 quanh tháp cho thêm 10% vàng, làm tròn xuống; nhiều hiệu ứng nhân dồn." },
					levels_enhanced = { "Triệu hồi tượng sư tử.\nKẻ địch chết trong bán kính 336 quanh tháp cho thêm 10% vàng, làm tròn xuống; nhiều hiệu ứng nhân dồn." },
					prices_standard = { "85" },
					prices_enhanced = { "85" }
				},
				{
					name = "Võ tăng Thiếu Lâm",
					standard = "Tuyển thêm võ tăng.\nTăng quân số lên 4.",
					enhanced = "Tuyển thêm võ tăng.\nTăng quân số lên 5.",
					levels_standard = { "Tuyển thêm võ tăng.\nTăng quân số lên 4.", "Tuyển thêm võ tăng.\nTăng quân số lên 5.", "Tuyển thêm võ tăng.\nTăng quân số lên 6." },
					levels_enhanced = { "Tuyển thêm võ tăng.\nTăng quân số lên 5.", "Tuyển thêm võ tăng.\nTăng quân số lên 6.", "Tuyển thêm võ tăng.\nTăng quân số lên 8." },
					prices_standard = { "148", "148", "148" },
					prices_enhanced = { "148", "148", "148" }
				},
			}
		},
		["tower_swamp_monster_lvl4"] = {
			doc_id = "",
			title = "Quái vật đầm lầy",
			attack = {
				standard = "Ném cầu thực vật mục mỗi 2.1 giây, gây sát thương vật lý.\nĐập đất mỗi 2.5 giây, gây sát thương vật lý cho tối đa 5 mục tiêu trong bán kính 150. Hồi sinh 20 giây. Miễn nhiễm lây bệnh người sói mạnh phần 1 và độc.\nCó thể đổi thành tháp cung.",
				enhanced = "Ném cầu thực vật mục mỗi 2.1 giây, gây sát thương vật lý.\nĐập đất mỗi 2.5 giây, gây sát thương vật lý cho tối đa 15 mục tiêu trong bán kính 150. Hồi sinh 20 giây. Miễn nhiễm lây bệnh người sói mạnh phần 1, độc, tiêu diệt ngay, phân rã, biến hình và ký sinh.\nCó thể đổi thành tháp cung."
			},
			change_note = "Nhận xét: 3 phần trước có nhiều hiệu ứng tiêu diệt ngay, nên tăng khả năng sống sót trước sát thủ doanh trại. Thực vật ăn thịt bản cũ phần 4 giá 68 vàng.",
			port_note = "Thay đổi khi chuyển sang mod: Phạm vi tập kết gốc mọi cấp 250; kế thừa miễn nhiễm lây bệnh của Tinh linh đất.",
			notes = "",
			skills = {
				{
					name = "Sức mạnh nghiền nát",
					standard = "Mỗi cầu thực vật hoặc đòn đập đất có 2% cơ hội tiêu diệt ngay mục tiêu bị cầu đánh trúng hoặc đang bị chặn.",
					enhanced = "Mỗi cầu thực vật hoặc đòn đập đất có 2% cơ hội tiêu diệt ngay mục tiêu bị cầu đánh trúng hoặc đang bị chặn.",
					levels_standard = { "Mỗi cầu thực vật hoặc đòn đập đất có 2% cơ hội tiêu diệt ngay mục tiêu bị cầu đánh trúng hoặc đang bị chặn.", "Mỗi cầu thực vật hoặc đòn đập đất có 4% cơ hội tiêu diệt ngay mục tiêu bị cầu đánh trúng hoặc đang bị chặn.", "Mỗi cầu thực vật hoặc đòn đập đất có 6% cơ hội tiêu diệt ngay mục tiêu bị cầu đánh trúng hoặc đang bị chặn." },
					levels_enhanced = { "Mỗi cầu thực vật hoặc đòn đập đất có 2% cơ hội tiêu diệt ngay mục tiêu bị cầu đánh trúng hoặc đang bị chặn.", "Mỗi cầu thực vật hoặc đòn đập đất có 4% cơ hội tiêu diệt ngay mục tiêu bị cầu đánh trúng hoặc đang bị chặn.", "Mỗi cầu thực vật hoặc đòn đập đất có 6% cơ hội tiêu diệt ngay mục tiêu bị cầu đánh trúng hoặc đang bị chặn." },
					prices_standard = { "119", "119", "119" },
					prices_enhanced = { "119", "119", "119" }
				},
				{
					name = "Nọc gây mù",
					standard = "Mỗi cầu thực vật hoặc đòn đập đất có 20% cơ hội làm choáng mục tiêu trúng đòn.",
					enhanced = "Mỗi cầu thực vật hoặc đòn đập đất có 20% cơ hội làm choáng mục tiêu trúng đòn.",
					levels_standard = { "Mỗi cầu thực vật hoặc đòn đập đất có 20% cơ hội làm choáng mục tiêu trúng đòn.", "Mỗi cầu thực vật hoặc đòn đập đất có 40% cơ hội làm choáng mục tiêu trúng đòn.", "Mỗi cầu thực vật hoặc đòn đập đất có 60% cơ hội làm choáng mục tiêu trúng đòn." },
					levels_enhanced = { "Mỗi cầu thực vật hoặc đòn đập đất có 20% cơ hội làm choáng mục tiêu trúng đòn.", "Mỗi cầu thực vật hoặc đòn đập đất có 40% cơ hội làm choáng mục tiêu trúng đòn.", "Mỗi cầu thực vật hoặc đòn đập đất có 60% cơ hội làm choáng mục tiêu trúng đòn." },
					prices_standard = { "102", "102", "102" },
					prices_enhanced = { "102", "102", "102" }
				},
				{
					name = "Thực vật ăn thịt",
					standard = "Hồi 1050 máu mỗi lần giết kẻ địch.",
					enhanced = "Hồi 1050 máu mỗi lần giết kẻ địch.",
					levels_standard = { "Hồi 1050 máu mỗi lần giết kẻ địch." },
					levels_enhanced = { "Hồi 1050 máu mỗi lần giết kẻ địch." },
					prices_standard = { "119" },
					prices_enhanced = { "68" }
				},
			}
		},
		["tower_ignis_altar_lvl4"] = {
			doc_id = "",
			title = "Tế đàn lửa",
			attack = {
				standard = "Khi đạn chạm đất, tạo hố đường kính 100 tồn tại 3.5 giây. Gây 2/4/6/8 sát thương pháo mỗi 0.4/0.35/0.3/0.2 giây cho quái mặt đất trong hố, tổng 20/44/78/152. Sát thương nhiều hố cộng dồn.",
				enhanced = "Khi đạn chạm đất, tạo hố đường kính 100 tồn tại 3.5 giây. Gây 2/4/6/8 sát thương pháo mỗi 0.4/0.35/0.3/0.2 giây cho quái mặt đất trong hố, tổng 20/44/78/152. Sát thương nhiều hố cộng dồn."
			},
			change_note = "Nhận xét: Tháp pháo mạnh cả cơ chế sát thương lẫn tiến trình nâng cấp, không cần tăng thêm. Tăng khả năng của Tinh linh dung nham trước mục tiêu có giáp nhưng giảm khả năng chống sát thương chuẩn.",
			port_note = "Thay đổi khi chuyển sang mod: Tầm gốc mọi cấp 300/330/360/390. Chỉ số đòn đánh bản gốc là sát thương mỗi lần; bản mod là tổng sát thương cả chu kỳ.\nKỹ năng 2 bản gốc gây sát thương phép trong bán kính 100 sau khi mục tiêu chết; bản mod gây sát thương trước rồi áp dụng dễ tổn thương.",
			notes = "",
			skills = {
				{
					name = "Tinh linh dung nham",
					standard = "Triệu hồi Tinh linh dung nham: 450 (585) máu, 0 giáp, hồi sinh 10, tốc độ 30, sức đánh 19-43, tập kết 400.",
					enhanced = "Triệu hồi Tinh linh dung nham: 225 (292) máu, 70 giáp, hồi sinh 10, tốc độ 30, sức đánh 19-43, tập kết 400.",
					levels_standard = { "Triệu hồi Tinh linh dung nham: 450 (585) máu, 0 giáp, hồi sinh 10, tốc độ 30, sức đánh 19-43, tập kết 400.", "Triệu hồi Tinh linh dung nham: 450 (585) máu, 0 giáp, hồi sinh 10, tốc độ 30, sức đánh 1.0, tập kết 400." },
					levels_enhanced = { "Triệu hồi Tinh linh dung nham: 225 (292) máu, 70 giáp, hồi sinh 10, tốc độ 30, sức đánh 19-43, tập kết 400.", "Triệu hồi Tinh linh dung nham: 225 (292) máu, 70 giáp, hồi sinh 10, tốc độ 30, sức đánh 1.0, tập kết 400." },
					prices_standard = { "255" },
					prices_enhanced = { "255" }
				},
				{
					name = "Vòng lửa nghiệp",
					standard = "Bắn đạn dung nham vào kẻ địch nhiều máu nhất trong tầm, gây 32 sát thương phép và dễ tổn thương 10 giây, tăng 50% sát thương nhận. CD: 18 giây.",
					enhanced = "Bắn đạn dung nham vào kẻ địch nhiều máu nhất trong tầm, gây 32 sát thương phép và dễ tổn thương 10 giây, tăng 50% sát thương nhận. CD: 18 giây.",
					levels_standard = { "Bắn đạn dung nham vào kẻ địch nhiều máu nhất trong tầm, gây 32 sát thương phép và dễ tổn thương 10 giây, tăng 50% sát thương nhận. CD: 18 giây.", "Bắn đạn dung nham vào kẻ địch nhiều máu nhất trong tầm, gây 54 sát thương phép và dễ tổn thương 10 giây, tăng 75% sát thương nhận. CD: 18 giây.", "Bắn đạn dung nham vào kẻ địch nhiều máu nhất trong tầm, gây 76 sát thương phép và dễ tổn thương 10 giây, tăng 100% sát thương nhận. CD: 18 giây." },
					levels_enhanced = { "Bắn đạn dung nham vào kẻ địch nhiều máu nhất trong tầm, gây 32 sát thương phép và dễ tổn thương 10 giây, tăng 50% sát thương nhận. CD: 18 giây.", "Bắn đạn dung nham vào kẻ địch nhiều máu nhất trong tầm, gây 54 sát thương phép và dễ tổn thương 10 giây, tăng 75% sát thương nhận. CD: 18 giây.", "Bắn đạn dung nham vào kẻ địch nhiều máu nhất trong tầm, gây 76 sát thương phép và dễ tổn thương 10 giây, tăng 100% sát thương nhận. CD: 18 giây." },
					prices_standard = { "153", "85", "85" },
					prices_enhanced = { "153", "85", "85" }
				},
				{
					name = "Lửa làm chậm",
					standard = "Kẻ địch vào hố bị giảm 50% tốc độ trong 0.3 giây; thời gian làm chậm được làm mới khi còn ở trong hố.",
					enhanced = "Kẻ địch vào hố bị giảm 50% tốc độ trong 0.3 giây; thời gian làm chậm được làm mới khi còn ở trong hố.",
					levels_standard = { "Kẻ địch vào hố bị giảm 50% tốc độ trong 0.3 giây; thời gian làm chậm được làm mới khi còn ở trong hố." },
					levels_enhanced = { "Kẻ địch vào hố bị giảm 50% tốc độ trong 0.3 giây; thời gian làm chậm được làm mới khi còn ở trong hố." },
					prices_standard = { "212" },
					prices_enhanced = { "212" }
				},
			}
		},
		["tower_sandworm_lvl4"] = {
			doc_id = "",
			title = "Tổ giun cát",
			attack = {
				standard = "Cứ 6 giây tạo một miệng giun đường kính 80, tồn tại 3/3.5/4/4.5 giây. Kẻ địch mặt đất trong vùng chịu hiệu ứng kéo dài 0.5 giây: nhận 4/9/14/19 sát thương pháo mỗi 0.25 giây.\nMỗi lượt đánh thường gây tổng cộng 56/144/252/380 sát thương pháo. Sát thương từ nhiều miệng giun có thể cộng dồn.",
				enhanced = "Cứ 6 giây tạo một miệng giun đường kính 110, tồn tại 3/3.5/4/4.5 giây. Kẻ địch mặt đất trong vùng chịu hiệu ứng kéo dài 0.5 giây: nhận 4/9/14/19 sát thương pháo mỗi 0.25 giây.\nMỗi lượt đánh thường gây tổng cộng 56/144/252/380 sát thương pháo. Sát thương từ nhiều miệng giun có thể cộng dồn."
			},
			change_note = "Nhận xét: Miệng giun khó giữ chân địch, kỹ năng 2 hồi quá lâu, còn kỹ năng 3 không tăng sức mạnh cho đòn đánh thường và thậm chí làm giảm sát thương thường. Không thêm làm chậm vì núi lửa phần 4 và tổ giun cát NPC phần 2 đã có cơ chế này. Vì vậy, tăng sát thương kỹ năng 3 để tổng DPS không giảm sau khi mua kỹ năng 3.",
			port_note = "Thay đổi khi chuyển sang FL: Bản gốc có tầm đánh 300 ở mọi cấp. Sát thương hiển thị trước đây là của một lần đánh, còn bản này hiển thị tổng sát thương của một lượt đánh thường. Kỹ năng 2 ở bản gốc nuốt cả đồng minh lẫn kẻ địch; bản FL chỉ nuốt kẻ địch.",
			notes = "",
			skills = {
				{
					name = "Triệu hồi giun cát",
					standard = "Cứ 14/10 giây triệu hồi một giun cát bò về phía điểm xuất quân của địch.",
					enhanced = "Cứ 14/10 giây triệu hồi một giun cát bò về phía điểm xuất quân của địch.",
					levels_standard = { "Cứ 14 giây triệu hồi một giun cát bò về phía điểm xuất quân của địch.", "Cứ 10 giây triệu hồi một giun cát bò về phía điểm xuất quân của địch." },
					levels_enhanced = { "Cứ 14 giây triệu hồi một giun cát bò về phía điểm xuất quân của địch.", "Cứ 10 giây triệu hồi một giun cát bò về phía điểm xuất quân của địch." },
					prices_standard = { "144", "144" },
					prices_enhanced = { "144", "144" }
				},
				{
					name = "Bữa ăn Shaxian",
					standard = "Giun cát khổng lồ há miệng giữa đường, nuốt mọi kẻ địch không phải trùm trong phạm vi 160. Tầm đánh: 550. CD: 45 giây.",
					enhanced = "Giun cát khổng lồ há miệng giữa đường, nuốt mọi kẻ địch không phải trùm trong phạm vi 175. Tầm đánh: 550. CD: 42 giây.",
					levels_standard = { "Giun cát khổng lồ há miệng giữa đường, nuốt mọi kẻ địch không phải trùm trong phạm vi 160. Tầm đánh: 550. CD: 45 giây." },
					levels_enhanced = { "Giun cát khổng lồ há miệng giữa đường, nuốt mọi kẻ địch không phải trùm trong phạm vi 175. Tầm đánh: 550. CD: 42 giây." },
					prices_standard = { "255" },
					prices_enhanced = { "289" }
				},
				{
					name = "Cầu dịch nhầy tím",
					standard = "Ném một quả cầu dịch nhầy tím, tạo vùng dịch nhầy phạm vi 120 trong 5 giây. Kẻ địch trong vùng bị giảm 50% tốc độ di chuyển; tối đa 8 mục tiêu. CD: 14.",
					enhanced = "Ném cầu dịch nhầy tím gây sát thương bằng 4 đòn đánh thường (76) cho mục tiêu trúng đòn. Tạo vùng dịch nhầy phạm vi 120 trong 5 giây, giảm 50% tốc độ di chuyển của tối đa 8 kẻ địch. CD: 14.",
					levels_standard = { "Ném một quả cầu dịch nhầy tím, tạo vùng dịch nhầy phạm vi 120 trong 5 giây. Kẻ địch trong vùng bị giảm 50% tốc độ di chuyển; tối đa 8 mục tiêu. CD: 14.", "Ném một quả cầu dịch nhầy tím, tạo vùng dịch nhầy phạm vi 120 trong 6 giây. Kẻ địch trong vùng bị giảm 70% tốc độ di chuyển; tối đa 8 mục tiêu. CD: 12." },
					levels_enhanced = { "Ném cầu dịch nhầy tím gây sát thương bằng 4 đòn đánh thường (76) cho mục tiêu trúng đòn. Tạo vùng dịch nhầy phạm vi 120 trong 5 giây, giảm 50% tốc độ di chuyển của tối đa 8 kẻ địch. CD: 14.", "Ném cầu dịch nhầy tím gây sát thương bằng 8 đòn đánh thường (152) cho mục tiêu trúng đòn. Tạo vùng dịch nhầy phạm vi 120 trong 6 giây, giảm 70% tốc độ di chuyển của tối đa 8 kẻ địch. CD: 12." },
					prices_standard = { "127", "127" },
					prices_enhanced = { "127", "127" }
				},
			}
		},
		["tower_ogre_shipwreck_lvl4"] = {
			doc_id = "",
			title = "Tàu đắm Ogre",
			attack = {
				standard = "",
				enhanced = ""
			},
			change_note = "Nhận xét: Tháp đã phát huy sức mạnh ngay ở cấp 1 nên không tăng thêm. Chỉ điều chỉnh kỹ năng 2 vốn yếu hơn.",
			port_note = "Thay đổi khi chuyển sang FL: Tầm đánh của tháp cung bản gốc là 300 (+5%); tầm pháo là 400.",
			skills = {
				{
					name = "Nâng cấp thủy thủ",
					standard = "Tăng 18 sức tấn công và 30 giáp cho Ogre; tăng 4 sức tấn công và 30 giáp cho thủy thủ.",
					enhanced = "Tăng 18 sức tấn công và 30 giáp cho Ogre; tăng 4 sức tấn công và 30 giáp cho thủy thủ.",
					levels_standard = { "Tăng 18 sức tấn công và 30 giáp cho Ogre; tăng 4 sức tấn công và 30 giáp cho thủy thủ." },
					levels_enhanced = { "Tăng 18 sức tấn công và 30 giáp cho Ogre; tăng 4 sức tấn công và 30 giáp cho thủy thủ." },
					prices_standard = { "127" },
					prices_enhanced = { "127" }
				},
				{
					name = "Nạp đạn nhanh",
					standard = "Xạ thủ Orc bắn 15 viên đạn, mỗi viên gây 18 sát thương vật lý, tổng cộng 270. CD: 15.",
					enhanced = "Xạ thủ Orc bắn 15 viên đạn, mỗi viên gây 18 sát thương vật lý, tổng cộng 270. CD: 15.",
					levels_standard = { "Xạ thủ Orc bắn 15 viên đạn, gây tổng cộng 270 sát thương vật lý. CD: 15.", "Xạ thủ Orc bắn 15 viên đạn, mỗi viên gây 29 sát thương vật lý, tổng cộng 435. CD: 15.", "Xạ thủ Orc bắn 15 viên đạn, mỗi viên gây 40 sát thương vật lý, tổng cộng 600. CD: 15." },
					levels_enhanced = { "Xạ thủ Orc bắn 15 viên đạn, mỗi viên gây 18 sát thương vật lý, tổng cộng 270/540. CD: 15.", "Xạ thủ Orc bắn 15 viên đạn, mỗi viên gây 36 sát thương vật lý, tổng cộng 540. CD: 15.", "Xạ thủ Orc bắn 15 viên đạn, mỗi viên gây 54 sát thương vật lý, tổng cộng 810. CD: 15." },
					prices_standard = { "119", "119" },
					prices_enhanced = { "136", "136" }
				},
				{
					name = "Máy phóng Goblin",
					standard = "Pháo thủ dùng thêm Goblin làm đạn. Cứ 15 giây phóng một thủy thủ Goblin Mũ Đỏ, gây 50-70 (55-77) sát thương pháo trong phạm vi 105 (126) khi tiếp đất. Goblin rời đi sau 5 giây chiến đấu và miễn nhiễm sát thương diện rộng từ xa.",
					enhanced = "Pháo thủ dùng thêm Goblin làm đạn. Cứ 15 giây phóng một thủy thủ Goblin Mũ Đỏ, gây 50-70 (55-77) sát thương pháo trong phạm vi 105 (126) khi tiếp đất. Goblin rời đi sau 5 giây chiến đấu và miễn nhiễm sát thương diện rộng từ xa.",
					levels_standard = { "Pháo thủ dùng thêm Goblin làm đạn. Cứ 15 giây phóng một thủy thủ Goblin Mũ Đỏ, gây 50-70 (55-77) sát thương pháo trong phạm vi 105 (126) khi tiếp đất. Goblin rời đi sau 5 giây chiến đấu và miễn nhiễm sát thương diện rộng từ xa.", "Pháo thủ dùng thêm Goblin làm đạn. Cứ 10 giây phóng một thủy thủ Goblin Mũ Đỏ, gây 50-70 (55-77) sát thương pháo trong phạm vi 105 (126) khi tiếp đất. Goblin rời đi sau 5 giây chiến đấu và miễn nhiễm sát thương diện rộng từ xa." },
					levels_enhanced = { "Pháo thủ dùng thêm Goblin làm đạn. Cứ 15 giây phóng một thủy thủ Goblin Mũ Đỏ, gây 50-70 (55-77) sát thương pháo trong phạm vi 105 (126) khi tiếp đất. Goblin rời đi sau 5 giây chiến đấu và miễn nhiễm sát thương diện rộng từ xa.", "Pháo thủ dùng thêm Goblin làm đạn. Cứ 10 giây phóng một thủy thủ Goblin Mũ Đỏ, gây 50-70 (55-77) sát thương pháo trong phạm vi 105 (126) khi tiếp đất. Goblin rời đi sau 5 giây chiến đấu và miễn nhiễm sát thương diện rộng từ xa." },
					prices_standard = { "170", "85" },
					prices_enhanced = { "170", "85" }
				},
			}
		},
		["tower_paladin_covenant_lvl4"] = {
			doc_id = "",
			title = "Thánh đường hiệp sĩ",
			attack = {
				standard = "Tấn công cận chiến, gây sát thương vật lý.",
				enhanced = "Tấn công cận chiến, gây sát thương vật lý."
			},
			change_note = "Nhận xét: Đây là doanh trại đỡ đòn có chỉ số cơ bản thấp nhất; ở cấp tối đa gần như chỉ bằng lính cấp 3 của các phần trước. Vì vậy, tháp hướng tới giá rẻ và hiệu quả kinh tế.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Tiên phong gương mẫu",
					standard = "Nâng một binh sĩ thành đội trưởng với 200 (220) máu, 60 giáp và hồi 30 máu ngoài giao tranh; sức tấn công và tốc độ đánh không đổi. Đội trưởng tạo hào quang trong 5 giây, tăng 20% sức tấn công cho anh hùng và viện binh trong phạm vi 140. CD: 20 giây.",
					enhanced = "Nâng một binh sĩ thành đội trưởng với 200 (220) máu, 60 giáp và hồi 30 máu ngoài giao tranh; sức tấn công và tốc độ đánh không đổi. Đội trưởng tạo hào quang trong 5 giây, tăng 20% sức tấn công cho anh hùng và viện binh trong phạm vi 140. CD: 20 giây.",
					levels_standard = { "Nâng một binh sĩ thành đội trưởng với 200 (220) máu, 60 giáp và hồi 30 máu ngoài giao tranh; sức tấn công và tốc độ đánh không đổi. Đội trưởng tạo hào quang trong 5 giây, tăng 20% sức tấn công cho anh hùng và viện binh trong phạm vi 140. CD: 20 giây." },
					levels_enhanced = { "Nâng một binh sĩ thành đội trưởng với 200 (220) máu, 60 giáp và hồi 30 máu ngoài giao tranh; sức tấn công và tốc độ đánh không đổi. Đội trưởng tạo hào quang trong 5 giây, tăng 20% sức tấn công cho anh hùng và viện binh trong phạm vi 140. CD: 20 giây." },
					prices_standard = { "200" },
					prices_enhanced = { "140" }
				},
				{
					name = "Lời cầu nguyện chữa lành",
					standard = "Khi máu dưới 25%, trở nên bất tử nhưng không thể chặn địch.\nHồi 12 máu mỗi giây trong 4 giây. CD: 28.",
					enhanced = "Khi máu dưới 25%, trở nên bất tử nhưng không thể chặn địch.\nHồi 12 máu mỗi giây trong 4 giây. CD: 23.",
					levels_standard = { "Khi máu dưới 25%, trở nên bất tử nhưng không thể chặn địch.\nHồi 12 máu mỗi giây trong 4 giây. CD: 28.", "Khi máu dưới 25%, trở nên bất tử nhưng không thể chặn địch.\nHồi 24 máu mỗi giây trong 4 giây. CD: 25.", "Khi máu dưới 25%, trở nên bất tử nhưng không thể chặn địch.\nHồi 36 máu mỗi giây trong 4 giây. CD: 22." },
					levels_enhanced = { "Khi máu dưới 25%, trở nên bất tử nhưng không thể chặn địch.\nHồi 12 máu mỗi giây trong 4 giây. CD: 23.", "Khi máu dưới 25%, trở nên bất tử nhưng không thể chặn địch.\nHồi 24 máu mỗi giây trong 4 giây. CD: 17.", "Khi máu dưới 25%, trở nên bất tử nhưng không thể chặn địch.\nHồi 36 máu mỗi giây trong 4 giây. CD: 11." },
					prices_standard = { "140", "105", "105" },
					prices_enhanced = { "120", "105", "105" }
				},
			}
		},
		["tower_royal_archers_lvl4"] = {
			doc_id = "",
			title = "Cung thủ Hoàng gia",
			attack = {
				standard = "Bắn một mũi tên mỗi 0.8 giây, gây sát thương vật lý.",
				enhanced = "Bắn một mũi tên mỗi 0.8 giây, gây sát thương vật lý."
			},
			change_note = "Nhận xét: Tháp cung chỉ chuyên gây sát thương nhưng vẫn thua tháp nỏ phần 2 và tháp cung cấp 3 phần 3. Vì vậy, cũng hướng tới giá rẻ và hiệu quả kinh tế.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Bắn xuyên giáp",
					standard = "Bắn 3 mũi tên, mỗi mũi gây 38-58 sát thương vật lý và bỏ qua 20 giáp của mục tiêu. CD: 15 (12) (6.4) giây. Kỹ năng làm chậm lượt đánh thường tiếp theo.",
					enhanced = "Bắn 3 mũi tên, mỗi mũi gây 38-58 sát thương vật lý và bỏ qua 20 giáp của mục tiêu. CD: 8 (6.4) giây. Kỹ năng làm chậm lượt đánh thường tiếp theo.",
					levels_standard = { "Bắn 3 mũi tên, mỗi mũi gây 38-58 sát thương vật lý và bỏ qua 20 giáp của mục tiêu. CD: 15 (12) giây. Kỹ năng làm chậm lượt đánh thường tiếp theo.", "Bắn 3 mũi tên, mỗi mũi gây 78-118 sát thương vật lý và bỏ qua 35 giáp của mục tiêu. CD: 15 (12) giây. Kỹ năng làm chậm lượt đánh thường tiếp theo.", "Bắn 3 mũi tên, mỗi mũi gây 120-150 sát thương vật lý và bỏ qua 50 giáp của mục tiêu. CD: 15 (12) giây. Kỹ năng làm chậm lượt đánh thường tiếp theo." },
					levels_enhanced = { "Bắn 3 mũi tên, mỗi mũi gây 38-58 sát thương vật lý và bỏ qua 20 giáp của mục tiêu. CD: 8 (6.4) giây. Kỹ năng làm chậm lượt đánh thường tiếp theo.", "Bắn 3 mũi tên, mỗi mũi gây 78-118 sát thương vật lý và bỏ qua 35 giáp của mục tiêu. CD: 8 (6.4) giây. Kỹ năng làm chậm lượt đánh thường tiếp theo.", "Bắn 3 mũi tên, mỗi mũi gây 120-150 sát thương vật lý và bỏ qua 50 giáp của mục tiêu. CD: 8 (6.4) giây. Kỹ năng làm chậm lượt đánh thường tiếp theo." },
					prices_standard = { "120", "90", "90" },
					prices_enhanced = { "120", "90", "90" }
				},
				{
					name = "Thợ săn tham lam",
					standard = "Triệu hồi chiến ưng tấn công địch trên đường, gây 18-26 sát thương vật lý.\nCD trung bình: 2.7 giây.",
					enhanced = "Triệu hồi chiến ưng tấn công địch trên đường, gây 34-67 sát thương vật lý.\nCD trung bình: 2.7 giây.",
					levels_standard = { "Triệu hồi chiến ưng tấn công địch trên đường, gây 18-26 sát thương vật lý.\nCD trung bình: 2.7 giây.", "Triệu hồi chiến ưng tấn công địch trên đường, gây 34-52 sát thương vật lý.\nCD trung bình: 2.7 giây.", "Triệu hồi chiến ưng tấn công địch trên đường, gây 52-78 sát thương vật lý.\nCD trung bình: 2.7 giây." },
					levels_enhanced = { "Triệu hồi chiến ưng tấn công địch trên đường, gây 34-67 sát thương vật lý.\nCD trung bình: 2.7 giây.", "Triệu hồi chiến ưng tấn công địch trên đường, gây 66-133 sát thương vật lý.\nCD trung bình: 2.7 giây.", "Triệu hồi chiến ưng tấn công địch trên đường, gây 98-199 sát thương vật lý.\nCD trung bình: 2.7 giây." },
					prices_standard = { "200", "150", "150" },
					prices_enhanced = { "150", "120", "120" }
				},
			}
		},
		["tower_arcane_wizard_lvl4"] = {
			doc_id = "",
			title = "Pháp sư bí thuật",
			attack = {
				standard = "Phóng tia phép mỗi 2.0 giây, gây sát thương phép.",
				enhanced = "Phóng tia phép mỗi 1.9 giây, gây sát thương phép."
			},
			change_note = "Nhận xét: Trước khi được tăng sức mạnh, Pháp sư Bí thuật đã hữu ích nhờ khả năng tăng sát thương. Các phần 3 đầu có vị trí tháp sát nhau, nên chọn đúng chỗ có thể hỗ trợ tới 7 tháp. Từ phần 6, hào quang được cân theo Học giả Cổ thư phần 6. Kỹ năng 1 vốn gây sát thương lên trùm nhưng không nhắm trùm, nên bổ sung cơ chế chọn mục tiêu để phát huy tác dụng này.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Tia phân rã",
					standard = "Bắn tia năng lượng cường hóa: tiêu diệt ngay mục tiêu không phải trùm, hoặc gây 800 sát thương phép lên trùm.\nCD: 30 (25) giây.",
					enhanced = "Bắn tia năng lượng cường hóa: tiêu diệt ngay mục tiêu không phải trùm, hoặc gây 800 sát thương phép lên trùm.\nƯu tiên trùm đi xa nhất trong tầm đánh; nếu không có trùm, chọn kẻ địch đi xa nhất. CD: 30 (25) giây.",
					levels_standard = { "Bắn tia năng lượng cường hóa: tiêu diệt ngay mục tiêu không phải trùm, hoặc gây 800 sát thương phép lên trùm.\nCD: 30 (25) giây.", "Bắn tia năng lượng cường hóa: tiêu diệt ngay mục tiêu không phải trùm, hoặc gây 1200 sát thương phép lên trùm.\nCD: 28 (22.4) giây.", "Bắn tia năng lượng cường hóa: tiêu diệt ngay mục tiêu không phải trùm, hoặc gây 1500 sát thương phép lên trùm.\nCD: 26 (20.8) giây." },
					levels_enhanced = { "Bắn tia năng lượng cường hóa: tiêu diệt ngay mục tiêu không phải trùm, hoặc gây 800 sát thương phép lên trùm.\nƯu tiên trùm đi xa nhất trong tầm đánh; nếu không có trùm, chọn kẻ địch đi xa nhất. CD: 30 (25) giây.", "Bắn tia năng lượng cường hóa: tiêu diệt ngay mục tiêu không phải trùm, hoặc gây 1440 sát thương phép lên trùm.\nƯu tiên trùm đi xa nhất trong tầm đánh; nếu không có trùm, chọn kẻ địch đi xa nhất. CD: 28 (22.4) giây.", "Bắn tia năng lượng cường hóa: tiêu diệt ngay mục tiêu không phải trùm, hoặc gây 2080 sát thương phép lên trùm.\nƯu tiên trùm đi xa nhất trong tầm đánh; nếu không có trùm, chọn kẻ địch đi xa nhất. CD: 26 (20.8) giây." },
					prices_standard = { "300", "112", "112" },
					prices_enhanced = { "300", "112", "112" }
				},
				{
					name = "Hào quang cường hóa",
					standard = "Tăng 15% sát thương cho các tháp trong phạm vi 440.\n",
					enhanced = "Tăng 15% sát thương cho bản thân và các tháp trong phạm vi 465.\n",
					levels_standard = { "Tăng 15% sát thương cho các tháp trong phạm vi 440, trừ bản thân. Phạm vi chịu ảnh hưởng của hiệu ứng tăng tầm đánh.\n", "Tăng 25% sát thương cho các tháp trong phạm vi 440, trừ bản thân. Phạm vi chịu ảnh hưởng của hiệu ứng tăng tầm đánh.\n", "Tăng 40% sát thương cho các tháp trong phạm vi 440, trừ bản thân. Phạm vi chịu ảnh hưởng của hiệu ứng tăng tầm đánh.\n" },
					levels_enhanced = { "Tăng 15% sát thương cho bản thân và các tháp trong phạm vi 465. Phạm vi chịu ảnh hưởng của hiệu ứng tăng tầm đánh.\n", "Tăng 25% sát thương cho bản thân và các tháp trong phạm vi 465. Phạm vi chịu ảnh hưởng của hiệu ứng tăng tầm đánh.\n", "Tăng 40% sát thương cho bản thân và các tháp trong phạm vi 465. Phạm vi chịu ảnh hưởng của hiệu ứng tăng tầm đánh.\n" },
					prices_standard = { "200", "150", "150" },
					prices_enhanced = { "200", "150", "150" }
				},
			}
		},
		["tower_tricannon_lvl4"] = {
			doc_id = "",
			title = "Pháo ba nòng",
			attack = {
				standard = "Cứ 3 giây bắn 3 quả đạn vào địch mặt đất, gây sát thương pháo trong phạm vi 90 (112.5).\nNếu có nhiều mục tiêu, 3 quả đạn sẽ nhắm vào các kẻ địch khác nhau.",
				enhanced = "Cứ 3 giây bắn 3 quả đạn vào địch mặt đất, gây sát thương pháo trong phạm vi 90 (112.5).\nNếu có nhiều mục tiêu, 3 quả đạn sẽ nhắm vào các kẻ địch khác nhau."
			},
			change_note = "Nhận xét: Cho kỹ năng 2 phối hợp với kỹ năng 1, thay vì vô tình làm yếu kỹ năng 1.",
			port_note = "Kỹ năng 1 nhận mọi hiệu ứng tăng sát thương từ các phần, ví dụ Sylvara, Murglun, Pháp sư Bí thuật phần 5 hoặc Lò luyện.",
			notes = "",
			skills = {
				{
					name = "Oanh tạc dữ dội",
					standard = "Thay thế và làm chậm đòn đánh thường, bắn nhanh 8 quả đạn ra xung quanh, cách nhau 110. Mỗi quả gây 24-48 sát thương pháo. CD: 15 (12) giây.\nKhông dùng được bom nung đỏ của kỹ năng 2 khi đang thi triển.",
					enhanced = "Thay thế và làm chậm đòn đánh thường, bắn nhanh 8 quả đạn ra xung quanh, cách nhau 110. Mỗi quả gây 24-48 sát thương pháo. CD: 15 (12) giây.\nNếu hiệu ứng kỹ năng 2 đang có hiệu lực, toàn bộ đạn bắn ra là bom nung đỏ.",
					levels_standard = { "Thay thế và làm chậm đòn đánh thường, bắn nhanh 8 quả đạn ra xung quanh, cách nhau 110. Mỗi quả gây 24-48 sát thương pháo. CD: 15 (12) giây.\nKhông dùng được bom nung đỏ của kỹ năng 2 khi đang thi triển.", "Thay thế và làm chậm đòn đánh thường, bắn nhanh 14 quả đạn ra xung quanh, cách nhau 60. Mỗi quả gây 32-64 sát thương pháo. CD: 15 (12) giây.\nKhông dùng được bom nung đỏ của kỹ năng 2 khi đang thi triển.", "Thay thế và làm chậm đòn đánh thường, bắn nhanh 22 quả đạn ra xung quanh, cách nhau 40. Mỗi quả gây 40-80 sát thương pháo. CD: 15 (12) giây.\nKhông dùng được bom nung đỏ của kỹ năng 2 khi đang thi triển." },
					levels_enhanced = { "Thay thế và làm chậm đòn đánh thường, bắn nhanh 8 quả đạn ra xung quanh, cách nhau 110. Mỗi quả gây 24-48 sát thương pháo. CD: 15 (12) giây.\nNếu hiệu ứng kỹ năng 2 đang có hiệu lực, toàn bộ đạn bắn ra là bom nung đỏ.", "Thay thế và làm chậm đòn đánh thường, bắn nhanh 14 quả đạn ra xung quanh, cách nhau 60. Mỗi quả gây 32-64 sát thương pháo. CD: 15 (12) giây.\nNếu hiệu ứng kỹ năng 2 đang có hiệu lực, toàn bộ đạn bắn ra là bom nung đỏ.", "Thay thế và làm chậm đòn đánh thường, bắn nhanh 22 quả đạn ra xung quanh, cách nhau 40. Mỗi quả gây 40-80 sát thương pháo. CD: 15 (12) giây.\nNếu hiệu ứng kỹ năng 2 đang có hiệu lực, toàn bộ đạn bắn ra là bom nung đỏ." },
					prices_standard = { "250", "150", "150" },
					prices_enhanced = { "250", "150", "150" }
				},
				{
					name = "Chế độ quá nhiệt",
					standard = "Nung đỏ nòng pháo trong 3 giây, tương đương 1 lượt đánh thường. Bom đốt mặt đất trong phạm vi 80 suốt 3.0 giây, gây 3 sát thương chuẩn mỗi 0.25 giây cho địch đi qua. Không cộng dồn. CD: 24 (19.2).\nKhông thể dùng kỹ năng 1 trong thời gian này.",
					enhanced = "Nung đỏ nòng pháo trong 3 giây, tương đương 1 lượt đánh thường. Bom đốt mặt đất trong phạm vi 80 suốt 3.0 giây, gây 3 sát thương chuẩn mỗi 0.25 giây cho địch đi qua. Không cộng dồn. CD: 24 (19.2).\nCó thể dùng kỹ năng 1 trong thời gian hiệu ứng có tác dụng.",
					levels_standard = { "Nung đỏ nòng pháo trong 3 giây, tương đương 1 lượt đánh thường. Bom đốt mặt đất trong phạm vi 80 suốt 3.0 giây, gây 3 sát thương chuẩn mỗi 0.25 giây cho địch đi qua. Không cộng dồn. CD: 24 (19.2).\nKhông thể dùng kỹ năng 1 trong thời gian này.", "Nung đỏ nòng pháo trong 6 giây, tương đương 2 lượt đánh thường. Bom đốt mặt đất trong phạm vi 80 suốt 3.0 giây, gây 5 sát thương chuẩn mỗi 0.25 giây cho địch đi qua. Không cộng dồn. CD: 24 (19.2).\nKhông thể dùng kỹ năng 1 trong thời gian này.", "Nung đỏ nòng pháo trong 9 giây, tương đương 3 lượt đánh thường. Bom đốt mặt đất trong phạm vi 80 suốt 3.0 giây, gây 7 sát thương chuẩn mỗi 0.25 giây cho địch đi qua. Không cộng dồn. CD: 24 (19.2).\nKhông thể dùng kỹ năng 1 trong thời gian này." },
					levels_enhanced = { "Nung đỏ nòng pháo trong 3 giây, tương đương 1 lượt đánh thường. Bom của đòn đánh thường và Oanh tạc dữ dội đốt mặt đất trong phạm vi 80 suốt 3.0 giây, gây 3 sát thương chuẩn mỗi 0.25 giây cho địch đi qua. Không cộng dồn. CD: 24 (19.2).", "Nung đỏ nòng pháo trong 6 giây, tương đương 2 lượt đánh thường. Bom của đòn đánh thường và Oanh tạc dữ dội đốt mặt đất trong phạm vi 80 suốt 3.0 giây, gây 6 sát thương chuẩn mỗi 0.25 giây cho địch đi qua. Không cộng dồn. CD: 24 (19.2).", "Nung đỏ nòng pháo trong 9 giây, tương đương 3 lượt đánh thường. Bom của đòn đánh thường và Oanh tạc dữ dội đốt mặt đất trong phạm vi 80 suốt 3.0 giây, gây 9 sát thương chuẩn mỗi 0.25 giây cho địch đi qua. Không cộng dồn. CD: 24 (19.2)." },
					prices_standard = { "150", "112", "112" },
					prices_enhanced = { "150", "112", "112" }
				},
			}
		},
		["tower_arborean_emissary_lvl4"] = {
			doc_id = "",
			title = "Sứ giả Arborean",
			attack = {
				standard = "Cứ 1.8 giây bắn đạn phép, gây sát thương phép và khiến mục tiêu dễ bị tổn thương trong 5/5/5/5 giây, với hệ số 1.2/1.3/1.4/1.5.\nTháp giảm ưu tiên tấn công các mục tiêu đã chịu hiệu ứng.",
				enhanced = "Cứ 1.8 giây bắn đạn phép, gây sát thương phép và khiến mục tiêu dễ bị tổn thương trong 4/6/8/10 giây, với hệ số 1.2/1.3/1.4/1.5.\nTháp giảm ưu tiên tấn công các mục tiêu đã chịu hiệu ứng."
			},
			change_note = "Nhận xét: Sát thương thường bản gốc quá thấp khiến các cấp 2/3/4 ít hữu ích, nên tăng chỉ số và thời gian dễ bị tổn thương. Bản FL có 12 ô chọn tháp, đủ chỗ mang tháp hỗ trợ, nên không cần tăng quá mạnh.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Quà tặng thiên nhiên",
					standard = "Triệu hồi tiên chữa lành đồng minh trong phạm vi 460: hồi 4 máu mỗi 0.25 giây, kéo dài 6 giây. CD: 20 (16) giây.",
					enhanced = "Triệu hồi tiên chữa lành đồng minh trong phạm vi 460: hồi 4 máu mỗi 0.25 giây, kéo dài 6 giây. CD: 20 (16) giây.",
					levels_standard = { "Triệu hồi tiên chữa lành đồng minh trong phạm vi 460: hồi 4 máu mỗi 0.25 giây, kéo dài 6 giây. CD: 20 (16) giây.", "Triệu hồi tiên chữa lành đồng minh trong phạm vi 460: hồi 8 máu mỗi 0.25 giây, kéo dài 6 giây. CD: 20 (16) giây.", "Triệu hồi tiên chữa lành đồng minh trong phạm vi 460: hồi 12 máu mỗi 0.25 giây, kéo dài 6 giây. CD: 20 (16) giây." },
					levels_enhanced = { "Triệu hồi tiên chữa lành đồng minh trong phạm vi 460: hồi 4 máu mỗi 0.25 giây, kéo dài 6 giây. CD: 20 (16) giây.", "Triệu hồi tiên chữa lành đồng minh trong phạm vi 460: hồi 8 máu mỗi 0.25 giây, kéo dài 6 giây. CD: 20 (16) giây.", "Triệu hồi tiên chữa lành đồng minh trong phạm vi 460: hồi 12 máu mỗi 0.25 giây, kéo dài 6 giây. CD: 20 (16) giây." },
					prices_standard = { "120", "90", "90" },
					prices_enhanced = { "120", "90", "90" }
				},
				{
					name = "Dây gai trói buộc",
					standard = "Mọc 3 rễ cây, trói địch trong phạm vi 440 suốt 3 giây và gây 40 sát thương chuẩn. CD: 15 (12) giây.",
					enhanced = "Mọc 3 rễ cây, trói địch trong phạm vi 440 suốt 3 giây và gây 40 sát thương chuẩn. CD: 15 (12) giây.",
					levels_standard = { "Mọc 3 rễ cây, trói địch trong phạm vi 440 suốt 3 giây và gây 40 sát thương chuẩn. CD: 15 (12) giây.", "Mọc 5 rễ cây, trói địch trong phạm vi 440 suốt 3 giây và gây 40 sát thương chuẩn. CD: 13 (10.4) giây.", "Mọc 8 rễ cây, trói địch trong phạm vi 440 suốt 3 giây và gây 40 sát thương chuẩn. CD: 12 (9.6) giây." },
					levels_enhanced = { "Mọc 3 rễ cây, trói địch trong phạm vi 440 suốt 3 giây và gây 40 sát thương chuẩn. CD: 15 (12) giây.", "Mọc 5 rễ cây, trói địch trong phạm vi 440 suốt 3 giây và gây 65 sát thương chuẩn. CD: 13 (10.4) giây.", "Mọc 8 rễ cây, trói địch trong phạm vi 440 suốt 3 giây và gây 90 sát thương chuẩn. CD: 12 (9.6) giây." },
					prices_standard = { "160", "120", "120" },
					prices_enhanced = { "160", "120", "120" }
				},
			}
		},
		["tower_demon_pit_lvl4"] = {
			doc_id = "",
			title = "Hố quỷ",
			attack = {
				standard = "Cứ 4 giây phóng một tiểu quỷ chặn địch và gây sát thương vật lý. Sau 10 giây hoặc khi chết, nó phát nổ, gây sát thương pháo bằng [sức tấn công × 1] trong phạm vi 80 (100). Vụ nổ làm choáng địch 0.25/0.4/0.6/0.8 giây.",
				enhanced = "Cứ 2.8 giây phóng một tiểu quỷ chặn địch và gây sát thương vật lý. Sau 10 giây hoặc khi chết, nó phát nổ, gây sát thương pháo bằng [sức tấn công × 3.75] trong phạm vi 80 (100). Vụ nổ làm choáng địch 0.25/0.4/0.6/0.8 giây."
			},
			change_note = "Nhận xét: Các cấp 2/3/4 của bản gốc hầu như không hữu ích. Dựa trên thiết kế cũ, chuyển tháp sang hướng pháo để tăng hiệu quả kỹ năng 1, giảm khoảng trống giữa các đòn và tăng tính linh hoạt.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Bậc thầy vụ nổ",
					standard = "Tăng 20% sát thương nổ của tiểu quỷ. Vụ nổ đốt địch, gây 2-4 sát thương chuẩn mỗi giây trong 3 giây.",
					enhanced = "Tăng 30% sát thương nổ của tiểu quỷ. Vụ nổ đốt địch, gây 2-4 sát thương chuẩn mỗi giây trong 3 giây.",
					levels_standard = { "Tăng 20% sát thương nổ của tiểu quỷ. Vụ nổ đốt địch, gây 2-4 sát thương chuẩn mỗi giây trong 3 giây.", "Tăng 40% sát thương nổ của tiểu quỷ. Vụ nổ đốt địch, gây 4-6 sát thương chuẩn mỗi giây trong 4 giây.", "Tăng 60% sát thương nổ của tiểu quỷ. Vụ nổ đốt địch, gây 6-10 sát thương chuẩn mỗi giây trong 5 giây." },
					levels_enhanced = { "Tăng 30% sát thương nổ của tiểu quỷ. Vụ nổ đốt địch, gây 2-4 sát thương chuẩn mỗi giây trong 3 giây.", "Tăng 60% sát thương nổ của tiểu quỷ. Vụ nổ đốt địch, gây 4-6 sát thương chuẩn mỗi giây trong 4 giây.", "Tăng 100% sát thương nổ của tiểu quỷ. Vụ nổ đốt địch, gây 6-10 sát thương chuẩn mỗi giây trong 5 giây." },
					prices_standard = { "150", "112", "112" },
					prices_enhanced = { "150", "112", "112" }
				},
				{
					name = "Đại quỷ giáng trần",
					standard = "Triệu hồi đại quỷ với 110 máu và 19-29 sức tấn công. Khi chết, nó phát nổ gây 100 sát thương pháo.\nCD: 40 (32) giây. Được tính là một đòn đánh thường cường hóa.",
					enhanced = "Triệu hồi đại quỷ với 110 máu và 19-29 sức tấn công. Khi chết, nó phát nổ gây 100 sát thương pháo.\nCD: 28 (22.4) giây. Được tính là một đòn đánh thường cường hóa.",
					levels_standard = { "Triệu hồi đại quỷ với 110 máu và 19-29 sức tấn công. Khi chết, nó phát nổ gây 100 sát thương pháo.\nCD: 40 (32) giây. Được tính là một đòn đánh thường cường hóa.", "Triệu hồi đại quỷ với 165 máu và 28-42 sức tấn công. Khi chết, nó phát nổ gây 150 sát thương pháo.\nCD: 40 (32) giây. Được tính là một đòn đánh thường cường hóa.", "Triệu hồi đại quỷ với 220 máu và 37-55 sức tấn công. Khi chết, nó phát nổ gây 250 sát thương pháo.\nCD: 40 (32) giây. Được tính là một đòn đánh thường cường hóa." },
					levels_enhanced = { "Triệu hồi đại quỷ với 110 máu và 19-29 sức tấn công. Khi chết, nó phát nổ gây 100 sát thương pháo.\nCD: 28 (22.4) giây. Được tính là một đòn đánh thường cường hóa.", "Triệu hồi đại quỷ với 165 máu và 28-42 sức tấn công. Khi chết, nó phát nổ gây 150 sát thương pháo.\nCD: 28 (22.4) giây. Được tính là một đòn đánh thường cường hóa.", "Triệu hồi đại quỷ với 220 máu và 37-55 sức tấn công. Khi chết, nó phát nổ gây 250 sát thương pháo.\nCD: 28 (22.4) giây. Được tính là một đòn đánh thường cường hóa." },
					prices_standard = { "200", "75", "75" },
					prices_enhanced = { "200", "75", "75" }
				},
			}
		},
		["tower_elven_stargazers_lvl4"] = {
			doc_id = "",
			title = "Tinh linh Chiêm tinh",
			attack = {
				standard = "Cứ 2.7 giây thực hiện một lượt đánh gồm 5 tia phép; mỗi tia gây sát thương phép theo bảng chỉ số. Nếu có ít nhất 5 địch, 5 mục tiêu nhận 1 lần đánh mỗi mục tiêu; nếu ít hơn, các mục tiêu trong tầm lần lượt chịu đòn.",
				enhanced = "Cứ 2.7 giây thực hiện một lượt đánh gồm 5 tia phép; mỗi tia gây sát thương phép theo bảng chỉ số. Nếu có ít nhất 5 địch, 5 mục tiêu nhận 1 lần đánh mỗi mục tiêu; nếu ít hơn, các mục tiêu trong tầm lần lượt chịu đòn."
			},
			change_note = "Nhận xét: Chỉ tăng tính hữu dụng của kỹ năng 2 khi không xây nhiều tháp Chiêm tinh.",
			port_note = "Thay đổi khi chuyển sang FL: Kỹ năng 1 bản gốc khiến mục tiêu bất tử giữa hoạt ảnh dịch chuyển thứ 1 và thứ 2. Giữ cơ chế này có thể khiến địch bị kẹt ở trạng thái bất tử, nên bản FL đã bỏ nó.",
			notes = "",
			skills = {
				{
					name = "Chân trời sự kiện",
					standard = "Dịch chuyển tối đa 3 kẻ địch lùi 200 đơn vị khoảng cách.\nLàm chậm đòn đánh thường tiếp theo. CD: 20 giây.",
					enhanced = "Dịch chuyển tối đa 3 kẻ địch lùi 200 đơn vị khoảng cách.\nLàm chậm đòn đánh thường tiếp theo. CD: 20 giây.",
					levels_standard = { "Dịch chuyển tối đa 3 kẻ địch lùi 200 đơn vị khoảng cách.\nLàm chậm đòn đánh thường tiếp theo. CD: 20 giây.", "Dịch chuyển tối đa 4 kẻ địch lùi 250 đơn vị khoảng cách.\nLàm chậm đòn đánh thường tiếp theo. CD: 18 giây.", "Dịch chuyển tối đa 6 kẻ địch lùi 300 đơn vị khoảng cách.\nLàm chậm đòn đánh thường tiếp theo. CD: 16 giây." },
					levels_enhanced = { "Dịch chuyển tối đa 3 kẻ địch lùi 200 đơn vị khoảng cách.\nLàm chậm đòn đánh thường tiếp theo. CD: 20 giây.", "Dịch chuyển tối đa 4 kẻ địch lùi 250 đơn vị khoảng cách.\nLàm chậm đòn đánh thường tiếp theo. CD: 18 giây.", "Dịch chuyển tối đa 6 kẻ địch lùi 300 đơn vị khoảng cách.\nLàm chậm đòn đánh thường tiếp theo. CD: 16 giây." },
					prices_standard = { "250", "75", "75" },
					prices_enhanced = { "250", "75", "75" }
				},
				{
					name = "Ánh sao bùng nổ",
					standard = "Đòn đánh đánh dấu mục tiêu bằng ánh sao trong 0.8 giây. Khi mục tiêu chết, tạo sao phép theo số địch trong phạm vi 400 quanh nó, tối đa 3 sao. Mỗi sao gây 18-30 sát thương phép và làm choáng 0.8 giây.",
					enhanced = "Đòn đánh đánh dấu mục tiêu bằng ánh sao trong 1.5 giây. Khi mục tiêu chết, tạo sao phép theo số địch trong phạm vi 400 quanh nó, tối đa 3 sao. Mỗi sao gây 18-30 sát thương phép và làm choáng 0.8 giây.",
					levels_standard = { "Đòn đánh đánh dấu mục tiêu bằng ánh sao trong 0.8 giây. Khi mục tiêu chết, tạo sao phép theo số địch trong phạm vi 400 quanh nó, tối đa 3 sao. Mỗi sao gây 18-30 sát thương phép và làm choáng 0.8 giây.", "Đòn đánh đánh dấu mục tiêu bằng ánh sao trong 0.8 giây. Khi mục tiêu chết, tạo sao phép theo số địch trong phạm vi 400 quanh nó, tối đa 4 sao. Mỗi sao gây 28-42 sát thương phép và làm choáng 0.8 giây.", "Đòn đánh đánh dấu mục tiêu bằng ánh sao trong 0.8 giây. Khi mục tiêu chết, tạo sao phép theo số địch trong phạm vi 400 quanh nó, tối đa 5 sao. Mỗi sao gây 36-54 sát thương phép và làm choáng 0.8 giây." },
					levels_enhanced = { "Đòn đánh đánh dấu mục tiêu bằng ánh sao trong 1.5 giây. Khi mục tiêu chết, tạo sao phép theo số địch trong phạm vi 400 quanh nó, tối đa 3 sao. Mỗi sao gây 18-30 sát thương phép và làm choáng 0.8 giây.", "Bắn thêm 1 tia mỗi lượt. Đòn đánh đánh dấu mục tiêu bằng ánh sao trong 1.5 giây. Khi mục tiêu chết, tạo sao phép theo số địch trong phạm vi 400 quanh nó, tối đa 4 sao. Mỗi sao gây 28-42 sát thương phép và làm choáng 0.8 giây.", "Bắn thêm 2 tia mỗi lượt. Đòn đánh đánh dấu mục tiêu bằng ánh sao trong 1.5 giây. Khi mục tiêu chết, tạo sao phép theo số địch trong phạm vi 400 quanh nó, tối đa 5 sao. Mỗi sao gây 36-54 sát thương phép và làm choáng 0.8 giây." },
					prices_standard = { "150", "112", "112" },
					prices_enhanced = { "150", "150", "150" }
				},
			}
		},
		["tower_rocket_gunners_lvl4"] = {
			doc_id = "",
			title = "Xạ thủ tên lửa",
			attack = {
				standard = "Bắn từ xa khi có địch trong phạm vi 300 (330), cận chiến khi địch ở phạm vi 40. Có thể chuyển giữa chế độ mặt đất và trên không. Trên không không thể chặn địch.",
				enhanced = "Bắn từ xa khi có địch trong phạm vi 300 (330), cận chiến khi địch ở phạm vi 40. Có thể chuyển giữa chế độ mặt đất và trên không. Trên không không thể chặn địch và miễn nhiễm mọi sát thương từ xa."
			},
			change_note = "Nhận xét: Bản gốc gây sát thương thấp, đánh chậm, chỉ có 110 máu và 30 giáp nên thường bị hạ trước khi gây đủ sát thương. Bản FL tăng chỉ số và bảo đảm xạ thủ có thể phát huy sát thương khi bay.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Tên lửa Stinger",
					standard = "Cường hóa đòn đánh thường: bắn tên lửa tiêu diệt ngay một kẻ địch trong tầm có máu không vượt quá 300. CD: 24 (19.2) giây.",
					enhanced = "Cường hóa đòn đánh thường: bắn tên lửa tiêu diệt ngay một kẻ địch trong tầm có máu không vượt quá 500. CD: 24 (19.2) giây.",
					levels_standard = { "Cường hóa đòn đánh thường: bắn tên lửa tiêu diệt ngay một kẻ địch trong tầm có máu không vượt quá 300. CD: 24 (19.2) giây.", "Cường hóa đòn đánh thường: bắn tên lửa tiêu diệt ngay một kẻ địch trong tầm có máu không vượt quá 600. CD: 20 (16) giây.", "Cường hóa đòn đánh thường: bắn tên lửa tiêu diệt ngay một kẻ địch trong tầm có máu không vượt quá 900. CD: 16 (12.8) giây." },
					levels_enhanced = { "Cường hóa đòn đánh thường: bắn tên lửa tiêu diệt ngay một kẻ địch trong tầm có máu không vượt quá 500. CD: 24 (19.2) giây.", "Cường hóa đòn đánh thường: bắn tên lửa tiêu diệt ngay một kẻ địch trong tầm có máu không vượt quá 1000. CD: 20 (16) giây.", "Cường hóa đòn đánh thường: bắn tên lửa tiêu diệt ngay một kẻ địch trong tầm có máu không vượt quá 1500. CD: 16 (12.8) giây." },
					prices_standard = { "250", "75", "75" },
					prices_enhanced = { "250", "75", "75" }
				},
				{
					name = "Đạn phốt pho",
					standard = "Cường hóa đòn đánh thường: mỗi đòn giảm 1 giáp của mục tiêu và gây thêm 13-16 (16) sát thương pháo trong phạm vi 80 (100).",
					enhanced = "Cường hóa đòn đánh thường: mỗi đòn giảm 1 giáp của mục tiêu và gây thêm 13-16 (16) sát thương pháo trong phạm vi 80 (100).",
					levels_standard = { "Cường hóa đòn đánh thường: mỗi đòn giảm 1 giáp của mục tiêu và gây thêm 13-16 (16) sát thương pháo trong phạm vi 80 (100).", "Cường hóa đòn đánh thường: mỗi đòn giảm 2 giáp của mục tiêu và gây thêm 17-22 (24) sát thương pháo trong phạm vi 80 (100).", "Cường hóa đòn đánh thường: mỗi đòn giảm 3 giáp của mục tiêu và gây thêm 21-27 (32) sát thương pháo trong phạm vi 80 (100)." },
					levels_enhanced = { "Cường hóa đòn đánh thường: mỗi đòn giảm 1 giáp của mục tiêu và gây thêm 13-16 (16) sát thương pháo trong phạm vi 80 (100).", "Cường hóa đòn đánh thường: mỗi đòn giảm 2 giáp của mục tiêu và gây thêm 19-24 (24) sát thương pháo trong phạm vi 80 (100).", "Cường hóa đòn đánh thường: mỗi đòn giảm 3 giáp của mục tiêu và gây thêm 25-32 (32) sát thương pháo trong phạm vi 80 (100)." },
					prices_standard = { "200", "150", "150" },
					prices_enhanced = { "200", "150", "150" }
				},
			}
		},
		["tower_ballista_lvl4"] = {
			doc_id = "",
			title = "Trạm nỏ lớn",
			attack = {
				standard = "Cứ 4 giây liên tiếp bắn 5 mũi tên gây sát thương vật lý. Nâng cấp sẽ lập tức làm mới CD.\nSau khi hạ mục tiêu, chuyển sang địch khác nếu có trong phạm vi 150.",
				enhanced = "Cứ 4 giây liên tiếp bắn 5 mũi tên gây sát thương vật lý. Nâng cấp sẽ lập tức làm mới CD.\nSau khi hạ mục tiêu, chuyển sang địch khác nếu có trong phạm vi 150."
			},
			change_note = "Nhận xét: Kém linh hoạt hơn Cung thủ Hoàng gia và các tháp cung thường, nên cần chỉ số đánh thường cao hơn. Tăng sát thương cho cả hai kỹ năng.",
			port_note = "Kỹ năng 1 nhận mọi hiệu ứng tăng sát thương từ các phần, ví dụ Sylvara, Murglun, Pháp sư Bí thuật phần 5 hoặc Lò luyện.",
			notes = "",
			skills = {
				{
					name = "Mũi tên kết liễu",
					standard = "Mũi tên cuối trong 5 mũi tên mỗi lượt gây sát thương bằng 1.5 lần đòn đánh thường và làm choáng mục tiêu 2.5 giây.",
					enhanced = "Mũi tên cuối trong 5 mũi tên mỗi lượt xuyên qua mọi kẻ địch trên đường, gây sát thương gấp 1.2 lần và làm choáng 1.1 giây.",
					levels_standard = { "Mũi tên cuối trong 5 mũi tên mỗi lượt gây sát thương bằng 1.5 lần đòn đánh thường và làm choáng mục tiêu 2.5 giây.", "Mũi tên cuối trong 5 mũi tên mỗi lượt gây sát thương bằng 2 lần đòn đánh thường và làm choáng mục tiêu 2.5 giây.", "Mũi tên cuối trong 5 mũi tên mỗi lượt gây sát thương bằng 2.5 lần đòn đánh thường và làm choáng mục tiêu 2.5 giây." },
					levels_enhanced = { "Mũi tên cuối trong 5 mũi tên mỗi lượt xuyên qua mọi kẻ địch trên đường, gây sát thương gấp 1.2 lần và làm choáng mọi mục tiêu trúng đòn 1.1 giây.", "Mũi tên cuối trong 5 mũi tên mỗi lượt xuyên qua mọi kẻ địch trên đường, gây sát thương gấp 1.6 lần và làm choáng mọi mục tiêu trúng đòn 1.1 giây.", "Mũi tên cuối trong 5 mũi tên mỗi lượt xuyên qua mọi kẻ địch trên đường, gây sát thương gấp 2.0 lần và làm choáng mọi mục tiêu trúng đòn 1.1 giây." },
					prices_standard = { "250", "75", "75" },
					prices_enhanced = { "250", "75", "75" }
				},
				{
					name = "Bom phế liệu",
					standard = "Ném bom phế liệu với tầm đánh 500, nổ tại 3 vùng tròn bán kính 120.\nGây 82-124 (124) sát thương pháo và làm chậm 50% trong 6 giây. Địch ở vùng giao nhau chỉ nhận 1 lần sát thương. CD: 24 (19.2) giây.",
					enhanced = "Ném bom phế liệu với tầm đánh 500, nổ tại 3 vùng tròn bán kính 120.\nGây 100-200 (200) sát thương pháo và làm chậm 50% trong 6 giây. Địch ở vùng giao nhau chỉ nhận 1 lần sát thương. CD: 24 (19.2) giây.",
					levels_standard = { "Ném bom phế liệu với tầm đánh 500, nổ tại 3 vùng tròn bán kính 120.\nGây 82-124 (124) sát thương pháo và làm chậm 50% trong 6 giây. Địch ở vùng giao nhau chỉ nhận 1 lần sát thương. CD: 24 (19.2) giây.", "Ném bom phế liệu với tầm đánh 500, nổ tại 3 vùng tròn bán kính 120.\nGây 118-176 (176) sát thương pháo và làm chậm 50% trong 6 giây. Địch ở vùng giao nhau chỉ nhận 1 lần sát thương. CD: 20 (16) giây.", "Ném bom phế liệu với tầm đánh 500, nổ tại 3 vùng tròn bán kính 120.\nGây 142-214 (214) sát thương pháo và làm chậm 50% trong 6 giây. Địch ở vùng giao nhau chỉ nhận 1 lần sát thương. CD: 16 (12.8) giây." },
					levels_enhanced = { "Ném bom phế liệu với tầm đánh 500, nổ tại 3 vùng tròn bán kính 120.\nGây 100-200 (200) sát thương pháo và làm chậm 50% trong 6 giây. Địch ở vùng giao nhau chỉ nhận 1 lần sát thương. CD: 24 (19.2) giây.", "Ném bom phế liệu với tầm đánh 500, nổ tại 3 vùng tròn bán kính 120.\nGây 170-325 (325) sát thương pháo và làm chậm 50% trong 6 giây. Địch ở vùng giao nhau chỉ nhận 1 lần sát thương. CD: 20 (16) giây.", "Ném bom phế liệu với tầm đánh 500, nổ tại 3 vùng tròn bán kính 120.\nGây 240-450 (450) sát thương pháo và làm chậm 50% trong 6 giây. Địch ở vùng giao nhau chỉ nhận 1 lần sát thương. CD: 16 (12.8) giây." },
					prices_standard = { "200", "150", "150" },
					prices_enhanced = { "200", "150", "150" }
				},
			}
		},
		["tower_necromancer_lvl4"] = {
			doc_id = "",
			title = "Pháp sư chiêu hồn",
			attack = {
				standard = "Tích đạn khi không có mục tiêu, tối đa 4 đạn phép. Cứ 1.5 giây bắn một đạn gây sát thương phép.\nĐòn đánh gây trạng thái tử linh trong 3 giây. Địch chết khi chịu hiệu ứng không kích hoạt hiệu ứng khi chết và biến thành bộ xương theo kích cỡ: địch nhỏ thành xương nhỏ, địch vừa/lớn thành xương lớn. Xương nhỏ có 50 máu, 0 giáp; xương lớn có 150 máu, 0 giáp.\nMỗi tháp duy trì tối đa 2/3/4/5 bộ xương, trong đó tối đa 1 xương lớn. Toàn bản đồ tối đa 30 bộ xương.",
				enhanced = "Tích đạn khi không có mục tiêu hoặc khi một kẻ địch chết, tối đa 4 đạn phép. Cứ 1.5 giây bắn một đạn gây sát thương phép.\nĐòn đánh gây trạng thái tử linh trong 3 giây. Địch chết khi chịu hiệu ứng không kích hoạt hiệu ứng khi chết và biến thành bộ xương theo kích cỡ: địch nhỏ thành xương nhỏ, địch vừa/lớn thành xương lớn. Xương nhỏ có 50 máu, 0 giáp; xương lớn có 150 máu, 0 giáp.\nMỗi tháp duy trì tối đa 2/3/4/5 bộ xương, trong đó tối đa 1 xương lớn. Toàn bản đồ tối đa 30 bộ xương."
			},
			change_note = "Nhận xét: Chỉ số quá thấp nên điều chỉnh đòn đánh thường theo Tử linh sư phần 2. Lượt kết liễu phần 2 tạo khả năng chặn địch, còn phần 5 tạo sức tấn công. Các phần 3 đầu đông quái: kỹ năng 2 yếu ở phần 5 nhưng đủ quét một đường trong các phần 3 đầu. Chỉ số 150 thấp nhưng không cần tăng nhiều.",
			port_note = "Thay đổi khi chuyển sang FL: Bộ xương bản gốc xuất hiện sau khi địch chết 2 giây; bản FL tạo ngay lập tức. Thêm các đồng minh thuộc nhóm bộ xương phần 2 vào danh sách chịu hiệu ứng kỹ năng 1.",
			notes = "",
			skills = {
				{
					name = "Vật tổ Rung xương",
					standard = "Triệu hồi vật tổ tồn tại 12 giây, phạm vi 250. Địch bước vào lập tức chịu trạng thái tử linh. Tăng 50% sức tấn công cho bộ xương trong vùng, gồm xương của Tử linh sư phần 2, Tử linh sư phần 5, Rồng Xương phần 2 và Rồng Xương phần 5. CD: 20 giây.",
					enhanced = "Triệu hồi vật tổ tồn tại 12 giây, phạm vi 250. Địch bước vào lập tức chịu trạng thái tử linh. Tăng 50% sức tấn công cho bộ xương trong vùng, gồm xương của Tử linh sư phần 2, Tử linh sư phần 5, Rồng Xương phần 2 và Rồng Xương phần 5. CD: 20 giây.",
					levels_standard = { "Triệu hồi vật tổ tồn tại 12 giây, phạm vi 250. Địch bước vào lập tức chịu trạng thái tử linh. Tăng 50% sức tấn công cho bộ xương trong vùng, gồm xương của Tử linh sư phần 2, Tử linh sư phần 5, Rồng Xương phần 2 và Rồng Xương phần 5. CD: 20 giây.", "Triệu hồi vật tổ tồn tại 12 giây, phạm vi 250. Địch bước vào lập tức chịu trạng thái tử linh. Tăng 100% sức tấn công cho bộ xương trong vùng, gồm xương của Tử linh sư phần 2, Tử linh sư phần 5, Rồng Xương phần 2 và Rồng Xương phần 5. CD: 16 giây.", "Triệu hồi vật tổ tồn tại 12 giây, phạm vi 250. Địch bước vào lập tức chịu trạng thái tử linh. Tăng 150% sức tấn công cho bộ xương trong vùng, gồm xương của Tử linh sư phần 2, Tử linh sư phần 5, Rồng Xương phần 2 và Rồng Xương phần 5. CD: 12 giây." },
					levels_enhanced = { "Triệu hồi vật tổ tồn tại 12 giây, phạm vi 250. Địch bước vào lập tức chịu trạng thái tử linh. Tăng 50% sức tấn công cho bộ xương trong vùng, gồm xương của Tử linh sư phần 2, Tử linh sư phần 5, Rồng Xương phần 2 và Rồng Xương phần 5. CD: 20 giây.", "Triệu hồi vật tổ tồn tại 12 giây, phạm vi 250. Địch bước vào lập tức chịu trạng thái tử linh. Tăng 100% sức tấn công cho bộ xương trong vùng, gồm xương của Tử linh sư phần 2, Tử linh sư phần 5, Rồng Xương phần 2 và Rồng Xương phần 5. CD: 16 giây.", "Triệu hồi vật tổ tồn tại 12 giây, phạm vi 250. Địch bước vào lập tức chịu trạng thái tử linh. Tăng 150% sức tấn công cho bộ xương trong vùng, gồm xương của Tử linh sư phần 2, Tử linh sư phần 5, Rồng Xương phần 2 và Rồng Xương phần 5. CD: 12 giây." },
					prices_standard = { "120", "90", "90" },
					prices_enhanced = { "120", "45", "45" }
				},
				{
					name = "Kỵ sĩ xác sống",
					standard = "Cần ít nhất 2 địch trong tầm để kích hoạt. Triệu hồi kỵ sĩ bất tử lao về trước 750 đơn vị khoảng cách, gây 60 sát thương chuẩn cho địch mặt đất và áp dụng trạng thái tử linh. CD: 28 (22.4) giây.",
					enhanced = "Cần ít nhất 2 địch trong tầm để kích hoạt. Triệu hồi kỵ sĩ bất tử lao về trước 750 đơn vị khoảng cách, gây 80 sát thương chuẩn cho địch mặt đất và áp dụng trạng thái tử linh. CD: 28 (22.4) giây.",
					levels_standard = { "Cần ít nhất 2 địch trong tầm để kích hoạt. Triệu hồi kỵ sĩ bất tử lao về trước 750 đơn vị khoảng cách, gây 60 sát thương chuẩn cho địch mặt đất và áp dụng trạng thái tử linh. CD: 28 (22.4) giây.", "Cần ít nhất 2 địch trong tầm để kích hoạt. Triệu hồi kỵ sĩ bất tử lao về trước 750 đơn vị khoảng cách, gây 110 sát thương chuẩn cho địch mặt đất và áp dụng trạng thái tử linh. CD: 25 (20) giây.", "Cần ít nhất 2 địch trong tầm để kích hoạt. Triệu hồi kỵ sĩ bất tử lao về trước 750 đơn vị khoảng cách, gây 150 sát thương chuẩn cho địch mặt đất và áp dụng trạng thái tử linh. CD: 22 (17.6) giây." },
					levels_enhanced = { "Cần ít nhất 2 địch trong tầm để kích hoạt. Triệu hồi kỵ sĩ bất tử lao về trước 750 đơn vị khoảng cách, gây 80 sát thương chuẩn cho địch mặt đất và áp dụng trạng thái tử linh. CD: 28 (22.4) giây.", "Cần ít nhất 2 địch trong tầm để kích hoạt. Triệu hồi kỵ sĩ bất tử lao về trước 750 đơn vị khoảng cách, gây 145 sát thương chuẩn cho địch mặt đất và áp dụng trạng thái tử linh. CD: 25 (20) giây.", "Cần ít nhất 2 địch trong tầm để kích hoạt. Triệu hồi kỵ sĩ bất tử lao về trước 750 đơn vị khoảng cách, gây 200 sát thương chuẩn cho địch mặt đất và áp dụng trạng thái tử linh. CD: 22 (17.6) giây." },
					prices_standard = { "200", "150", "150" },
					prices_enhanced = { "200", "150", "150" }
				},
			}
		},
		["tower_flamespitter_lvl4"] = {
			doc_id = "",
			title = "Súng phun lửa Người Lùn",
			attack = {
				standard = "Cứ 3.2 giây phun lửa về một hướng trong 0.5 giây. Mỗi 0.25 giây gây sát thương chuẩn cho địch mặt đất và trên không trong phạm vi 120 ở đầu ngọn lửa, đồng thời gây bỏng trong 3 giây: nhận 1/2/3/4 sát thương chuẩn mỗi 0.25 giây.",
				enhanced = "Cứ 3.2 giây phun lửa về một hướng trong 0.5 giây. Mỗi 0.25 giây gây sát thương chuẩn cho địch mặt đất và trên không trong phạm vi 140 ở đầu ngọn lửa, đồng thời gây bỏng trong 3 giây: nhận 1/2/3/4 sát thương chuẩn mỗi 0.25 giây."
			},
			change_note = "Nhận xét: Hai kỹ năng gây sát thương tốt với chi phí hợp lý, nhưng tháp cơ bản đắt, đánh thường yếu và dễ trượt nên khó có tiền mua kỹ năng. Giá cao cũng khiến khả năng chống địch bay khó phát huy. Vì vậy, tăng vùng đánh thường và giảm giá tháp cơ bản để dễ vượt qua giai đoạn đầu và mua kỹ năng hơn.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Cột lửa",
					standard = "Phóng các cột lửa, mỗi cột gây 42-70 sát thương vật lý trong phạm vi 100, chuyển thành sát thương chuẩn trong phạm vi 50, rồi làm choáng 1 giây. CD: 20 (16) giây.",
					enhanced = "Phóng các cột lửa, mỗi cột gây 42-70 sát thương vật lý trong phạm vi 100, chuyển thành sát thương chuẩn trong phạm vi 50, rồi làm choáng 1 giây. CD: 20 (16) giây.",
					levels_standard = { "Phóng các cột lửa, mỗi cột gây 42-70 sát thương vật lý trong phạm vi 100, chuyển thành sát thương chuẩn trong phạm vi 50, rồi làm choáng 1 giây. CD: 20 (16) giây.", "Phóng các cột lửa, mỗi cột gây 108-180 sát thương vật lý trong phạm vi 100, chuyển thành sát thương chuẩn trong phạm vi 50, rồi làm choáng 1 giây. CD: 20 (16) giây.", "Phóng các cột lửa, mỗi cột gây 180-300 sát thương vật lý trong phạm vi 100, chuyển thành sát thương chuẩn trong phạm vi 50, rồi làm choáng 1 giây. CD: 20 (16) giây." },
					levels_enhanced = { "Phóng các cột lửa, mỗi cột gây 42-70 sát thương vật lý trong phạm vi 100, chuyển thành sát thương chuẩn trong phạm vi 50, rồi làm choáng 1 giây. CD: 20 (16) giây.", "Phóng các cột lửa, mỗi cột gây 108-180 sát thương vật lý trong phạm vi 100, chuyển thành sát thương chuẩn trong phạm vi 50, rồi làm choáng 1 giây. CD: 20 (16) giây.", "Phóng các cột lửa, mỗi cột gây 180-300 sát thương vật lý trong phạm vi 100, chuyển thành sát thương chuẩn trong phạm vi 50, rồi làm choáng 1 giây. CD: 20 (16) giây." },
					prices_standard = { "200", "150", "150" },
					prices_enhanced = { "200", "150", "150" }
				},
				{
					name = "Vệt lửa rực cháy",
					standard = "Kích hoạt trong phạm vi 600, bắn đạn cháy gây 80 sát thương pháo trong phạm vi 300. Gây bỏng với 4 sát thương chuẩn mỗi 0.25. Không cộng dồn với bỏng từ đòn đánh thường nhưng làm mới thời gian bỏng. CD: 20 (16) giây.",
					enhanced = "Kích hoạt trong phạm vi 600, bắn đạn cháy gây 80 sát thương pháo trong phạm vi 300. Gây bỏng với 4 sát thương chuẩn mỗi 0.25. Không cộng dồn với bỏng từ đòn đánh thường nhưng làm mới thời gian bỏng. CD: 20 (16) giây.",
					levels_standard = { "Kích hoạt trong phạm vi 600, bắn đạn cháy gây 80 sát thương pháo trong phạm vi 300. Gây bỏng với 4 sát thương chuẩn mỗi 0.25. Không cộng dồn với bỏng từ đòn đánh thường nhưng làm mới thời gian bỏng. CD: 20 (16) giây.", "Kích hoạt trong phạm vi 600, bắn đạn cháy gây 160 sát thương pháo trong phạm vi 300. Gây bỏng với 4 sát thương chuẩn mỗi 0.25. Không cộng dồn với bỏng từ đòn đánh thường nhưng làm mới thời gian bỏng. CD: 20 (16) giây.", "Kích hoạt trong phạm vi 600, bắn đạn cháy gây 280 sát thương pháo trong phạm vi 300. Gây bỏng với 4 sát thương chuẩn mỗi 0.25. Không cộng dồn với bỏng từ đòn đánh thường nhưng làm mới thời gian bỏng. CD: 20 (16) giây." },
					levels_enhanced = { "Kích hoạt trong phạm vi 600, bắn đạn cháy gây 80 sát thương pháo trong phạm vi 300. Gây bỏng với 4 sát thương chuẩn mỗi 0.25. Không cộng dồn với bỏng từ đòn đánh thường nhưng làm mới thời gian bỏng. CD: 20 (16) giây.", "Kích hoạt trong phạm vi 600, bắn đạn cháy gây 160 sát thương pháo trong phạm vi 300. Gây bỏng với 4 sát thương chuẩn mỗi 0.25. Không cộng dồn với bỏng từ đòn đánh thường nhưng làm mới thời gian bỏng. CD: 20 (16) giây.", "Kích hoạt trong phạm vi 600, bắn đạn cháy gây 280 sát thương pháo trong phạm vi 300. Gây bỏng với 4 sát thương chuẩn mỗi 0.25. Không cộng dồn với bỏng từ đòn đánh thường nhưng làm mới thời gian bỏng. CD: 20 (16) giây." },
					prices_standard = { "150", "112", "112" },
					prices_enhanced = { "150", "112", "112" }
				},
			}
		},
		["tower_sand_lvl4"] = {
			doc_id = "",
			title = "Lính gác Cồn cát",
			attack = {
				standard = "Cứ 0.8 giây ném phi tiêu gây sát thương vật lý. Nếu có địch khác trong phạm vi 260 quanh mục tiêu, phi tiêu nảy tiếp, tối đa 2/3/4/5 lần. Sát thương mỗi lần nảy bằng 0.6 lần lần trước.",
				enhanced = "Cứ 0.8 giây ném phi tiêu gây sát thương vật lý. Nếu có địch khác trong phạm vi 260 quanh mục tiêu, phi tiêu nảy tiếp, tối đa 2/3/4/5 lần. Sát thương mỗi lần nảy bằng 0.6/0.7/0.8/0.9 lần lần trước."
			},
			change_note = "Nhận xét: Sát thương khi phi tiêu nảy qua nhiều địch đã khá đủ, nhưng khi đánh một mục tiêu, DPS chỉ hơn 30. Kỹ năng 2 là sát thương diện rộng nhưng hiếm khi gây đủ sát thương. Bản FL tiếp tục chuyên biệt hóa khả năng nảy qua nhiều mục tiêu.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Săn tiền thưởng",
					standard = "Cường hóa đòn đánh thường, kích hoạt trong phạm vi 300: ném phi tiêu gây 56 sát thương vật lý, hệ số sát thương mỗi lần nảy 0.6, tối đa 4 lần nảy. Địch bị hạ cho thêm 4 vàng. CD: 8 (6.4) giây.",
					enhanced = "Cường hóa đòn đánh thường, kích hoạt trong phạm vi 300: ném phi tiêu gây 56 sát thương vật lý, hệ số sát thương mỗi lần nảy 1.0, tối đa 4 lần nảy. Địch bị hạ cho thêm 4 vàng. CD: 8 (6.4) giây.",
					levels_standard = { "Cường hóa đòn đánh thường, kích hoạt trong phạm vi 300: ném phi tiêu gây 56 sát thương vật lý, hệ số sát thương mỗi lần nảy 0.6, tối đa 4 lần nảy. Địch bị hạ cho thêm 4 vàng. CD: 8 (6.4) giây.", "Cường hóa đòn đánh thường, kích hoạt trong phạm vi 300: ném phi tiêu gây 118 sát thương vật lý, hệ số sát thương mỗi lần nảy 0.6, tối đa 4 lần nảy. Địch bị hạ cho thêm 8 vàng. CD: 8 (6.4) giây.", "Cường hóa đòn đánh thường, kích hoạt trong phạm vi 300: ném phi tiêu gây 184 sát thương vật lý, hệ số sát thương mỗi lần nảy 0.6, tối đa 4 lần nảy. Địch bị hạ cho thêm 12 vàng. CD: 8 (6.4) giây." },
					levels_enhanced = { "Cường hóa đòn đánh thường, kích hoạt trong phạm vi 300: ném phi tiêu gây 56 sát thương vật lý, hệ số sát thương mỗi lần nảy 1.0, tối đa 4 lần nảy. Địch bị hạ cho thêm 4 vàng. CD: 8 (6.4) giây.", "Cường hóa đòn đánh thường, kích hoạt trong phạm vi 300: ném phi tiêu gây 118 sát thương vật lý, hệ số sát thương mỗi lần nảy 1.0, tối đa 4 lần nảy. Địch bị hạ cho thêm 8 vàng. CD: 8 (6.4) giây.", "Cường hóa đòn đánh thường, kích hoạt trong phạm vi 300: ném phi tiêu gây 184 sát thương vật lý, hệ số sát thương mỗi lần nảy 1.0, tối đa 4 lần nảy. Địch bị hạ cho thêm 12 vàng. CD: 8 (6.4) giây." },
					prices_standard = { "250", "187", "187" },
					prices_enhanced = { "250", "187", "187" }
				},
				{
					name = "Vòng xoáy tai ương",
					standard = "Kích hoạt trong phạm vi 400, tạo 2 phi tiêu xoay nhanh trong 4 giây.\nCứ 0.25 giây gây 6-10 sát thương vật lý cho địch trong phạm vi 80 và làm chậm 25%. CD: 16 (12.8) giây.",
					enhanced = "Kích hoạt trong phạm vi 400, tạo 2 phi tiêu xoay nhanh trong 4 giây.\nCứ 0.25 giây gây 6-10 sát thương vật lý cho địch trong phạm vi 80120 và làm chậm 60%. CD: 16 (12.8) giây.",
					levels_standard = { "Kích hoạt trong phạm vi 400, tạo 2 phi tiêu xoay nhanh trong 4 giây.\nCứ 0.25 giây gây 6-10 sát thương vật lý cho địch trong phạm vi 80 và làm chậm 25%. CD: 16 (12.8) giây.", "Kích hoạt trong phạm vi 400, tạo 2 phi tiêu xoay nhanh trong 5 giây.\nCứ 0.25 giây gây 10-16 sát thương vật lý cho địch trong phạm vi 80 và làm chậm 25%. CD: 16 (12.8) giây.", "Kích hoạt trong phạm vi 400, tạo 2 phi tiêu xoay nhanh trong 6 giây.\nCứ 0.25 giây gây 13-19 sát thương vật lý cho địch trong phạm vi 80 và làm chậm 25%. CD: 16 (12.8) giây." },
					levels_enhanced = { "Kích hoạt trong phạm vi 400, tạo 2 phi tiêu xoay nhanh trong 4 giây.\nCứ 0.25 giây gây 6-10 sát thương vật lý cho địch trong phạm vi 120 và làm chậm 60%. CD: 16 (12.8) giây.", "Kích hoạt trong phạm vi 400, tạo 2 phi tiêu xoay nhanh trong 5 giây.\nCứ 0.25 giây gây 10-16 sát thương vật lý cho địch trong phạm vi 120 và làm chậm 60%. CD: 16 (12.8) giây.", "Kích hoạt trong phạm vi 400, tạo 2 phi tiêu xoay nhanh trong 6 giây.\nCứ 0.25 giây gây 13-19 sát thương vật lý cho địch trong phạm vi 120 và làm chậm 60%. CD: 16 (12.8) giây." },
					prices_standard = { "200", "150", "150" },
					prices_enhanced = { "200", "150", "150" }
				},
			}
		},
		["tower_ghost_lvl4"] = {
			doc_id = "",
			title = "Chiến hồn U minh",
			attack = {
				standard = "Cận chiến, gây sát thương chuẩn. Có thể đổi vị trí tháp bất cứ lúc nào.\nSau khi đổi tháp, đơn vị triệu hồi lập tức sống lại; một số kỹ năng được làm mới CD ngay.",
				enhanced = "Cận chiến, gây sát thương chuẩn. Có thể đổi vị trí tháp bất cứ lúc nào.\nSau khi đổi tháp, đơn vị triệu hồi lập tức sống lại; một số kỹ năng được làm mới CD ngay."
			},
			change_note = "Nhận xét: Ngoài khả năng đổi tháp, chiến hồn ít nổi bật. Tuy nhiên, sát thương chuẩn và sức tấn công cao cho thấy tiềm năng gây sát thương nếu tăng khả năng sống sót. Kỹ năng 1/2 có thể cản nhau, nên tùy tình huống chọn 1 trong 2 kỹ năng.",
			port_note = "Thay đổi khi chuyển sang FL: Bỏ khả năng đổi với chính mình để nhân bản vô hạn.\nLưu ý: Do cơ chế làm mới khác nhau, một số kỹ năng có thể dùng ngay sau khi đổi tháp; lính doanh trại cũng hồi sinh ngay. Ví dụ, thao tác đúng có thể cho tháp súng bắn đạn ghém mỗi 3 giây hoặc cho cóc làm mới kỹ năng nuốt mỗi 3 giây. Tính năng này vốn có trong bản gốc, đòi hỏi tập trung vào 2-3 tháp và thao tác nhiều hơn, nên tác giả giữ lại để tăng cách chơi; có thể dùng nhưng không khuyến khích lạm dụng.\nCác phần 3 đầu có nhiều kỹ năng dùng được cách này hơn phần 4/5. Qua kiểm tra, trừ kỹ năng 1 của Đại Druid phần 3, gần như mọi kỹ năng tháp ở các phần 3 đầu khi nâng tới cấp 2/3 đều có tính năng này.",
			notes = "Tính năng này vốn có trong bản gốc, đòi hỏi tập trung vào 2-3 tháp và thao tác nhiều hơn, nên tác giả giữ lại để tăng cách chơi; có thể dùng nhưng không khuyến khích lạm dụng.\nCác phần 3 đầu có nhiều kỹ năng dùng được cách này hơn phần 4/5. Qua kiểm tra, trừ kỹ năng 1 của Đại Druid phần 3, gần như mọi kỹ năng tháp ở các phần 3 đầu khi nâng tới cấp 2/3 đều có tính năng này.",
			skills = {
				{
					name = "Hút linh hồn",
					standard = "Sau 5 giây chiến đấu, chiến binh ma tăng 50% sức tấn công. Hiệu ứng mất sau 4 giây ngoài giao tranh.",
					enhanced = "Sau 1 giây chiến đấu, chiến binh ma tăng 50% sức tấn công. Hiệu ứng mất sau 4 giây ngoài giao tranh.",
					levels_standard = { "Sau 5 giây chiến đấu, chiến binh ma tăng 50% sức tấn công. Hiệu ứng mất sau 4 giây ngoài giao tranh.", "Sau 5 giây chiến đấu, chiến binh ma tăng 75% sức tấn công. Hiệu ứng mất sau 4 giây ngoài giao tranh.", "Sau 5 giây chiến đấu, chiến binh ma tăng 100% sức tấn công. Hiệu ứng mất sau 4 giây ngoài giao tranh." },
					levels_enhanced = { "Sau 1 giây chiến đấu, chiến binh ma tăng 50% sức tấn công. Hiệu ứng mất sau 4 giây ngoài giao tranh.", "Sau 1 giây chiến đấu, chiến binh ma tăng 75% sức tấn công. Hiệu ứng mất sau 4 giây ngoài giao tranh.", "Sau 1 giây chiến đấu, chiến binh ma tăng 100% sức tấn công. Hiệu ứng mất sau 4 giây ngoài giao tranh." },
					prices_standard = { "200", "75", "75" },
					prices_enhanced = { "150", "60", "60" }
				},
				{
					name = "Nỗi sợ vĩnh hằng",
					standard = "Khi chiến binh ma chết, ám một kẻ địch, gây 60 sát thương chuẩn, giảm 50% sức tấn công và 40% tốc độ di chuyển trong 5 giây.",
					enhanced = "Khi chiến binh ma chết, ám một kẻ địch, gây 70 sát thương chuẩn, giảm 50% sức tấn công và 40% tốc độ di chuyển trong 5 giây.",
					levels_standard = { "Khi chiến binh ma chết, ám một kẻ địch, gây 60 sát thương chuẩn, giảm 50% sức tấn công và 40% tốc độ di chuyển trong 5 giây.", "Khi chiến binh ma chết, ám một kẻ địch, gây 120 sát thương chuẩn, giảm 50% sức tấn công và 40% tốc độ di chuyển trong 5 giây.", "Khi chiến binh ma chết, ám một kẻ địch, gây 180 sát thương chuẩn, giảm 50% sức tấn công và 40% tốc độ di chuyển trong 5 giây." },
					levels_enhanced = { "Khi chiến binh ma chết, ám một kẻ địch, gây 70 sát thương chuẩn, giảm 50% sức tấn công và 40% tốc độ di chuyển trong 5 giây.", "Khi chiến binh ma chết, ám một kẻ địch, gây 240 sát thương chuẩn, giảm 50% sức tấn công và 40% tốc độ di chuyển trong 5 giây.", "Khi chiến binh ma chết, ám một kẻ địch, gây 410 sát thương chuẩn, giảm 50% sức tấn công và 40% tốc độ di chuyển trong 5 giây." },
					prices_standard = { "150", "112", "112" },
					prices_enhanced = { "150", "112", "112" }
				},
			}
		},
		["tower_barrel_lvl4"] = {
			doc_id = "",
			title = "Thợ chiến Ủ rượu",
			attack = {
				standard = "Cứ 2.5 giây bắn 1 thùng rượu, gây sát thương pháo lên địch mặt đất trong phạm vi 120 (150). Khiến địch say 3 giây, giảm 50% sức tấn công.",
				enhanced = "Cứ 2.5 giây bắn 1 thùng rượu, gây sát thương pháo lên địch mặt đất trong phạm vi 120 (150). Khiến địch say 3 giây, giảm 50% sức tấn công."
			},
			change_note = "Nhận xét: Chỉ số đánh thường và giảm sức tấn công đã đủ tốt, nhưng kỹ năng 2 thường nổ khi địch đã ra khỏi vùng, hồi quá lâu và sát thương vật lý khó xuyên giáp.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Rượu thuốc thần kỳ",
					standard = "Triệu hồi chiến binh uống rượu thuốc, chiến đấu 10 giây. Máu: 100 (110); giáp: 0; khoảng cách giữa đòn đánh: 1; hồi sinh: 12 (9.6) giây; sát thương vật lý thường: 26-38.",
					enhanced = "Triệu hồi chiến binh uống rượu thuốc, chiến đấu 10 giây. Máu: 100 (110); giáp: 0; khoảng cách giữa đòn đánh: 1; hồi sinh: 12 (9.6) giây; sát thương vật lý thường: 26-38.",
					levels_standard = { "Triệu hồi chiến binh uống rượu thuốc, chiến đấu 10 giây. Máu: 100 (110); giáp: 0; khoảng cách giữa đòn đánh: 1; hồi sinh: 12 (9.6) giây; sát thương vật lý thường: 26-38.", "Triệu hồi chiến binh uống rượu thuốc, chiến đấu 10 giây. Máu: 140 (154); giáp: 0; khoảng cách giữa đòn đánh: 1; hồi sinh: 12 (9.6) giây; sát thương vật lý thường: 37-55.", "Triệu hồi chiến binh uống rượu thuốc, chiến đấu 10 giây. Máu: 180 (198); giáp: 0; khoảng cách giữa đòn đánh: 1; hồi sinh: 12 (9.6) giây; sát thương vật lý thường: 48-72." },
					levels_enhanced = { "Triệu hồi chiến binh uống rượu thuốc, chiến đấu 10 giây. Máu: 100 (110); giáp: 0; khoảng cách giữa đòn đánh: 1; hồi sinh: 12 (9.6) giây; sát thương vật lý thường: 26-38.", "Triệu hồi chiến binh uống rượu thuốc, chiến đấu 10 giây. Máu: 140 (154); giáp: 0; khoảng cách giữa đòn đánh: 1; hồi sinh: 12 (9.6) giây; sát thương vật lý thường: 37-55.", "Triệu hồi chiến binh uống rượu thuốc, chiến đấu 10 giây. Máu: 180 (198); giáp: 0; khoảng cách giữa đòn đánh: 1; hồi sinh: 12 (9.6) giây; sát thương vật lý thường: 48-72." },
					prices_standard = { "200", "75", "75" },
					prices_enhanced = { "200", "75", "75" }
				},
				{
					name = "Mẻ rượu hỏng",
					standard = "Ném thùng rượu độc, nhiễm độc mặt đất trong phạm vi 160 suốt 5 giây. Cứ 0.25 giây gây 1 sát thương chuẩn và làm chậm 50%, rồi nổ gây 120 sát thương vật lý trong phạm vi 120 (150). Là đòn đánh thường cường hóa. CD: 24 (19.2) giây.",
					enhanced = "Ném thùng rượu độc, nhiễm độc mặt đất trong phạm vi 160 suốt 5 giây. Cứ 0.25 giây gây 1 sát thương chuẩn và làm chậm 70%, rồi nổ gây 120 sát thương pháo trong phạm vi 120 (150). Là đòn đánh thường cường hóa. CD: 24 (19.2) giây.",
					levels_standard = { "Ném thùng rượu độc, nhiễm độc mặt đất trong phạm vi 160 suốt 5 giây. Cứ 0.25 giây gây 1 sát thương chuẩn và làm chậm 50%, rồi nổ gây 120 sát thương vật lý trong phạm vi 120 (150). Là đòn đánh thường cường hóa. CD: 24 (19.2) giây.", "Ném thùng rượu độc, nhiễm độc mặt đất trong phạm vi 160 suốt 5 giây. Cứ 0.25 giây gây 1 sát thương chuẩn và làm chậm 50%, rồi nổ gây 264 sát thương vật lý trong phạm vi 120 (150). Là đòn đánh thường cường hóa. CD: 24 (19.2) giây.", "Ném thùng rượu độc, nhiễm độc mặt đất trong phạm vi 160 suốt 5 giây. Cứ 0.25 giây gây 1 sát thương chuẩn và làm chậm 50%, rồi nổ gây 432 sát thương vật lý trong phạm vi 120 (150). Là đòn đánh thường cường hóa. CD: 24 (19.2) giây." },
					levels_enhanced = { "Ném thùng rượu độc, nhiễm độc mặt đất trong phạm vi 160 suốt 5 giây. Cứ 0.25 giây gây 1 sát thương chuẩn và làm chậm 70%, rồi nổ gây 120 sát thương pháo trong phạm vi 120 (150). Là đòn đánh thường cường hóa. CD: 24 (19.2) giây.", "Ném thùng rượu độc, nhiễm độc mặt đất trong phạm vi 160 suốt 5 giây. Cứ 0.25 giây gây 1 sát thương chuẩn và làm chậm 70%, rồi nổ gây 264 sát thương pháo trong phạm vi 120 (150). Là đòn đánh thường cường hóa. CD: 22 (17.6) giây.", "Ném thùng rượu độc, nhiễm độc mặt đất trong phạm vi 160 suốt 5 giây. Cứ 0.25 giây gây 1 sát thương chuẩn và làm chậm 70%, rồi nổ gây 432 sát thương pháo trong phạm vi 120 (150). Là đòn đánh thường cường hóa. CD: 20 (16) giây." },
					prices_standard = { "200", "150", "150" },
					prices_enhanced = { "200", "150", "150" }
				},
			}
		},
		["tower_ray_lvl4"] = {
			doc_id = "",
			title = "Pháp sư Ảo thuật",
			attack = {
				standard = "Chọn và khóa mục tiêu trong 0.5 giây, bắn tia phép liên tục 3.75 giây với 16 lần sát thương, rồi nghỉ 0.5 giây trước khi chọn mục tiêu mới. Nếu mục tiêu chết, ngừng bắn và chuyển ngay sang thời gian nghỉ. Sát thương ở giây thứ 1/2/3/4 bằng 0.1/0.2/0.35/0.35 lần chỉ số đánh thường.",
				enhanced = "Chọn và khóa mục tiêu trong 0.5 giây, bắn tia phép liên tục 3.75 giây với 16 lần sát thương, rồi nghỉ 0.5 giây trước khi chọn mục tiêu mới. Nếu mục tiêu chết, ngừng bắn và chuyển ngay sang thời gian nghỉ. Sát thương ở giây thứ 1/2/3/4 bằng 0.4/0.4/0.1/0.1 lần chỉ số đánh thường."
			},
			change_note = "Nhận xét: Đổi mục tiêu liên tục làm mất sát thương, nhất là khi sát thương tập trung cuối lượt. Vì tháp bắn 3.75 giây rồi nghỉ 1 giây, dồn hơn 63.16% sát thương vào 2 giây đầu giúp đổi mục tiêu ở giây 2-3.75 mà không mất sát thương, đạt DPS lý thuyết. Tăng nhẹ chỉ số cơ bản; không tăng quá nhiều vì cả hai kỹ năng vốn rất mạnh.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Tràn năng lượng",
					standard = "Tia phép nối thêm tối đa 3 kẻ địch trong khoảng cách 260 và làm chậm 4 mục tiêu 20%.\nMỗi mục tiêu nối thêm nhận sát thương phép bằng 25% sát thương đánh thường.",
					enhanced = "Tia phép nối thêm tối đa 3 kẻ địch trong khoảng cách 260 và làm chậm 4 mục tiêu 20%.\nMỗi mục tiêu nối thêm nhận sát thương phép bằng 25% sát thương đánh thường.",
					levels_standard = { "Tia phép nối thêm tối đa 3 kẻ địch trong khoảng cách 260 và làm chậm 4 mục tiêu 20%.\nMỗi mục tiêu nối thêm nhận sát thương phép bằng 25% sát thương đánh thường.", "Tia phép nối thêm tối đa 3 kẻ địch trong khoảng cách 260 và làm chậm 4 mục tiêu 20%.\nMỗi mục tiêu nối thêm nhận sát thương phép bằng 50% sát thương đánh thường.", "Tia phép nối thêm tối đa 3 kẻ địch trong khoảng cách 260 và làm chậm 4 mục tiêu 20%.\nMỗi mục tiêu nối thêm nhận sát thương phép bằng 75% sát thương đánh thường." },
					levels_enhanced = { "Tia phép nối thêm tối đa 3 kẻ địch trong khoảng cách 260 và làm chậm 4 mục tiêu 20%.\nMỗi mục tiêu nối thêm nhận sát thương phép bằng 25% sát thương đánh thường.", "Tia phép nối thêm tối đa 3 kẻ địch trong khoảng cách 260 và làm chậm 4 mục tiêu 20%.\nMỗi mục tiêu nối thêm nhận sát thương phép bằng 50% sát thương đánh thường.", "Tia phép nối thêm tối đa 3 kẻ địch trong khoảng cách 260 và làm chậm 4 mục tiêu 20%.\nMỗi mục tiêu nối thêm nhận sát thương phép bằng 75% sát thương đánh thường." },
					prices_standard = { "150", "112", "112" },
					prices_enhanced = { "150", "112", "112" }
				},
				{
					name = "Bùa biến hình",
					standard = "Biến kẻ địch không phải trùm thành cừu với máu bằng 50% máu tối đa ban đầu. Nhấp 5 lần để giết cừu và nhận vàng. CD: 20 (16).",
					enhanced = "Biến kẻ địch không phải trùm thành cừu với máu bằng 50% máu tối đa ban đầu. Nhấp 5 lần để giết cừu và nhận vàng. CD: 20 (16).",
					levels_standard = { "Biến kẻ địch không phải trùm thành cừu với máu bằng 50% máu tối đa ban đầu. Nhấp 5 lần để giết cừu và nhận vàng. CD: 20 (16)." },
					levels_enhanced = { "Biến kẻ địch không phải trùm thành cừu với máu bằng 50% máu tối đa ban đầu. Nhấp 5 lần để giết cừu và nhận vàng. CD: 20 (16)." },
					prices_standard = { "160" },
					prices_enhanced = { "160" }
				},
			}
		},
		["tower_dark_elf_lvl4"] = {
			doc_id = "",
			title = "Trường cung Chạng vạng",
			attack = {
				standard = "Cứ 2.95 giây bắn một mũi tên, chọn mục tiêu ngay khi bắt đầu giương cung. Có thể chọn thủ công ưu tiên địch nhiều máu nhất hoặc gần lối ra nhất.",
				enhanced = "Cứ 2.95 giây bắn một mũi tên bỏ qua 5/10/15/20 giáp, chọn mục tiêu ngay khi bắt đầu giương cung. Có thể chọn thủ công ưu tiên địch nhiều máu nhất hoặc gần lối ra nhất."
			},
			change_note = "Nhận xét: Tháp cung đánh chậm và chỉ gây sát thương nên cần xuyên giáp. Thêm cơ chế tích lũy sức mạnh và nội tại cho kỹ năng 2 để dễ kết liễu hơn.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Viện binh Lưỡi kiếm",
					standard = "Triệu hồi 2 Chiến binh Quấy rối Chạng vạng. Hồi sinh: 10; phạm vi điều quân: 290; máu: 60 (66); hồi máu: 8; giáp: 40; khoảng cách giữa đòn đánh: 1.0; sức tấn công: 10-14; phạm vi phản ứng: 140; né tránh: 60%.",
					enhanced = "Triệu hồi 2 Chiến binh Quấy rối Chạng vạng. Hồi sinh: 10; phạm vi điều quân: 290; máu: 60 (66); hồi máu: 8; giáp: 40; khoảng cách giữa đòn đánh: 1.0; sức tấn công: 10-14; phạm vi phản ứng: 140; né tránh: 68%.",
					levels_standard = { "Triệu hồi 2 Chiến binh Quấy rối Chạng vạng. Hồi sinh: 10; phạm vi điều quân: 290; máu: 60 (66); hồi máu: 8; giáp: 40; khoảng cách giữa đòn đánh: 1.0; sức tấn công: 10-14; phạm vi phản ứng: 140; né tránh: 60%.", "Triệu hồi 2 Chiến binh Quấy rối Chạng vạng. Hồi sinh: 10; phạm vi điều quân: 290; máu: 90 (99); hồi máu: 12; giáp: 40; khoảng cách giữa đòn đánh: 1.0; sức tấn công: 14-22; phạm vi phản ứng: 140; né tránh: 60%.", "Triệu hồi 2 Chiến binh Quấy rối Chạng vạng. Hồi sinh: 10; phạm vi điều quân: 290; máu: 120 (132); hồi máu: 16; giáp: 40; khoảng cách giữa đòn đánh: 1.0; sức tấn công: 22-30; phạm vi phản ứng: 140; né tránh: 60%." },
					levels_enhanced = { "Triệu hồi 2 Chiến binh Quấy rối Chạng vạng. Hồi sinh: 10; phạm vi điều quân: 290; máu: 60 (66); hồi máu: 8; giáp: 40; khoảng cách giữa đòn đánh: 1.0; sức tấn công: 10-14; phạm vi phản ứng: 140; né tránh: 68%.", "Triệu hồi 2 Chiến binh Quấy rối Chạng vạng. Hồi sinh: 10; phạm vi điều quân: 290; máu: 90 (99); hồi máu: 12; giáp: 40; khoảng cách giữa đòn đánh: 1.0; sức tấn công: 14-22; phạm vi phản ứng: 140; né tránh: 68%.", "Triệu hồi 2 Chiến binh Quấy rối Chạng vạng. Hồi sinh: 10; phạm vi điều quân: 290; máu: 120 (132); hồi máu: 16; giáp: 40; khoảng cách giữa đòn đánh: 1.0; sức tấn công: 22-30; phạm vi phản ứng: 140; né tránh: 68%." },
					prices_standard = { "150", "112", "112" },
					prices_enhanced = { "150", "112", "112" }
				},
				{
					name = "Sát khí săn mồi",
					standard = "Mỗi lần hạ địch, tăng vĩnh viễn 1 sát thương tối thiểu và 2 sát thương tối đa trong màn hiện tại.",
					enhanced = "Cung thủ cảm nhận sát khí. Mỗi lần hạ địch, tăng vĩnh viễn 2 sát thương tối thiểu và 4 sát thương tối đa trong màn hiện tại.\nKhi nhắm địch còn không quá 60% máu, tấn công với 1.6 lần sức mạnh và bỏ qua 35 giáp.",
					levels_standard = { "Mỗi lần hạ địch, tăng vĩnh viễn 1 sát thương tối thiểu và 2 sát thương tối đa trong màn hiện tại." },
					levels_enhanced = { "Cung thủ cảm nhận sát khí. Mỗi lần hạ địch, tăng vĩnh viễn 2 sát thương tối thiểu và 4 sát thương tối đa trong màn hiện tại.\nKhi nhắm địch còn không quá 60% máu, tấn công với 1.5 lần sức mạnh và bỏ qua 30 giáp." },
					prices_standard = { "160" },
					prices_enhanced = { "280" }
				},
			}
		},
		["tower_hermit_toad_lvl4"] = {
			doc_id = "",
			title = "Ẩn sĩ Đầm lầy",
			attack = {
				standard = "Chế độ phép: Cứ 1.2 giây phun bong bóng gây sát thương phép.\nChế độ pháo: Cứ 2.5 giây phun bong bóng gây sát thương pháo trong phạm vi 120 (150), làm chậm 20/30/40/50% trong 1.95 giây.",
				enhanced = "Chế độ phép: Cứ 1.2 giây phun bong bóng gây sát thương phép.\nChế độ pháo: Cứ 2.5 giây phun bong bóng gây sát thương pháo trong phạm vi 120 (150), làm chậm 20/30/40/50% trong 1.95 giây."
			},
			change_note = "Nhận xét: Ngoài môi trường nhiều tiểu trùm của phần 5, đây là kỹ năng tiêu diệt tức thì xếp thứ 1 toàn bộ các phần. Các cấp 4 đầu cũng hữu dụng nên không tăng thêm. Kỹ năng của Pháp sư Ảo thuật và cóc phần 5 đã mạnh tới mức nếu không giảm các kỹ năng tiêu diệt tức thì khác thì sẽ mất cân bằng.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Cú nhảy nghiền nát",
					standard = "Nhảy vào một vùng, gây 80 sát thương vật lý trong phạm vi 200 và làm choáng 2 giây, rồi trở lại ao.\nCD: 35 (28) giây.",
					enhanced = "Nhảy vào một vùng, gây 120 sát thương vật lý trong phạm vi 200 và làm choáng 2 giây, rồi trở lại ao.\nCD: 35 (28) giây.",
					levels_standard = { "Nhảy vào một vùng, gây 80 sát thương vật lý trong phạm vi 200 và làm choáng 2 giây, rồi trở lại ao.\nCD: 35 (28) giây.", "Nhảy vào một vùng, gây 140 sát thương vật lý trong phạm vi 200 và làm choáng 3 giây, rồi trở lại ao.\nCD: 30 (24) giây.", "Nhảy vào một vùng, gây 180 sát thương vật lý trong phạm vi 200 và làm choáng 4 giây, rồi trở lại ao.\nCD: 25 (20) giây." },
					levels_enhanced = { "Nhảy vào một vùng, gây 120 sát thương vật lý trong phạm vi 200 và làm choáng 2 giây, rồi trở lại ao.\nCD: 35 (28) giây.", "Nhảy vào một vùng, gây 210 sát thương vật lý trong phạm vi 200 và làm choáng 3 giây, rồi trở lại ao.\nCD: 30 (24) giây.", "Nhảy vào một vùng, gây 270 sát thương vật lý trong phạm vi 200 và làm choáng 4 giây, rồi trở lại ao.\nCD: 25 (20) giây." },
					prices_standard = { "120", "90", "90" },
					prices_enhanced = { "120", "75", "75" }
				},
				{
					name = "Lưỡi dính",
					standard = "Nuốt ngay một kẻ địch không phải trùm trong phạm vi 480.\nCD: 18 (14.4) giây.",
					enhanced = "Nuốt ngay một kẻ địch không phải trùm trong phạm vi 480.\nCD: 18 (14.4) giây.",
					levels_standard = { "Nuốt ngay một kẻ địch không phải trùm trong phạm vi 480.\nCD: 18 (14.4) giây." },
					levels_enhanced = { "Nuốt ngay một kẻ địch không phải trùm trong phạm vi 480.\nCD: 18 (14.4) giây." },
					prices_standard = { "240" },
					prices_enhanced = { "240" }
				},
			}
		},
		["tower_dwarf_lvl4"] = {
			doc_id = "",
			title = "Tiểu đội Pháo binh",
			attack = {
				standard = "Bắn từ xa khi có địch trong phạm vi 300 (330). Chặn địch bằng cận chiến khi ở chế độ mặt đất và có địch trong phạm vi 120.",
				enhanced = "Bắn từ xa khi có địch trong phạm vi 300 (330). Chặn địch bằng cận chiến khi ở chế độ mặt đất và có địch trong phạm vi 120."
			},
			change_note = "Nhận xét: Không tăng sức mạnh thêm. Chỉ làm quá trình nâng cấp mượt hơn vì doanh trại cấp 3/4 hơi yếu.",
			port_note = "Thay đổi khi chuyển sang FL: Kỹ năng 1 bản gốc giá 120/180/240 [hoàn lại 120]; bản FL giá 120/200/200, sau nâng cấp nghiên cứu là 120/150/150. Tổng giá sau nghiên cứu bằng bản gốc.",
			notes = "",
			skills = {
				{
					name = "Mở rộng tiểu đội",
					standard = "Tăng quân số tiểu đội lên 3 người.",
					enhanced = "Tăng quân số tiểu đội lên 3 người.",
					levels_standard = { "Tăng quân số tiểu đội lên 3 người.", "Tăng quân số tiểu đội lên 4 người.", "Tăng quân số tiểu đội lên 5 người." },
					levels_enhanced = { "Tăng quân số tiểu đội lên 3 người.", "Tăng quân số tiểu đội lên 4 người.", "Tăng quân số tiểu đội lên 5 người." },
					prices_standard = { "120", "150", "150" },
					prices_enhanced = { "150", "150", "150" }
				},
				{
					name = "Đạn cháy",
					standard = "Mỗi người ném một bom cháy, gây 20-28 sát thương pháo trong phạm vi 100 và đốt vùng đó 2 giây, tổng cộng 24 sát thương chuẩn.",
					enhanced = "Mỗi người ném một bom cháy, gây 20-28 sát thương pháo trong phạm vi 100 và đốt vùng đó 2 giây, tổng cộng 24 sát thương chuẩn.",
					levels_standard = { "Mỗi người ném một bom cháy, gây 20-28 sát thương pháo trong phạm vi 100 và đốt vùng đó 2 giây, tổng cộng 24 sát thương chuẩn.", "Mỗi người ném một bom cháy, gây 38-58 sát thương pháo trong phạm vi 100 và đốt vùng đó 2 giây, tổng cộng 64 sát thương chuẩn.", "Mỗi người ném một bom cháy, gây 52-80 sát thương pháo trong phạm vi 100 và đốt vùng đó 2 giây, tổng cộng 112 sát thương chuẩn." },
					levels_enhanced = { "Mỗi người ném một bom cháy, gây 20-28 sát thương pháo trong phạm vi 100 và đốt vùng đó 2 giây, tổng cộng 24 sát thương chuẩn.", "Mỗi người ném một bom cháy, gây 38-58 sát thương pháo trong phạm vi 100 và đốt vùng đó 2 giây, tổng cộng 64 sát thương chuẩn.", "Mỗi người ném một bom cháy, gây 52-80 sát thương pháo trong phạm vi 100 và đốt vùng đó 2 giây, tổng cộng 112 sát thương chuẩn." },
					prices_standard = { "150", "112", "112" },
					prices_enhanced = { "150", "112", "112" }
				},
			}
		},
		["tower_sparking_geode_lvl4"] = {
			doc_id = "",
			title = "Cự tượng Điện năng",
			attack = {
				standard = "Bắn sét gây sát thương chuẩn. Nếu có địch khác trong phạm vi 280 quanh mục tiêu, sét nảy tiếp. Sát thương mỗi lần nảy bằng 1.05/1.1/1.15/1.25 lần lần trước.",
				enhanced = "Bắn sét gây sát thương chuẩn. Nếu có địch khác trong phạm vi 280 quanh mục tiêu, sét nảy tiếp. Sát thương mỗi lần nảy bằng 1.05/1.1/1.15/1.25 lần lần trước."
			},
			change_note = "Nhận xét: Đòn đánh thường bản gốc đã đủ mạnh; vấn đề là kỹ năng hồi quá lâu.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Kết tinh",
					standard = "Kết tinh 2 địch trong tầm suốt 5 giây. Mục tiêu không thể hành động và nhận thêm 30% sát thương.\nCD: 31 (24.8) giây.",
					enhanced = "Kết tinh 2 địch trong tầm suốt 5 giây. Mục tiêu không thể hành động và nhận thêm 30% sát thương.\nCD: 30 (24) giây.",
					levels_standard = { "Kết tinh 2 địch trong tầm suốt 5 giây. Mục tiêu không thể hành động và nhận thêm 30% sát thương.\nCD: 31 (24.8) giây.", "Kết tinh 3 địch trong tầm suốt 5 giây. Mục tiêu không thể hành động và nhận thêm 30% sát thương.\nCD: 28 (22.4) giây.", "Kết tinh 4 địch trong tầm suốt 5 giây. Mục tiêu không thể hành động và nhận thêm 30% sát thương.\nCD: 25 (20) giây." },
					levels_enhanced = { "Kết tinh 2 địch trong tầm suốt 5 giây. Mục tiêu không thể hành động và nhận thêm 30% sát thương.\nCD: 30 (24) giây.", "Kết tinh 3 địch trong tầm suốt 5 giây. Mục tiêu không thể hành động và nhận thêm 30% sát thương.\nCD: 26 (20.8) giây.", "Kết tinh 4 địch trong tầm suốt 5 giây. Mục tiêu không thể hành động và nhận thêm 30% sát thương.\nCD: 22 (17.6) giây." },
					prices_standard = { "150", "112", "112" },
					prices_enhanced = { "150", "112", "112" }
				},
				{
					name = "Dòng điện trào dâng",
					standard = "Tạo điện trường trong phạm vi 400, gây 3 sát thương chuẩn mỗi 0.5 giây và giảm 30% tốc độ di chuyển trong 6 giây. CD: 40 (32) giây.",
					enhanced = "Tạo điện trường trong phạm vi 400, gây 3 sát thương chuẩn mỗi 0.5 giây và giảm 30% tốc độ di chuyển trong 6 giây. CD: 38 (30.4) giây.",
					levels_standard = { "Tạo điện trường trong phạm vi 400, gây 3 sát thương chuẩn mỗi 0.5 giây và giảm 30% tốc độ di chuyển trong 6 giây. CD: 40 (32) giây.", "Tạo điện trường trong phạm vi 400, gây 4 sát thương chuẩn mỗi 0.5 giây và giảm 40% tốc độ di chuyển trong 8 giây. CD: 35 (28) giây.", "Tạo điện trường trong phạm vi 400, gây 5 sát thương chuẩn mỗi 0.5 giây và giảm 50% tốc độ di chuyển trong 10 giây. CD: 30 (24) giây." },
					levels_enhanced = { "Tạo điện trường trong phạm vi 400, gây 3 sát thương chuẩn mỗi 0.5 giây và giảm 30% tốc độ di chuyển trong 6 giây. CD: 38 (30.4) giây.", "Tạo điện trường trong phạm vi 400, gây 4 sát thương chuẩn mỗi 0.5 giây và giảm 40% tốc độ di chuyển trong 8 giây. CD: 32 (25.6) giây.", "Tạo điện trường trong phạm vi 400, gây 5 sát thương chuẩn mỗi 0.5 giây và giảm 50% tốc độ di chuyển trong 10 giây. CD: 26 (20.8) giây." },
					prices_standard = { "200", "150", "150" },
					prices_enhanced = { "200", "150", "150" }
				},
			}
		},
		["tower_pandas_lvl4"] = {
			doc_id = "",
			title = "Tam hiệp Trúc tông",
			attack = {
				standard = "Cận chiến gây sát thương vật lý. Khi máu giảm tới 0, gấu trúc trở về tháp bắn trong 5 (3) giây rồi xuống chặn địch. Mỗi gấu đánh cách nhau 1.5 giây; nếu có đủ 3 gấu, mỗi 0.5 giây đánh 1 lần. Tầm đánh: 360; sức tấn công: 4-6/7-10/10-15/15-20, gây sát thương chuẩn. Chủ động: Đưa cả 3 gấu về tháp bắn từ xa trong 8 giây.",
				enhanced = "Cận chiến gây sát thương vật lý. Khi máu giảm tới 0, gấu trúc trở về tháp bắn trong 5 (3) giây rồi xuống chặn địch. Mỗi gấu đánh cách nhau 1.5 giây; nếu có đủ 3 gấu, mỗi 0.5 giây đánh 1 lần. Tầm đánh: 360; sức tấn công: 4-6/7-10/10-15/15-20, gây sát thương chuẩn. Chủ động: Đưa cả 3 gấu về tháp bắn từ xa trong 8 giây."
			},
			change_note = "Nhận xét: Hoặc giữ cấp 1, hoặc mua kỹ năng. Kỹ năng 1 chỉ gây sát thương nên cần mạnh hơn; kỹ năng 3 cấp 2 quá kém hiệu quả so với giá.",
			port_note = "",
			notes = "",
			skills = {
				{
					name = "Phi nón trảm",
					standard = "Ném nón tấn công địch. Nếu có địch khác trong phạm vi 360 quanh mục tiêu, nón nảy tiếp. Mỗi mục tiêu nhận 20-25 sát thương chuẩn, tối đa 3 mục tiêu. CD: 8; tầm thi triển: 400.",
					enhanced = "Ném nón tấn công địch. Nếu có địch khác trong phạm vi 360 quanh mục tiêu, nón nảy tiếp. Mỗi mục tiêu nhận 28-35 sát thương chuẩn, tối đa 3 mục tiêu. CD: 8; tầm thi triển: 400.",
					levels_standard = { "Ném nón tấn công địch. Nếu có địch khác trong phạm vi 360 quanh mục tiêu, nón nảy tiếp. Mỗi mục tiêu nhận 20-25 sát thương chuẩn, tối đa 3 mục tiêu. CD: 8; tầm thi triển: 400.", "Ném nón tấn công địch. Nếu có địch khác trong phạm vi 400 quanh mục tiêu, nón nảy tiếp. Mỗi mục tiêu nhận 40-50 sát thương chuẩn, tối đa 5 mục tiêu. CD: 8; tầm thi triển: 400." },
					levels_enhanced = { "Ném nón tấn công địch. Nếu có địch khác trong phạm vi 360 quanh mục tiêu, nón nảy tiếp. Mỗi mục tiêu nhận 28-35 sát thương chuẩn, tối đa 3 mục tiêu. CD: 8; tầm thi triển: 400.", "Ném nón tấn công địch. Nếu có địch khác trong phạm vi 400 quanh mục tiêu, nón nảy tiếp. Mỗi mục tiêu nhận 56-70 sát thương chuẩn, tối đa 5 mục tiêu. CD: 8; tầm thi triển: 400." },
					prices_standard = { "150", "100" },
					prices_enhanced = { "150", "100" }
				},
				{
					name = "Thiên lôi phá",
					standard = "Gọi sét gây 12-24 sát thương chuẩn trong phạm vi 200 và làm choáng 1.5 giây. CD: 15; tầm thi triển: 400.",
					enhanced = "Gọi sét gây 12-24 sát thương chuẩn trong phạm vi 200 và làm choáng 1.5 giây. CD: 15; tầm thi triển: 400.",
					levels_standard = { "Gọi sét gây 12-24 sát thương chuẩn trong phạm vi 200 và làm choáng 1.5 giây. CD: 15; tầm thi triển: 400.", "Gọi sét gây 22-34 sát thương chuẩn trong phạm vi 200 và làm choáng 1.5 giây. CD: 10; tầm thi triển: 400." },
					levels_enhanced = { "Gọi sét gây 12-24 sát thương chuẩn trong phạm vi 200 và làm choáng 1.5 giây. CD: 15; tầm thi triển: 400.", "Gọi sét gây 22-34 sát thương chuẩn trong phạm vi 200 và làm choáng 1.5 giây. CD: 10; tầm thi triển: 400." },
					prices_standard = { "150", "100" },
					prices_enhanced = { "150", "100" }
				},
				{
					name = "Hỏa ngục kiếp",
					standard = "Bắn tối đa 5 cầu lửa, mỗi quả gây 3-6 sát thương chuẩn và dịch chuyển mục tiêu lùi 200-240 đơn vị khoảng cách. Mỗi địch bị dịch chuyển tối đa 3 lần. CD: 20; tầm thi triển: 400.",
					enhanced = "Bắn tối đa 5 cầu lửa, mỗi quả gây 3-6 sát thương chuẩn và dịch chuyển mục tiêu lùi 200-240 đơn vị khoảng cách. Mỗi địch bị dịch chuyển tối đa 3 lần. CD: 20; tầm thi triển: 400.",
					levels_standard = { "Bắn tối đa 5 cầu lửa, mỗi quả gây 3-6 sát thương chuẩn và dịch chuyển mục tiêu lùi 200-240 đơn vị khoảng cách. Mỗi địch bị dịch chuyển tối đa 3 lần. CD: 20; tầm thi triển: 400.", "Bắn tối đa 5 cầu lửa, mỗi quả gây 6-9 sát thương chuẩn và dịch chuyển mục tiêu lùi 200-240 đơn vị khoảng cách. Mỗi địch bị dịch chuyển tối đa 3 lần. CD: 15; tầm thi triển: 400." },
					levels_enhanced = { "Bắn tối đa 5 cầu lửa, mỗi quả gây 3-6 sát thương chuẩn và dịch chuyển mục tiêu lùi 200-240 đơn vị khoảng cách. Mỗi địch bị dịch chuyển tối đa 3 lần. CD: 20; tầm thi triển: 400.", "Bắn tối đa 5 cầu lửa, mỗi quả gây 6-9 sát thương chuẩn và dịch chuyển mục tiêu lùi 200-240 đơn vị khoảng cách. Mỗi địch bị dịch chuyển tối đa 3 lần. CD: 15; tầm thi triển: 400." },
					prices_standard = { "150", "100" },
					prices_enhanced = { "150", "100" }
				},
			}
		},
		["tower_dragons_lvl4"] = {
			doc_id = "",
			title = "Trại ấp Rồng",
			attack = {
				standard = "Triệu hồi 1/2/3/3 rồng tham chiến. Mỗi rồng bắn đạn phép mỗi 2.13 giây, gây sát thương phép và giảm 60% tốc độ của địch trong 2 giây.",
				enhanced = "Triệu hồi 2/3/4/4 rồng tham chiến. Mỗi rồng bắn đạn phép mỗi 2.13 giây, gây sát thương phép và giảm /40%/50%/60%/70% tốc độ của địch trong 2 giây."
			},
			change_note = "Nhận xét: Tháp rất đa dụng nhưng bản gốc thiếu sát thương; 1 rồng ít tác dụng. So với bản gốc, tháp nhận nghiên cứu của cả hai phe Hắc ám: tăng sát thương, tăng tầm và giảm CD.",
			port_note = "Khoảng cách giữa đòn đánh trong mã của mỗi rồng là 2 giây; thực tế khoảng 2.13 giây. Tốc độ đánh hiển thị là [2 ÷ số rồng].",
			notes = "Tháp rất đa dụng nhưng bản gốc thiếu sát thương; 1 rồng ít tác dụng.\nLưu ý: Khoảng cách giữa đòn đánh phụ thuộc khoảng cách tới tháp. 2.13 là tốc độ khi đánh địch ở xa; liên tục đánh địch ở gần sẽ nhanh hơn, lý thuyết có thể dưới 1 giây. DPS thực tế thường cao hơn giá trị lý thuyết.",
			skills = {
				{
					name = "Nước bọt Ma thuật",
					standard = "Phun 3 khối nước bọt phép, gây 100-150 sát thương phép và thêm 20-30 sát thương phép cho địch trong phạm vi 100. CD: 12 (9.6).",
					enhanced = "Phun 3 khối nước bọt phép, gây 100-150 sát thương phép và thêm 20-30 sát thương phép cho địch trong phạm vi 100. CD: 12 (9.6).",
					levels_standard = { "Phun 3 khối nước bọt phép, gây 100-150 sát thương phép và thêm 20-30 sát thương phép cho địch trong phạm vi 100. CD: 12 (9.6).", "Phun 3 khối nước bọt phép, gây 200-300 sát thương phép và thêm 40-60 sát thương phép cho địch trong phạm vi 100. CD: 12 (9.6).", "Phun 3 khối nước bọt phép, gây 400-600 sát thương phép và thêm 70-100 sát thương phép cho địch trong phạm vi 100. CD: 12 (9.6)." },
					levels_enhanced = { "Phun 3 khối nước bọt phép, gây 100-150 sát thương phép và thêm 20-30 sát thương phép cho địch trong phạm vi 100. CD: 12 (9.6).", "Phun 3 khối nước bọt phép, gây 200-300 sát thương phép và thêm 40-60 sát thương phép cho địch trong phạm vi 100. CD: 12 (9.6).", "Phun 3 khối nước bọt phép, gây 400-600 sát thương phép và thêm 70-100 sát thương phép cho địch trong phạm vi 100. CD: 12 (9.6)." },
					prices_standard = { "200", "150", "150" },
					prices_enhanced = { "200", "150", "150" }
				},
				{
					name = "Tiếng gầm kinh hãi",
					standard = "Làm choáng tối đa 15 địch trong phạm vi 360 suốt 2.5 giây. CD: 22 (17.6).",
					enhanced = "Làm choáng tối đa 15 địch trong phạm vi 360 suốt 2.5 giây và gây 45 sát thương chuẩn. CD: 22 (17.6).",
					levels_standard = { "Làm choáng tối đa 15 địch trong phạm vi 360 suốt 2.5 giây. CD: 22 (17.6).", "Làm choáng tối đa 15 địch trong phạm vi 360 suốt 4 giây. CD: 22 (17.6)." },
					levels_enhanced = { "Làm choáng tối đa 15 địch trong phạm vi 360 suốt 2.5 giây và gây 45 sát thương chuẩn. CD: 22 (17.6).", "Làm choáng tối đa 15 địch trong phạm vi 360 suốt 4 giây và gây 90 sát thương chuẩn. CD: 22 (17.6)." },
					prices_standard = { "200", "150" },
					prices_enhanced = { "200", "150" }
				},
			}
		},
		["tower_archers_lvl4"] = {
			doc_id = "",
			title = "Pháo đài Cung thủ",
			attack = {
				standard = "Cứ 0.6 (0.54) giây bắn 1 mũi tên gây sát thương vật lý.",
				enhanced = "Cứ 0.6 (0.54) giây bắn 1 mũi tên gây sát thương vật lý. Sau khi học Xuyên gân, gây thêm 16%/32%/48% sát thương lên địch đang bị chặn hoặc choáng."
			},
			change_note = "Nhận xét: Kỹ năng tăng tầm đã rất mạnh nên chỉ tăng kỹ năng choáng vốn ít hữu ích hơn, đồng thời bổ sung tương tác phù hợp với nghiên cứu tháp cung phần 6.", port_note = "", notes = "", skills = {
				{
					name = "Xuyên gân",
					standard = "Bắn mỗi mục tiêu trong 2 địch một mũi tên, gây 16-24 sát thương vật lý và làm choáng 2 giây. CD: 15 giây.",
					enhanced = "Bắn mỗi mục tiêu trong 4 địch một mũi tên, gây 18-29 sát thương vật lý và làm choáng 2 giây. Tháp gây thêm 11% sát thương lên địch bị chặn hoặc choáng. CD: 15 giây.",
					levels_standard = { "Bắn mỗi mục tiêu trong 2 địch một mũi tên, gây 16-24 sát thương vật lý và làm choáng 2 giây. CD: 15 giây.", "Bắn mỗi mục tiêu trong 2 địch một mũi tên, gây 20-30 sát thương vật lý và làm choáng 4 giây. CD: 15 giây.", "Bắn mỗi mục tiêu trong 2 địch một mũi tên, gây 24-36 sát thương vật lý và làm choáng 6 giây. CD: 15 giây." },
					levels_enhanced = { "Bắn mỗi mục tiêu trong 4 địch một mũi tên, gây 18-29 sát thương vật lý và làm choáng 2 giây. Tháp gây thêm 11% sát thương lên địch bị chặn hoặc choáng. CD: 15 giây.", "Bắn mỗi mục tiêu trong 4 địch một mũi tên, gây 36-58 sát thương vật lý và làm choáng 4 giây. Tháp gây thêm 22% sát thương lên địch bị chặn hoặc choáng. CD: 15 giây.", "Bắn mỗi mục tiêu trong 4 địch một mũi tên, gây 54-87 sát thương vật lý và làm choáng 6 giây. Tháp gây thêm 33% sát thương lên địch bị chặn hoặc choáng. CD: 15 giây." },
					prices_standard = { "150", "150", "150" }, prices_enhanced = { "225", "225", "225" }
				},
				{
					name = "Mắt trời",
					standard = "Tăng 15% tầm đánh cho bản thân và các tháp xung quanh.",
					enhanced = "Tăng 15% tầm đánh cho bản thân và các tháp xung quanh.",
					levels_standard = { "Tăng 15% tầm đánh cho bản thân và các tháp xung quanh.", "Tăng 25% tầm đánh cho bản thân và các tháp xung quanh.", "Tăng 35% tầm đánh cho bản thân và các tháp xung quanh." },
					levels_enhanced = { "Tăng 15% tầm đánh cho bản thân và các tháp xung quanh.", "Tăng 25% tầm đánh cho bản thân và các tháp xung quanh.", "Tăng 35% tầm đánh cho bản thân và các tháp xung quanh." },
					prices_standard = { "120", "120", "120" }, prices_enhanced = { "120", "120", "120" }
				},
				{
					name = "Vạch điểm yếu",
					standard = "Đánh dấu địch, khiến mục tiêu nhận thêm 30% sát thương trong 5 giây; với trùm là 15%. CD: 12 giây.",
					enhanced = "Đánh dấu địch, khiến mục tiêu nhận thêm 30% sát thương trong 5 giây; với trùm là 15%. CD: 12 giây.",
					levels_standard = { "Đánh dấu địch, khiến mục tiêu nhận thêm 30% sát thương trong 5 giây; với trùm là 15%. CD: 12 giây.", "Đánh dấu địch, khiến mục tiêu nhận thêm 50% sát thương trong 6 giây; với trùm là 25%. CD: 12 giây.", "Đánh dấu địch, khiến mục tiêu nhận thêm 75% sát thương trong 7 giây; với trùm là 35%. CD: 12 giây." },
					levels_enhanced = { "Đánh dấu địch, khiến mục tiêu nhận thêm 30% sát thương trong 5 giây; với trùm là 15%. CD: 12 giây.", "Đánh dấu địch, khiến mục tiêu nhận thêm 50% sát thương trong 6 giây; với trùm là 25%. CD: 12 giây.", "Đánh dấu địch, khiến mục tiêu nhận thêm 75% sát thương trong 7 giây; với trùm là 35%. CD: 12 giây." },
					prices_standard = { "200", "200", "200" }, prices_enhanced = { "200", "200", "200" }
				},
				{
					name = "Mưa tên cuồng kích",
					standard = "Bắn tên nhanh trong 6 giây, mỗi 0.3 giây một mũi. CD: 36 giây.",
					enhanced = "Bắn tên nhanh trong 6 giây, mỗi 0.3 giây một mũi. CD: 36 giây.",
					levels_standard = { "Bắn tên nhanh trong 6 giây, mỗi 0.3 giây một mũi. CD: 36 giây." },
					levels_enhanced = { "Bắn tên nhanh trong 6 giây, mỗi 0.3 giây một mũi. CD: 36 giây." },
					prices_standard = { "0" }, prices_enhanced = { "0" }
				}
			}
		},
		["tower_knights_lvl4"] = {
			doc_id = "",
			title = "Hiệp sĩ Hộ vệ",
			attack = {
				standard = "Doanh trại cử 3 hiệp sĩ chặn địch, cận chiến gây sát thương vật lý.",
				enhanced = "Doanh trại cử 3 hiệp sĩ chặn địch, cận chiến gây sát thương vật lý."
			},
			change_note = "Tăng sức mạnh kỹ năng 2 để dễ luân phiên chặn địch.", port_note = "", notes = "", skills = {
				{
					name = "Khích lệ hộ vệ",
					standard = "Mỗi 1 anh hùng ở gần tăng 5% giáp cho hiệp sĩ.",
					enhanced = "Mỗi 1 anh hùng ở gần tăng 5% giáp cho hiệp sĩ.",
					levels_standard = { "Mỗi 1 anh hùng ở gần tăng 5% giáp cho hiệp sĩ.", "Mỗi 1 anh hùng ở gần tăng 10% giáp cho hiệp sĩ.", "Mỗi 1 anh hùng ở gần tăng 15% giáp cho hiệp sĩ." },
					levels_enhanced = { "Mỗi 1 anh hùng ở gần tăng 5% giáp cho hiệp sĩ.", "Mỗi 1 anh hùng ở gần tăng 10% giáp cho hiệp sĩ.", "Mỗi 1 anh hùng ở gần tăng 15% giáp cho hiệp sĩ." },
					prices_standard = { "120", "120", "120" }, prices_enhanced = { "120", "120", "120" }
				},
				{
					name = "Bền bỉ chiến đấu",
					standard = "Khi vào giao tranh, hiệp sĩ hồi 25% máu tối đa. CD: 15 giây.",
					enhanced = "Khi vào giao tranh, hiệp sĩ hồi 25% máu tối đa. CD: 15 giây.",
					levels_standard = { "Khi vào giao tranh, hiệp sĩ hồi 25% máu tối đa. CD: 15 giây.", "Khi vào giao tranh, hiệp sĩ hồi 40% máu tối đa. CD: 15 giây.", "Khi vào giao tranh, hiệp sĩ hồi 60% máu tối đa. CD: 15 giây." },
					levels_enhanced = { "Khi vào giao tranh, hiệp sĩ hồi 25% máu tối đa. CD: 15 giây.", "Khi vào giao tranh, hiệp sĩ hồi 40% máu tối đa. CD: 15 giây.", "Khi vào giao tranh, hiệp sĩ hồi 60% máu tối đa. CD: 15 giây." },
					prices_standard = { "180", "180", "180" }, prices_enhanced = { "180", "180", "180" }
				},
				{
					name = "Kế thừa ý chí",
					standard = "Khi một hiệp sĩ gần đó ngã xuống, những người còn lại giảm 20% khoảng cách giữa đòn đánh trong 8 giây.",
					enhanced = "Khi một hiệp sĩ gần đó ngã xuống, những người còn lại giảm 20% khoảng cách giữa đòn đánh trong 8 giây và hồi 20% máu tối đa.",
					levels_standard = { "Khi một hiệp sĩ gần đó ngã xuống, những người còn lại giảm 20% khoảng cách giữa đòn đánh trong 8 giây.", "Khi một hiệp sĩ gần đó ngã xuống, những người còn lại giảm 40% khoảng cách giữa đòn đánh trong 8 giây.", "Khi một hiệp sĩ gần đó ngã xuống, những người còn lại giảm 60% khoảng cách giữa đòn đánh trong 8 giây." },
					levels_enhanced = { "Khi một hiệp sĩ gần đó ngã xuống, những người còn lại giảm 20% khoảng cách giữa đòn đánh trong 8 giây và hồi 20% máu tối đa.", "Khi một hiệp sĩ gần đó ngã xuống, những người còn lại giảm 40% khoảng cách giữa đòn đánh trong 8 giây và hồi 35% máu tối đa.", "Khi một hiệp sĩ gần đó ngã xuống, những người còn lại giảm 60% khoảng cách giữa đòn đánh trong 8 giây và hồi 50% máu tối đa." },
					prices_standard = { "150", "100", "100" }, prices_enhanced = { "150", "100", "100" }
				},
				{
					name = "Phòng tuyến cuối cùng",
					standard = "Khi dưới 20% máu và đang cận chiến, hiệp sĩ bất tử trong 5 giây. CD: 30 giây.",
					enhanced = "Khi dưới 20% máu và đang cận chiến, hiệp sĩ bất tử trong 5 giây. CD: 30 giây.",
					levels_standard = { "Khi dưới 20% máu và đang cận chiến, hiệp sĩ bất tử trong 5 giây. CD: 30 giây." },
					levels_enhanced = { "Khi dưới 20% máu và đang cận chiến, hiệp sĩ bất tử trong 5 giây. CD: 30 giây." },
					prices_standard = { "0" }, prices_enhanced = { "0" }
				}
			}
		},
		["tower_wizard_lvl4"] = {
			doc_id = "",
			title = "Học giả Cổ thư",
			attack = {
				standard = "Cứ 2 giây kích hoạt hai cổ thư hai bên, mỗi cuốn bắn một đạn phép. Chỉ số hiển thị là của một đạn.",
				enhanced = "Cứ 2 giây kích hoạt hai cổ thư hai bên, mỗi cuốn bắn một đạn phép. Chỉ số hiển thị là của một đạn."
			},
			change_note = "Đưa chỉ số kỹ năng 3 về mức của phiên bản Học giả Cổ thư đầu tiên. Tháp đã có DPS cao và tăng sát thương diện rộng nên không tăng thêm. Đổi kỹ năng 3 chỉ tăng tiềm năng tối đa, không tăng hiệu quả so với giá.", port_note = "", notes = "", skills = {
				{
					name = "Sách lửa",
					standard = "Ném sách lửa gây 40 sát thương phép, rồi 32 sát thương bỏng chuẩn trong 4 giây. CD: 20 giây.",
					enhanced = "Ném sách lửa gây 40 sát thương phép, rồi 32 sát thương bỏng chuẩn trong 4 giây. CD: 20 giây.",
					levels_standard = { "Ném sách lửa gây 40 sát thương phép, rồi 32 sát thương bỏng chuẩn trong 4 giây. CD: 20 giây.", "Ném sách lửa gây 100 sát thương phép, rồi 48 sát thương bỏng chuẩn trong 4 giây. CD: 20 giây.", "Ném sách lửa gây 160 sát thương phép, rồi 64 sát thương bỏng chuẩn trong 4 giây. CD: 20 giây." },
					levels_enhanced = { "Ném sách lửa gây 40 sát thương phép, rồi 32 sát thương bỏng chuẩn trong 4 giây. CD: 20 giây.", "Ném sách lửa gây 100 sát thương phép, rồi 48 sát thương bỏng chuẩn trong 4 giây. CD: 20 giây.", "Ném sách lửa gây 160 sát thương phép, rồi 64 sát thương bỏng chuẩn trong 4 giây. CD: 20 giây." },
					prices_standard = { "120", "120", "120" }, prices_enhanced = { "120", "120", "120" }
				},
				{
					name = "Cuộn tri thức",
					standard = "Tăng 50% sát thương cho tháp gần đó trong 8 giây. CD: 25 giây.",
					enhanced = "Tăng 50% sát thương cho tháp gần đó trong 8 giây. CD: 25 giây.",
					levels_standard = { "Tăng 50% sát thương cho tháp gần đó trong 8 giây. CD: 25 giây.", "Tăng 75% sát thương cho tháp gần đó trong 10 giây. CD: 25 giây.", "Tăng 100% sát thương cho tháp gần đó trong 12 giây. CD: 25 giây." },
					levels_enhanced = { "Tăng 50% sát thương cho tháp gần đó trong 8 giây. CD: 25 giây.", "Tăng 75% sát thương cho tháp gần đó trong 10 giây. CD: 25 giây.", "Tăng 100% sát thương cho tháp gần đó trong 12 giây. CD: 25 giây." },
					prices_standard = { "200", "160", "160" }, prices_enhanced = { "200", "160", "160" }
				},
				{
					name = "Bản sao dự phòng",
					standard = "Ném sách phép gây 50 sát thương khi trúng đích, rồi bắn 3 đạn phép gây 34-60 sát thương. CD: 25 giây.",
					enhanced = "Ném sách phép gây 50 sát thương khi trúng đích, rồi bắn 5 đạn phép gây 35-65 sát thương. CD: 25 giây.",
					levels_standard = { "Ném sách phép gây 50 sát thương khi trúng đích, rồi bắn 3 đạn phép gây 34-60 sát thương. CD: 25 giây.", "Ném sách phép gây 50 sát thương khi trúng đích, rồi bắn 5 đạn phép gây 52-92 sát thương. CD: 25 giây.", "Ném sách phép gây 50 sát thương khi trúng đích, rồi bắn 8 đạn phép gây 62-108 sát thương. CD: 25 giây." },
					levels_enhanced = { "Ném sách phép gây 50 sát thương khi trúng đích, rồi bắn 5 đạn phép gây 35-65 sát thương. CD: 25 giây.", "Ném sách phép gây 50 sát thương khi trúng đích, rồi bắn 7 đạn phép gây 56-104 sát thương. CD: 25 giây.", "Ném sách phép gây 50 sát thương khi trúng đích, rồi bắn 10 đạn phép gây 77-143 sát thương. CD: 25 giây." },
					prices_standard = { "160", "160", "160" }, prices_enhanced = { "150", "150", "150" }
				},
				{
					name = "Thiên thạch Bí thuật",
					standard = "Gọi thiên thạch gây 620 sát thương phép và làm choáng địch xung quanh 1 giây. CD: 36 giây.",
					enhanced = "Gọi thiên thạch gây 620 sát thương phép và làm choáng địch xung quanh 1 giây. CD: 36 giây.",
					levels_standard = { "Gọi thiên thạch gây 620 sát thương phép và làm choáng địch xung quanh 1 giây. CD: 36 giây." },
					levels_enhanced = { "Gọi thiên thạch gây 620 sát thương phép và làm choáng địch xung quanh 1 giây. CD: 36 giây." },
					prices_standard = { "0" }, prices_enhanced = { "0" }
				}
			}
		},
		["tower_catapult_lvl4"] = {
			doc_id = "",
			title = "Máy bắn đá Hoàng gia",
			attack = {
				standard = "Cứ 5.2 giây ném đá, gây sát thương pháo trong phạm vi 120.",
				enhanced = "Cứ 5.2 giây ném đá, gây sát thương pháo trong phạm vi 120. Sau khi tiếp đất, đá lăn ngược đường tối đa 400 đơn vị khoảng cách; mỗi lần va chạm gây sát thương bằng 15% chỉ số của đòn đó."
			},
			change_note = "Tháp pháo có hiệu quả sát thương so với giá thấp nhất trong các phần. Cường hóa đánh thường để mọi đòn đều có hiệu ứng của tuyệt kỹ.", port_note = "", notes = "", skills = {
				{
					name = "Phủ hắc ín",
					standard = "Ném thùng hắc ín, nổ gây 80-120 sát thương pháo và làm chậm 40% trong 6 giây. CD: 15 giây.",
					enhanced = "Ném thùng hắc ín, nổ gây 80-120 sát thương pháo và làm chậm 40% trong 6 giây. CD: 15 giây.",
					levels_standard = { "Ném thùng hắc ín, nổ gây 80-120 sát thương pháo và làm chậm 40% trong 6 giây. CD: 15 giây.", "Ném thùng hắc ín, nổ gây 80-120 sát thương pháo và làm chậm 50% trong 8 giây. CD: 15 giây.", "Ném thùng hắc ín, nổ gây 80-120 sát thương pháo và làm chậm 60% trong 10 giây. CD: 15 giây." },
					levels_enhanced = { "Ném thùng hắc ín, nổ gây 80-120 sát thương pháo và làm chậm 40% trong 6 giây. CD: 15 giây.", "Ném thùng hắc ín, nổ gây 80-120 sát thương pháo và làm chậm 50% trong 8 giây. CD: 15 giây.", "Ném thùng hắc ín, nổ gây 80-120 sát thương pháo và làm chậm 60% trong 10 giây. CD: 15 giây." },
					prices_standard = { "100", "100", "100" }, prices_enhanced = { "100", "100", "100" }
				},
				{
					name = "Đá nổ",
					standard = "Đá thường nổ thêm sau khi tiếp đất, gây 18-32 sát thương pháo.",
					enhanced = "Đá thường nổ thêm sau khi tiếp đất, gây 18-32 sát thương pháo, rồi lăn ngược tối đa 25 điểm trên đường. Mỗi lần va chạm gây sát thương bằng 15% chỉ số của đòn đó.",
					levels_standard = { "Đá thường nổ thêm sau khi tiếp đất, gây 18-32 sát thương pháo.", "Đá thường nổ thêm sau khi tiếp đất, gây 36-64 sát thương pháo.", "Đá thường nổ thêm sau khi tiếp đất, gây 52-92 sát thương pháo." },
					levels_enhanced = { "Đá thường nổ thêm sau khi tiếp đất, gây 18-32 sát thương pháo. Phần sát thương này được tính vào sát thương khi đá lăn.", "Đá thường nổ thêm sau khi tiếp đất, gây 36-64 sát thương pháo. Phần sát thương này được tính vào sát thương khi đá lăn.", "Đá thường nổ thêm sau khi tiếp đất, gây 52-92 sát thương pháo. Phần sát thương này được tính vào sát thương khi đá lăn." },
					prices_standard = { "200", "200", "200" }, prices_enhanced = { "200", "200", "200" }
				},
				{
					name = "Khu vực phòng vệ",
					standard = "Cứ 7 giây đặt bẫy cạnh tháp. Khi kích hoạt, gây 20-30 sát thương vật lý và làm choáng 1 giây. Tối đa 3 bẫy.",
					enhanced = "Cứ 7 giây đặt bẫy cạnh tháp. Khi kích hoạt, gây 20-30 sát thương vật lý và làm choáng 1 giây. Tối đa 3 bẫy.",
					levels_standard = { "Cứ 7 giây đặt bẫy cạnh tháp. Khi kích hoạt, gây 20-30 sát thương vật lý và làm choáng 1 giây. Tối đa 3 bẫy.", "Cứ 7 giây đặt bẫy cạnh tháp. Khi kích hoạt, gây 32-48 sát thương vật lý và làm choáng 2 giây. Tối đa 4 bẫy.", "Cứ 7 giây đặt bẫy cạnh tháp. Khi kích hoạt, gây 48-72 sát thương vật lý và làm choáng 3 giây. Tối đa 5 bẫy." },
					levels_enhanced = { "Cứ 7 giây đặt bẫy cạnh tháp. Khi kích hoạt, gây 20-30 sát thương vật lý và làm choáng 1 giây. Tối đa 3 bẫy.", "Cứ 7 giây đặt bẫy cạnh tháp. Khi kích hoạt, gây 32-48 sát thương vật lý và làm choáng 2 giây. Tối đa 4 bẫy.", "Cứ 7 giây đặt bẫy cạnh tháp. Khi kích hoạt, gây 48-72 sát thương vật lý và làm choáng 3 giây. Tối đa 5 bẫy." },
					prices_standard = { "150", "100", "100" }, prices_enhanced = { "150", "100", "100" }
				},
				{
					name = "Đá lửa",
					standard = "Ném đá cháy lăn 500 đơn vị khoảng cách, va chạm và phát nổ, gây tổng cộng 195 sát thương pháo và để lại vùng cháy. CD: 30 giây.",
					enhanced = "Ném đá cháy lăn 500 đơn vị khoảng cách, va chạm và phát nổ, gây tổng cộng 195 sát thương pháo và để lại vùng cháy. CD: 30 giây.",
					levels_standard = { "Ném đá cháy lăn 500 đơn vị khoảng cách, va chạm và phát nổ, gây tổng cộng 195 sát thương pháo và để lại vùng cháy. CD: 30 giây." },
					levels_enhanced = { "Ném đá cháy lăn 500 đơn vị khoảng cách, va chạm và phát nổ, gây tổng cộng 195 sát thương pháo và để lại vùng cháy. CD: 30 giây." },
					prices_standard = { "0" }, prices_enhanced = { "0" }
				}
			}
		},
		["tower_ranger_lvl4"] = {
			doc_id = "",
			title = "Du kích Tinh linh Tinh nhuệ",
			attack = {
				standard = "Cứ 1.5 (1.35) giây bắn 1 mũi tên gây sát thương vật lý.",
				enhanced = "Cứ 1.5 (1.35) giây bắn 1 mũi tên gây sát thương vật lý."
			},
			change_note = "Khi nâng Tên nảy Rừng xanh, tên độc cũng nảy và áp dụng đầy đủ hiệu ứng độc ở cấp hiện tại cho mỗi mục tiêu. Hồi chiêu tên độc: 15 giây.", port_note = "", notes = "", skills = {
				{
					name = "Tên tẩm độc",
					standard = "Bắn 3 tên độc, mỗi tên gây sát thương vật lý và 24 sát thương độc chuẩn trong 3 giây. CD: 15 giây.",
					enhanced = "Bắn 3 tên độc, mỗi tên gây sát thương vật lý và 24 sát thương độc chuẩn trong 3 giây. CD: 15 giây. Khi nâng Tên nảy Rừng xanh, tên độc cũng nảy và áp dụng đầy đủ hiệu ứng độc cho mỗi mục tiêu.",
					levels_standard = { "Bắn 3 tên độc, mỗi tên gây sát thương vật lý và 24 sát thương độc chuẩn trong 3 giây. CD: 15 giây.", "Bắn 3 tên độc, mỗi tên gây sát thương vật lý và 80 sát thương độc chuẩn trong 5 giây. CD: 15 giây.", "Bắn 3 tên độc, mỗi tên gây sát thương vật lý và 192 sát thương độc chuẩn trong 8 giây. CD: 15 giây." },
					levels_enhanced = { "Bắn 3 tên độc, mỗi tên gây sát thương vật lý và 24 sát thương độc chuẩn trong 3 giây. CD: 15 giây. Tên nảy áp dụng đầy đủ hiệu ứng độc.", "Bắn 3 tên độc, mỗi tên gây sát thương vật lý và 80 sát thương độc chuẩn trong 5 giây. CD: 15 giây. Tên nảy áp dụng đầy đủ hiệu ứng độc.", "Bắn 3 tên độc, mỗi tên gây sát thương vật lý và 192 sát thương độc chuẩn trong 8 giây. CD: 15 giây. Tên nảy áp dụng đầy đủ hiệu ứng độc." },
					prices_standard = { "200", "200", "200" }, prices_enhanced = { "200", "200", "200" }
				},
				{
					name = "Bắn dây gai",
					standard = "Giương cung bắn gây 80-120 sát thương vật lý và làm choáng 2 giây; làm chậm địch gần đó 60% trong 6 giây. CD: 25 giây.",
					enhanced = "Giương cung bắn gây 80-120 sát thương vật lý và làm choáng 2 giây; làm chậm địch gần đó 60% trong 6 giây. CD: 25 giây.",
					levels_standard = { "Giương cung bắn gây 80-120 sát thương vật lý và làm choáng 2 giây; làm chậm địch gần đó 60% trong 6 giây. CD: 25 giây.", "Giương cung bắn gây 120-180 sát thương vật lý và làm choáng 2 giây; làm chậm địch gần đó 60% trong 7 giây. CD: 25 giây.", "Giương cung bắn gây 160-240 sát thương vật lý và làm choáng 2 giây; làm chậm địch gần đó 60% trong 9 giây. CD: 25 giây." },
					levels_enhanced = { "Giương cung bắn gây 80-120 sát thương vật lý và làm choáng 2 giây; làm chậm địch gần đó 60% trong 6 giây. CD: 25 giây.", "Giương cung bắn gây 120-180 sát thương vật lý và làm choáng 2 giây; làm chậm địch gần đó 60% trong 7 giây. CD: 25 giây.", "Giương cung bắn gây 160-240 sát thương vật lý và làm choáng 2 giây; làm chậm địch gần đó 60% trong 9 giây. CD: 25 giây." },
					prices_standard = { "150", "150", "150" }, prices_enhanced = { "150", "150", "150" }
				},
				{
					name = "Tên nảy Rừng xanh",
					standard = "Tên nảy tối đa 3 lần, sát thương nảy bằng 25% sát thương ban đầu.",
					enhanced = "Tên nảy tối đa 3 lần, sát thương nảy bằng 25% sát thương ban đầu. Tên độc cũng nảy; sát thương và thời gian độc không giảm qua mỗi lần nảy.",
					levels_standard = { "Tên nảy tối đa 3 lần, sát thương nảy bằng 25% sát thương ban đầu.", "Tên nảy tối đa 3 lần, sát thương nảy bằng 50% sát thương ban đầu.", "Tên nảy tối đa 3 lần, sát thương nảy bằng 75% sát thương ban đầu." },
					levels_enhanced = { "Tên nảy tối đa 3 lần, sát thương nảy bằng 25% sát thương ban đầu. Tên độc nảy giữ nguyên hiệu ứng độc.", "Tên nảy tối đa 3 lần, sát thương nảy bằng 50% sát thương ban đầu. Tên độc nảy giữ nguyên hiệu ứng độc.", "Tên nảy tối đa 3 lần, sát thương nảy bằng 75% sát thương ban đầu. Tên độc nảy giữ nguyên hiệu ứng độc." },
					prices_standard = { "250", "200", "200" }, prices_enhanced = { "230", "185", "185" }
				},
				{
					name = "Bắn hạ tàn nhẫn",
					standard = "Tiêu diệt địch thường dưới 40% máu; gây 500 sát thương lên trùm. CD: 32 giây.",
					enhanced = "Tiêu diệt địch thường dưới 40% máu; gây 500 sát thương lên trùm. CD: 32 giây.",
					levels_standard = { "Tiêu diệt địch thường dưới 40% máu; gây 500 sát thương lên trùm. CD: 32 giây." },
					levels_enhanced = { "Tiêu diệt địch thường dưới 40% máu; gây 500 sát thương lên trùm. CD: 32 giây." },
					prices_standard = { "0" }, prices_enhanced = { "0" }
				}
			}
		},
		["tower_culverine_lvl4"] = {
			doc_id = "",
			title = "Pháo tản Người Lùn",
			attack = {
				standard = "Cứ 3 giây bắn đạn pháo, gây sát thương pháo trong phạm vi 110.",
				enhanced = "Cứ 3 giây bắn đạn pháo, gây sát thương pháo trong phạm vi 110."
			},
			change_note = "Trong 3 kỹ năng, chỉ bắn liên thanh phối hợp tốt với phép; giảm giáp và lưu huỳnh ít hữu ích, lưu huỳnh còn làm giảm hiệu quả. Đổi giảm giáp thành khắc chế địch giáp cao; đạn lưu huỳnh là đòn cường hóa nên nhận thêm sát thương của một đòn thường.", port_note = "", notes = "", skills = {
				{
					name = "Nổ lưu huỳnh",
					standard = "Bắn đạn lưu huỳnh gây 66-86 sát thương pháo. Khói giảm 100% kháng phép của địch trong 6 giây. CD: 16 giây.",
					enhanced = "Chỉ cần 1 địch để bắn đạn lưu huỳnh, gây sát thương đánh thường cộng 66-86 sát thương pháo. Khói giảm 100% kháng phép trong 6 giây. CD: 16 giây.",
					levels_standard = { "Bắn đạn lưu huỳnh gây 66-86 sát thương pháo. Khói giảm 100% kháng phép của địch trong 6 giây. CD: 16 giây.", "Bắn đạn lưu huỳnh gây 108-148 sát thương pháo. Khói giảm 100% kháng phép của địch trong 8 giây. CD: 16 giây.", "Bắn đạn lưu huỳnh gây 156-218 sát thương pháo. Khói giảm 100% kháng phép của địch trong 10 giây. CD: 16 giây." },
					levels_enhanced = { "Chỉ cần 1 địch để bắn đạn lưu huỳnh, gây sát thương đánh thường cộng 66-86 sát thương pháo. Khói giảm 100% kháng phép trong 6 giây. CD: 16 giây.", "Chỉ cần 1 địch để bắn đạn lưu huỳnh, gây sát thương đánh thường cộng 108-148 sát thương pháo. Khói giảm 100% kháng phép trong 8 giây. CD: 16 giây.", "Chỉ cần 1 địch để bắn đạn lưu huỳnh, gây sát thương đánh thường cộng 156-218 sát thương pháo. Khói giảm 100% kháng phép trong 10 giây. CD: 16 giây." },
					prices_standard = { "150", "150", "150" }, prices_enhanced = { "150", "150", "150" }
				},
				{
					name = "Mảnh đạn sắc",
					standard = "Đạn pháo thường giảm 3% giáp của địch trúng đòn.",
					enhanced = "Mỗi địch trúng đòn nhận thêm sát thương chuẩn bằng giá trị phần trăm giáp của nó × 0.25.",
					levels_standard = { "Đạn pháo thường giảm 3% giáp của địch trúng đòn.", "Đạn pháo thường giảm 5% giáp của địch trúng đòn.", "Đạn pháo thường giảm 7% giáp của địch trúng đòn." },
					levels_enhanced = { "Mỗi địch trúng đòn nhận thêm sát thương chuẩn bằng 0.3 lần giá trị phần trăm giáp của nó.", "Mỗi địch trúng đòn nhận thêm sát thương chuẩn bằng 0.7 lần giá trị phần trăm giáp của nó.", "Mỗi địch trúng đòn nhận thêm sát thương chuẩn bằng 1.2 lần giá trị phần trăm giáp của nó." },
					prices_standard = { "100", "100", "100" }, prices_enhanced = { "100", "100", "100" }
				},
				{
					name = "Toàn lực khai hỏa",
					standard = "Bắn nhanh liên tiếp 3 quả đạn. CD: 25 giây.",
					enhanced = "Bắn nhanh liên tiếp 3 quả đạn. CD: 25 giây.",
					levels_standard = { "Bắn nhanh liên tiếp 3 quả đạn. CD: 25 giây.", "Bắn nhanh liên tiếp 6 quả đạn. CD: 25 giây.", "Bắn nhanh liên tiếp 9 quả đạn. CD: 25 giây." },
					levels_enhanced = { "Bắn nhanh liên tiếp 3 quả đạn. CD: 25 giây.", "Bắn nhanh liên tiếp 6 quả đạn. CD: 25 giây.", "Bắn nhanh liên tiếp 9 quả đạn. CD: 25 giây." },
					prices_standard = { "200", "200", "200" }, prices_enhanced = { "200", "200", "200" }
				},
				{
					name = "Xả lửa nóng",
					standard = "Sau 6 lần đánh, xả lửa gây 60-110 sát thương pháo cho địch xung quanh và làm choáng 2 giây. CD: 35 giây.",
					enhanced = "Sau 6 lần đánh, xả lửa gây 60-110 sát thương pháo cho địch xung quanh và làm choáng 2 giây. CD: 35 giây.",
					levels_standard = { "Sau 6 lần đánh, xả lửa gây 60-110 sát thương pháo cho địch xung quanh và làm choáng 2 giây. CD: 35 giây." },
					levels_enhanced = { "Sau 6 lần đánh, xả lửa gây 60-110 sát thương pháo cho địch xung quanh và làm choáng 2 giây. CD: 35 giây." },
					prices_standard = { "0" }, prices_enhanced = { "0" }
				}
			}
		},
		["tower_sunray_master_lvl4"] = {
			doc_id = "",
			title = "Bậc thầy Nhật quang",
			attack = {
				standard = "Chuyển giữa tia sáng và bắn nhanh, mặc định bắn nhanh. Tia sáng chỉ đánh địch mặt đất trong 0.5 giây: mỗi 4.43 giây gây 4 lần sát thương phép theo chỉ số trong bán kính 55 và làm chậm 20%. Chế độ bắn nhanh bắn 1 đạn phép mỗi 0.28 giây, có thể đánh địch bay.",
				enhanced = "Chuyển giữa tia sáng và bắn nhanh, mặc định bắn nhanh. Tia sáng chỉ đánh địch mặt đất trong 0.5 giây: mỗi 4.43 giây gây 4 lần sát thương phép theo chỉ số trong bán kính 55 và làm chậm 20%. Chế độ bắn nhanh bắn 1 đạn phép mỗi 0.28 giây, có thể đánh địch bay."
			},
			change_note = "Chủ yếu cải thiện chế độ tia sáng, tăng sát thương Quá tải và khả năng chặn địch của tinh linh. Tia sáng giờ có thể đổi mỗi 6.1 giây lấy 140 sát thương diện rộng cùng khống chế ngắn, đủ hiệu quả so với giá.", port_note = "", notes = "", skills = {
				{
					name = "Tinh linh nhỏ",
					standard = "Triệu hồi 2 tinh linh nhỏ chặn địch; mỗi tinh linh có 100 máu và gây 3-5 sát thương cận chiến.",
					enhanced = "Triệu hồi 2 tinh linh nhỏ chặn địch; mỗi tinh linh có 180 máu, 40% giáp, cận chiến gây 10-30 sát thương trong phạm vi 32.5.",
					levels_standard = { "Triệu hồi 2 tinh linh nhỏ chặn địch; mỗi tinh linh có 100 máu và gây 3-5 sát thương cận chiến.", "Triệu hồi 2 tinh linh nhỏ chặn địch; mỗi tinh linh có 140 máu và gây 4-6 sát thương cận chiến.", "Triệu hồi 2 tinh linh nhỏ chặn địch; mỗi tinh linh có 180 máu và gây 5-7 sát thương cận chiến." },
					levels_enhanced = { "Triệu hồi 2 tinh linh nhỏ chặn địch; mỗi tinh linh có 180 máu, 30% giáp, cận chiến gây 10-30 sát thương trong phạm vi 32.5.", "Triệu hồi 2 tinh linh nhỏ chặn địch; mỗi tinh linh có 265 máu, 50% giáp, cận chiến gây 20-40 sát thương trong phạm vi 32.5.", "Triệu hồi 2 tinh linh nhỏ chặn địch; mỗi tinh linh có 350 máu, 60% giáp, cận chiến gây 30-50 sát thương trong phạm vi 32.5." },
					prices_standard = { "200", "100", "100" }, prices_enhanced = { "300", "150", "150" }
				},
				{
					name = "Quá tải Nhật quang",
					standard = "Khi tia sáng quá nhiệt, phát sóng xung kích gây 16-24 sát thương và làm chậm 20% trong 3 giây.",
					enhanced = "Khi tia sáng quá nhiệt, phát sóng xung kích gây 64-96 sát thương và làm chậm 20% trong 3 giây.",
					levels_standard = { "Khi tia sáng quá nhiệt, phát sóng xung kích gây 16-24 sát thương và làm chậm 20% trong 3 giây.", "Khi tia sáng quá nhiệt, phát sóng xung kích gây 32-48 sát thương và làm chậm 30% trong 3 giây.", "Khi tia sáng quá nhiệt, phát sóng xung kích gây 48-72 sát thương và làm chậm 40% trong 3 giây." },
					levels_enhanced = { "Khi tia sáng quá nhiệt, phát sóng xung kích gây 64-96 sát thương và làm chậm 20% trong 3 giây.", "Khi tia sáng quá nhiệt, phát sóng xung kích gây 88-132 sát thương và làm chậm 30% trong 3 giây.", "Khi tia sáng quá nhiệt, phát sóng xung kích gây 112-168 sát thương và làm chậm 40% trong 3 giây." },
					prices_standard = { "150", "150", "150" }, prices_enhanced = { "185", "185", "185" }
				},
				{
					name = "Quang năng cuồng bạo",
					standard = "Ở chế độ bắn nhanh, mỗi đạn thứ 4 gây thêm 40% sát thương và giảm 2% giáp của mục tiêu.",
					enhanced = "Ở chế độ bắn nhanh, đạn thứ 2 và thứ 4 gây thêm 40% sát thương và giảm 2% giáp của mục tiêu.",
					levels_standard = { "Ở chế độ bắn nhanh, mỗi đạn thứ 4 gây thêm 40% sát thương và giảm 2% giáp của mục tiêu.", "Ở chế độ bắn nhanh, mỗi đạn thứ 4 gây thêm 70% sát thương và giảm 3% giáp của mục tiêu.", "Ở chế độ bắn nhanh, mỗi đạn thứ 4 gây thêm 100% sát thương và giảm 4% giáp của mục tiêu." },
					levels_enhanced = { "Ở chế độ bắn nhanh, đạn thứ 2 và thứ 4 gây thêm 40% sát thương và giảm 2% giáp của mục tiêu.", "Ở chế độ bắn nhanh, đạn thứ 2 và thứ 4 gây thêm 70% sát thương và giảm 3% giáp của mục tiêu.", "Ở chế độ bắn nhanh, đạn thứ 2 và thứ 4 gây thêm 100% sát thương và giảm 4% giáp của mục tiêu." },
					prices_standard = { "100", "100", "100" }, prices_enhanced = { "130", "130", "130" }
				},
				{
					name = "Phán quyết Nhật quang",
					standard = "Bắn 4 tia sáng, mỗi tia gây 36-64 sát thương phép và làm choáng 2 giây. CD: 40 giây.",
					enhanced = "Bắn 4 tia sáng, mỗi tia gây 36-64 sát thương phép và làm choáng 2 giây. CD: 40 giây.",
					levels_standard = { "Bắn 4 tia sáng, mỗi tia gây 36-64 sát thương phép và làm choáng 2 giây. CD: 40 giây." },
					levels_enhanced = { "Bắn 4 tia sáng, mỗi tia gây 36-64 sát thương phép và làm choáng 2 giây. CD: 40 giây." },
					prices_standard = { "0" }, prices_enhanced = { "0" }
				}
			}
		},
		["tower_light_priestess_lvl4"] = {
			doc_id = "",
			title = "Nữ tư tế Ánh sáng",
			attack = {
				standard = "Cứ 1.6 giây bắn đạn phép. Đồng minh xung quanh nhận thêm 10/15/20/25 giáp.",
				enhanced = "Cứ 1.6 giây bắn đạn phép. Đồng minh xung quanh nhận thêm 10/15/20/25 giáp."
			},
			change_note = "Tăng tầm đánh và phạm vi hiệu ứng để tháp hữu dụng hơn, đồng thời có thể khiến địch ngoài tầm đánh câm lặng.", port_note = "", notes = "", skills = {
				{
					name = "Thánh địa Hộ vệ",
					standard = "Hồi 96 máu cho đồng minh trong 4 giây và tăng thêm 10% giáp. CD: 16 giây.",
					enhanced = "Hồi 96 máu cho đồng minh trong 4 giây và tăng thêm 10% giáp. CD: 16 giây.",
					levels_standard = { "Hồi 96 máu cho đồng minh trong 4 giây và tăng thêm 10% giáp. CD: 16 giây.", "Hồi 128 máu cho đồng minh trong 4 giây và tăng thêm 20% giáp. CD: 16 giây.", "Hồi 192 máu cho đồng minh trong 4 giây và tăng thêm 30% giáp. CD: 16 giây." },
					levels_enhanced = { "Hồi 96 máu cho đồng minh trong 4 giây và tăng thêm 10% giáp. CD: 16 giây.", "Hồi 128 máu cho đồng minh trong 4 giây và tăng thêm 20% giáp. CD: 16 giây.", "Hồi 192 máu cho đồng minh trong 4 giây và tăng thêm 30% giáp. CD: 16 giây." },
					prices_standard = { "200", "200", "200" }, prices_enhanced = { "200", "200", "200" }
				},
				{
					name = "Hào quang Câm lặng",
					standard = "Làm chậm địch xung quanh 40% và khiến chúng câm lặng 6 giây. CD: 22 giây.",
					enhanced = "Làm chậm địch xung quanh 40% và khiến chúng câm lặng 6 giây. CD: 22 giây.",
					levels_standard = { "Làm chậm địch xung quanh 40% và khiến chúng câm lặng 6 giây. CD: 22 giây.", "Làm chậm địch xung quanh 40% và khiến chúng câm lặng 8 giây. CD: 22 giây.", "Làm chậm địch xung quanh 40% và khiến chúng câm lặng 10 giây. CD: 22 giây." },
					levels_enhanced = { "Làm chậm địch xung quanh 40% và khiến chúng câm lặng 6 giây. CD: 22 giây.", "Làm chậm địch xung quanh 40% và khiến chúng câm lặng 8 giây. CD: 22 giây.", "Làm chậm địch xung quanh 40% và khiến chúng câm lặng 10 giây. CD: 22 giây." },
					prices_standard = { "120", "120", "120" }, prices_enhanced = { "120", "120", "120" }
				},
				{
					name = "Phước lành Panacea",
					standard = "Tăng 50% sát thương cho một tháp trong 5 giây. CD: 18 giây.",
					enhanced = "Tăng 50% sát thương cho một tháp trong 5 giây. CD: 18 giây.",
					levels_standard = { "Tăng 50% sát thương cho một tháp trong 5 giây. CD: 18 giây.", "Tăng 75% sát thương cho một tháp trong 7 giây. CD: 18 giây.", "Tăng 100% sát thương cho một tháp trong 9 giây. CD: 18 giây." },
					levels_enhanced = { "Tăng 15% sức tấn công và giảm 25% thời gian hồi kỹ năng cho 1 tháp gần nhất.", "Tăng 15% sức tấn công và giảm 25% thời gian hồi kỹ năng cho 2 tháp gần nhất.", "Tăng 15% sức tấn công và giảm 25% thời gian hồi kỹ năng cho 3 tháp gần nhất." },
					prices_standard = { "150", "150", "150" }, prices_enhanced = { "335", "335", "335" }
				},
				{
					name = "Thánh quang Giáng thế",
					standard = "Phóng thánh quang trong 5 giây, gây 20-30 sát thương phép mỗi 0.25 giây và giảm giáp; đồng minh gần đó trở nên bất tử. CD: 37 giây.",
					enhanced = "Phóng thánh quang trong 5 giây, gây 20-30 sát thương phép mỗi 0.25 giây và giảm giáp; đồng minh gần đó trở nên bất tử. CD: 37 giây.",
					levels_standard = { "Phóng thánh quang trong 5 giây, gây 20-30 sát thương phép mỗi 0.25 giây và giảm giáp; đồng minh gần đó trở nên bất tử. CD: 37 giây." },
					levels_enhanced = { "Phóng thánh quang trong 5 giây, gây 20-30 sát thương phép mỗi 0.25 giây và giảm giáp; đồng minh gần đó trở nên bất tử. CD: 37 giây." },
					prices_standard = { "0" }, prices_enhanced = { "0" }
				}
			}
		},
		["tower_tree_lvl4"] = {
			doc_id = "",
			title = "Thụ tinh Thiết mộc",
			attack = {
				standard = "Dạng tháp đập diện rộng lên địch mặt đất. Ở cấp 4, mỗi đòn gây sát thương pháo cho mọi địch trong vùng, cách nhau 4.07 (3.77) giây. Đổi sang dạng thụ tinh sẽ ngừng đánh từ tháp, thay bằng 1 thụ tinh chặn địch và cận chiến gây sát thương pháo trong phạm vi 100, cách nhau 3 giây. Chỉ dùng được một dạng mỗi lúc.",
				enhanced = "Dạng tháp đập diện rộng lên địch mặt đất. Ở cấp 4, mỗi đòn gây sát thương pháo cho mọi địch trong vùng và thêm 2 lần chỉ số sát thương cho 1 địch ngẫu nhiên, cách nhau 4.07 (3.77) giây. Dạng thụ tinh ngừng đánh từ tháp, thay bằng 1 thụ tinh chặn địch, cận chiến gây sát thương pháo trong phạm vi 100 và thêm 2 lần chỉ số sát thương cho 1 địch ngẫu nhiên, cách nhau 3 giây. Chỉ dùng được một dạng mỗi lúc."
			},
			change_note = "", port_note = "", notes = "", skills = {
				{
					name = "Dị ứng phấn hoa",
					standard = "Phát tán phấn hoa, gây 32 sát thương chuẩn trong 4 giây và giảm 90% sát thương tấn công của địch. CD: 20 giây.",
					enhanced = "Phát tán phấn hoa, gây 32 sát thương chuẩn trong 4 giây, giảm 90% sát thương tấn công và giảm cả giáp lẫn kháng phép đi 20% giá trị ban đầu. CD: 20 giây.",
					levels_standard = { "Phát tán phấn hoa, gây 32 sát thương chuẩn trong 4 giây và giảm 90% sát thương tấn công của địch. CD: 20 giây.", "Phát tán phấn hoa, gây 72 sát thương chuẩn trong 6 giây và giảm 90% sát thương tấn công của địch. CD: 20 giây.", "Phát tán phấn hoa, gây 128 sát thương chuẩn trong 8 giây và giảm 90% sát thương tấn công của địch. CD: 20 giây." },
					levels_enhanced = { "Phát tán phấn hoa, gây 32 sát thương chuẩn trong 4 giây, giảm 90% sát thương tấn công và giảm cả giáp lẫn kháng phép đi 20% giá trị ban đầu. CD: 20 giây.", "Phát tán phấn hoa, gây 72 sát thương chuẩn trong 6 giây, giảm 90% sát thương tấn công và giảm cả giáp lẫn kháng phép đi 35% giá trị ban đầu. CD: 20 giây.", "Phát tán phấn hoa, gây 128 sát thương chuẩn trong 8 giây, giảm 90% sát thương tấn công và giảm cả giáp lẫn kháng phép đi 50% giá trị ban đầu. CD: 20 giây." },
					prices_standard = { "150", "150", "150" }, prices_enhanced = { "150", "150", "150" }
				},
				{
					name = "Bàn tay Thiên nhiên",
					standard = "Ở dạng thụ tinh, chôn một kẻ địch có máu tối đa không quá 1500. CD: 25 giây.",
					enhanced = "Ở dạng thụ tinh, chôn một kẻ địch có máu tối đa không quá 1500. CD: 25 giây.",
					levels_standard = { "Ở dạng thụ tinh, chôn một kẻ địch có máu tối đa không quá 1500. CD: 25 giây.", "Ở dạng thụ tinh, chôn một kẻ địch có máu tối đa không quá 2000. CD: 25 giây.", "Ở dạng thụ tinh, chôn một kẻ địch có máu tối đa không quá 2800. CD: 25 giây." },
					levels_enhanced = { "Ở dạng thụ tinh, chôn một kẻ địch có máu tối đa không quá 1500. CD: 25 giây.", "Ở dạng thụ tinh, chôn một kẻ địch có máu tối đa không quá 2000. CD: 25 giây.", "Ở dạng thụ tinh, chôn một kẻ địch có máu tối đa không quá 2800. CD: 25 giây." },
					prices_standard = { "300", "100", "100" }, prices_enhanced = { "300", "100", "100" }
				},
				{
					name = "Rễ cây chằng chịt",
					standard = "Ở dạng tháp, trói tối đa 4 địch trong 2 giây. CD: 14 giây.",
					enhanced = "Ở dạng tháp, trói tối đa 4 địch trong 2 giây. CD: 14 giây.",
					levels_standard = { "Ở dạng tháp, trói tối đa 4 địch trong 2 giây. CD: 14 giây.", "Ở dạng tháp, trói tối đa 5 địch trong 3 giây. CD: 14 giây.", "Ở dạng tháp, trói tối đa 6 địch trong 4 giây. CD: 14 giây." },
					levels_enhanced = { "Ở dạng tháp, trói tối đa 4 địch trong 2 giây. CD: 14 giây.", "Ở dạng tháp, trói tối đa 5 địch trong 3 giây. CD: 14 giây.", "Ở dạng tháp, trói tối đa 6 địch trong 4 giây. CD: 14 giây." },
					prices_standard = { "180", "100", "100" }, prices_enhanced = { "180", "100", "100" }
				},
				{
					name = "Mầm cây cáu kỉnh",
					standard = "Ném quả sồi gây 80-120 sát thương pháo và triệu hồi 3 mầm cây. Mỗi mầm có 60 máu, cận chiến gây 6-10 sát thương vật lý. CD: 35 giây.",
					enhanced = "Ném quả sồi gây 80-120 sát thương pháo và triệu hồi 3 mầm cây. Mỗi mầm có 60 máu, cận chiến gây 6-10 sát thương vật lý. CD: 35 giây.",
					levels_standard = { "Ném quả sồi gây 80-120 sát thương pháo và triệu hồi 3 mầm cây. Mỗi mầm có 60 máu, cận chiến gây 6-10 sát thương vật lý. CD: 35 giây." },
					levels_enhanced = { "Ném quả sồi gây 80-120 sát thương pháo và triệu hồi 3 mầm cây. Mỗi mầm có 60 máu, cận chiến gây 6-10 sát thương vật lý. CD: 35 giây." },
					prices_standard = { "0" }, prices_enhanced = { "0" }
				}
			}
		},
		["tower_wildcat_lvl4"] = {
			doc_id = "",
			title = "Nữ thợ săn Linh miêu",
			attack = {
				standard = "Cử 2 nữ thợ săn chặn địch; cận chiến và ném từ xa đều gây sát thương vật lý. Khoảng cách giữa đòn đánh: 1; tầm đánh xa: 350.",
				enhanced = "Cử 2 nữ thợ săn chặn địch; cận chiến và ném từ xa đều gây sát thương vật lý. Khoảng cách giữa đòn đánh: 1; tầm đánh xa: 350. Khi cận chiến, có 10/20/30/40% cơ hội né đòn."
			},
			change_note = "", port_note = "", notes = "", skills = {
				{
					name = "Phi đao bạc", standard = "Ném phi đao gây 18-28 sát thương vật lý, nảy 2 lần và không giảm sát thương. CD: 15 giây.", enhanced = "Ném phi đao gây 18-28 sát thương vật lý, nảy 2 lần và không giảm sát thương. CD: 15 giây.",
					levels_standard = { "Ném phi đao gây 18-28 sát thương vật lý, nảy 2 lần và không giảm sát thương. CD: 15 giây.", "Ném phi đao gây 32-46 sát thương vật lý, nảy 3 lần và không giảm sát thương. CD: 15 giây.", "Ném phi đao gây 38-56 sát thương vật lý, nảy 4 lần và không giảm sát thương. CD: 15 giây." },
					levels_enhanced = { "Ném phi đao gây 18-28 sát thương vật lý, nảy 2 lần và không giảm sát thương. CD: 15 giây.", "Ném phi đao gây 32-46 sát thương vật lý, nảy 3 lần và không giảm sát thương. CD: 15 giây.", "Ném phi đao gây 38-56 sát thương vật lý, nảy 4 lần và không giảm sát thương. CD: 15 giây." },
					prices_standard = { "120", "120", "120" }, prices_enhanced = { "120", "120", "120" }
				},
				{
					name = "Cú cắn chí mạng", standard = "Báo cắn gây 27-42 sát thương vật lý và thêm 48 sát thương theo thời gian trong 4 giây. CD: 12 giây.", enhanced = "Báo cắn gây 27-42 sát thương vật lý và thêm 48 sát thương theo thời gian trong 4 giây. CD: 12 giây.",
					levels_standard = { "Báo cắn gây 27-42 sát thương vật lý và thêm 48 sát thương theo thời gian trong 4 giây. CD: 12 giây.", "Báo cắn gây 80-120 sát thương vật lý và thêm 64 sát thương theo thời gian trong 4 giây. CD: 12 giây.", "Báo cắn gây 134-200 sát thương vật lý và thêm 80 sát thương theo thời gian trong 4 giây. CD: 12 giây." },
					levels_enhanced = { "Báo cắn gây 27-42 sát thương vật lý và thêm 48 sát thương theo thời gian trong 4 giây. CD: 12 giây.", "Báo cắn gây 80-120 sát thương vật lý và thêm 64 sát thương theo thời gian trong 4 giây. CD: 12 giây.", "Báo cắn gây 134-200 sát thương vật lý và thêm 80 sát thương theo thời gian trong 4 giây. CD: 12 giây." },
					prices_standard = { "160", "160", "160" }, prices_enhanced = { "160", "160", "160" }
				},
				{
					name = "Mưa tên Săn mồi", standard = "Bắn 8 mũi tên, mỗi mũi gây 14-22 sát thương vật lý. CD: 18 giây.", enhanced = "Hai thợ săn có thể dùng Mưa tên riêng biệt, mỗi người bắn 8 mũi tên, mỗi mũi gây 14-22 sát thương vật lý. CD riêng: 18 giây.",
					levels_standard = { "Một thợ săn bắn 8 mũi tên, mỗi mũi gây 14-22 sát thương vật lý. CD: 18 giây.", "Một thợ săn bắn 8 mũi tên, mỗi mũi gây 24-34 sát thương vật lý. CD: 18 giây.", "Một thợ săn bắn 8 mũi tên, mỗi mũi gây 30-44 sát thương vật lý. CD: 18 giây." },
					levels_enhanced = { "Hai thợ săn có thể dùng Mưa tên riêng biệt, mỗi người bắn 8 mũi tên, mỗi mũi gây 14-22 sát thương vật lý. CD riêng: 18 giây.", "Hai thợ săn có thể dùng Mưa tên riêng biệt, mỗi người bắn 10 mũi tên, mỗi mũi gây 24-34 sát thương vật lý. CD riêng: 18 giây.", "Hai thợ săn có thể dùng Mưa tên riêng biệt, mỗi người bắn 12 mũi tên, mỗi mũi gây 30-44 sát thương vật lý. CD riêng: 18 giây." },
					prices_standard = { "180", "180", "180" }, prices_enhanced = { "180", "180", "180" }
				},
				{
					name = "Vuốt săn Lén lút", standard = "Cử 4 báo tập kích, mỗi đòn gây 160-240 sát thương vật lý. CD: 35 giây.", enhanced = "Cử 4 báo tập kích, mỗi đòn gây 160-240 sát thương vật lý. CD: 35 giây.",
					levels_standard = { "Cử 4 báo tập kích, mỗi đòn gây 160-240 sát thương vật lý. CD: 35 giây." },
					levels_enhanced = { "Cử 4 báo tập kích, mỗi đòn gây 160-240 sát thương vật lý. CD: 35 giây." },
					prices_standard = { "0" }, prices_enhanced = { "0" }
				}
			}
		},
		["tower_alchemist_lvl4"] = {
			doc_id = "",
			title = "Lều Giả kim",
			attack = {
				standard = "Ném lọ thuốc, để lại vũng thuốc trong phạm vi 96. Mỗi 0.3 giây gây sát thương chuẩn theo chỉ số và làm chậm 40%, tồn tại 2/3/4/5 giây. Khoảng cách giữa lần ném: 3.8 (3.7) giây.",
				enhanced = "Ném lọ thuốc, để lại vũng thuốc trong phạm vi 96. Mỗi 0.3 giây gây sát thương chuẩn theo chỉ số và làm chậm 40%, tồn tại 2/3/4/5 giây. Khoảng cách giữa lần ném: 3.8 (3.7) giây."
			},
			change_note = "Nhà giả kim mượn sức mạnh từ pháp sư Shaman bên tế đàn lẫn Kỹ sư Hắc ám. Kết hợp hai nguồn sức mạnh này sẽ tạo nên điều gì?", port_note = "Có thể xem lượng vàng kiếm được từ tuyệt kỹ trong menu.", notes = "", skills = {
				{
					name = "Dịch nhầy bắn tóe", standard = "Phun 8 phần dịch nhầy, làm chậm địch trong vùng 40% suốt 5 giây. CD: 15 giây.", enhanced = "Phun 8 phần dịch nhầy, mỗi phần gây 25 sát thương chuẩn khi rơi xuống. Làm chậm địch trong vùng 40% suốt 5 giây; dịch nhầy còn lại không gây sát thương. CD: 15 giây.",
					levels_standard = { "Phun 8 phần dịch nhầy, làm chậm địch trong vùng 40% suốt 5 giây. CD: 15 giây.", "Phun 10 phần dịch nhầy, làm chậm địch trong vùng 55% suốt 6 giây. CD: 15 giây.", "Phun 12 phần dịch nhầy, làm chậm địch trong vùng 70% suốt 7 giây. CD: 15 giây." },
					levels_enhanced = { "Phun 8 phần dịch nhầy, mỗi phần gây 25 sát thương chuẩn khi rơi xuống. Làm chậm địch trong vùng 40% suốt 5 giây. CD: 15 giây.", "Phun 10 phần dịch nhầy, mỗi phần gây 40 sát thương chuẩn khi rơi xuống. Làm chậm địch trong vùng 55% suốt 6 giây. CD: 15 giây.", "Phun 12 phần dịch nhầy, mỗi phần gây 55 sát thương chuẩn khi rơi xuống. Làm chậm địch trong vùng 70% suốt 7 giây. CD: 15 giây." },
					prices_standard = { "100", "100", "100" }, prices_enhanced = { "250", "200", "200" }
				},
				{
					name = "Trợ lý thí nghiệm", standard = "Triệu hồi trợ lý chiến đấu 30 giây, có 150 máu, cận chiến gây 16-24 sát thương chuẩn. CD: 22 giây.", enhanced = "Triệu hồi trợ lý chiến đấu 30 giây, có 150 máu, cận chiến gây 16-24 sát thương chuẩn. CD: 22 giây.",
					levels_standard = { "Triệu hồi trợ lý chiến đấu 30 giây, có 150 máu, cận chiến gây 16-24 sát thương chuẩn. CD: 22 giây.", "Triệu hồi trợ lý chiến đấu 30 giây, có 180 máu, cận chiến gây 32-48 sát thương chuẩn. CD: 22 giây.", "Triệu hồi trợ lý chiến đấu 30 giây, có 210 máu, cận chiến gây 64-96 sát thương chuẩn. CD: 22 giây." },
					levels_enhanced = { "Triệu hồi trợ lý chiến đấu 30 giây, có 150 máu, cận chiến gây 16-24 sát thương chuẩn. CD: 22 giây.", "Triệu hồi trợ lý chiến đấu 30 giây, có 180 máu, cận chiến gây 32-48 sát thương chuẩn. CD: 22 giây.", "Triệu hồi trợ lý chiến đấu 30 giây, có 210 máu, cận chiến gây 64-96 sát thương chuẩn. CD: 22 giây." },
					prices_standard = { "150", "150", "150" }, prices_enhanced = { "150", "150", "150" }
				},
				{
					name = "Công thức hoàn hảo", standard = "Lọ thuốc nổ thêm gây 10-16 sát thương pháo. Thuốc gây 5-7 sát thương chuẩn mỗi 0.3 giây.", enhanced = "Lọ thuốc nổ thêm gây 10-16 sát thương pháo. Thuốc gây 5-7 sát thương chuẩn mỗi 0.3 giây.",
					levels_standard = { "Lọ thuốc nổ thêm gây 10-16 sát thương pháo. Thuốc gây 5-7 sát thương chuẩn mỗi 0.3 giây.", "Lọ thuốc nổ thêm gây 28-46 sát thương pháo. Thuốc gây 6-8 sát thương chuẩn mỗi 0.3 giây.", "Lọ thuốc nổ thêm gây 46-68 sát thương pháo. Thuốc gây 7-9 sát thương chuẩn mỗi 0.3 giây." },
					levels_enhanced = { "Lọ thuốc nổ thêm gây 10-16 sát thương pháo. Thuốc gây 5-7 sát thương chuẩn mỗi 0.3 giây.", "Lọ thuốc nổ thêm gây 28-46 sát thương pháo. Thuốc gây 6-8 sát thương chuẩn mỗi 0.3 giây.", "Lọ thuốc nổ thêm gây 46-68 sát thương pháo. Thuốc gây 7-9 sát thương chuẩn mỗi 0.3 giây." },
					prices_standard = { "200", "200", "200" }, prices_enhanced = { "200", "200", "200" }
				},
				{
					name = "Kiệt tác Tối thượng", standard = "Biến một địch có máu không quá 600 thành heo vàng trong 15 giây. Máu không đổi nhưng mất mọi khả năng kháng và kỹ năng. Hạ heo vàng nhận tiền thưởng ban đầu của địch cộng thêm 15 vàng. CD: 40 giây.", enhanced = "Biến một địch có máu không quá 600 thành heo vàng trong 15 giây. Máu không đổi nhưng mất mọi khả năng kháng và kỹ năng. Hạ heo vàng nhận tiền thưởng ban đầu của địch cộng thêm 15 vàng. CD: 40 giây.",
					levels_standard = { "Biến một địch có máu không quá 600 thành heo vàng trong 15 giây. Máu không đổi nhưng mất mọi khả năng kháng và kỹ năng. Hạ heo vàng nhận tiền thưởng ban đầu của địch cộng thêm 15 vàng. CD: 40 giây." },
					levels_enhanced = { "Biến một địch có máu không quá 600 thành heo vàng trong 15 giây. Máu không đổi nhưng mất mọi khả năng kháng và kỹ năng. Hạ heo vàng nhận tiền thưởng ban đầu của địch cộng thêm 15 vàng. CD: 40 giây." },
					prices_standard = { "0" }, prices_enhanced = { "0" }
				}
			}
		},
		["tower_forger_lvl4"] = {
			doc_id = "",
			title = "Thợ rèn Ảo thuật",
			attack = {
				standard = "Rèn và bắn vũ khí bí thuật, gây sát thương phép diện rộng trong phạm vi 100 khi trúng đích. Tích trữ tối đa 3 vũ khí.",
				enhanced = "Rèn và bắn vũ khí bí thuật, gây sát thương phép diện rộng trong phạm vi 100 khi trúng đích. Tích trữ tối đa 3 vũ khí."
			},
			change_note = "Tháp pháo phép đã đủ mạnh. Chỉ tăng hiệu quả so với giá của kỹ năng 2 và khả năng chọn mục tiêu của tuyệt kỹ.", port_note = "", notes = "", skills = {
				{
					name = "Cưa tròn Xé toạc", standard = "Thả 3 cưa tròn chạy dọc đường, mỗi cưa gây tổng cộng 60-90 sát thương phép. CD: 18 giây.", enhanced = "Thả 3 cưa tròn chạy dọc đường, mỗi cưa gây tổng cộng 60-90 sát thương phép. CD: 18 giây.",
					levels_standard = { "Thả 3 cưa tròn chạy dọc đường, mỗi cưa gây tổng cộng 60-90 sát thương phép. CD: 18 giây.", "Thả 3 cưa tròn chạy dọc đường, mỗi cưa gây tổng cộng 120-180 sát thương phép. CD: 18 giây.", "Thả 3 cưa tròn chạy dọc đường, mỗi cưa gây tổng cộng 180-270 sát thương phép. CD: 18 giây." },
					levels_enhanced = { "Thả 3 cưa tròn chạy dọc đường, mỗi cưa gây tổng cộng 60-90 sát thương phép. CD: 18 giây.", "Thả 3 cưa tròn chạy dọc đường, mỗi cưa gây tổng cộng 120-180 sát thương phép. CD: 18 giây.", "Thả 3 cưa tròn chạy dọc đường, mỗi cưa gây tổng cộng 180-270 sát thương phép. CD: 18 giây." },
					prices_standard = { "250", "250", "250" }, prices_enhanced = { "250", "250", "250" }
				},
				{
					name = "Vệ binh Quang lăng", standard = "Triệu hồi 2 tinh thể trong 10 giây. Mỗi tinh thể gây 32-48 sát thương phép mỗi giây, biến mất sau khi gây tổng cộng 100 sát thương. CD: 20 giây.", enhanced = "Triệu hồi 3 tinh thể trong 10 giây. Mỗi tinh thể gây 32-48 sát thương phép mỗi giây, biến mất sau khi gây tổng cộng 100 sát thương. CD: 20 giây.",
					levels_standard = { "Triệu hồi 2 tinh thể trong 10 giây. Mỗi tinh thể gây 32-48 sát thương phép mỗi giây, biến mất sau khi gây tổng cộng 100 sát thương. CD: 20 giây.", "Triệu hồi 2 tinh thể trong 10 giây. Mỗi tinh thể gây 64-96 sát thương phép mỗi giây, biến mất sau khi gây tổng cộng 200 sát thương. CD: 20 giây.", "Triệu hồi 2 tinh thể trong 10 giây. Mỗi tinh thể gây 96-144 sát thương phép mỗi giây, biến mất sau khi gây tổng cộng 300 sát thương. CD: 20 giây." },
					levels_enhanced = { "Triệu hồi 3 tinh thể trong 10 giây. Mỗi tinh thể gây 32-48 sát thương phép mỗi giây, biến mất sau khi gây tổng cộng 100 sát thương. CD: 20 giây.", "Triệu hồi 3 tinh thể trong 10 giây. Mỗi tinh thể gây 64-96 sát thương phép mỗi giây, biến mất sau khi gây tổng cộng 200 sát thương. CD: 20 giây.", "Triệu hồi 3 tinh thể trong 10 giây. Mỗi tinh thể gây 96-144 sát thương phép mỗi giây, biến mất sau khi gây tổng cộng 300 sát thương. CD: 20 giây." },
					prices_standard = { "160", "160", "160" }, prices_enhanced = { "190", "190", "190" }
				},
				{
					name = "Ngục Ánh sáng", standard = "Giam tối đa 2 địch trong 5 giây. CD: 26 giây.", enhanced = "Giam tối đa 2 địch trong 5 giây. CD: 26 giây.",
					levels_standard = { "Giam tối đa 2 địch trong 5 giây. CD: 26 giây.", "Giam tối đa 3 địch trong 7 giây. CD: 26 giây.", "Giam tối đa 4 địch trong 9 giây. CD: 26 giây." },
					levels_enhanced = { "Giam tối đa 2 địch trong 5 giây, khiến mục tiêu nhận thêm 20% sát thương. CD: 26 giây.", "Giam tối đa 3 địch trong 7 giây, khiến mục tiêu nhận thêm 25% sát thương. CD: 26 giây.", "Giam tối đa 4 địch trong 9 giây, khiến mục tiêu nhận thêm 30% sát thương. CD: 26 giây." },
					prices_standard = { "200", "200", "200" }, prices_enhanced = { "200", "200", "200" }
				},
				{
					name = "Bí thuật Nuốt chửng", standard = "Triệu hồi rồng nuốt một nhóm địch có tổng máu hiện tại 300-1200. CD: 40 giây.", enhanced = "Ưu tiên địch có kháng phép; triệu hồi rồng nuốt một nhóm có tổng máu hiện tại 300-1200. CD: 40 giây.",
					levels_standard = { "Triệu hồi rồng nuốt một nhóm địch có tổng máu hiện tại 300-1200. CD: 40 giây." },
					levels_enhanced = { "Ưu tiên địch có kháng phép; triệu hồi rồng nuốt một nhóm có tổng máu hiện tại 300-1200. CD: 40 giây." },
					prices_standard = { "0" }, prices_enhanced = { "0" }
				}
			}
		},
		["tower_crossbows_lvl4"] = {
			doc_id = "",
			title = "Nỏ thủ Nguyền rủa",
			attack = {
				standard = "Cứ 2.1 (2.0) giây bắn liên tiếp ba phát nỏ gây sát thương vật lý. Nếu mục tiêu chết, có thể chuyển sang địch gần đó.",
				enhanced = "Cứ 2.1 (2.0) giây bắn liên tiếp ba phát nỏ gây sát thương vật lý. Nếu mục tiêu chết, có thể chuyển sang địch gần đó."
			},
			change_note = "Hai kỹ năng gây sợ hãi và tên tiêu diệt tức thì ít hữu ích. Dùng cơ chế kích hoạt như tháp Chiêm tinh để tăng cơ hội gây sợ hãi; bổ sung hiệu ứng bù khi tên không tiêu diệt tức thì.", port_note = "", notes = "", skills = {
				{
					name = "Cuồng bạo Tha hóa", standard = "Nỏ thủ bắn liên thanh nhanh trong 4 giây. CD: 25 giây.", enhanced = "Nỏ thủ bắn liên thanh nhanh, mỗi tên gây 18-28 sát thương vật lý, kéo dài 4 giây. CD: 25 giây.",
					levels_standard = { "Nỏ thủ bắn liên thanh nhanh trong 4 giây. CD: 25 giây.", "Nỏ thủ bắn liên thanh nhanh trong 6 giây. CD: 25 giây.", "Nỏ thủ bắn liên thanh nhanh, mỗi tên gây 18-28 sát thương vật lý, kéo dài 9 giây. CD: 25 giây." },
					levels_enhanced = { "Nỏ thủ bắn liên thanh nhanh trong 4 giây. CD: 18 giây.", "Nỏ thủ bắn liên thanh nhanh trong 6 giây. CD: 18 giây.", "Nỏ thủ bắn liên thanh nhanh trong 9 giây. CD: 18 giây." },
					prices_standard = { "200", "200", "200" }, prices_enhanced = { "200", "200", "200" }
				},
				{
					name = "Mầm mống Sợ hãi", standard = "Khi hạ địch, phát tán sợ hãi, giảm 20% tốc độ di chuyển và 10% sát thương tấn công của địch gần đó trong 4 giây.", enhanced = "Đánh thường gây hoảng hồn trong 2 giây. Nếu mục tiêu bị hạ bởi bất kỳ nguồn nào trong thời gian này, phát tán sợ hãi, giảm 20% tốc độ di chuyển và 10% sát thương tấn công của địch gần đó trong 4 giây.",
					levels_standard = { "Khi hạ địch, phát tán sợ hãi, giảm 20% tốc độ di chuyển và 10% sát thương tấn công của địch gần đó trong 4 giây.", "Khi hạ địch, phát tán sợ hãi, giảm 35% tốc độ di chuyển và 25% sát thương tấn công của địch gần đó trong 6 giây.", "Khi hạ địch, phát tán sợ hãi, giảm 50% tốc độ di chuyển và 40% sát thương tấn công của địch gần đó trong 8 giây." },
					levels_enhanced = { "Đánh thường gây hoảng hồn trong 2 giây. Nếu mục tiêu bị hạ bởi bất kỳ nguồn nào trong thời gian này, phát tán sợ hãi, giảm 20% tốc độ di chuyển, 10% sát thương tấn công và gây 4 sát thương phép mỗi giây cho địch gần đó trong 4 giây.", "Đánh thường gây hoảng hồn trong 2.5 giây. Nếu mục tiêu bị hạ bởi bất kỳ nguồn nào trong thời gian này, phát tán sợ hãi, giảm 35% tốc độ di chuyển, 25% sát thương tấn công và gây 5 sát thương phép mỗi giây cho địch gần đó trong 6 giây.", "Đánh thường gây hoảng hồn trong 3 giây. Nếu mục tiêu bị hạ bởi bất kỳ nguồn nào trong thời gian này, phát tán sợ hãi, giảm 50% tốc độ di chuyển, 40% sát thương tấn công và gây 6 sát thương phép mỗi giây cho địch gần đó trong 8 giây." },
					prices_standard = { "150", "150", "150" }, prices_enhanced = { "150", "150", "150" }
				},
				{
					name = "Tên nỏ Nguyền rủa", standard = "Bắn tên nguyền rủa gây 120-180 sát thương chuẩn, có 10% cơ hội tiêu diệt tức thì. CD: 20 giây.", enhanced = "Bắn tên nguyền rủa gây 120-180 sát thương chuẩn, có 10% cơ hội tiêu diệt tức thì. Nếu không kích hoạt, gây thêm sát thương chuẩn bằng 50% sát thương cơ bản của đòn đó. CD: 20 giây.",
					levels_standard = { "Bắn tên nguyền rủa gây 120-180 sát thương chuẩn, có 10% cơ hội tiêu diệt tức thì. CD: 20 giây.", "Bắn tên nguyền rủa gây 240-360 sát thương chuẩn, có 25% cơ hội tiêu diệt tức thì. CD: 20 giây.", "Bắn tên nguyền rủa gây 360-540 sát thương chuẩn, có 40% cơ hội tiêu diệt tức thì. CD: 20 giây." },
					levels_enhanced = { "Bắn tên nguyền rủa gây 120-180 sát thương chuẩn, có 10% cơ hội tiêu diệt tức thì. Nếu không kích hoạt, phát tán sợ hãi: giảm 20% tốc độ di chuyển, 10% sát thương tấn công và gây 4 sát thương phép mỗi giây cho địch gần đó trong 4 giây. CD: 20 giây.", "Bắn tên nguyền rủa gây 240-360 sát thương chuẩn, có 25% cơ hội tiêu diệt tức thì. Nếu không kích hoạt, phát tán thêm sợ hãi: giảm 35% tốc độ di chuyển, 25% sát thương tấn công và gây 5 sát thương phép mỗi giây cho địch gần đó trong 6 giây. CD: 20 giây.", "Bắn tên nguyền rủa gây 360-540 sát thương chuẩn, có 40% cơ hội tiêu diệt tức thì. Nếu không kích hoạt, phát tán thêm sợ hãi: giảm 50% tốc độ di chuyển, 40% sát thương tấn công và gây 6 sát thương phép mỗi giây cho địch gần đó trong 8 giây. CD: 20 giây." },
					prices_standard = { "200", "200", "200" }, prices_enhanced = { "200", "200", "200" }
				},
				{
					name = "Kỵ sĩ Tử hồn", standard = "Triệu hồi Kỵ sĩ Tử hồn chiến đấu 30 giây, có 250 máu, 80% giáp vật lý và gây 32-48 sát thương vật lý cận chiến. CD: 36 giây.", enhanced = "Triệu hồi Kỵ sĩ Tử hồn chiến đấu 24 giây, có 444 máu, 94% giáp vật lý và gây 44-94 sát thương vật lý cận chiến. CD: 44 giây.",
					levels_standard = { "Triệu hồi Kỵ sĩ Tử hồn chiến đấu 30 giây, có 250 máu, 80% giáp vật lý và gây 32-48 sát thương vật lý cận chiến. CD: 36 giây." },
					levels_enhanced = { "Triệu hồi Kỵ sĩ Tử hồn chiến đấu 24 giây, có 444 máu, 94% giáp vật lý và gây 44-94 sát thương vật lý cận chiến. CD: 44 giây." },
					prices_standard = { "0" }, prices_enhanced = { "0" }
				}
			}
		},
		["tower_miners_lvl4"] = {
			doc_id = "",
			title = "Người Lùn Đãi vàng",
			attack = {
				standard = "Khi địch vào phạm vi tập kết, thợ mỏ chui lên chặn địch và cận chiến gây sát thương vật lý; tháp không trực tiếp bắn đạn. Tối đa 8 thợ mỏ cùng lúc, mỗi 5.7 giây thử bổ sung 1 người. Tổng các tháp Đãi vàng kiếm tối đa 300 vàng mỗi đợt.",
				enhanced = "Khi địch vào phạm vi tập kết, thợ mỏ chui lên chặn địch và cận chiến gây sát thương vật lý; tháp không trực tiếp bắn đạn. Tối đa 8 thợ mỏ cùng lúc, mỗi 5.7 giây thử bổ sung 1 người. Tổng các tháp Đãi vàng kiếm tối đa 750 vàng mỗi đợt."
			},
			change_note = "Cả ba kỹ năng giờ đều kiếm được vàng, thợ mỏ cũng có chỉ số cao hơn. Bạn có thu hồi được vốn không?", port_note = "Có thể xem lượng vàng kiếm được từ tuyệt kỹ trong menu.", notes = "", skills = {
				{
					name = "Đoàn thám hiểm Điên cuồng", standard = "Phóng xe mỏ gây 18-28 sát thương pháo khi va chạm, triệu hồi 2 thợ mỏ chiến đấu 15 giây. CD: 20 giây.", enhanced = "Phóng xe mỏ gây 18-28 sát thương pháo. Mỗi 1 địch bị va chạm cho thêm 10% tiền thưởng của địch đó, làm tròn lên. Triệu hồi 2 thợ mỏ chiến đấu 15 giây. CD: 20 giây.",
					levels_standard = { "Phóng xe mỏ gây 18-28 sát thương pháo khi va chạm, triệu hồi 2 thợ mỏ chiến đấu 15 giây. CD: 20 giây.", "Phóng xe mỏ gây 40-60 sát thương pháo khi va chạm, triệu hồi 2 thợ mỏ chiến đấu 15 giây. CD: 20 giây.", "Phóng xe mỏ gây 52-78 sát thương pháo khi va chạm, triệu hồi 2 thợ mỏ chiến đấu 15 giây. CD: 20 giây." },
					levels_enhanced = { "Phóng xe mỏ gây 18-28 sát thương pháo. Mỗi 1 địch bị va chạm cho thêm 10% tiền thưởng của địch đó, làm tròn lên. Triệu hồi 2 thợ mỏ chiến đấu 15 giây. CD: 20 giây.", "Phóng xe mỏ gây 40-60 sát thương pháo. Mỗi 1 địch bị va chạm cho thêm 20% tiền thưởng của địch đó, làm tròn lên. Triệu hồi 2 thợ mỏ chiến đấu 15 giây. CD: 20 giây.", "Phóng xe mỏ gây 52-78 sát thương pháo. Mỗi 1 địch bị va chạm cho thêm 30% tiền thưởng của địch đó, làm tròn lên. Triệu hồi 2 thợ mỏ chiến đấu 15 giây. CD: 20 giây." },
					prices_standard = { "150", "150", "150" }, prices_enhanced = { "350", "350", "350" }
				},
				{
					name = "Phá đất trồi lên", standard = "Thợ mỏ trồi lên gây 8-12 sát thương vật lý cho địch quanh đó và làm choáng 1 giây.", enhanced = "Thợ mỏ trồi lên gây 8-12 sát thương vật lý cho địch quanh đó và làm choáng 1 giây. Mỗi 1 địch bị choáng cho thêm 1 vàng.",
					levels_standard = { "Thợ mỏ trồi lên gây 8-12 sát thương vật lý cho địch quanh đó và làm choáng 1 giây.", "Thợ mỏ trồi lên gây 20-30 sát thương vật lý cho địch quanh đó và làm choáng 1.5 giây.", "Thợ mỏ trồi lên gây 32-48 sát thương vật lý cho địch quanh đó và làm choáng 2 giây." },
					levels_enhanced = { "Thợ mỏ trồi lên gây 8-12 sát thương vật lý cho địch quanh đó và làm choáng 1 giây. Mỗi 1 địch bị choáng cho thêm 1 vàng.", "Thợ mỏ trồi lên gây 20-30 sát thương vật lý cho địch quanh đó và làm choáng 1.5 giây. Mỗi 1 địch bị choáng cho thêm 2 vàng.", "Thợ mỏ trồi lên gây 32-48 sát thương vật lý cho địch quanh đó và làm choáng 2 giây. Mỗi 1 địch bị choáng cho thêm 3 vàng." },
					prices_standard = { "200", "200", "200" }, prices_enhanced = { "450", "450", "450" }
				},
				{
					name = "Luân phiên vào việc", standard = "Thợ mỏ vẫn tạo vàng khi vào giao tranh, mỗi lần bằng 1 lần lượng cơ bản.", enhanced = "Thợ mỏ vẫn tạo vàng khi vào giao tranh, mỗi lần bằng 1 lần lượng cơ bản.",
					levels_standard = { "Thợ mỏ vẫn tạo vàng khi vào giao tranh, mỗi lần bằng 1 lần lượng cơ bản.", "Thợ mỏ vẫn tạo vàng khi vào giao tranh, mỗi lần bằng 1.5 lần lượng cơ bản.", "Thợ mỏ vẫn tạo vàng khi vào giao tranh, mỗi lần bằng 2 lần lượng cơ bản." },
					levels_enhanced = { "Thợ mỏ vẫn tạo vàng khi vào giao tranh, mỗi lần bằng 1 lần lượng cơ bản.", "Thợ mỏ vẫn tạo vàng khi vào giao tranh, mỗi lần bằng 1.5 lần lượng cơ bản.", "Thợ mỏ vẫn tạo vàng khi vào giao tranh, mỗi lần bằng 2 lần lượng cơ bản." },
					prices_standard = { "250", "100", "100" }, prices_enhanced = { "250", "100", "100" }
				},
				{
					name = "Cơn sốt Vàng", standard = "Tạo thêm 72-96 vàng trong 1.5 giây. CD: 50 giây.", enhanced = "Tạo thêm 72-96 vàng trong 1.5 giây. CD: 50 giây.",
					levels_standard = { "Tạo thêm 72-96 vàng trong 1.5 giây. CD: 50 giây." },
					levels_enhanced = { "Tạo thêm 72-96 vàng trong 1.5 giây. CD: 50 giây." },
					prices_standard = { "0" }, prices_enhanced = { "0" }
				}
			}
		},
		["tower_sniper_lvl4"] = {
			doc_id = "",
			title = "Tháp canh Lính gác",
			attack = {
				standard = "Bắn tỉa cực xa, có thể chọn ưu tiên địch gần lối ra nhất hoặc có máu tối đa cao nhất. Tầm xa không giới hạn, nhưng phạm vi 150 quanh tháp là vùng không thể bắn. Khoảng cách giữa đòn đánh: 7.4 (7.0) giây.",
				enhanced = "Bắn tỉa cực xa, có thể chọn ưu tiên địch gần lối ra nhất hoặc có máu tối đa cao nhất. Tầm xa không giới hạn, nhưng phạm vi 150 quanh tháp là vùng không thể bắn. Khoảng cách giữa đòn đánh: 7.4 (7.0) giây. Cứ mỗi 12/8/5/3 điểm kháng phép của địch, đòn thường gây thêm sát thương vật lý bằng 1% máu tối đa của mục tiêu; giới hạn với trùm là 80/120/200/300."
			},
			change_note = "Bổ sung khả năng khắc chế địch kháng phép và tăng tác dụng kỹ năng Khí thế chiến đấu.", port_note = "", notes = "", skills = {
				{
					name = "Khí thế chiến đấu", standard = "Sau khi đánh thường hạ địch, phát bắn kế tiếp tăng 10% sát thương và giảm 25% khoảng cách giữa đòn đánh.", enhanced = "Sau khi mua, không cần hạ địch để kích hoạt: phát bắn kế tiếp tăng 10% sát thương, giảm 25% khoảng cách giữa đòn đánh, thêm sát thương vật lý bằng máu tối đa × kháng phép ÷ 2. Với trùm, tối đa 300 sát thương.",
					levels_standard = { "Sau khi đánh thường hạ địch, phát bắn kế tiếp tăng 10% sát thương và giảm 25% khoảng cách giữa đòn đánh.", "Sau khi đánh thường hạ địch, phát bắn kế tiếp tăng 25% sát thương và giảm 25% khoảng cách giữa đòn đánh.", "Sau khi đánh thường hạ địch, phát bắn kế tiếp tăng 40% sát thương và giảm 25% khoảng cách giữa đòn đánh." },
					levels_enhanced = { "Tăng 10% sát thương bắn và giảm 25% khoảng cách giữa đòn đánh.", "Tăng 25% sát thương bắn và giảm 25% khoảng cách giữa đòn đánh.", "Tăng 40% sát thương bắn và giảm 25% khoảng cách giữa đòn đánh." },
					prices_standard = { "150", "150", "150" }, prices_enhanced = { "150", "150", "150" }
				},
				{
					name = "Phát bắn Chí mạng", standard = "Bắn mục tiêu gây chảy máu, tổng cộng 128-160 sát thương chuẩn trong 4 giây. CD: 12 giây.", enhanced = "Bắn mục tiêu gây chảy máu, tổng cộng 128-160 sát thương chuẩn trong 4 giây. CD: 12 giây.",
					levels_standard = { "Bắn mục tiêu gây chảy máu, tổng cộng 128-160 sát thương chuẩn trong 4 giây. CD: 12 giây.", "Bắn mục tiêu gây chảy máu, tổng cộng 256-320 sát thương chuẩn trong 4 giây. CD: 12 giây.", "Bắn mục tiêu gây chảy máu, tổng cộng 384-480 sát thương chuẩn trong 4 giây. CD: 12 giây." },
					levels_enhanced = { "Bắn mục tiêu gây chảy máu, tổng cộng 128-160 sát thương chuẩn trong 4 giây. CD: 12 giây.", "Bắn mục tiêu gây chảy máu, tổng cộng 256-320 sát thương chuẩn trong 4 giây. CD: 12 giây.", "Bắn mục tiêu gây chảy máu, tổng cộng 384-480 sát thương chuẩn trong 4 giây. CD: 12 giây." },
					prices_standard = { "200", "200", "200" }, prices_enhanced = { "200", "200", "200" }
				},
				{
					name = "Chó săn Hộ vệ", standard = "Cử chó săn đánh địch ở gần, mỗi lần gây 22-30 sát thương vật lý, toàn lượt gây 66-90. CD: 6 giây.", enhanced = "Cử chó săn đánh địch ở gần, mỗi lần gây 22-30 sát thương vật lý, toàn lượt gây 66-90. CD: 6 giây.",
					levels_standard = { "Cử chó săn đánh địch ở gần, mỗi lần gây 22-30 sát thương vật lý, toàn lượt gây 66-90. CD: 6 giây.", "Cử chó săn đánh địch ở gần, mỗi lần gây 46-58 sát thương vật lý, toàn lượt gây 138-177. CD: 6 giây.", "Cử chó săn đánh địch ở gần, mỗi lần gây 68-88 sát thương vật lý, toàn lượt gây 204-264. CD: 6 giây." },
					levels_enhanced = { "Cử chó săn đánh địch ở gần, mỗi lần gây 22-30 sát thương vật lý, toàn lượt gây 66-90. CD: 6 giây.", "Cử chó săn đánh địch ở gần, mỗi lần gây 46-58 sát thương vật lý, toàn lượt gây 138-177. CD: 6 giây.", "Cử chó săn đánh địch ở gần, mỗi lần gây 68-88 sát thương vật lý, toàn lượt gây 204-264. CD: 6 giây." },
					prices_standard = { "180", "180", "180" }, prices_enhanced = { "180", "180", "180" }
				},
				{
					name = "Bắn nhanh ba phát", standard = "Bắn liên tiếp 3 viên đạn, mỗi viên gây 110% sát thương phát bắn thường. CD: 50 giây.", enhanced = "Bắn liên tiếp 3 viên đạn, mỗi viên gây 110% sát thương phát bắn thường và thêm sát thương vật lý bằng máu tối đa của mục tiêu × kháng phép ÷ 3. Với trùm, tối đa 300 mỗi viên. CD: 50 giây.",
					levels_standard = { "Bắn liên tiếp 3 viên đạn, mỗi viên gây 110% sát thương phát bắn thường. CD: 50 giây." },
					levels_enhanced = { "Bắn liên tiếp 3 viên đạn, mỗi viên gây 110% sát thương phát bắn thường và thêm sát thương vật lý bằng máu tối đa của mục tiêu × kháng phép ÷ 3. Với trùm, tối đa 300 mỗi viên. CD: 50 giây." },
					prices_standard = { "0" }, prices_enhanced = { "0" }
				}
			}
		},
	}
}

return M
