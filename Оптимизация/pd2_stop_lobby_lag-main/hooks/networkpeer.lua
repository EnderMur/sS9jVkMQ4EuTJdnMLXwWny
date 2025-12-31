
local skip_first = {}
local function hook_function(func_name)
    --If the function exists, save it
    local func = NetworkPeer[func_name]

    --Since right now, we are trying to wrap functions, that are not originally in NetworkPeer, but added by Beardlib
    --So we check if the function exists 
    if func then
        --If it exists override the function, to add a check if the player is ready
        --If he is, then run the original function
        NetworkPeer[func_name] = function(self, ...)
            if not (managers.network:session() and managers.network:session():_local_peer_in_lobby()) then
                return func(self, ...)
            end

            local state = managers.menu:get_peer_state(self:id())

            --Again skip the first check to ensure loading the character
            if not skip_first[self:id()] then
                skip_first[self:id()] = true
                return func(self, ...)
            end

            if state and state ~= "lobby" then
                return
            end

            return func(self, ...)
        end
    end
end

--Names of the functions we want to wrap
local hooks = {
    "set_outfit_string_beardlib",
    "set_extra_outfit_string_beardlib",
    "beardlib_reload_outfit",
    "beardlib_reload_extra_outfit"
}

for i = 1, #hooks do
    hook_function(hooks[i])
end