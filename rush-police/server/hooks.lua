-- Hooks

local hookId = exports.ox_inventory:registerHook('createItem', function(payload)
    local metadata = payload.metadata
    metadata.locker = metadata.locker or 'Unknown'
    metadata.evidence = metadata.evidence or false
    return metadata
end, {
    itemFilter = {
        raidticket = true
    }
})