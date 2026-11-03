-- Blue Navira keeps one opponent until death, retreat or loss of contact.
local M={shield_textures={}}
for i=1,5 do M.shield_textures[i]=string.format("go_fx_volibear_native_e_shield_bubble_visualfix_p%02d",i) end
local C,E,U,bit
function M.level(slot)
 if slot==nil then
  local storage=require('storage')
  slot=storage.slot
  if not slot and storage.active_slot_idx then slot=storage:load_slot(nil,true) end
 end
 local value=slot and slot.liuhui and slot.liuhui.navira_blue_level
 if type(value)~='number' or value~=value then return 1 end
 return math.max(0,math.min(1,math.floor(value)))
end
function M.label(slot) return M.level(slot)==1 and 'Buff Solo: bật' or 'Buff Solo: tắt' end
function M.description(level)
 if level==0 then
  return 'Tắt gói Solo. Đồng minh: đánh AOE 280 luân phiên vật lý/phép, mỗi 10 giây đấm AOE 560 chuẩn và giữ 3 tia choáng; đánh bay, lướt địa hình, miễn khống chế, không hút xác. Không có 20 dấu, hút máu 40%, chặn/phản đòn hay sát thương theo HP. Boss địch dùng kỹ năng gốc. Áp dụng từ trận kế tiếp, cùng lựa chọn cho hai phe.'
 end
 return 'Bật Solo cho Navi xanh hai phe. Khóa đối thủ trong tầm 450; tối đa 20 dấu: mỗi dấu +15% đấm thường, thêm 0,2% HP tối đa đối thủ chuẩn và giảm 3% sát thương từ đối thủ. Hút máu 40%. Khiên tự chạy liên tục: bật 4 giây, nghỉ 2 giây, kể cả ngoài giao chiến; không cần trúng đòn để kích hoạt. Trong khiên, chuyển 100% sát thương sau giảm trừ từ mọi nguồn thành hồi HP, tối đa đầy máu. Lúc khiên nghỉ: chặn 3 đòn từ đối thủ, mỗi lần phản sát thương chuẩn bằng 10% HP tối đa CỦA CHÍNH NAVI; nạp mỗi 10 giây. Đấm riêng 840 chuẩn +12% HP tối đa đối thủ mỗi 8 giây. Mỗi 6 giây, 3 tia cùng đối thủ, mỗi tia 280 phép +1% HP tối đa chuẩn. Không hút xác. Boss xuống sân bắt đầu chu kỳ khiên và dùng cùng bộ Solo, không biến lốc theo HP; phong ấn tháp trên tượng giữ nguyên. Áp dụng từ trận kế tiếp.'
end
function M.opponent(this,target)
 return target and (this.enemy and target.soldier and not target.enemy or not this.enemy and target.enemy) and true or false
end
local function state(this,store)
 local s=C.state(this,store)
 if not s.duel then s.duel={stacks=0,guards=3,guard_refresh=store.tick_ts+10} end
 if store.tick_ts>=s.duel.guard_refresh then s.duel.guards,s.duel.guard_refresh=3,store.tick_ts+10 end
 return s.duel
end
local function valid(this,target)
 return C.alive(target) and M.opponent(this,target) and target.pos and C.dist(this.pos,target.pos)<=450
end
local function lock(s,target)
 if s.target_id~=target.id then s.target_id,s.stacks=target.id,0 end
 return target
end
function M.release(this,store)
 local s=state(this,store)
 s.target_id,s.stacks=nil,0
end
function M.current(this,store)
 local s=state(this,store)
 if not C.alive(this) or this.nav_rally and this.nav_rally.new then M.release(this,store);return end
 local blocked
 if this.enemy then blocked=U.get_blocker(store,this) else blocked=store.entities[this.soldier.target_id] end
 if valid(this,blocked) and (this.enemy or U.blocker_rank(store,this)) and bit.band(blocked.vis.flags,F_FLYING)==0 then return lock(s,blocked) end
 local target=store.entities[s.target_id]
 if valid(this,target) then return target end
 M.release(this,store)
end
function M.select(this,store,target)
 if not valid(this,target) then return false end
 local current=M.current(this,store)
 if current and current.id~=target.id then return false end
 lock(state(this,store),target)
 if not this.navira_duel_sort then
  this.navira_duel_sort=function(a,b,center)
   if a.id==b.id then return false end
   local s=this.boss_state and this.boss_state.duel
   if s and s.target_id and (a.id==s.target_id or b.id==s.target_id) then return a.id==s.target_id end
   return C.target_before(a,b,center)
  end
 end
 this.melee.fn_sort_targets=this.navira_duel_sort
 return true
end
local function damage(this,target,store,value,kind,ray)
 if not C.alive(target) or not M.opponent(this,target) then return end
 local d=E:create_damage()
 d.source_id,d.target_id=this.id,target.id
 d.value,d.damage_type=value,kind or bit.bor(DAMAGE_TRUE,DAMAGE_MODIFIER)
 d.navira_duel_ray=ray
 store.damage_queue[#store.damage_queue+1]=d
end
local function on_damage_dealt(this,target,store,d,amount,direct)
 if not C.alive(this) or not M.opponent(this,target) then return end
 local s=state(this,store)
 if this.nav_rally and this.nav_rally.new or target.id~=s.target_id then return end
 if direct and (d.navira_duel_ray or d.track_damage and bit.band(d.damage_type,DAMAGE_MODIFIER)==0) then
  s.stacks=math.min(20,s.stacks+1)
  if C.alive(target) then damage(this,target,store,target.health.hp_max*0.002*s.stacks) end
 end
 if bit.band(d.damage_type,DAMAGE_NO_LIFESTEAL)==0 then
  this.health.hp=math.min(this.health.hp_max,this.health.hp+amount*0.4)
 end
 if not C.alive(target) then s.target_id,s.stacks=nil,0 end
end
function M.burst(this,store,target)
 if M.current(this,store)~=target then return false end
 damage(this,target,store,840+target.health.hp_max*0.12)
 return true
end
function M.ray(this,store,target)
 if M.current(this,store)~=target then return false end
 damage(this,target,store,280,DAMAGE_MAGICAL,true)
 damage(this,target,store,target.health.hp_max*0.01)
 return true
end
local function shield_visual(owner,store,expires)
 local name='navira_blue_conversion_shield'
 local A=require('animation_db')
 if not A.db[name] then
  local frames={};for i=1,49 do frames[i]=i end
  A.db[name]={prefix='fx_volibear_native_e_shield_bubble',frames=frames}
 end
 if not E.entities[name] then
  local t=E:register_t(name,'decal_scripted')
  local sp=t.render.sprites[1]
  sp.name=name;sp.animated=true;sp.loop=false;sp.fps=49/4
  sp.anchor={x=.5,y=.5};sp.shader='p_navira_shield_blue';sp.z=Z_OBJECTS+1
  t.main_script.insert=nil
  t.main_script.update=function(this,st)
   while st.tick_ts<this.expires do
    local target=st.entities[this.owner_id]
    if not C.alive(target) or not target.navira_duelist then break end
    local offset=target.unit.hit_offset
    this.pos.x,this.pos.y=target.pos.x+offset.x,target.pos.y+offset.y
    coroutine.yield()
   end
   C.remove(this)
  end
 end
 local e=E:create_entity(name)
 e.owner_id,e.expires=owner.id,expires
 e.pos=C.copy(owner.pos)
 e.pos.x,e.pos.y=e.pos.x+owner.unit.hit_offset.x,e.pos.y+owner.unit.hit_offset.y
 local sp=e.render.sprites[1]
 sp.ts=expires-4
 local scale=math.max(100,math.abs(owner.unit.hit_offset.y)*2.6)/256
 sp.scale={x=scale,y=scale}
 C.insert(e)
end
local function update_shield(this,store)
 if not this.navira_duelist or not C.alive(this) or this.enemy and not this.navira_duel_fighting then return end
 local s=state(this,store)
 s.convert_ready=s.convert_ready or store.tick_ts
 if store.tick_ts>=s.convert_ready then
  -- Keep the six-second rhythm even when an update skips across a phase boundary.
  local started=s.convert_ready+math.floor((store.tick_ts-s.convert_ready)/6)*6
  s.convert_until,s.convert_ready=started+4,started+6
  if store.tick_ts<s.convert_until then shield_visual(this,store,s.convert_until) end
 end
end
function M.tick(this,store)
 M.current(this,store)
 update_shield(this,store)
end
function M.apply(t)
 C,E,U,bit=require("allied_boss_common"),require("entity_db"),require("utils"),require("bit")
 if M.level()==0 then
  local old=t.navira_duel_base
  if old then
   t.unit.on_damage_dealt,t.unit.prepare_damage,t.health.on_damage=old.dealt,old.prepare,old.damage
   t.melee.fn_can_pick=old.pick
   t.main_script.update=old.update
   t.navira_duelist,t.navira_duel_base,t.navira_duel_previous_pick_filter=nil,nil,nil
  end
  return t
 end
 if not t.navira_duelist then
  t.navira_duel_base={dealt=t.unit.on_damage_dealt,prepare=t.unit.prepare_damage,damage=t.health.on_damage,pick=t.melee.fn_can_pick,update=t.main_script.update}
 end
 if not t.navira_duelist then t.navira_duel_previous_pick_filter=t.melee.fn_can_pick end
 -- The common picker is rebuilt on registration; its filter preserves the duel for flying foes too.
 t.melee.fn_can_pick=function(this,target)
  local s=this.boss_state and this.boss_state.duel
  local previous=this.navira_duel_previous_pick_filter
  return (not s or not s.target_id or s.target_id==target.id) and (not previous or previous(this,target))
 end
 if t.navira_duelist then return end
 t.navira_duelist=true
 local update=t.main_script.update
 t.main_script.update=function(this,store)
  local co=coroutine.create(update)
  while true do
   update_shield(this,store)
   local ok,err=coroutine.resume(co,this,store)
   if not ok then error(err) end
   if coroutine.status(co)=='dead' then return end
   coroutine.yield()
  end
 end
 t.unit.on_damage_dealt=on_damage_dealt
 local previous_prepare=t.unit.prepare_damage
 t.unit.prepare_damage=function(this,target,store,d)
  if previous_prepare then previous_prepare(this,target,store,d) end
  if d.track_damage and bit.band(d.damage_type,DAMAGE_MODIFIER)==0 and M.current(this,store)==target then
   d.value=d.value*(1+0.15*state(this,store).stacks)
  end
 end
 local previous=t.health.on_damage
 t.health.on_damage=function(this,store,d)
  if previous and not previous(this,store,d) then return false end
  update_shield(this,store)
  local target=M.current(this,store)
  local s=state(this,store)
  local source=store.entities[d.source_id]
  local dealer=source and source.modifier and store.entities[source.modifier.source_id] or
   source and source.bullet and store.entities[source.bullet.source_id] or source
  local locked=target and dealer and dealer.id==target.id
  if (d.value or 0)>0 and bit.band(d.damage_type,bit.bor(DAMAGE_ARMOR,DAMAGE_MAGICAL_ARMOR,DAMAGE_INSTAKILL,DAMAGE_EAT))==0 and
   store.tick_ts<(s.convert_until or 0) then
   if locked then d.value=d.value*(1-0.03*s.stacks) end
   -- Cancellation bypasses the health system's preparation, so run it once here.
   local preparer=source and source.modifier and store.entities[source.modifier.source_id] or source
   if preparer and preparer.unit and preparer.unit.prepare_damage then preparer.unit.prepare_damage(preparer,this,store,d) end
   local incoming=math.max(0,U.predict_damage(this,d))
   if incoming>0 then
    this.health.hp=math.min(this.health.hp_max,this.health.hp+incoming)
    if store.tick_ts>=(s.convert_fx_at or 0) then
     s.convert_fx_at=store.tick_ts+0.35
     C.visual("mod_bullet_stage_19_navira_heal",this.pos,store,0.35,"idle")
    end
   end
   return false
  end
  if not locked then return true end
  if (d.value or 0)>0 and bit.band(d.damage_type,bit.bor(DAMAGE_ARMOR,DAMAGE_MAGICAL_ARMOR))==0 then
   if s.guards>0 and not (source.modifier or source.dps) and bit.band(d.damage_type,bit.bor(DAMAGE_MODIFIER,DAMAGE_POISON))==0 then
    s.guards=s.guards-1
    damage(this,target,store,this.health.hp_max*0.1)
    C.visual("mod_bullet_stage_19_navira_heal",this.pos,store,0.35,"idle")
    return false
   end
   d.value=d.value*(1-0.03*s.stacks)
  end
  return true
 end
 return t
end

function M.enemy_update(this,store,on_death)
 this.navira_duel_fighting=true
 update_shield(this,store)
 local blue=require('allied_navira').blue
 local SU=require('script_utils')
 while true do
  if this.health.dead then on_death();return end
  local walking=false
  local target=M.current(this,store)
  if not target then
   local candidates=U.find_soldiers_in_range(store.entities,this.pos,0,450,F_AREA,0) or {}
   table.sort(candidates,function(a,b)return C.target_before(a,b,this.pos)end)
   for _,candidate in ipairs(candidates)do
    if M.select(this,store,candidate)then target=candidate;break end
   end
  end
  if this.unit.is_stunned then
   SU.y_enemy_stun(store,this)
  elseif blue.automatic(this,store,target and {target} or {}) then
  elseif target and U.is_inside_ellipse(target.pos,this.pos,this.melee.attacks[1].damage_radius) then
   SU.y_enemy_melee_attacks(store,this,target)
  elseif #this.enemy.blockers>0 then
   U.cleanup_blockers(store,this)
   U.animation_start(this,'idle',nil,store.tick_ts,true)
  else
   walking=true
   SU.y_enemy_walk_step(store,this)
  end
  if this.render.sprites[1].z>=Z_OBJECTS_COVERS then this.render.sprites[1].z=Z_OBJECTS end
  if not walking then coroutine.yield() end
 end
end

function M.install_enemy()
 if M.level()==0 then return end
 local db=require('entity_db')
 local t=db:get_template('boss_navira')
 if t.navira_duel_installed then return end
 t.navira_duel_installed=true
 local insert=t.main_script.insert
 t.main_script.insert=function(this,store,script)
  if insert and not insert(this,store,script)then return false end
  local blue=require('allied_navira').blue
  local ally=blue.register()
  local A=require('animation_db')
  local prefix=this.render.sprites[1].prefix
  A.db[prefix..'_charged_attack']=A.db[ally.render.sprites[1].prefix..'_charged_attack']
  this.boss_kind=ally.boss_kind
  this.melee.attacks=table.deepclone(ally.melee.attacks)
  this.melee.cooldown=ally.melee.cooldown or ally.melee.attacks[1].cooldown
  for _,attack in ipairs(this.melee.attacks)do attack.ts=store.tick_ts end
  blue.protect(this)
  M.apply(this)
  this.melee.order=U.attack_order(this.melee.attacks)
  return true
 end
end
return M
