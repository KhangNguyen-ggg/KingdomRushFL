-- Run with a standalone LÖVE runtime: love tests/volibear_passive.
local root=love.filesystem.getSource()..'/../..'
local output=os.getenv('KRFL_VOLIBEAR_TEST_OUTPUT') or love.filesystem.getSaveDirectory()
local function write(name,value)
 local f=assert(io.open(output..'/'..name,'wb'));f:write(value);f:close()
end
local function fail(err)write('result.txt','FAIL '..tostring(err));love.event.quit(1)end
love.errhand=fail
function love.load()
 local ok,err=xpcall(function()
  package.path=root..'/all/?.lua;'..root..'/lib/?.lua;'..package.path
  require('constants');TICK_LENGTH=1/FPS
  local A=require('animation_db');local Assets=require('volibear_animation_map')
  local Hands=require('volibear_hand_anchors');Assets.register('test_voli',A)
  local shader_file=assert(io.open(root..'/all-desktop/assets/shaders/p_volibear_passive.c','rb'))
  local shader=love.graphics.newShader(shader_file:read('*a'));shader_file:close()
  local q_shader_file=assert(io.open(root..'/all-desktop/assets/shaders/p_volibear_q_trail.c','rb'))
  assert(love.graphics.newShader(q_shader_file:read('*a')));q_shader_file:close()
  local G=love.graphics;local samples=love.image.newImageData(6,1)
  local colors={{220,210,205,255},{165,140,130,255},{55,18,70,255},
   {230,100,25,255},{230,70,180,255},{230,100,25,128}}
  for x,c in ipairs(colors)do samples:setPixel(x-1,0,unpack(c))end
  local canvas=G.newCanvas(6,1);G.setCanvas(canvas);G.setBlendMode('replace')
  G.setColor(255,255,255,255);G.setShader(shader);G.draw(G.newImage(samples),0,0)
  G.setShader();G.setCanvas();G.setBlendMode('alpha')
  local pixels=canvas:newImageData()
  for x,c in ipairs(colors)do
   local r,g,b,a=pixels:getPixel(x-1,0);assert(math.abs(a-c[4])<=1,'Glow changed transparency')
   if x<=3 then assert(math.abs(r-c[1])<=1 and math.abs(g-c[2])<=1 and math.abs(b-c[3])<=1,'Glow changed fur or dark armor')
   else
    -- Canvas readback premultiplies RGB by alpha.
    local alpha=c[4]/255
    assert(r>c[1]*alpha and g>c[2]*alpha and b>=c[3]*alpha,'Marking '..x..' did not emit light')
   end
  end
  assert(loadfile(root..'/all/allied_volibear.lua'))
  package.loaded['klove.shader_db']={get=function(_,name)assert(name=='p_volibear_passive');return shader end}
  local store={tick_ts=0,entities={}};local next_id=10;local inserted=0;local last_chain,last_trail,last_smoke
  local E={entities={}}
  function E:register_t(name) local t={main_script={}};self.entities[name]=t;return t end
  function E:create_entity()next_id=next_id+1;return {id=next_id,render={sprites={}}}end
  function E:clone_c()return {}end
  package.loaded.entity_db=E
  package.loaded.simulation={
   queue_insert_entity=function(_,e)
    store.entities[e.id]=e;inserted=inserted+1
    if e.kind=='chain' then last_chain=e elseif e.kind=='q_trail' then last_trail=e elseif e.kind=='r_smoke' then last_smoke=e end
   end,
   queue_remove_entity=function(_,e)e.pending_removal=true;store.entities[e.id]=nil end
  }
  local FX=require('volibear_original_vfx');FX.register()
  local body={name='attack',prefix='test_voli',ts=0,offset={x=3,y=7},time_offset=0,flip_x=false}
  local original_shader,original_args={},{}
  local frame={shader=original_shader,shader_args=original_args}
  local owner={id=1,pos={x=150,y=180},health={hp=100},unit={hit_offset={x=0,y=75}},
   render={sprites={body},frames={frame}},boss_state={voli_ready=true,stacks=4}}
  local target={id=2,pos={x=450,y=170},health={hp=100},unit={hit_offset={x=4,y=18}}}
  local other={id=3,pos={x=600,y=200},health={hp=100},unit={hit_offset={x=-3,y=32}}}
  store.entities[1],store.entities[2],store.entities[3]=owner,target,other
  FX.tick(owner,store);assert(frame.shader==original_shader and inserted==0,'Glow before five stacks')
  owner.boss_state.stacks=5;FX.tick(owner,store)
  assert(frame.shader==shader and frame.shader_args==nil and inserted==2,'Passive did not activate')
  FX.tick(owner,store);assert(inserted==2,'Duplicate passive effects')
  owner.boss_state.stacks=0;FX.tick(owner,store)
  assert(frame.shader==original_shader and frame.shader_args==original_args,'Shader not restored on expiry')
  owner.boss_state.stacks=5;FX.tick(owner,store);owner.health.dead=true;FX.tick(owner,store)
  assert(frame.shader==original_shader and frame.shader_args==original_args,'Glow survives death')
  owner.health.dead=false
  local function step(e)
   e.co=e.co or coroutine.create(E.entities.volibear_original_vfx.main_script.update)
   local success,message=coroutine.resume(e.co,e,store);assert(success,message)
  end
  local function near(a,b)assert(math.abs(a-b)<1e-6,tostring(a)..' ~= '..tostring(b))end
  local function origin(e,x,y)
   local sp=e.render.sprites[1];local half=sp.scale.x*240/2
   near(e.pos.x-math.cos(sp.r)*half,x);near(e.pos.y-math.sin(sp.r)*half,y)
  end
  local checks=0
  for _,spec in ipairs({{'attack1','attack',2},{'attack2','attack2',1},{'w_slash','w',2},
   {'q_attack','q_attack',2},{'r_attack1','attack',2},{'r_attack2','attack2',1},
   {'rw_slash','w',2},{'rq_attack','q_attack',2},{'idle8_e','idle',2},{'walk8_nw','walk',2}})do
   local tag,name,hand=unpack(spec);body.name=name
   owner.boss_state.ult_end=tag:sub(1,1)=='r' and 10 or nil
   assert(FX.chain(owner,store,owner,target)==target)
   local beam=last_chain;assert(beam.from_hand==hand,'Wrong attacking hand')
   local hands=FX.emit(owner,store,'p_hands',{follow_id=owner.id})
   for _,flip in ipairs({false,true})do
    body.flip_x=flip
    for n=1,Assets.clips[tag].count do
     body.animation={prefix='volibear_native_'..tag,frames={n}}
     step(beam);step(hands)
     local sp=hands.render.sprites[hand]
     origin(beam,owner.pos.x+sp.offset.x,owner.pos.y+sp.offset.y);checks=checks+1
    end
   end
  end
  owner.boss_state.ult_end=nil;body.name='attack2';body.flip_x=true
  body.animation=A.db.test_voli_attack2;body.time_offset=7/FPS
  FX.chain(owner,store,owner,target);local beam=last_chain
  local hands=FX.emit(owner,store,'p_hands',{follow_id=owner.id});step(beam);step(hands)
  local point=Hands.poses[A:fni(body.animation,body.time_offset,false)]
  origin(beam,owner.pos.x+body.offset.x-point[1]*Assets.model_units,owner.pos.y+body.offset.y+point[2]*Assets.model_units)
  owner.pos.x=owner.pos.x+21;store.tick_ts=.05;step(beam);step(hands)
  origin(beam,owner.pos.x+hands.render.sprites[1].offset.x,owner.pos.y+hands.render.sprites[1].offset.y)
  FX.chain(owner,store,target,other);local bounce=last_chain
  assert(not bounce.from_hand,'Bounce attached to owner hand');step(bounce)
  origin(bounce,target.pos.x+4,target.pos.y+18)
  target.pos.x=target.pos.x+17;step(bounce);origin(bounce,target.pos.x+4,target.pos.y+18)
  other.health.dead=true;step(bounce);assert(bounce.pending_removal,'Dead endpoint retained')
  store.tick_ts=1;step(beam);assert(beam.pending_removal,'Beam outlives animation')
  local Back=require('volibear_back_anchors');local Planes=require('volibear_back_planes')
  local aura=FX.emit(owner,store,'p_aura',{follow_id=owner.id});local aura_ts=aura.render.sprites[1].ts
  local plane_checks=0
  for name,pose in pairs(Back.poses)do
   local plane=assert(Planes[name],name)
   assert(plane[2]>0 and plane[2]<2 and plane[3]>0 and plane[3]<2 and plane[4]>=0 and plane[4]<=8,'Invalid back plane')
   body.animation={prefix=name:sub(1,-6),frames={tonumber(name:sub(-4))}}
   for _,flip in ipairs({false,true})do
    body.flip_x=flip;step(aura)
    local sp=aura.render.sprites[1];local sign=pose[5]<0 and flip and -1 or 1
    near(aura.pos.x,owner.pos.x+body.offset.x+pose[1]*Assets.model_units*sign)
    near(aura.pos.y,owner.pos.y+body.offset.y+pose[2]*Assets.model_units)
    near(sp.r,plane[1]*sign);near(sp.scale.x/sp.scale.y,plane[2]/plane[3])
    assert(sp.ts==aura_ts,'Back pose change restarts passive animation');plane_checks=plane_checks+1
   end
  end
  owner.boss_state.stacks=0;step(aura);assert(aura.pending_removal,'Back aura survives passive expiry')
  body.name='walk';body.volibear_native_tag='qrun8_e';body.animation=A.db.test_voli_qrun8_e;body.ts=store.tick_ts
  owner.boss_state.q_end=store.tick_ts+3;FX.tick(owner,store)
  assert(not last_trail,'Q emits a trail while stationary')
  owner.pos.x=owner.pos.x+12;store.tick_ts=store.tick_ts+.1;FX.tick(owner,store)
  local trail=assert(last_trail,'Q movement emits no trail');step(trail)
  for _,sp in ipairs(trail.render.sprites)do
   assert(sp.shader=='p_volibear_q_trail' and sp.alpha>0,'Q uses wrong trail effect')
   assert(sp.z==Z_OBJECTS and sp.sort_y>owner.pos.y,'Q trail draws over its owner')
  end
  local alpha=trail.render.sprites[1].alpha;store.tick_ts=store.tick_ts+.1;step(trail)
  assert(trail.render.sprites[1].alpha<alpha,'Q trail does not fade')
  FX.tick(owner,store);assert(last_trail==trail,'Stationary Q keeps emitting')
  owner.boss_state.q_end=nil;owner.pos.x=owner.pos.x+12;store.tick_ts=store.tick_ts+.15;FX.tick(owner,store)
  assert(last_trail==trail,'Trail emitted after Q ends');step(trail);assert(trail.pending_removal,'Q trail not removed')
  owner.boss_state.q_end=store.tick_ts+2;owner.unit.is_stunned=true;FX.tick(owner,store)
  owner.pos.x=owner.pos.x+12;store.tick_ts=store.tick_ts+.1;FX.tick(owner,store)
  assert(last_trail==trail,'Stunned Q emits trails')
  owner.unit.is_stunned=false;body.volibear_native_tag='rqrun8_ne';owner.boss_state.ult_end=store.tick_ts+2
  body.animation=A.db.test_voli_rqrun8_ne;FX.tick(owner,store)
  owner.pos.x=owner.pos.x+8;owner.pos.y=owner.pos.y+8;store.tick_ts=store.tick_ts+.1;FX.tick(owner,store)
  assert(last_trail~=trail,'R+Q emits no trail');step(last_trail)
  near(last_trail.render.sprites[2].scale.y,92*1.25/256)
  owner.boss_state.q_end=nil;owner.boss_state.ult_end=nil;FX.tick(owner,store)
  local before_r=inserted;owner.boss_state.ult_end=store.tick_ts+12;FX.tick(owner,store)
  local smoke=assert(last_smoke,'R has no dark smoke');assert(inserted==before_r+1)
  FX.tick(owner,store);assert(inserted==before_r+1,'R emits duplicate smoke')
  step(smoke);assert(smoke.render.sprites[1].alpha==0,'R smoke does not fade in')
  store.tick_ts=store.tick_ts+.2;owner.pos.x=owner.pos.x+25;body.z=Z_FLYING_HEROES;step(smoke)
  local sp=smoke.render.sprites[1];assert(sp.alpha==255 and sp.loop and sp.z==Z_FLYING_HEROES,'R smoke does not follow flight')
  local pose=Back.poses[A:fni(body.animation,store.tick_ts-body.ts,false,body.fps)]
  local sign=pose[5]<0 and body.flip_x and -1 or 1
  near(smoke.pos.x,owner.pos.x+body.offset.x+pose[6]*Assets.model_units*1.25*sign)
  near(smoke.pos.y,owner.pos.y+body.offset.y+pose[7]*Assets.model_units*1.25)
  assert(sp.sort_y>owner.pos.y,'R smoke covers its owner')
  owner.boss_state.ult_end=store.tick_ts+15;step(smoke);assert(not smoke.pending_removal,'Recast truncates R smoke')
  store.tick_ts=owner.boss_state.ult_end-.1;step(smoke);assert(sp.alpha>0 and sp.alpha<255,'R smoke does not fade out')
  store.tick_ts=owner.boss_state.ult_end;step(smoke);assert(smoke.pending_removal,'R smoke survives expiry')
  FX.tick(owner,store);owner.boss_state.ult_end=store.tick_ts+12;FX.tick(owner,store)
  owner.health.dead=true;step(last_smoke);assert(last_smoke.pending_removal,'R smoke survives death')
  local r_frames=0
  for _,atlas in ipairs({'go_volibear_native_r_impact_visualfix_p01','go_volibear_native_r_impact_visualfix_p02',
   'go_volibear_native_r_outro_visualfix_p01','go_fx_volibear_prestige_r_smoke','go_fx_volibear_native_r_landingimpact_01_atmosphere_p01'})do
   local meta=assert(loadfile(root..'/kr3-desktop/assets/images/fullhd/'..atlas..'.lua'))()
   local f=assert(io.open(root..'/kr3-desktop/assets/images/fullhd/'..atlas..'.png','rb'))
   local tex=G.newImage(love.filesystem.newFileData(f:read('*a'),atlas..'.png'));f:close()
   for _,s in pairs(meta)do
    local q=s.f_quad;assert(s.a_size[1]==tex:getWidth() and s.a_size[2]==tex:getHeight(),'Invalid R atlas size')
    assert(q[1]>=0 and q[2]>=0 and q[1]+q[3]<=s.a_size[1] and q[2]+q[4]<=s.a_size[2],'Invalid R frame bounds')
    r_frames=r_frames+1
   end
  end
  assert(r_frames==75,'R body/smoke/native dragon frames missing')
  write('result.txt','PASS: shader compiled; fur/dark armor unchanged; gold/pink markings lit; alpha preserved; passive activation/expiry/death; '..checks..
   ' hand/frame/flip checks; animation offset; moving owner; moving chain bounce; dead target and expiry; '..plane_checks..
   ' back plane/flip/phase checks; Q movement/stationary/end/stun/R scale/fade/removal; R smoke start/follow/depth/recast/fades/expiry/death; 75 R frames loaded on GPU including native gold dragon.')
 end,debug.traceback)
 if not ok then fail(err)else love.event.quit(0)end
end
