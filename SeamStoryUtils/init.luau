--[=[
    Utilities for hooking up Seam to UI Labs for UI stories.

    @class SeamStoryUtils
]=]

local SeamStoryUtils = {}

-- Imports
local Seam = require(script.Parent.Seam)

--[=[
    Returns reactive Seam value states based on the generic controls of a UI labs story.

    @prop Scope Scope -- The Seam scope
    @prop Props {[any] : any} -- The `props` table passed into the generic story
    @return {[string] : Seam.ValueInstance<any>} -- The dictionary of controls mapped to value states
]=]

function SeamStoryUtils.GetValuesFromControls(Scope : Seam.Scope, Props : {[any] : any}) : {[string] : Seam.ValueInstance<any>}
    if not Scope then
        error("Scope required to get values from controls")
    end

    local Values : {[string] : Seam.ValueInstance<any>} = {}

    for Index, ControlValue in Props.controls do
        Values[Index] = Scope:Value(ControlValue)
    end

    local Unsubscribe = Props.subscribe(function(_, Data)
        for Index, Info in Data do
            if not Values[Index] then
                continue
            end

            if Info.__new ~= Info.__old then
                Values[Index].Value = Info.__new 
            end
        end
    end)

    Scope:AddObject(Unsubscribe)

    return Values
end

--[=[
    Returns a function that cleans up the scope

    @prop Scope Scope -- The Seam scope
    @return () -> nil -- The wrapped cleanup function
]=]

function SeamStoryUtils.WrappedScopeCleanup(Scope : Seam.Scope) : () -> nil
    return function()
        Scope:Destroy()
    end
end

return SeamStoryUtils