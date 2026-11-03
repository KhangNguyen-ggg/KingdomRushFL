-- Camera-space headings and per-clip projection keep the feet and model size stable.
local M={}
local A
local Assets=require('volibear_animation_map')
local directions={'e','ne','n','nw','w','sw','s','se'}
local walking={walk=true,walkUp=true,walkDown=true}
local aliases={attack='attack1',w='w_slash',walk='run',walkUp='run',walkDown='run',levelup='idle'}
local empowered={attack1='r_attack1',attack2='r_attack2',q_intro='rq_intro',q_attack='rq_attack',q_outro='rq_outro',q_idle='rq_idle',w_slash='rw_slash',e_idle='re_idle'}
function M.register(_,animations) A=animations end
function M.update(this,store,s)
 local sp=this.render.sprites[1];local previous=sp.animation
 local ult=s.ult_end and store.tick_ts<s.ult_end
 local moving=walking[sp.name] and not this.unit.is_stunned and not this.health.dead
 local tag
 if walking[sp.name] or sp.name=='idle' then
  if moving and this.motion.dest and not this.motion.arrived then
   local dx,dy=this.motion.dest.x-this.pos.x,this.motion.dest.y-this.pos.y
   if dx*dx+dy*dy>.0001 then s.move_direction=math.floor((math.atan2(dy,dx)+math.pi/8)/(math.pi/4))%8 end
  end
  local clip=moving and (s.q_end and (ult and 'rqrun8' or 'qrun8') or ult and 'rrun8' or 'walk8')
   or s.q_end and (ult and 'rq_idle' or 'q_idle') or ult and 'ridle8' or 'idle8'
  if s.move_clip~=clip then sp.ts=store.tick_ts;sp.runs=0;s.move_clip=clip end
  if clip:sub(-1)=='8' then
   tag=clip..'_'..directions[(s.move_direction or 0)+1];sp.flip_x=false
   sp.volibear_move_direction=s.move_direction or 0
  else
   tag=clip;sp.flip_x=not ((s.move_direction or 0)>=3 and (s.move_direction or 0)<=5)
   sp.volibear_move_direction=nil
  end
 else
  s.move_clip=nil;sp.volibear_move_direction=nil
  if sp.name=='attack' or sp.name=='attack2' or sp.name=='q_intro' or sp.name=='q_attack' or sp.name=='w' or sp.name=='e_idle' or sp.name=='jump' then s.move_direction=sp.flip_x and 0 or 4 end
  tag=aliases[sp.name] or sp.name
  if ult then tag=empowered[tag] or tag end
 end
 local info=assert(Assets.clips[tag],'Missing Volibear projection: '..tostring(tag))
 sp.animation=assert(A.db[sp.prefix..'_'..tag]);sp.volibear_native_tag=tag
 sp.anchor.x,sp.anchor.y=info.x,info.y
 local scale=info.world/(info.canvas or 256)*Assets.model_units*(ult and sp.name~='death' and sp.name~='respawn' and 1.25 or 1)
 sp.scale.x,sp.scale.y=scale,scale
 if previous~=sp.animation then sp._render_state_ts=nil end
end
return M
