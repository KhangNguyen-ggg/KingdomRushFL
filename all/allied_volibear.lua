-- LoL level-20 base with custom buffs; distances use 1 LoL unit = 0.25 KR units.
local C,E,A,U,V,bit
local FX=require("volibear_original_vfx")
local Movement=require("volibear_movement")
local function round(n) return math.floor(n+0.5) end
local growth=19*(0.7025+0.0175*19)
local stats={hp=round(650+104*growth),ad=round(65+3.5*growth),armor=round(35+5.2*growth),mr=round(32+2.05*growth),
 hp_regen=round((9+0.75*growth)/5),speed=85,
 attacks_per_minute=round((0.625+0.7*0.02*growth)*60),passive_damage=74}
stats.armor_percent,stats.mr_percent=65,40
local M={name="hero_allied_volibear_prestige",kind="volibear_prestige",source="enemy_set",
 title="Volibear Long Trảo - Cấp 20",hero_class="LoL 20 - Lôi Long",icon="encyclopedia_creep_thumbs_volibear_prestige",custom_portrait=true,
 textures={"ui_volibear_lol20"},sounds={},stats=stats,
 preview_stats={health={hp_max=stats.hp,armor=stats.armor_percent/100,magic_armor=stats.mr_percent/100},melee={attacks={{damage_min=stats.ad,damage_max=stats.ad}}}},
 skill={label="R",cooldown=50,range=175,description="Thần Lôi Giáng Thế: nhảy, gây 700 sát thương vật lý ở tâm; làm chậm xung quanh. Tăng 525 HP, tầm đánh và kích cỡ trong 12 giây. Hồi 50 giây."},
 skill_cards={
  {icon="volibear_skill_p",title="Nội tại - Bão Tố Cuồng Nộ",description="Đánh và chiêu trúng tích tối đa 5 cộng dồn, tồn tại 6 giây. Đủ 5: đạt 3 đòn thường/giây, mỗi đòn trúng giảm 1 giây hồi Q/W/E/R; sét lan tối đa 5 mục tiêu, gây 74 + 1% HP tối đa của từng mục tiêu thành sát thương phép. Hút máu 33%, hồi nền 5 HP/s. Mỗi 1% HP mất tăng 0,2% sát thương; còn 5% HP được +19%. Giáp 65%, kháng phép 40%."},
  {icon="volibear_skill_q",title="Q - Sấm Động",description="Tăng 26% tốc chạy trong 4 giây, 52% khi hướng tới địch. Đòn tiếp theo gây 184 sát thương vật lý và choáng 1 giây. Bị choáng trước khi đánh: hoàn lại hồi chiêu. Hồi 8 giây."},
  {icon="volibear_skill_w",title="W - Điên Cuồng Cắn Xé",description="Gây 105 + 110% sức đánh + 6% HP tối đa của Volibear thành sát thương vật lý, đánh dấu 8 giây. Cắn lại mục tiêu có dấu: sát thương tăng 50%, hồi 80 + 20% HP đã mất. Hồi 4 giây."},
  {icon="volibear_skill_e",title="E - Gọi Bão",description="Vùng tác dụng và hiệu ứng rộng gấp đôi. Sau 2 giây: gây 200 + 15% HP tối đa mục tiêu thành sát thương phép, chậm 40% trong 2 giây. Quái thường và mini boss không giới hạn; boss tối đa 610 sát thương trước kháng phép, sau hệ số tăng sát thương. Đứng trong vùng sét: khiên 14% HP tối đa, 3 giây. Hồi 13 giây."},
  {icon="volibear_skill_r",title="R - Thần Lôi Giáng Thế",description="Nhảy 1 giây, gây 700 sát thương vật lý ở tâm; vùng ngoài chậm 50% giảm dần trong 1 giây. Tăng 525 HP, tầm đánh, kích cỡ 12 giây. Hồi 50 giây."}
 }}
for _,texture in ipairs(require("volibear_animation_map").textures)do M.textures[#M.textures+1]=texture end
local function state(this,store)
 local s=C.state(this,store)
 if not s.voli_ready then
  s.voli_ready=true;s.clock=store.tick_ts;s.marks={};s.hand=1;s.stacks=0
  s.last.active=store.tick_ts-50
  for key,cd in pairs({q=8,w=4,e=13})do s.last["voli_"..key]=store.tick_ts-cd end
 end
 return s
end
local function enemies(store,pos,radius)
 return U.find_enemies_in_range(store.entities,pos,0,radius,F_AREA,0) or {}
end
function M.damage_factor(this)
 local h=this.health
 return 1+.2*math.max(0,math.min(1,1-h.hp/h.hp_max))
end
local function lifesteal(this,target,store,d,amount)
 if not C.alive(this) or not target.enemy or amount<=0 then return end
 this.health.hp=math.min(this.health.hp_max,this.health.hp+amount*.33)
end
local function hurt(this,store,target,value,kind,limit)
 if not C.alive(target) then return false end
 local d=E:create_damage()
 d.source_id,d.target_id=this.id,target.id;d.value=round(value*(this.unit.damage_factor or 1)*M.damage_factor(this));d.damage_type=kind or DAMAGE_PHYSICAL
 if limit then d.value=math.min(limit,d.value)end
 store.damage_queue[#store.damage_queue+1]=d
 return true
end
local function modifier(this,store,target,name,duration)
 if not C.alive(target) or bit.band(target.vis.bans,F_MOD)~=0 then return end
 if name=="mod_stun" and bit.band(target.vis.bans,F_STUN)~=0 then return end
 if name~="mod_stun" and bit.band(target.vis.bans,F_SLOW)~=0 then return end
 local m=E:create_entity(name);m.modifier.source_id,m.modifier.target_id=this.id,target.id;m.modifier.duration=duration
 C.insert(m)
end
local function stack(this,store)
 local s=state(this,store);s.stacks=math.min(5,(store.tick_ts<(s.stack_end or 0) and s.stacks or 0)+1);s.stack_end=store.tick_ts+6
end
local function on_hit(this,store,target)
 stack(this,store)
 local s=state(this,store)
 if s.stacks<5 then return end
 local hit={};local current=target
 local from=this
 for _=1,5 do
  if not current then break end
  hit[current.id]=true;hurt(this,store,current,stats.passive_damage+0.01*current.health.hp_max,DAMAGE_MAGICAL)
  from=FX.chain(this,store,from,current)
  local nearest,distance
  for _,other in ipairs(enemies(store,current.pos,113))do
   local d=C.dist(current.pos,other.pos)
   if not hit[other.id] and (not distance or d<distance or d==distance and other.id<nearest.id)then nearest,distance=other,d end
  end
  current=nearest
 end
end
local function rate(s)
 if s.stacks>=5 then return 180 end
 return round((0.625+0.7*(0.02*growth+0.05*s.stacks))*60)
end
local function play(this,store,name,duration,hit_time,hit,uninterruptible)
 local sp=this.render.sprites[1];local animation=assert(A.db[sp.prefix.."_"..name])
 sp.animation=nil;sp.fps=#animation.frames/duration;C.animate(this,name,store,false)
 local start,done=store.tick_ts,false
 while store.tick_ts-start<duration do
  M.passive(this,store)
  if not C.alive(this) or not uninterruptible and (this.unit.is_stunned or this.nav_rally.new) then return false end
  if hit and not done and store.tick_ts-start>=hit_time then hit();done=true;break end
  coroutine.yield()
 end
 if hit and not done and C.alive(this) then hit();done=true end
 if done then
  -- Show the contact pose for one tick, then release the cancellable Q/W recovery.
  coroutine.yield()
  if C.alive(this) then
   sp.animation=nil;sp.fps=FPS;sp.ts=store.tick_ts;sp.runs=0
   C.animate(this,"idle",store,true)
  end
 end
 return C.alive(this)
end
local function armor_shield(this,store,d)
 local s=state(this,store)
 if bit.band(d.damage_type,bit.bor(DAMAGE_ARMOR,DAMAGE_MAGICAL_ARMOR))~=0 then return true end
 if store.tick_ts<(s.shield_end or 0) and (s.shield or 0)>0 then
  local incoming=math.max(0,U.predict_damage(this,d))
  local absorbed=math.min(s.shield,incoming);s.shield=s.shield-absorbed
  if absorbed>0 then FX.shield_damage(this,store,s.shield<=0)end
  if incoming>0 then d.value=d.value*(incoming-absorbed)/incoming end
  if incoming>0 and absorbed>=incoming then return false end
 end
 return true
end
function M.passive(this,store)
 local s=state(this,store);local dt=math.max(0,store.tick_ts-s.clock);s.clock=store.tick_ts
 if C.alive(this)then
  this.health.hp=math.min(this.health.hp_max,this.health.hp+stats.hp_regen*dt)
 end
 if store.tick_ts>=(s.stack_end or 0)then s.stacks=0 end
 if store.tick_ts>=(s.mark_cleanup or 0)then
  for id,until_ts in pairs(s.marks)do if until_ts<=store.tick_ts or not store.entities[id]then s.marks[id]=nil end end
  s.mark_cleanup=store.tick_ts+1
 end
 if s.q_end and (store.tick_ts>=s.q_end or this.unit.is_stunned or not C.alive(this)) then
  if this.unit.is_stunned then s.last.voli_q=store.tick_ts-8 end
  s.q_end=nil;this.motion.max_speed=this.motion.max_speed/(s.q_speed or 1);s.q_speed=nil
 end
 if s.ult_end and store.tick_ts>=s.ult_end then
  this.health.hp_max=this.health.hp_max-525;this.health.hp=math.min(this.health.hp,this.health.hp_max)
  s.ult_end=nil;this.melee.range=107
 end
 if s.e_at and store.tick_ts>=s.e_at then
  local pos=s.e_pos;s.e_at,s.e_pos=nil,nil;local struck=false
  for _,target in ipairs(enemies(store,pos,162))do
   local value=200+0.15*target.health.hp_max
   local limit=bit.band(target.vis.flags,F_BOSS)~=0 and 610 or nil
   hurt(this,store,target,value,DAMAGE_MAGICAL,limit);modifier(this,store,target,"voli_lol20_slow",2);struck=true
  end
  if struck then stack(this,store)end
  FX.emit(this,store,"e_hit",{pos=pos})
  FX.emit(this,store,"e_ground",{pos=pos})
  if C.dist(this.pos,pos)<=162 and C.alive(this) then
   s.shield=round(this.health.hp_max*0.14);s.shield_end=store.tick_ts+3
   FX.emit(this,store,"shield",{follow_id=this.id,face=true,y=70})
  end
 end
 if not this.boss_casting then
  local sp=this.render.sprites[1]
  if sp.name~="attack" and sp.name~="attack2" then sp.fps=30 end
 end
 Movement.update(this,store,s)
 local cooldown=60/rate(s)
 -- The native picker uses strict >; don't lose a frame at exactly ten ticks.
 if s.stacks>=5 then cooldown=cooldown-1e-9 end
 for _,a in ipairs(this.melee.attacks)do a.cooldown=cooldown end
 FX.tick(this,store)
end
function M.hold(this,store) M.passive(this,store);return false end
function M.can_cast_active(this,store) return not this.unit.is_stunned end
function M.automatic(this,store,targets)
 local s=state(this,store);local target=store.entities[this.soldier.target_id] or targets and targets[1]
 if not C.alive(target) then return false end
 local distance=C.dist(this.pos,target.pos)
 if not s.q_end and C.ready(this,store,"voli_q",8) and distance<=175 then
  this.render.sprites[1].flip_x=target.pos.x>this.pos.x
  C.stamp(this,store,"voli_q");s.q_end=store.tick_ts+4
  s.q_speed=bit.band(target.vis.flags,bit.bor(F_BOSS,F_MINIBOSS))~=0 and 1.52 or 1.26
  this.motion.max_speed=this.motion.max_speed*s.q_speed
  FX.emit(this,store,"q_cast")
  FX.emit(this,store,"q_charge",{follow_id=this.id,face=true})
  play(this,store,"q_intro",0.55)
  return true
 end
 if s.q_end and distance<=138 and bit.band(target.vis.flags,F_FLYING)==0 then
  this.render.sprites[1].flip_x=target.pos.x>this.pos.x
  if play(this,store,"q_attack",0.5,0.30,function()
   if hurt(this,store,target,stats.ad+50)then
    modifier(this,store,target,"mod_stun",1);on_hit(this,store,target)
    FX.strike(this,store,target,"q_hit")
   end
   for _,a in ipairs(this.melee.attacks)do a.ts=store.tick_ts-a.cooldown end
  end)then
   if s.q_speed then this.motion.max_speed=this.motion.max_speed/s.q_speed end;s.q_end,s.q_speed=nil,nil
  end
  return true
 end
 if distance<=(s.ult_end and 162 or 149) and C.ready(this,store,"voli_w",4) and bit.band(target.vis.flags,F_FLYING)==0 then
  C.stamp(this,store,"voli_w");this.render.sprites[1].flip_x=target.pos.x>this.pos.x
  local marked=(s.marks[target.id] or 0)>store.tick_ts
  play(this,store,"w",0.75,0.25,function()
   local value=105+1.1*stats.ad+0.06*this.health.hp_max
   if marked then value=value*1.5 end
   if hurt(this,store,target,value)then
    if marked then
     this.health.hp=math.min(this.health.hp_max,this.health.hp+round(80+0.2*(this.health.hp_max-this.health.hp)))
    end
    s.marks[target.id]=store.tick_ts+8;on_hit(this,store,target)
    FX.strike(this,store,target,"w_hit",marked);FX.mark(this,store,target)
   end
  end)
  return true
 end
 if distance<=300 and C.ready(this,store,"voli_e",13) then
  this.render.sprites[1].flip_x=target.pos.x>this.pos.x
  C.stamp(this,store,"voli_e");s.e_pos=C.copy(target.pos);s.e_at=store.tick_ts+2
  FX.emit(this,store,"e_warning",{pos=s.e_pos})
  play(this,store,"e_idle",0.8)
  return true
 end
 return false
end
function M.active(this,store,pos)
 local s=state(this,store)
 if not M.can_cast_active(this,store) or C.dist(this.pos,pos)>M.skill.range then return end
 local destination=C.copy(pos);local origin=C.copy(this.pos);local sp=this.render.sprites[1];local old_y=sp.offset.y
 sp.flip_x=destination.x>origin.x or destination.x==origin.x and not ((s.move_direction or 0)>=3 and (s.move_direction or 0)<=5)
 if not s.ult_end then this.health.hp_max=this.health.hp_max+525;this.health.hp=this.health.hp+525 end
 s.ult_end=store.tick_ts+12;this.melee.range=131
 if s.q_end then s.q_end=s.q_end+1 end
 U.unblock_target(store,this)
 local bans=this.vis.bans;this.vis.bans=bit.bor(bans,F_BLOCK,F_TELEPORT);this.boss_form=true
 local began=store.tick_ts
 FX.emit(this,store,"r_warning",{pos=destination})
 FX.emit(this,store,"r_leap",{follow_id=this.id,face=true,y=65})
 sp.animation=nil;C.animate(this,"jump",store,false);sp.fps=#A.db[sp.prefix.."_jump"].frames
 while store.tick_ts-began<1 and C.alive(this)do
  M.passive(this,store)
  local f=math.min(1,store.tick_ts-began)
  this.pos.x=origin.x+(destination.x-origin.x)*f;this.pos.y=origin.y+(destination.y-origin.y)*f;sp.offset.y=old_y -- Native R clip already contains the jump arc.
  coroutine.yield()
 end
 sp.offset.y=old_y;this.vis.bans=bans;this.boss_form=nil;C.land(this,C.alive(this) and destination or origin)
 if not C.alive(this) then return end
 FX.emit(this,store,"r_hit",{pos=destination})
 FX.emit(this,store,"r_ground",{pos=destination})
 local struck=false
 for _,target in ipairs(enemies(store,destination,125))do
  modifier(this,store,target,"voli_lol20_r_slow",1)
  if C.dist(target.pos,destination)<=75 then hurt(this,store,target,700);struck=true end
 end
 if struck then stack(this,store)end
 play(this,store,"land",0.25,nil,nil,true);play(this,store,"r_outro",0.34)
end
function M.prepare(t)
 local p=t.render.sprites[1].prefix
 require("volibear_animation_map").register(p,A)
 Movement.register(p,A)
 -- Native combat frames face left; invert KR's two-side lookup for these attacks.
 local sp=E:clone_c("sprite");sp.prefix=p;sp.name="idle";sp.anchor=V.v(.5,34/256);sp.scale=V.v(1,1);sp.angles={walk={"walk","walkUp","walkDown"},attack={"attack","attack"},attack2={"attack2","attack2"}};sp.angles_flip_horizontal={true,true}
 sp.animation=A.db[p.."_idle8_e"]
 t.render.sprites={sp};t.health.hp_max,t.health.hp=stats.hp,stats.hp;t.health.armor,t.health.magic_armor=stats.armor_percent/100,stats.mr_percent/100
 t.health.on_damage=armor_shield;t.health.dead_lifetime=20;t.health_bar.offset=V.v(0,159)
 t.regen.health=0;t.regen.cooldown=1;t.motion.max_speed=85;t.unit.size=UNIT_SIZE_MEDIUM
 t.unit.hit_offset,t.unit.mod_offset,t.unit.marker_offset=V.v(0,75),V.v(0,75),V.v(0,0)
 t.unit.on_damage_dealt=lifesteal
 t.ui.click_rect={pos=V.v(-40,0),size=V.v(80,150)};t.unit.death_animation="death";t.soldier.melee_slot_offset=V.v(51,0);t.melee.range=107;t.melee.attacks={}
 for hand=1,2 do
  local a=E:clone_c("melee_attack");a.damage_min,a.damage_max=stats.ad,stats.ad;a.damage_type=DAMAGE_PHYSICAL;a.cooldown=60/stats.attacks_per_minute
  a.animation=hand==1 and "attack" or "attack2";a.voli_hand=hand;a.shared_cooldown=true;a.hit_time=0.4
  a.fn_can=function(this,store,attack)
   local s=state(this,store)
   if attack.voli_hand~=s.hand then return false end
   local duration=60/rate(s);attack.hit_time=duration*0.35
   local sprite=this.render.sprites[1];sprite.animation=nil;sprite.fps=#A.db[sprite.prefix.."_"..attack.animation].frames/duration
   return true
  end
  a.fn_damage=function(this,store,attack,target)
   local s=state(this,store);s.hand=3-attack.voli_hand;on_hit(this,store,target)
   if s.stacks>=5 then
    for key,cd in pairs({voli_q=8,voli_w=4,voli_e=13,active=50})do
     s.last[key]=math.max(store.tick_ts-cd,s.last[key]-1)
    end
   end
   FX.strike(this,store,target)
   return round(stats.ad*(this.unit.damage_factor or 1)*M.damage_factor(this))
  end
  a.vis_flags,a.vis_bans=F_BLOCK,bit.bor(F_FLYING,F_CLIFF);a.xp_gain_factor=0;t.melee.attacks[hand]=a
 end
 t.melee.order={1,2};t.info.i18n_key="HERO_ALLIED_VOLIBEAR_PRESTIGE";t.info.portrait="info_portrait_volibear_lol20";t.info.hero_portrait=M.icon
 t.volibear_level=20;Movement.update(t,{tick_ts=0},{move_direction=0})
end
function M.respawn(this)
 this.volibear_vfx_respawn=true
 this.health.hp_max=stats.hp;this.health.hp=stats.hp;this.motion.max_speed=85;this.melee.range=107
 this.render.sprites[1].offset.y=0
end
function M.register()
 C,E,A,U,V,bit=require("allied_boss_common"),require("entity_db"),require("animation_db"),require("utils"),require("klua.vector"),require("bit")
 FX.register()
 if not E.entities.voli_lol20_slow then
  local t=E:register_t("voli_lol20_slow","mod_slow");t.render=nil;t.slow.factor=0.6;t.modifier.duration=2
  t=E:register_t("voli_lol20_r_slow","voli_lol20_slow");t.slow.factor=0.5;t.modifier.duration=1
  t.main_script.update=function(e,store)
   while store.tick_ts-e.modifier.ts<e.modifier.duration do
    local target=store.entities[e.modifier.target_id]
    if not C.alive(target) then break end
    local factor=0.5+0.5*math.min(1,(store.tick_ts-e.modifier.ts)/e.modifier.duration)
    target.motion.max_speed=target.motion.max_speed/e.slow.factor*factor;e.slow.factor=factor
    coroutine.yield()
   end
   C.remove(e)
  end
 end
 local t=C.create(M)
 if not t.volibear_tick_wrapper then
  local update=t.main_script.update
  t.main_script.update=function(this,store)
   local worker=coroutine.create(function()update(this,store)end)
   while coroutine.status(worker)~="dead" do
    M.passive(this,store)
    local ok,err=coroutine.resume(worker);if not ok then error(err)end
    Movement.update(this,store,this.boss_state or {})
    coroutine.yield()
   end
  end
  t.volibear_tick_wrapper=true
 end
 for _,msgs in pairs(require("i18n").msgs)do msgs.HERO_ALLIED_VOLIBEAR_PRESTIGE_NAME=M.title;msgs.HERO_ALLIED_VOLIBEAR_PRESTIGE_DESCRIPTION=M.skill.description end
 return t
end
return M
