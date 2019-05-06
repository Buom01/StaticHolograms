PLUGIN = nil

function Initialize(Plugin)
	Plugin:SetName("StaticHolograms")
	Plugin:SetVersion(3)

	-- Hooks

	PLUGIN = Plugin -- NOTE: only needed if you want OnDisable() to use GetName() or something like that

	-- Command Bindings
  cPluginManager.BindCommand("/sholograms", "sholograms", MainHandler, " ~ Manage holograms")


	LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
	return true
end

function OnDisable()
	LOG(PLUGIN:GetName() .. " is shutting down...")
end

function MainHandler(Split, Player)
	if Split[2] == "list" then
		PrintList(Player)
	elseif Split[2] == "add" then
		AddHologram(Split, Player)
	elseif Split[2] == "remove" then
		RemoveHologram(Split, Player)
	elseif Split[2] == "move" then
		MoveHologram(Split, Player)
	elseif Split[2] == "edit" then
		EditHologram(Split, Player)
	else
		PrintUsage(Player)
	end
	return true
end

function IsAnHologram(Entity)
	return (Entity:IsArmorStand() and Entity:IsInvisible() and Entity:HasCustomName() and Entity:IsCustomNameAlwaysVisible() and Entity:IsMarker() and not Entity:HasGravity())
end

function GetText(Split, Begin)
	local Text = Split[Begin]
	for i=Begin+1, #Split do
		Text = Text .. " " .. Split[i]
	end
	Text = Text:gsub("%&", "§")
	return Text
end

function PrintUsage(Player)
	Player:SendMessageInfo("Usage: /sholograms [list|add|remove|move|edit] <id> <x> <y> <z> <text> ~ Always apply in your current world")
	return true
end

function PrintList(Player)
	Player:SendMessageInfo("Here is the list of all holograms (in loaded chunks only)")
	Player:SendMessageInfo("ID | World | X Y Z | Text")
	cRoot:Get():ForEachWorld(
		function(World)
			World:ForEachEntity(
				function(Entity)
					if (IsAnHologram(Entity)) then
						Player:SendMessageInfo(Entity:GetUniqueID() .. " | " .. World:GetName() .. " | ".. Entity:GetPosX() .. " " .. Entity:GetPosY() .. " " .. Entity:GetPosZ() .. " | " .. Entity:GetCustomName())
					end
				end
			)
		end
	)
end

function AddHologram(Split, Player)
	local X = tonumber(Split[3])
	local Y = tonumber(Split[4])
	local Z = tonumber(Split[5])
	if (X == nil or Y == nil or Z == nil) then  -- If the player pass invalid numbers (or don't pass it at all)
		return PrintUsage(Player)
	end

	local Text = GetText(Split, 6)

	local World = Player:GetWorld()

	local ArmorStandId = World:SpawnArmorStand(Vector3d(X, Y, Z), 0)

	if ArmorStandId == INVALID_ID then
		return Player:SendMessageFailure("Failed to spawn the hologram")
	end

	World:DoWithEntityByID(
		ArmorStandId,
		function(ArmorStand)
			ArmorStand:SetGravity(0)
			ArmorStand:SetMarker()
			ArmorStand:SetVisible(false)
			ArmorStand:SetCustomName(Text)
			ArmorStand:SetCustomNameAlwaysVisible(true)
			Player:SendMessageSuccess("Hologram successfully spawn at ("..X..", "..Y..", "..Z..") in world "..World:GetName().." with the ID "..ArmorStandId.." and the text: "..Text)
		end
	)
end

function RemoveHologram(Split, Player)
	local ArmorStandId = tonumber(Split[3])
	if (ArmorStandId == nil) then  -- If the player pass invalid numbers
		return PrintUsage(Player)
	end

	local wasDestroyed = Player:GetWorld():DoWithEntityByID(
		ArmorStandId,
		function(ArmorStand)
			if (IsAnHologram(ArmorStand)) then
				ArmorStand:Destroy()
				Player:SendMessageSuccess("Hologram successfully destroyed")
				return true
			end
			return false
		end
	)
	if (not wasDestroyed) then
		Player:SendMessageFailure("No such hologram in world "..Player:GetWorld():GetName())
	end
end

function MoveHologram(Split, Player)
	local ArmorStandId = tonumber(Split[3])
	local X = tonumber(Split[4])
	local Y = tonumber(Split[5])
	local Z = tonumber(Split[6])
	if (ArmorStandId == nil or X == nil or Y == nil or Z == nil) then  -- If the player pass invalid numbers (or don't pass it at all)
		return PrintUsage(Player)
	end

	local wasMoved = Player:GetWorld():DoWithEntityByID(
		ArmorStandId,
		function(ArmorStand)
			if (IsAnHologram(ArmorStand)) then
				ArmorStand:SetPosition(Vector3d(X,Y,Z))
				Player:SendMessageSuccess("Hologram successfully moved")
				Player:SendMessageInfo("You might need to reconnect to see the move")
				return true
			end
			return false
		end
	)
	if (not wasMoved) then
		Player:SendMessageFailure("No such hologram in world "..Player:GetWorld():GetName())
	end
end

function EditHologram(Split, Player)
	local ArmorStandId = tonumber(Split[3])
	if (ArmorStandId == nil or #Split < 4) then  -- If the player pass invalid numbers (or don't pass it at all)
		return PrintUsage(Player)
	end

	local Text = GetText(Split, 4)

	local wasEdited = Player:GetWorld():DoWithEntityByID(
		ArmorStandId,
		function(ArmorStand)
			if (IsAnHologram(ArmorStand)) then
				ArmorStand:SetCustomName(Text)
				Player:SendMessageSuccess("Hologram successfully edited")
				return true
			end
			return false
		end
	)
	if (not wasEdited) then
		Player:SendMessageFailure("No such hologram in world "..Player:GetWorld():GetName())
	end
end
