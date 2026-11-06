-- Baked from the user HAVE_UTL geometry and original skin09 BIN/ANM/mesh VFX.
local M={model_units=.42}
M.textures={"go_volibear_native_idle_p01","go_volibear_native_run_p01","go_volibear_native_attack1_p01","go_volibear_native_attack2_p01","go_volibear_native_q_intro_p01","go_volibear_native_q_run_p01","go_volibear_native_q_idle_p01","go_volibear_native_q_attack_p01","go_volibear_native_q_outro_p01","go_volibear_native_w_slash_p01","go_volibear_native_e_windup_p01","go_volibear_native_e_channel_p01","go_volibear_native_e_idle_p01","go_volibear_native_death_p01","go_volibear_native_knockup_p01","go_volibear_native_idle8_e_p01","go_volibear_native_idle8_ne_p01","go_volibear_native_idle8_n_p01","go_volibear_native_idle8_nw_p01","go_volibear_native_idle8_w_p01","go_volibear_native_idle8_sw_p01","go_volibear_native_idle8_s_p01","go_volibear_native_idle8_se_p01","go_volibear_native_walk8_e_p01","go_volibear_native_walk8_ne_p01","go_volibear_native_walk8_n_p01","go_volibear_native_walk8_nw_p01","go_volibear_native_walk8_w_p01","go_volibear_native_walk8_sw_p01","go_volibear_native_walk8_s_p01","go_volibear_native_walk8_se_p01","go_volibear_native_qrun8_e_p01","go_volibear_native_qrun8_ne_p01","go_volibear_native_qrun8_n_p01","go_volibear_native_qrun8_nw_p01","go_volibear_native_qrun8_w_p01","go_volibear_native_qrun8_sw_p01","go_volibear_native_qrun8_s_p01","go_volibear_native_qrun8_se_p01","go_fx_volibear_native_e_aoe_warning_p01","go_fx_volibear_native_e_aoe_warning_p02","go_fx_volibear_native_r_aoe_warning_p01","go_fx_volibear_native_q_hit_p01","go_fx_volibear_native_basicattack_hit_right_p01","go_fx_volibear_native_w_marked_scratch_p01","go_fx_volibear_native_passive_hitflash_01_p01","go_fx_volibear_native_w_hit_01_p01","go_fx_volibear_native_e_hit_01_p01","go_fx_volibear_native_q_pawprints_p01","go_fx_volibear_native_r_leapgroundshadow_p01","go_fx_volibear_native_r_impact_dust_a_p01","go_fx_volibear_native_e_aoe_ground_p01","go_fx_volibear_native_e_aoe_atmosphere_p01","go_fx_volibear_native_r_landingimpact_01_ground_p01","go_fx_volibear_native_r_landingimpact_01_atmosphere_p01","go_volibear_native_respawn_p01","go_fx_volibear_native_w_chomp_head_p01","go_fx_volibear_native_passive_chainlightning_strip_p01","go_volibear_native_r_cast_visualfix_p01","go_volibear_native_r_impact_visualfix_p01","go_volibear_native_r_impact_visualfix_p02","go_volibear_native_r_outro_visualfix_p01","go_volibear_native_r_run_visualfix_p01","go_volibear_native_r_idle_visualfix_p01","go_volibear_native_r_idle_visualfix_p02","go_volibear_native_r_idle_visualfix_p03","go_volibear_native_r_idle_visualfix_p04","go_volibear_native_r_attack1_visualfix_p01","go_volibear_native_r_attack2_visualfix_p01","go_volibear_native_rq_intro_visualfix_p01","go_volibear_native_rq_idle_visualfix_p01","go_volibear_native_rq_run_visualfix_p01","go_volibear_native_rq_attack_visualfix_p01","go_volibear_native_rq_outro_visualfix_p01","go_volibear_native_rrun8_e_visualfix_p01","go_volibear_native_rrun8_ne_visualfix_p01","go_volibear_native_rrun8_n_visualfix_p01","go_volibear_native_rrun8_nw_visualfix_p01","go_volibear_native_rrun8_w_visualfix_p01","go_volibear_native_rrun8_sw_visualfix_p01","go_volibear_native_rrun8_s_visualfix_p01","go_volibear_native_rrun8_se_visualfix_p01","go_volibear_native_ridle8_e_visualfix_p01","go_volibear_native_ridle8_e_visualfix_p02","go_volibear_native_ridle8_e_visualfix_p03","go_volibear_native_ridle8_e_visualfix_p04","go_volibear_native_ridle8_ne_visualfix_p01","go_volibear_native_ridle8_ne_visualfix_p02","go_volibear_native_ridle8_ne_visualfix_p03","go_volibear_native_ridle8_ne_visualfix_p04","go_volibear_native_ridle8_n_visualfix_p01","go_volibear_native_ridle8_n_visualfix_p02","go_volibear_native_ridle8_n_visualfix_p03","go_volibear_native_ridle8_n_visualfix_p04","go_volibear_native_ridle8_nw_visualfix_p01","go_volibear_native_ridle8_nw_visualfix_p02","go_volibear_native_ridle8_nw_visualfix_p03","go_volibear_native_ridle8_nw_visualfix_p04","go_volibear_native_ridle8_w_visualfix_p01","go_volibear_native_ridle8_w_visualfix_p02","go_volibear_native_ridle8_w_visualfix_p03","go_volibear_native_ridle8_w_visualfix_p04","go_volibear_native_ridle8_sw_visualfix_p01","go_volibear_native_ridle8_sw_visualfix_p02","go_volibear_native_ridle8_sw_visualfix_p03","go_volibear_native_ridle8_sw_visualfix_p04","go_volibear_native_ridle8_s_visualfix_p01","go_volibear_native_ridle8_s_visualfix_p02","go_volibear_native_ridle8_s_visualfix_p03","go_volibear_native_ridle8_s_visualfix_p04","go_volibear_native_ridle8_se_visualfix_p01","go_volibear_native_ridle8_se_visualfix_p02","go_volibear_native_ridle8_se_visualfix_p03","go_volibear_native_ridle8_se_visualfix_p04","go_volibear_native_rw_slash_visualfix_p01","go_volibear_native_re_idle_visualfix_p01","go_volibear_native_re_idle_visualfix_p02","go_volibear_native_rqrun8_e_visualfix_p01","go_volibear_native_rqrun8_ne_visualfix_p01","go_volibear_native_rqrun8_n_visualfix_p01","go_volibear_native_rqrun8_nw_visualfix_p01","go_volibear_native_rqrun8_w_visualfix_p01","go_volibear_native_rqrun8_sw_visualfix_p01","go_volibear_native_rqrun8_s_visualfix_p01","go_volibear_native_rqrun8_se_visualfix_p01","go_fx_volibear_native_passive_back_base_visualfix_p01","go_fx_volibear_native_passive_back_e_visualfix_p01","go_fx_volibear_native_passive_back_ne_visualfix_p01","go_fx_volibear_native_passive_back_n_visualfix_p01","go_fx_volibear_native_passive_back_nw_visualfix_p01","go_fx_volibear_native_passive_back_w_visualfix_p01","go_fx_volibear_native_passive_back_sw_visualfix_p01","go_fx_volibear_native_passive_back_s_visualfix_p01","go_fx_volibear_native_passive_back_se_visualfix_p01","go_fx_volibear_native_e_shield_bubble_visualfix_p01","go_fx_volibear_native_e_shield_bubble_visualfix_p02","go_fx_volibear_native_e_shield_bubble_visualfix_p03","go_fx_volibear_native_e_shield_bubble_visualfix_p04","go_fx_volibear_native_e_shield_bubble_visualfix_p05","go_fx_volibear_native_passive_hand_l_base_handsfix_p01","go_fx_volibear_native_passive_hand_r_base_handsfix_p01","go_fx_volibear_native_passive_hand_l_e_handsfix_p01","go_fx_volibear_native_passive_hand_r_e_handsfix_p01","go_fx_volibear_native_passive_hand_l_ne_handsfix_p01","go_fx_volibear_native_passive_hand_r_ne_handsfix_p01","go_fx_volibear_native_passive_hand_l_n_handsfix_p01","go_fx_volibear_native_passive_hand_r_n_handsfix_p01","go_fx_volibear_native_passive_hand_l_nw_handsfix_p01","go_fx_volibear_native_passive_hand_r_nw_handsfix_p01","go_fx_volibear_native_passive_hand_l_w_handsfix_p01","go_fx_volibear_native_passive_hand_r_w_handsfix_p01","go_fx_volibear_native_passive_hand_l_sw_handsfix_p01","go_fx_volibear_native_passive_hand_r_sw_handsfix_p01","go_fx_volibear_native_passive_hand_l_s_handsfix_p01","go_fx_volibear_native_passive_hand_r_s_handsfix_p01","go_fx_volibear_native_passive_hand_l_se_handsfix_p01","go_fx_volibear_native_passive_hand_r_se_handsfix_p01","go_fx_volibear_native_passive_target_shock_shockfix_p01"}
M.textures[#M.textures+1]='go_fx_volibear_prestige_q_trail'
M.textures[#M.textures+1]='go_fx_volibear_prestige_r_smoke'
M.clips={
 idle={count=48,duration=3,world=650,x=0.5,y=0.3267948},
 run={count=19,duration=1.1333335638046265,world=650,x=0.5,y=0.3267948},
 attack1={count=22,duration=1.3666666746139526,world=650,x=0.5,y=0.3267948},
 attack2={count=22,duration=1.3666666746139526,world=650,x=0.5,y=0.3267948},
 q_intro={count=16,duration=1,world=650,x=0.5,y=0.3267948},
 q_run={count=11,duration=0.6666668057441711,world=650,x=0.5,y=0.3267948},
 q_idle={count=32,duration=1.9999994039535522,world=650,x=0.5,y=0.3267948},
 q_attack={count=8,duration=0.5,world=1040,x=0.5,y=0.39174676},
 q_outro={count=38,duration=2.3333332538604736,world=650,x=0.5,y=0.3267948},
 w_slash={count=21,duration=1.2666667699813843,world=650,x=0.5,y=0.3267948},
 e_windup={count=7,duration=0.4000000059604645,world=650,x=0.5,y=0.3267948},
 e_channel={count=48,duration=3.999997615814209,world=650,x=0.5,y=0.3267948},
 e_idle={count=46,duration=2.866666555404663,world=650,x=0.5,y=0.3267948},
 r_cast={count=1,duration=0.03333333507180214,world=1100,x=0.5,y=0.26381135,canvas=512},
 r_impact={count=17,duration=1.0000003576278687,world=1100,x=0.5,y=0.26381135,canvas=512},
 r_outro={count=6,duration=0.3333333432674408,world=650,x=0.5,y=0.3267948,canvas=320},
 r_run={count=19,duration=1.1333333253860474,world=650,x=0.5,y=0.3267948,canvas=320},
 r_idle={count=160,duration=10,world=650,x=0.5,y=0.3267948,canvas=320},
 r_attack1={count=22,duration=1.3666666746139526,world=650,x=0.5,y=0.3267948,canvas=320},
 r_attack2={count=23,duration=1.399999976158142,world=650,x=0.5,y=0.3267948,canvas=320},
 rq_intro={count=16,duration=1,world=650,x=0.5,y=0.3267948,canvas=320},
 rq_idle={count=32,duration=2,world=650,x=0.5,y=0.3267948,canvas=320},
 rq_run={count=12,duration=0.7000001668930054,world=650,x=0.5,y=0.3267948,canvas=320},
 rq_attack={count=8,duration=0.5,world=1040,x=0.5,y=0.39174676,canvas=512},
 rq_outro={count=38,duration=2.3333332538604736,world=650,x=0.5,y=0.3267948,canvas=320},
 death={count=48,duration=4.966663360595703,world=650,x=0.5,y=0.3267948},
 knockup={count=15,duration=0.933333694934845,world=650,x=0.5,y=0.3267948},
 idle8_e={count=48,duration=3,world=650,x=0.5,y=0.3267948},
 idle8_ne={count=48,duration=3,world=650,x=0.5,y=0.3267948},
 idle8_n={count=48,duration=3,world=650,x=0.5,y=0.3267948},
 idle8_nw={count=48,duration=3,world=650,x=0.5,y=0.3267948},
 idle8_w={count=48,duration=3,world=650,x=0.5,y=0.3267948},
 idle8_sw={count=48,duration=3,world=650,x=0.5,y=0.3267948},
 idle8_s={count=48,duration=3,world=650,x=0.5,y=0.3267948},
 idle8_se={count=48,duration=3,world=650,x=0.5,y=0.3267948},
 walk8_e={count=24,duration=1.1333335638046265,world=650,x=0.5,y=0.3267948},
 walk8_ne={count=24,duration=1.1333335638046265,world=650,x=0.5,y=0.3267948},
 walk8_n={count=24,duration=1.1333335638046265,world=650,x=0.5,y=0.3267948},
 walk8_nw={count=24,duration=1.1333335638046265,world=650,x=0.5,y=0.3267948},
 walk8_w={count=24,duration=1.1333335638046265,world=650,x=0.5,y=0.3267948},
 walk8_sw={count=24,duration=1.1333335638046265,world=650,x=0.5,y=0.3267948},
 walk8_s={count=24,duration=1.1333335638046265,world=650,x=0.5,y=0.3267948},
 walk8_se={count=24,duration=1.1333335638046265,world=650,x=0.5,y=0.3267948},
 qrun8_e={count=24,duration=0.6666668057441711,world=650,x=0.5,y=0.3267948},
 qrun8_ne={count=24,duration=0.6666668057441711,world=650,x=0.5,y=0.3267948},
 qrun8_n={count=24,duration=0.6666668057441711,world=650,x=0.5,y=0.3267948},
 qrun8_nw={count=24,duration=0.6666668057441711,world=650,x=0.5,y=0.3267948},
 qrun8_w={count=24,duration=0.6666668057441711,world=650,x=0.5,y=0.3267948},
 qrun8_sw={count=24,duration=0.6666668057441711,world=650,x=0.5,y=0.3267948},
 qrun8_s={count=24,duration=0.6666668057441711,world=650,x=0.5,y=0.3267948},
 qrun8_se={count=24,duration=0.6666668057441711,world=650,x=0.5,y=0.3267948},
 rrun8_e={count=24,duration=1.1333333253860474,world=650,x=0.5,y=0.3267948,canvas=320},
 rrun8_ne={count=24,duration=1.1333333253860474,world=650,x=0.5,y=0.3267948,canvas=320},
 rrun8_n={count=24,duration=1.1333333253860474,world=650,x=0.5,y=0.3267948,canvas=320},
 rrun8_nw={count=24,duration=1.1333333253860474,world=650,x=0.5,y=0.3267948,canvas=320},
 rrun8_w={count=24,duration=1.1333333253860474,world=650,x=0.5,y=0.3267948,canvas=320},
 rrun8_sw={count=24,duration=1.1333333253860474,world=650,x=0.5,y=0.3267948,canvas=320},
 rrun8_s={count=24,duration=1.1333333253860474,world=650,x=0.5,y=0.3267948,canvas=320},
 rrun8_se={count=24,duration=1.1333333253860474,world=650,x=0.5,y=0.3267948,canvas=320},
 ridle8_e={count=160,duration=10,world=650,x=0.5,y=0.3267948,canvas=320},
 ridle8_ne={count=160,duration=10,world=650,x=0.5,y=0.3267948,canvas=320},
 ridle8_n={count=160,duration=10,world=650,x=0.5,y=0.3267948,canvas=320},
 ridle8_nw={count=160,duration=10,world=650,x=0.5,y=0.3267948,canvas=320},
 ridle8_w={count=160,duration=10,world=650,x=0.5,y=0.3267948,canvas=320},
 ridle8_sw={count=160,duration=10,world=650,x=0.5,y=0.3267948,canvas=320},
 ridle8_s={count=160,duration=10,world=650,x=0.5,y=0.3267948,canvas=320},
 ridle8_se={count=160,duration=10,world=650,x=0.5,y=0.3267948,canvas=320},
 rw_slash={count=21,duration=1.2666667699813843,world=650,x=0.5,y=0.3267948,canvas=320},
 re_idle={count=46,duration=2.866666555404663,world=650,x=0.5,y=0.3267948,canvas=320},
 rqrun8_e={count=24,duration=0.7000001668930054,world=650,x=0.5,y=0.3267948,canvas=320},
 rqrun8_ne={count=24,duration=0.7000001668930054,world=650,x=0.5,y=0.3267948,canvas=320},
 rqrun8_n={count=24,duration=0.7000001668930054,world=650,x=0.5,y=0.3267948,canvas=320},
 rqrun8_nw={count=24,duration=0.7000001668930054,world=650,x=0.5,y=0.3267948,canvas=320},
 rqrun8_w={count=24,duration=0.7000001668930054,world=650,x=0.5,y=0.3267948,canvas=320},
 rqrun8_sw={count=24,duration=0.7000001668930054,world=650,x=0.5,y=0.3267948,canvas=320},
 rqrun8_s={count=24,duration=0.7000001668930054,world=650,x=0.5,y=0.3267948,canvas=320},
 rqrun8_se={count=24,duration=0.7000001668930054,world=650,x=0.5,y=0.3267948,canvas=320},
 respawn={count=48,duration=2.9999985694885254,world=650,x=0.5,y=0.3267948},
}
M.effects={
 passive_target_shock={count=18,duration=0.6,world=359.8180847167969,x=0.5,y=0.50000036,canvas=192},
 passive_hand_l_base={count=36,duration=1.8,world=400,x=0.50000036,y=0.49999994,canvas=192},
 passive_hand_r_base={count=36,duration=1.8,world=400,x=0.49999973,y=0.49999976,canvas=192},
 passive_hand_l_e={count=36,duration=1.8,world=400,x=0.49999994,y=0.4999999,canvas=192},
 passive_hand_r_e={count=36,duration=1.8,world=400,x=0.49999994,y=0.50000024,canvas=192},
 passive_hand_l_ne={count=36,duration=1.8,world=400,x=0.5,y=0.50000036,canvas=192},
 passive_hand_r_ne={count=36,duration=1.8,world=400,x=0.5000006,y=0.50000024,canvas=192},
 passive_hand_l_n={count=36,duration=1.8,world=400,x=0.49999973,y=0.49999976,canvas=192},
 passive_hand_r_n={count=36,duration=1.8,world=400,x=0.5000001,y=0.49999997,canvas=192},
 passive_hand_l_nw={count=36,duration=1.8,world=400,x=0.5,y=0.49999994,canvas=192},
 passive_hand_r_nw={count=36,duration=1.8,world=400,x=0.5000004,y=0.49999988,canvas=192},
 passive_hand_l_w={count=36,duration=1.8,world=400,x=0.49999976,y=0.49999964,canvas=192},
 passive_hand_r_w={count=36,duration=1.8,world=400,x=0.50000006,y=0.49999973,canvas=192},
 passive_hand_l_sw={count=36,duration=1.8,world=400,x=0.50000024,y=0.49999988,canvas=192},
 passive_hand_r_sw={count=36,duration=1.8,world=400,x=0.5000003,y=0.5,canvas=192},
 passive_hand_l_s={count=36,duration=1.8,world=400,x=0.5000006,y=0.5000001,canvas=192},
 passive_hand_r_s={count=36,duration=1.8,world=400,x=0.50000024,y=0.5,canvas=192},
 passive_hand_l_se={count=36,duration=1.8,world=400,x=0.50000006,y=0.49999997,canvas=192},
 passive_hand_r_se={count=36,duration=1.8,world=400,x=0.49999958,y=0.5000001,canvas=192},
 passive_back_base={count=36,duration=1.8,world=500,x=0.49999982,y=0.50000006},
 passive_back_e={count=36,duration=1.8,world=500,x=0.49999982,y=0.5000001},
 passive_back_ne={count=36,duration=1.8,world=500,x=0.5000001,y=0.5000002},
 passive_back_n={count=36,duration=1.8,world=500,x=0.50000024,y=0.49999976},
 passive_back_nw={count=36,duration=1.8,world=500,x=0.49999973,y=0.5000002},
 passive_back_w={count=36,duration=1.8,world=500,x=0.5000004,y=0.5000001},
 passive_back_sw={count=36,duration=1.8,world=500,x=0.49999988,y=0.4999998},
 passive_back_s={count=36,duration=1.8,world=500,x=0.5,y=0.49999997},
 passive_back_se={count=36,duration=1.8,world=500,x=0.50000024,y=0.49999985},
 e_aoe_warning={count=52,duration=3.25,world=1470.5975341796875,x=0.5,y=0.25708142},
 r_aoe_warning={count=39,duration=2.4000000953674316,world=1156.5521240234375,x=0.5,y=0.5000001},
 q_hit={count=48,duration=3,world=1471.8431396484375,x=0.5,y=0.44116056},
 basicattack_hit_right={count=21,duration=1.2999999523162842,world=359.8180847167969,x=0.5,y=0.50000036},
 w_marked_scratch={count=64,duration=6,world=787.6426391601562,x=0.5,y=0.4268822},
 passive_hitflash_01={count=23,duration=1.399999976158142,world=359.8180847167969,x=0.5,y=0.50000036},
 w_hit_01={count=52,duration=3.2000000029802322,world=921.13427734375,x=0.5,y=0.5000001},
 e_hit_01={count=54,duration=3.3499999940395355,world=921.13427734375,x=0.5,y=0.5000001},
 q_pawprints={count=24,duration=1.5,world=359.8180847167969,x=0.5,y=0.50000036},
 q_trail={count=1,duration=.24,world=256,x=.5,y=0},
 r_smoke={count=24,duration=1.5,world=650,x=.5,y=.5},
 r_leapgroundshadow={count=16,duration=1,world=363.5395202636719,x=0.49353284,y=0.49554953},
 r_impact_dust_a={count=20,duration=1.2000000476837158,world=1196.48876953125,x=0.5,y=0.46091458},
 e_aoe_ground={count=56,duration=3.5,world=921.13427734375,x=0.5,y=0.5000001},
 e_aoe_atmosphere={count=56,duration=3.5,world=3828.76416015625,x=0.5,y=0.47738108},
 r_landingimpact_01_ground={count=28,duration=1.7200000584125519,world=1473.8148193359375,x=0.5,y=0.50000006},
 r_landingimpact_01_atmosphere={count=28,duration=1.7200000584125519,world=6467.279296875,x=0.4999999,y=0.48272577},
 e_shield_bubble={count=50,duration=3.100000001490116,world=359.8180847167969,x=0.5,y=0.5},
 w_chomp_head={count=20,duration=1.2000000029802322,world=822.9446411132812,x=0.4257184,y=0.41836196},
 passive_chainlightning_strip={count=16,duration=1,world=921.13427734375,x=0.5,y=0.5},
}
local function animation(prefix,info,ticks)
 local frames={};ticks=ticks or math.max(1,math.floor(info.duration*FPS+.5))
 for i=0,ticks-1 do frames[i+1]=math.floor(i*info.count/ticks)+1 end
 return {prefix=prefix,frames=frames}
end
local function contact(a,pose,fraction)
 local n=#a.frames;local last=a.frames[n];local at=math.floor(n*fraction)+1
 for i=1,n do a.frames[i]=i<=at and 1+math.floor((pose-1)*(i-1)/(at-1)+.5) or pose+math.ceil((last-pose)*(i-at)/(n-at)) end
end
function M.register(prefix,A)
 for tag,info in pairs(M.clips)do if tag~='jump' and tag~='land' then A.db[prefix..'_'..tag]=animation('volibear_native_'..tag,info) end end
 for _,pair in ipairs({{'r_attack1','attack1'},{'r_attack2','attack2'},{'rw_slash','w_slash'},{'re_idle','e_idle'},{'rq_intro','q_intro'},{'rq_attack','q_attack'},{'rq_outro','q_outro'}})do
  A.db[prefix..'_'..pair[1]]=animation('volibear_native_'..pair[1],M.clips[pair[1]],#A.db[prefix..'_'..pair[2]].frames)
 end
 for _,spec in ipairs({{'attack1',6,.35},{'attack2',7,.35},{'w_slash',6,1/3},{'r_attack1',6,.35},{'r_attack2',7,.35},{'rw_slash',6,1/3}})do contact(A.db[prefix..'_'..spec[1]],spec[2],spec[3]) end
 for _,tag in ipairs({'q_attack','rq_attack'})do A.db[prefix..'_'..tag].frames={1,2,2,3,4,5,6,7,7,8,8,8,8,8,8} end
 for target,source in pairs({attack='attack1',w='w_slash',walk='run',walkUp='run',walkDown='run',levelup='idle'})do A.db[prefix..'_'..target]=A.db[prefix..'_'..source] end
 local impact=A.db[prefix..'_r_impact'];local airborne,landing={},{}
 for _,frame in ipairs(impact.frames)do local frames=frame<=12 and airborne or landing;frames[#frames+1]=frame end
 A.db[prefix..'_jump']={prefix=impact.prefix,frames=airborne};A.db[prefix..'_land']={prefix=impact.prefix,frames=landing}
 M.clips.jump=M.clips.r_impact;M.clips.land=M.clips.r_impact
end
function M.register_fx(A)
 for tag,info in pairs(M.effects)do A.db['voli_native_fx_'..tag]=animation('fx_volibear_native_'..tag,info) end
end
return M
