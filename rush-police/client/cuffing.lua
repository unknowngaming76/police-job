local Brazzers = exports['brazzers-lib']:getLib()

cuffing = {}

local dialogue = {}

-- Functions

function cuffing.menu()
    local menu, data = {}, lib.callback.await('cuff:menuData')
    menu = data

    lib.registerContext({
        id = 'cuffing:menu',
        title = 'Criminals Cuffed',
        options = menu,
        filter = true,
    })
    lib.showContext('cuffing:menu')
end

function cuffing.addUser()
    local result = lib.callback.await('cuff:addUser')
    if not result then return end
end

function dialogue.openDialog(entity, name)
    local data = {}

    data.dialogue = {
        name = name,
        text = 'Checkout all the latest and greatest cuffed thugs.',
        job = 'DOC',
        buttons = {}
    }

    data.dialogue.buttons[#data.dialogue.buttons + 1] = {
        label = 'View Cuffed List', close = true,
        onSelect = function()
            cuffing.menu()
        end,
    }

    data.dialogue.buttons[#data.dialogue.buttons + 1] = {
        label = 'Leave Conversation', close = true,
    }

    exports['brazzers-lib']:openDialogue(entity, data)
end

-- Threads

CreateThread(function()
    for k, v in pairs(Config.Cuffing) do
        Brazzers.addPed({ 
            model = `csb_cop`,
            dist = 50,
            coords = vec3(v.coords.x, v.coords.y, v.coords.z),
            heading = v.coords.w,
            snapToGround = true,
            scenario = 'WORLD_HUMAN_CLIPBOARD',
            freeze = true,
            invincible = true,
            tempevents = true,
            id = 'brazzers:cuffing_'..k,
            target = {
                {
                    name = 'dialogue-ped',
                    icon = 'fa-regular fa-comment',
                    label = 'Talk',
                    id = 'dialogue-ped',
                    onSelect = function(entityTable)
                        dialogue.openDialog(entityTable.entity, v.name)
                    end,
                },
            },
        })
    end
end)