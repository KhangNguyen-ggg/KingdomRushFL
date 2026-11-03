-- Native VFX follow the original rig projections.
local M={}
local E,V,A
local Assets=require('volibear_animation_map')
local Back=require('volibear_back_anchors')
local Hands=require('volibear_hand_anchors')
local directions={'e','ne','n','nw','w','sw','s','se'}
local plans={
 hit={layers={'basicattack_hit_right'}},
 q_hit={layers={'q_hit'}},
 w_hit={layers={'w_hit_01'}},
 w_mark={layers={'w_marked_scratch'},life=8,flag='mark',loop=true},
 w_chomp={layers={'w_chomp_head'},body=true},
 chain={layers={'passive_chainlightning_strip'},life=.45},
 chain_hit={layers={'passive_target_shock'},life=.6,target_hit=true},
 p_charge={layers={'passive_back_base'},life=.5,flag='living',body=true,back=true},
 p_aura={layers={'passive_back_base'},life=1e9,flag='charged',body=true,back=true,loop=true},
 p_hands={layers={'passive_hand_l_base','passive_hand_r_base'},life=1e9,flag='charged',body=true,hands=true,loop=true},
 e_warning={layers={'e_aoe_warning'},life=2,scale=2},
 e_hit={layers={'e_aoe_ground','e_aoe_atmosphere'},ground_first=true,scale=2},
 shield={layers={'e_shield_bubble'},life=3,flag='shield',body=true,attach=true},
 shield_hit={layers={'passive_hitflash_01'},life=.22,flag='living',attach=true},
 shield_break={layers={'e_hit_01'},life=.4,flag='living',attach=true},
 r_warning={layers={'r_aoe_warning'},life=1,ground_first=true},
 r_leap={layers={'r_leapgroundshadow'},life=1,ground_first=true,flag='living'},
 r_hit={layers={'r_landingimpact_01_ground','r_landingimpact_01_atmosphere'},ground_first=true},
 r_end={layers={'r_impact_dust_a'},life=.55,ground_first=true},
 q_step={layers={'q_pawprints'},life=.75,ground_first=true}
}
local baked={aura=true,windup=true,slash=true,q_cast=true,q_charge=true,q_swing=true,q_impact=true,e_ground=true,r_ground=true,r_form=true,death=true,respawn=true}
local function alive(e)return e and not e.pending_removal and e.health and not e.health.dead and e.health.hp>0 end
local function left(sp)local d=sp.volibear_move_direction;return d~=nil and d>=3 and d<=5 or d==nil and not sp.flip_x or false end
local function remove(e,store)
 if e.kind=='w_mark' or e.kind=='chain_hit' then
  local owner=store.entities[e.owner_id];local s=owner and owner.boss_state
  local records=s and (e.kind=='w_mark' and s.vfx_marks or s.vfx_shocks)
  if records and records[e.follow_id]==e.id then records[e.follow_id]=nil end
 end
 require('simulation'):queue_remove_entity(e)
end
local function update(e,store)
 local plan=plans[e.kind]
 while store.tick_ts-e.started<e.life do
  local owner=store.entities[e.owner_id];local s=owner and owner.boss_state
  local elapsed=store.tick_ts-e.started
  if plan.flag and (not alive(owner) or not s or not s.voli_ready) then break end
  if plan.flag=='shield' and (store.tick_ts>=(s.shield_end or 0) or (s.shield or 0)<=0) then break end
  if plan.flag=='charged' and (s.stacks or 0)<5 then break end
  if plan.flag=='mark' and (not s.marks or (s.marks[e.follow_id] or 0)<=store.tick_ts) then break end
  local target=e.follow_id and store.entities[e.follow_id]
  if e.follow_id then
   if not alive(target) then break end
   e.pos.x,e.pos.y=target.pos.x+e.dx,target.pos.y+e.dy
   if plan.target_hit then
    e.pos.x,e.pos.y=e.pos.x+target.unit.hit_offset.x,e.pos.y+target.unit.hit_offset.y
   end
  end
  local flip=e.face and target and target.render and left(target.render.sprites[1]) or false
  local model_units=Assets.model_units*(s and s.ult_end and store.tick_ts<s.ult_end and 1.25 or 1)
  local body,frame,pose
  if plan.back or plan.attach or plan.hands then
   body=owner.render.sprites[1]
   frame=body.animation and A:fni(body.animation,store.tick_ts-body.ts,body.loop,body.fps) or A:fn(body.prefix..'_'..body.name,store.tick_ts-body.ts,body.loop,body.fps)
   pose=assert(Back.poses[frame],'Missing Volibear rig anchor: '..frame)
  end
  for i,sp in ipairs(e.render.sprites)do
   local info=Assets.effects[plan.layers[i]]
   local units=plan.body and model_units or .25*(plan.scale or 1)
   if plan.target_hit then units=math.max(.18,math.min(.9,math.abs(target.unit.hit_offset.y)/64)) end
   sp.scale.x,sp.scale.y=info.world/(info.canvas or 256)*units,info.world/(info.canvas or 256)*units
   sp.flip_x=flip;sp.alpha=255
   if plan.target_hit then sp.alpha=255*math.min(1,(e.life-elapsed)/.08) end
   if plan.back or plan.attach then
    if plan.attach then
     local sign=pose[5]<0 and body.flip_x and -1 or 1
     e.pos.x=owner.pos.x+body.offset.x+pose[6]*model_units*sign
     e.pos.y=owner.pos.y+body.offset.y+pose[7]*model_units
    else
     local direction=pose[5]<0 and 'base' or directions[pose[5]+1]
     local tag='passive_back_'..direction;info=Assets.effects[tag]
     local mirrored=pose[5]<0 and body.flip_x;local sign=mirrored and -1 or 1
     e.pos.x=owner.pos.x+body.offset.x+pose[1]*units*sign
     e.pos.y=owner.pos.y+body.offset.y+pose[2]*units
     sp.name='voli_native_fx_'..tag;sp.animation=A.db[sp.name]
     sp.anchor.x,sp.anchor.y=info.x,info.y
     sp.scale.x,sp.scale.y=info.world/(info.canvas or 256)*units,info.world/(info.canvas or 256)*units
     sp.r=(pose[3]-Back.references[direction][1])*sign;sp.flip_x=mirrored or false
     sp.z=body.z or Z_OBJECTS
     -- Keep the aura beside its owner in depth order, even though its anchor is raised.
     sp.sort_y=(body.sort_y or owner.pos.y+(body.sort_y_offset or 0))+(pose[4]>0 and -.01 or .01)
     sp._render_state_ts=nil
    end
   end
   if plan.hands then
    local hand=assert(Hands.poses[frame],'Missing Volibear hand anchor: '..frame);local at=(i-1)*4
    local direction=pose[5]<0 and 'base' or directions[pose[5]+1]
    local mirrored=pose[5]<0 and body.flip_x;local sign=mirrored and -1 or 1
    local tag='passive_hand_'..(i==1 and 'l' or 'r')..'_'..direction;info=Assets.effects[tag]
    sp.name='voli_native_fx_'..tag;sp.animation=A.db[sp.name]
    sp.offset.x,sp.offset.y=body.offset.x+hand[at+1]*model_units*sign,body.offset.y+hand[at+2]*model_units
    sp.anchor.x,sp.anchor.y=info.x,info.y;sp.scale.x,sp.scale.y=info.world/(info.canvas or 256)*model_units,info.world/(info.canvas or 256)*model_units
    sp.r=(hand[at+3]-Hands.references[direction][i])*sign;sp.flip_x=mirrored or false
    sp.z=body.z or Z_OBJECTS
    sp.sort_y=(body.sort_y or owner.pos.y+(body.sort_y_offset or 0))+(hand[at+4]>0 and -.02 or .02)
    sp._render_state_ts=nil
   end
   if e.chain then
    local from,to=store.entities[e.from_id],store.entities[e.target_id]
    if not alive(from) or not alive(to) then remove(e,store);return end
    local ax,ay=from.pos.x+from.unit.hit_offset.x,from.pos.y+from.unit.hit_offset.y
    local bx,by=to.pos.x+to.unit.hit_offset.x,to.pos.y+to.unit.hit_offset.y
    local dx,dy=bx-ax,by-ay
    e.pos.x,e.pos.y=(ax+bx)/2,(ay+by)/2
    sp.r=math.atan2(dy,dx);sp.anchor.x,sp.anchor.y=.5,.5
    sp.scale.x=math.max(8,math.sqrt(dx*dx+dy*dy))/240;sp.scale.y=.5
   end
  end
  coroutine.yield()
 end
 remove(e,store)
end
function M.register()
 E,V,A=require('entity_db'),require('klua.vector'),require('animation_db')
 Assets.register_fx(A)
 if E.entities.volibear_original_vfx then return end
 local t=E:register_t('volibear_original_vfx','decal_scripted');t.main_script.insert=nil;t.main_script.update=update
end
function M.emit(owner,store,kind,opts)
 if kind=='heal' or baked[kind] then return end
 opts=opts or {};local plan=assert(plans[kind],kind);local e=E:create_entity('volibear_original_vfx')
 e.kind,e.owner_id,e.follow_id,e.face=kind,owner.id,opts.follow_id,opts.face
 e.pos=V.vclone(opts.pos or owner.pos);e.dx,e.dy=opts.x or 0,opts.y or 0
 -- The leap shadow follows the ground root; baked animation carries vertical motion.
 if kind=='r_leap' or plan.body then e.dy=0 end
 e.started=store.tick_ts;e.life=opts.life or plan.life or Assets.effects[plan.layers[1]].duration
 e.render.sprites={}
 for i,tag in ipairs(plan.layers)do
  local info=assert(Assets.effects[tag]);local sp=E:clone_c('sprite')
  sp.name='voli_native_fx_'..tag;sp.animation=A.db[sp.name];sp.animated=true;sp.loop=plan.loop or false
  sp.ts=store.tick_ts;sp.fps=kind=='chain' and #sp.animation.frames/e.life or FPS
  sp.anchor=V.v(info.x,info.y);sp.offset=V.v(0,0);sp.scale=V.v(info.world/(info.canvas or 256)*.25*(plan.scale or 1),info.world/(info.canvas or 256)*.25*(plan.scale or 1))
  sp.r=opts.angle or 0;sp.alpha=0;sp.z=plan.ground_first and i==1 and Z_DECALS or Z_OBJECTS+1
  e.render.sprites[i]=sp
 end
 require('simulation'):queue_insert_entity(e);return e
end
function M.strike(owner,store,target,kind,marked)
 local offset=target.unit.hit_offset
 M.emit(owner,store,kind=='q_hit' and 'q_hit' or kind=='w_hit' and 'w_hit' or 'hit',{pos={x=target.pos.x+offset.x,y=target.pos.y+offset.y}})
 if kind=='w_hit' and marked then M.emit(owner,store,'w_chomp',{follow_id=owner.id,face=true}) end
end
function M.chain(owner,store,from,target)
 local offset=target.unit.hit_offset;local finish={x=target.pos.x+offset.x,y=target.pos.y+offset.y,id=target.id}
 local e=M.emit(owner,store,'chain');e.chain=true;e.from_id=from.id or owner.id;e.target_id=target.id
 M.shock(owner,store,target)
 return finish
end
function M.shock(owner,store,target)
 local s=owner.boss_state;s.vfx_shocks=s.vfx_shocks or {}
 local previous=store.entities[s.vfx_shocks[target.id] or -1]
 if previous and not previous.pending_removal then
  previous.started=store.tick_ts
  for _,sprite in ipairs(previous.render.sprites)do sprite.ts=store.tick_ts;sprite._render_state_ts=nil end
  return previous
 end
 local e=M.emit(owner,store,'chain_hit',{follow_id=target.id});s.vfx_shocks[target.id]=e.id
 return e
end
function M.mark(owner,store,target)
 local s=owner.boss_state;s.vfx_marks=s.vfx_marks or {}
 local previous=store.entities[s.vfx_marks[target.id] or -1]
 if previous and not previous.pending_removal then previous.started=store.tick_ts;return end
 local e=M.emit(owner,store,'w_mark',{follow_id=target.id,y=(target.health_bar and target.health_bar.offset.y or 30)+12})
 s.vfx_marks[target.id]=e.id
end
function M.shield_damage(owner,store,broken)
 local s=owner.boss_state
 if broken or store.tick_ts>=(s.vfx_shield_hit_at or 0) then
  s.vfx_shield_hit_at=store.tick_ts+.12
  M.emit(owner,store,broken and 'shield_break' or 'shield_hit',{follow_id=owner.id,y=70})
 end
end
function M.tick(owner,store)
 local s=owner.boss_state;local now=store.tick_ts
 if not alive(owner) then return end
 if (s.stacks or 0)>=5 and not s.vfx_charged then
  M.emit(owner,store,'p_aura',{follow_id=owner.id})
  M.emit(owner,store,'p_hands',{follow_id=owner.id})
 end
 s.vfx_charged=(s.stacks or 0)>=5
 if s.ult_end then s.vfx_ult=true elseif s.vfx_ult then s.vfx_ult=nil;M.emit(owner,store,'r_end') end
 if s.q_end then
  local previous=s.vfx_step_pos
  if not previous then s.vfx_step_pos=V.vclone(owner.pos)
  elseif now>=(s.vfx_step_at or 0) and (owner.pos.x-previous.x)^2+(owner.pos.y-previous.y)^2>=20^2 then
   M.emit(owner,store,'q_step',{pos=owner.pos})
   s.vfx_step_pos=V.vclone(owner.pos);s.vfx_step_at=now+.12
  end
 else s.vfx_step_pos=nil end
end
return M
