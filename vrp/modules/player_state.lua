local PlayerState = class("PlayerState", vRP.Extension)

-- METHODS

function PlayerState:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/player_state")
end

-- EVENT

PlayerState.event = {}

function PlayerState.event:playerSpawn(user, first_spawn)
  if first_spawn then
    self.remote._setSaveInterval(user.source, self.cfg.save_interval)
  end
  self.remote._setStateReady(user.source, false)

  -- cascade load customization then weapons
  if not user.cdata.state.customization then
    user.cdata.state.customization = self.cfg.default_customization
  end

  if not user.cdata.state.position and self.cfg.spawn_enabled then
    local x = self.cfg.spawn_position[1]+math.random()*self.cfg.spawn_radius*2-self.cfg.spawn_radius
    local y = self.cfg.spawn_position[2]+math.random()*self.cfg.spawn_radius*2-self.cfg.spawn_radius
    local z = self.cfg.spawn_position[3]+math.random()*self.cfg.spawn_radius*2-self.cfg.spawn_radius
    user.cdata.state.position = {x=x,y=y,z=z}
  end

  if user.cdata.state.position then -- teleport to saved pos
    vRP.EXT.Base.remote.teleport(user.source,user.cdata.state.position.x,user.cdata.state.position.y,user.cdata.state.position.z)
  end

  if user.cdata.state.customization then
    self.remote.setCustomization(user.source,user.cdata.state.customization) 
  end

  if user.cdata.state.weapons then -- load saved weapons
    self.remote.giveWeapons(user.source,user.cdata.state.weapons,true)
  end

  if user.cdata.state.health then
    self.remote.setHealth(user.source,user.cdata.state.health)
  end

  if user.cdata.state.armour then
    self.remote.setArmour(user.source,user.cdata.state.armour)
  end

  self.remote._setStateReady(user.source, true)
end

function PlayerState.event:playerDeath(user)
  user.cdata.state.position = nil
  user.cdata.state.weapons = nil
  user.cdata.state.health = nil
  user.cdata.state.armour = nil
end

function PlayerState.event:characterLoad(user)
  if not user.cdata.state then
    user.cdata.state = {}
  end
end

-- TUNNEL
PlayerState.tunnel = {}

function PlayerState.tunnel:update(state)
  local user = vRP.users_by_source[source]
  if user then
    for k,v in pairs(state) do
      user.cdata.state[k] = v
    end
  end
end

vRP:registerExtension(PlayerState)
