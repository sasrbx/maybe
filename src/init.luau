--!strict

local Maybe = {}
Maybe.__index = Maybe
Maybe.ClassName = "Maybe"

function Maybe.new<T>(value: T?, customErrorMessage: string?): Maybe<T>
    local self = setmetatable({}, Maybe)
    self._value = value
    self._customErrorMessage = customErrorMessage

    return self :: Maybe<T>
end

function Maybe.pcall<TupleType, ReturnType>(
    callback: (...TupleType) -> ReturnType,
    ...: TupleType
): Maybe<ReturnType>

    local success: boolean, resultOrError: ReturnType | string = pcall(callback, ...)
    if success then
        local result: ReturnType = resultOrError :: ReturnType
        return Maybe.new(result, "Wrapped result was nil")
    else
        local errorMessage: string = resultOrError :: string
        return Maybe.new(nil, errorMessage)
    end
end

function Maybe.retry<TupleType, ReturnType>(
    retryAmount: number,
    callback: (...TupleType) -> ReturnType, ...: TupleType
): Maybe<ReturnType>

    local result = Maybe.new(nil, "Could not compute value (retry)")
    local currentCounter: number = 0
    while not result:Exists() and currentCounter <= retryAmount do
        result = Maybe.pcall(callback, ...)
        if result:Exists() then
            break
        end

        -- Use exponential backoff to prevent overloading roblox's servers
        task.wait(2^currentCounter)
    end

    return result
end

function Maybe:GetError(): string
    return self._customErrorMessage
end

function Maybe:Is<T>(otherValue: unknown | Maybe<T?>): boolean
    if typeof(otherValue) == "table" and otherValue.ClassName == "Maybe" then
        return self._value == otherValue:Unwrap()
    else
        return self._value == otherValue
    end
end

function Maybe:Unwrap<T>(): T
    assert(self:Exists(), self._customErrorMessage or "Expected value to be non-nil")
    return self._value
end

function Maybe:Exists(): boolean
    return self._value ~= nil
end

export type Maybe<T> = {
    ClassName: "Maybe",
    GetError: (self: Maybe<T?>) -> string,
    Is: (self: Maybe<T?>, otherValue: unknown | Maybe<T>) -> boolean,
    Unwrap: (self: Maybe<T?>) -> T,
    Exists: (self: Maybe<T?>) -> boolean,
}

return Maybe
