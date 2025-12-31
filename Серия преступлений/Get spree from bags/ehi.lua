if not _G.EHI then
    return
end

Hooks:PostHook(EHI,"IsPlayingCrimeSpree","IsPlayingCrimeSpreeBagged",function()
    return false
end)