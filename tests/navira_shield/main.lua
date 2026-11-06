-- Run with a standalone LÖVE runtime: love tests/navira_shield.
local root=love.filesystem.getSource()..'/../..'
local output=os.getenv('KRFL_NAVIRA_TEST_OUTPUT') or love.filesystem.getSaveDirectory()
local function write(value)local f=assert(io.open(output..'/result.txt','wb'));f:write(value);f:close()end
local function fail(err)write('FAIL '..tostring(err));love.event.quit(1)end
love.errhand=fail
function love.load()
 local ok,err=xpcall(function()
  package.path=root..'/all/?.lua;'..root..'/lib/?.lua;'..package.path
  require('constants');require('klua.table');TICK_LENGTH=1/FPS
  local A=require('animation_db');local inserted={};local next_id=10
  local store={tick_ts=0,entities={},damage_queue={}}
  local C={}
  function C.alive(e)return e and not e.pending_removal and e.health and not e.health.dead and e.health.hp>0 end
  function C.state(e)e.boss_state=e.boss_state or {};return e.boss_state end
  function C.copy(p)return {x=p.x,y=p.y}end
  function C.dist(a,b)return math.sqrt((a.x-b.x)^2+(a.y-b.y)^2)end
  function C.insert(e)inserted[#inserted+1]=e;store.entities[e.id]=e end
  function C.remove(e)e.pending_removal=true;store.entities[e.id]=nil end
  function C.visual()end
  local E={entities={}}
  function E:register_t(name)local t={render={sprites={},frames={}},main_script={}};self.entities[name]=t;return t end
  function E:clone_c()return {offset={x=0,y=0},time_offset=0}end
  function E:create_entity(name)local e=table.deepclone(self.entities[name]);next_id=next_id+1;e.id=next_id;e.template_name=name;return e end
  package.loaded.allied_boss_common=C;package.loaded.entity_db=E
  package.loaded.utils={get_blocker=function()end,predict_damage=function(_,d)return d.value end}
  local storage={slot={liuhui={navira_blue_level=1}}};package.loaded.storage=storage
  local M=require('navira_duelist')
  local function owner(id,enemy)
   local e={id=id,pos={x=100,y=120},unit={hit_offset={x=2,y=40}},health={hp=50,hp_max=100},
    soldier={target_id=-1},melee={},main_script={update=function()while true do coroutine.yield()end end},
    render={sprites={{z=Z_OBJECTS,sort_y_offset=5}}},enemy=enemy and {blockers={}} or nil}
   M.apply(e);store.entities[id]=e;return e
  end
  local function step(e)
   e.co=e.co or coroutine.create(e.main_script.update)
   local success,message=coroutine.resume(e.co,e,store);assert(success,message)
  end
  local function near(a,b)assert(math.abs(a-b)<1e-7,tostring(a)..' ~= '..tostring(b))end
  local ally=owner(1);M.tick(ally,store)
  assert(#inserted==1,'Idle ally did not start its shield');local shield=inserted[1]
  assert(shield.expires==4 and #shield.render.sprites==2,'Invalid shield duration or layers')
  step(shield);assert(shield.render.sprites[1].alpha==0,'No shield fade-in')
  store.tick_ts=.2;step(shield);M.tick(ally,store)
  assert(#inserted==1,'Duplicate shield entity')
  for _,sp in ipairs(shield.render.sprites)do assert(sp.alpha==255 and sp.loop and sp.fps==24 and not sp.shader)end
  assert(shield.render.sprites[1].sort_y>125 and shield.render.sprites[2].sort_y<125,'Shield does not surround its owner')
  near(shield.pos.x,102);near(shield.pos.y,160)
  ally.pos.x,ally.pos.y=150,200;ally.render.sprites[1].z=Z_FLYING_HEROES;ally.render.sprites[1].sort_y=230
  step(shield);near(shield.pos.x,152);near(shield.pos.y,240)
  assert(shield.render.sprites[1].z==Z_FLYING_HEROES and shield.render.sprites[2].z==Z_FLYING_HEROES)
  assert(shield.render.sprites[1].sort_y>230 and shield.render.sprites[2].sort_y<230,'Explicit owner depth ignored')
  local hp=ally.health.hp
  assert(ally.health.on_damage(ally,store,{source_id=999,value=12,damage_type=DAMAGE_PHYSICAL})==false)
  near(ally.health.hp,hp+12)
  store.tick_ts=3.95;step(shield);assert(shield.render.sprites[1].alpha>0 and shield.render.sprites[1].alpha<255,'No shield fade-out')
  store.tick_ts=4;step(shield);assert(shield.pending_removal,'Shield survives expiry');M.tick(ally,store)
  assert(#inserted==1,'Shield appears during its rest phase')
  hp=ally.health.hp;assert(ally.health.on_damage(ally,store,{source_id=999,value=12,damage_type=DAMAGE_PHYSICAL})==true);near(ally.health.hp,hp)
  A.db.navira_blue_conversion_shield_back=nil;A.db.navira_blue_conversion_shield_front=nil
  store.tick_ts=6;M.tick(ally,store);assert(#inserted==2 and inserted[2].expires==10,'Four-on/two-off rhythm changed')
  assert(A.db.navira_blue_conversion_shield_front and A.db.navira_blue_conversion_shield_back,'Animations not restored after reload')
  ally.health.dead=true;step(inserted[2]);assert(inserted[2].pending_removal,'Dead owner retains its shield')
  local enemy=owner(2,true);M.tick(enemy,store);assert(#inserted==2,'Boss starts its shield before entering combat')
  enemy.navira_duel_fighting=true;M.tick(enemy,store);local boss_shield=inserted[#inserted]
  assert(boss_shield.owner_id==2 and boss_shield.expires==10,'Fighting boss shield missing')
  enemy.navira_duelist=nil;step(boss_shield);assert(boss_shield.pending_removal,'Shield survives Solo removal')
  local skip=owner(3);M.tick(skip,store);local count=#inserted
  store.tick_ts=20.25;M.tick(skip,store)
  assert(#inserted==count+1 and inserted[#inserted].expires==22,'Skipped updates change the shield cycle')
  storage.slot.liuhui.navira_blue_level=0;local off=owner(4);count=#inserted;M.tick(off,store)
  assert(not off.navira_duelist and #inserted==count,'Solo-off owner receives a shield')
  local frame_count=0
  for _,atlas in ipairs(M.shield_textures)do
   local meta=assert(loadfile(root..'/kr3-desktop/assets/images/fullhd/'..atlas..'.lua'))()
   local f=assert(io.open(root..'/kr3-desktop/assets/images/fullhd/'..atlas..'.png','rb'))
   local texture=love.graphics.newImage(love.filesystem.newFileData(f:read('*a'),atlas..'.png'));f:close()
   for _,s in pairs(meta)do
    assert(s.a_size[1]==texture:getWidth() and s.a_size[2]==texture:getHeight(),'Atlas dimensions mismatch')
    local q=s.f_quad;assert(q[1]>=0 and q[2]>=0 and q[1]+q[3]<=s.a_size[1] and q[2]+q[4]<=s.a_size[2])
    frame_count=frame_count+1
   end
  end
  assert(frame_count==96,'Missing shield frames')
  local before=A:fn('navira_blue_conversion_shield_front',0,true,24)
  assert(before~=A:fn('navira_blue_conversion_shield_front',.5,true,24),'Swirl does not animate')
  assert(before==A:fn('navira_blue_conversion_shield_front',2,true,24),'Swirl loop has the wrong period')
  write('PASS: 96 atlas frames loaded on GPU; two-layer depth; movement/flying; fades; 4s active/2s rest; idle ally/fighting boss; expiry/death/Solo-off; skipped ticks; animation reload/loop; damage-to-healing unchanged.')
 end,debug.traceback)
 if not ok then fail(err)else love.event.quit(0)end
end
