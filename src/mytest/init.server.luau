--!strict
local Players = game:GetService("Players")

local Maybe = require(script.Parent)

type Maybe<T> = Maybe.Maybe<T>

local function doSomeAsyncTask(plot)
    --...
    print(plot)
    return false
end

local function getOwner(plot): Maybe<{ Stuff: number }>
    local success = doSomeAsyncTask(plot) -- errors
    return Maybe.new(
        if success then { Stuff = 5 } 
        else nil,

        "Owner did not exist"
    )
end

local maybeOwner = getOwner({
    Key = "3u2349827",
})

if maybeOwner:Exists() then
    local owner = maybeOwner:Unwrap()
    print("Owner found:", owner.Stuff)
else
    print("Owner not found:", maybeOwner:GetError())
end

local maybeCharacterAppearanceInfo: Maybe<{ [string]: any }> = Maybe.pcall(
    Players.GetCharacterAppearanceInfoAsync, Players, 1
)

if maybeCharacterAppearanceInfo:Exists() then
    local characterAppearanceInfo = maybeCharacterAppearanceInfo:Unwrap()   
    print(characterAppearanceInfo)
else
    print(maybeCharacterAppearanceInfo:GetError())
end

--[[
local maybeCharacterAppearanceInfo: Maybe<{[string]: any}> = Maybe.retry(5, Players.GetCharacterAppearanceInfoAsync, Players, 1)
if maybeCharacterAppearanceInfo:Exists() then
    local characterAppearanceInfo = maybeCharacterAppearanceInfo:Unwrap()
    print(characterAppearanceInfo)
else
    print("Could not find anything LOL")
end
]]