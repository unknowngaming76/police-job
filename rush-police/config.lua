QBCore = exports['qb-core']:GetCoreObject()
Config = Config or {}

Config.Debug = true
Config.EmployeeEarnings = 20 -- 10 %
Config.BusinessEarnings = 80 -- 90 %

Config.PoliceGroups = {'police','sasp','bcso','ambulance', 'state'}

Config.Difficulty = {
    [1] = 1,
    [2] = 5,
    [3] = 3,
}

Config.Cuffing = {
    {
        name = 'Robert Miller',
        coords = vector4(479.37, -991.76, 26.39, 270.36),
    },
    {
        name = 'Joseph Davis',
        coords = vector4(1826.95, 3679.83, 29.66, 298.89),
    },
}

Config.UseTarget = 'ox_target'
Config.Locations = {
    ["duty"] = {
        [1] = vector3(441.02142333984, -980.10760498047, 30.898445129395), -- MRPD
        [2] = vec3(201.23, -808.44, 30.03), -- SANDY
        [3] = vector3(1769.13, 2571.09, 45.25), -- PRISON
        [4] = vector3(384.81, 795.05, 187.46), -- RANGERS
    },
    ["clothing"] = {
        [1] = vector3(480.73, -1010.75, 30.69), -- MRPD Male
        [2] = vector3(475.32, -992.39, 30.69), -- MRPD Female
        [3] = vector3(1828.19, 3678.04, 35.21), -- SANDY
        [4] = vector3(387.3, 799.8, 187.46), -- RANGERS
    },
    ["armory"] = {
        [1] = vector3(453.42358398438, -980.33941650391, 31.504810333252), -- MRPD
        [2] = vector3(1820.18, 3666.84, 30.31), -- Sandy Downstairs
        [3] = vector3(1833.8, 3695.3, 34.71), -- SANDY
        [4] = vector3(377.24, 799.46, 187.46), -- RANGERS
        [5] = vector3(1772.37, 2573.33, 45.73), -- PRISON
    },
    ["trash"] = {
        [1] = vector3(477.06, -989.24, 30.69), -- MRPD
        [2] = vector3(1823.01, 3663.27, 30.31), -- SANDY
        [3] = vector3(378.67, 797.75, 190.49), -- RANGERS
    },
    ["fridges"] = {
        [1] = vector3(447.58, -995.27, 30.68), --lspd 1
        [2] = vector3(464.76, -991.51, 26.38), -- lspd 2
        [3] = vector3(461.14, -976.19, 30.68), -- lspd 3
        [4] = vector3(1829.41, 3683.85, 39.12), -- bcso 1
    },
    ["helicopter"] = {
        [1] = { -- MRPD 
            ped = vector4(459.73, -978.97, 43.69, 123.66),
            spawn = vector4(448.22, -981.0, 42.69, 57.48),
        },
        [2] = { -- SANDY PD
            ped = vector4(1824.26, 3676.74, 42.98, 306.22),
            spawn = vector4(1824.12, 3686.38, 43.39, 118.99),
        },  
        [3] = { -- PALETO PD
            ped = vector4(-462.84, 6002.38, 31.49, 143.48),
            spawn = vector4(-475.25, 5988.52, 30.73, 316.1),
        }, 
        [4] = { -- Central LS
            ped = vector4(319.69, -1457.75, 46.51, 92.26),
            spawn = vector4(313.62, -1465.08, 46.9, 323.2),
        }, 
        [5] = { -- Sandy Medical
            ped = vector4(1647.34, 3654.7, 35.34, 210.62),
            spawn = vector4(1637.64, 3653.13, 35.73, 211.86),
        },
    },

    ["stations"] = {
        [1] = {label = "Mission Row Police Station", coords = vector4(428.23, -984.28, 29.76, 3.5)},
        [2] = {label = "Sandy Police Station", coords = vector4(1836.86, 3678.89, 35.88, 209.92)},
    },
}

Config.Helicopter = {
    ["lspd"] = {
        heli = "rhpdheli",
        livery = 0
    },
    ["bcso"] = {
        heli = "rhpdheli",
        livery = 1
    },
    ["sasp"] = {
        heli = "rhpdheli",
        livery = 2
    },
    ["ems"] = {
        heli = "rhemsheli",
        livery = 0
    },
    ["police"] = {
        heli = "rhemsheli",
        livery = 0
    }
}

Config.Items = {
    {
        name = "pistol_ammo",
        price = 3,
    },
    {
        name = "rifle_ammo",
        price = 7,
    },
    {
        name = "shotgun_ammo",
        price = 5,
    },
    {
        name = "smg_ammo",
        price = 5,
    },
    {
        name = "taser_ammo",
        price = 15,
    },
    {
        name = "repairkit",
        price = 570,
    },
    {
        name = "binoculars",
        price = 750,
    },
    {
        name = "heavyarmor",
        price = 500,
    },
    {
        name = "weapon_glock",
        price = 800,
    },
    {
        name = "weapon_fn57",
        price = 1250,
    },
    {
        name = "weapon_taser",
        price = 800,
    },
    {
        name = "weapon_nightstick",
        price = 400,
    },
    {
        name = "weapon_fireextinguisher",
        price = 450,
    },
    {
        name = "radio",
        price = 500,
    },
    {
        name = "nikon",
        price = 700,
    },
    {
        name = "sdcard",
        price = 150,
    },
    {
        name = "weapon_flashlight",
        price = 750,
    },
    {
        name = "ifak",
        price = 150,
    },
    {
        name = "weapon_m4",
        price = 4000,
    },
    {
        name = "grapple_gun",
        price = 8000,
    },
    {
        name = "weapon_specialcarbine_mk2",
        price = 4000,
    },
    {
        name = "weapon_pumpshotgun_mk2",
        price = 3000,
    },
    {
        name = "spikestrip",
        price = 400,
    },
    {
        name = "nvg",
        price = 3000,
    },
    {
        name = "adrenalineshot",
        price = 2250,
    },
    {
        name = "weapon_flashbang",
        price = 5000,
    },
    {
        name = "weapon_combatpdw",
        price = 3500,
    },
    {
        name = "detcord",
        price = 5000,
    },
    {
        name = "weapon_m14",
        price = 8000,
    },
    {
        name = "notepad",
        price = 200,
    },
    {
        name = "handcuffs",
        price = 1500,
    },
    {
        name = "handcuffkey",
        price = 500,
    },
    {
        name = "shepherdk9pd",
        price = 7500,
    },
    {
        name = "shepherdk9so",
        price = 7500,
    },
    {
        name = "shepherdk9sp",
        price = 7500,
    },
    {
        name = "pdbadge",
        price = 100,
    },
    {
        name = "medicalbag",
        price = 400,
    },
    {
        name = "regularbriefcase",
        price = 200,
    },
}

Config.Points = {
    [1] = {
        ['title'] = 'Inoperable on a scene',
        ['description'] = 'Vehicle found on scene in an inoperable state.',
        ['points'] = 0,
        ['depot'] = true,
    },
    [2] = {
        ['title'] = 'Vehicle Scuff',
        ['description'] = 'Vehicle in an unrecoverable state.',
        ['points'] = 0,
        ['depot'] = true,
    },
    [3] = {
        ['title'] = 'Evidence of a Crime',
        ['description'] = 'Vehicle has been used in or is evidence of a crime.',
        ['points'] = 0,
        ['depot'] = true,
    },
    [4] = {
        ['title'] = 'Joyride',
        ['description'] = 'Vehicle stolen and driven without owners permission.',
        ['points'] = 2,
        ['depot'] = true,
    },
    [5] = {
        ['title'] = 'Parking Violation',
        ['description'] = 'Vehicle parked in a restricted or unauthorized place.',
        ['points'] = 0,
        ['depot'] = true,
    },
    [6] = {
        ['title'] = 'Felony Hit and Run',
        ['description'] = 'Vehicle left the scene of an accident that resulted in injury or death.',
        ['points'] = 1,
        ['depot'] = false,
    },
    [7] = {
        ['title'] = 'Evading',
        ['description'] = 'Vehicle used to flee from a Peace Officer.',
        ['points'] = 2,
        ['depot'] = false,
    },
    [8] = {
        ['title'] = 'Reckless Evading',
        ['description'] = 'Driven carelessly with gross disregard for human life.',
        ['points'] = 2,
        ['depot'] = false,
    },
    [9] = {
        ['title'] = 'Street Racing',
        ['description'] = 'Vehicle was used in a speed contest on a public road/highway.',
        ['points'] = 3,
        ['depot'] = false,
    },
    [10] = {
        ['title'] = 'Driving While Intoxicated',
        ['description'] = 'Driving while under the influence of drugs or alcohol.',
        ['points'] = 1,
        ['depot'] = true,
    },
    [11] = {
        ['title'] = 'Violent Felony',
        ['description'] = 'Used in the commission of a violent crime either in a drive-by shooting or for transport to and from the scene of a violent crime.',
        ['points'] = 2,
        ['depot'] = false,
    },
    [12] = {
        ['title'] = 'Vehicle Repossession',
        ['description'] = 'Vehicle with an outstanding load that was not paid off and is to be seized.',
        ['points'] = 0,
        ['depot'] = true,
    },
    [13] = {
        ['title'] = 'Robbery or Kidnapping',
        ['description'] = 'Vehicle was used in the commission of any robbery or kidnapping related offense.',
        ['points'] = 3,
        ['depot'] = false,
    },
    [14] = {
        ['title'] = 'Used in a Felony Otherwise Not Listed',
        ['description'] = 'Used in any felony not listed by other impound reaons, will add 1 strike.',
        ['points'] = 0,
        ['depot'] = false,
    },
    [15] = {
        ['title'] = 'Unpaid Asset Fees',
        ['description'] = 'This vehicle has been flagged as they have no paid their asset fees.',
        ['points'] = 3,
        ['depot'] = true,
    },
}

-- Spikestrips 
Config.RequireJobPlace = true -- require job to place spikestrip 
Config.RequireJobRemove = true -- everyone be able to remove spikestrip or just police 

Config.SpikestripFeatures = {
    Item = "spikestrip",
    ReceiveRemove = true, 
    ReceiveJob = true, 
    UseWarmenu = false, 
    PoliceJobs = {
        "lspd",
        "bcso",
        "sasp",
        "ems",
        "police"
    },
}

Config.Colours = {
    ['0'] = "Metallic Black",
    ['1'] = "Metallic Graphite Black",
    ['2'] = "Metallic Black Steel",
    ['3'] = "Metallic Dark Silver",
    ['4'] = "Metallic Silver",
    ['5'] = "Metallic Blue Silver",
    ['6'] = "Metallic Steel Gray",
    ['7'] = "Metallic Shadow Silver",
    ['8'] = "Metallic Stone Silver",
    ['9'] = "Metallic Midnight Silver",
    ['10'] = "Metallic Gun Metal",
    ['11'] = "Metallic Anthracite Grey",
    ['12'] = "Matte Black",
    ['13'] = "Matte Gray",
    ['14'] = "Matte Light Grey",
    ['15'] = "Util Black",
    ['16'] = "Util Black Poly",
    ['17'] = "Util Dark silver",
    ['18'] = "Util Silver",
    ['19'] = "Util Gun Metal",
    ['20'] = "Util Shadow Silver",
    ['21'] = "Worn Black",
    ['22'] = "Worn Graphite",
    ['23'] = "Worn Silver Grey",
    ['24'] = "Worn Silver",
    ['25'] = "Worn Blue Silver",
    ['26'] = "Worn Shadow Silver",
    ['27'] = "Metallic Red",
    ['28'] = "Metallic Torino Red",
    ['29'] = "Metallic Formula Red",
    ['30'] = "Metallic Blaze Red",
    ['31'] = "Metallic Graceful Red",
    ['32'] = "Metallic Garnet Red",
    ['33'] = "Metallic Desert Red",
    ['34'] = "Metallic Cabernet Red",
    ['35'] = "Metallic Candy Red",
    ['36'] = "Metallic Sunrise Orange",
    ['37'] = "Metallic Classic Gold",
    ['38'] = "Metallic Orange",
    ['39'] = "Matte Red",
    ['40'] = "Matte Dark Red",
    ['41'] = "Matte Orange",
    ['42'] = "Matte Yellow",
    ['43'] = "Util Red",
    ['44'] = "Util Bright Red",
    ['45'] = "Util Garnet Red",
    ['46'] = "Worn Red",
    ['47'] = "Worn Golden Red",
    ['48'] = "Worn Dark Red",
    ['49'] = "Metallic Dark Green",
    ['50'] = "Metallic Racing Green",
    ['51'] = "Metallic Sea Green",
    ['52'] = "Metallic Olive Green",
    ['53'] = "Metallic Green",
    ['54'] = "Metallic Gasoline Blue Green",
    ['55'] = "Matte Lime Green",
    ['56'] = "Util Dark Green",
    ['57'] = "Util Green",
    ['58'] = "Worn Dark Green",
    ['59'] = "Worn Green",
    ['60'] = "Worn Sea Wash",
    ['61'] = "Metallic Midnight Blue",
    ['62'] = "Metallic Dark Blue",
    ['63'] = "Metallic Saxony Blue",
    ['64'] = "Metallic Blue",
    ['65'] = "Metallic Mariner Blue",
    ['66'] = "Metallic Harbor Blue",
    ['67'] = "Metallic Diamond Blue",
    ['68'] = "Metallic Surf Blue",
    ['69'] = "Metallic Nautical Blue",
    ['70'] = "Metallic Bright Blue",
    ['71'] = "Metallic Purple Blue",
    ['72'] = "Metallic Spinnaker Blue",
    ['73'] = "Metallic Ultra Blue",
    ['74'] = "Metallic Bright Blue",
    ['75'] = "Util Dark Blue",
    ['76'] = "Util Midnight Blue",
    ['77'] = "Util Blue",
    ['78'] = "Util Sea Foam Blue",
    ['79'] = "Uil Lightning blue",
    ['80'] = "Util Maui Blue Poly",
    ['81'] = "Util Bright Blue",
    ['82'] = "Matte Dark Blue",
    ['83'] = "Matte Blue",
    ['84'] = "Matte Midnight Blue",
    ['85'] = "Worn Dark blue",
    ['86'] = "Worn Blue",
    ['87'] = "Worn Light blue",
    ['88'] = "Metallic Taxi Yellow",
    ['89'] = "Metallic Race Yellow",
    ['90'] = "Metallic Bronze",
    ['91'] = "Metallic Yellow Bird",
    ['92'] = "Metallic Lime",
    ['93'] = "Metallic Champagne",
    ['94'] = "Metallic Pueblo Beige",
    ['95'] = "Metallic Dark Ivory",
    ['96'] = "Metallic Choco Brown",
    ['97'] = "Metallic Golden Brown",
    ['98'] = "Metallic Light Brown",
    ['99'] = "Metallic Straw Beige",
    ['100'] = "Metallic Moss Brown",
    ['101'] = "Metallic Biston Brown",
    ['102'] = "Metallic Beechwood",
    ['103'] = "Metallic Dark Beechwood",
    ['104'] = "Metallic Choco Orange",
    ['105'] = "Metallic Beach Sand",
    ['106'] = "Metallic Sun Bleeched Sand",
    ['107'] = "Metallic Cream",
    ['108'] = "Util Brown",
    ['109'] = "Util Medium Brown",
    ['110'] = "Util Light Brown",
    ['111'] = "Metallic White",
    ['112'] = "Metallic Frost White",
    ['113'] = "Worn Honey Beige",
    ['114'] = "Worn Brown",
    ['115'] = "Worn Dark Brown",
    ['116'] = "Worn straw beige",
    ['117'] = "Brushed Steel",
    ['118'] = "Brushed Black Steel",
    ['119'] = "Brushed Aluminium",
    ['120'] = "Chrome",
    ['121'] = "Worn Off White",
    ['122'] = "Util Off White",
    ['123'] = "Worn Orange",
    ['124'] = "Worn Light Orange",
    ['125'] = "Metallic Securicor Green",
    ['126'] = "Worn Taxi Yellow",
    ['127'] = "Police Car Blue",
    ['128'] = "Matte Green",
    ['129'] = "Matte Brown",
    ['130'] = "Worn Orange",
    ['131'] = "Matte White",
    ['132'] = "Worn White",
    ['133'] = "Worn Olive Army Green",
    ['134'] = "Pure White",
    ['135'] = "Hot Pink",
    ['136'] = "Salmon pink",
    ['137'] = "Metallic Vermillion Pink",
    ['138'] = "Orange",
    ['139'] = "Green",
    ['140'] = "Blue",
    ['141'] = "Mettalic Black Blue",
    ['142'] = "Metallic Black Purple",
    ['143'] = "Metallic Black Red",
    ['144'] = "hunter green",
    ['145'] = "Metallic Purple",
    ['146'] = "Metallic Dark Blue",
    ['147'] = "Black",
    ['148'] = "Matte Purple",
    ['149'] = "Matte Dark Purple",
    ['150'] = "Metallic Lava Red",
    ['151'] = "Matte Forest Green",
    ['152'] = "Matte Olive Drab",
    ['153'] = "Matte Desert Brown",
    ['154'] = "Matte Desert Tan",
    ['155'] = "Matte Foilage Green",
    ['156'] = "Default Alloy Color",
    ['157'] = "Epsilon Blue",
    ['158'] = "Pure Gold",
    ['159'] = "Brushed Gold",
    ['160'] = "MP100"
}

-- Just used for stealing shoes.
-- Also in rush-scripts for /s0 (shoes off) command to give ped barefeet.
-- Update when new shoes are added.
Config.PedComponentVariationMap = {
    ["shoes"] = {
        componentId = 6,
        ["barefoot"] = {
            ["female"] = 35,
            ["male"] = 34
        }
    }
}

Config.Firstname = {
    "Adam", "Abigail", "Benjamin", "Bella", "Christopher", "Charlotte", "Daniel", "Danielle", "Ethan", "Emily",
    "Felix", "Fiona", "Gabriel", "Grace", "Henry", "Hannah", "Isaac", "Isabella", "Jacob", "Jessica",
    "Kevin", "Katherine", "Liam", "Lily", "Mason", "Madison", "Nathan", "Natalie", "Oliver", "Olivia",
    "Patrick", "Penelope", "Quinn", "Rachel", "Ryan", "Samantha", "Samuel", "Taylor", "Thomas", "Uma",
    "Vincent", "Victoria", "William", "Willow", "Xavier", "Xena", "Yosef", "Yasmine", "Zachary", "Zara",
    "Alexander", "Ava", "Brandon", "Brooklyn", "Caleb", "Chloe", "David", "Daisy", "Elijah", "Ella",
    "Finn", "Faith", "Gavin", "Georgia", "Harrison", "Harper", "Ian", "Isabelle", "Jackson", "Julia",
    "Kai", "Kylie", "Lucas", "Leah", "Matthew", "Mia", "Nolan", "Nora", "Oscar", "Ophelia",
    "Peter", "Paige", "Quentin", "Quincy", "Robert", "Riley", "Sebastian", "Sophia", "Theodore", "Tessa",
    "Victor", "Ursula", "Wesley", "Violet", "Xander", "Willa", "Yuri", "Xia"
}

Config.Lastname = {
    "Anderson", "Brown", "Clark", "Davis", "Edwards", "Fisher", "Garcia", "Harris", "Irwin", "Johnson",
    "Keller", "Lewis", "Martin", "Nelson", "Owens", "Parker", "Quinn", "Roberts", "Smith", "Thompson",
    "Underwood", "Vargas", "Williams", "Xiong", "Young", "Zhang", "Adams", "Baker", "Carter", "Diaz",
    "Evans", "Foster", "Gonzalez", "Hall", "Ingram", "Jones", "Khan", "Lopez", "Morgan", "Nguyen",
    "Ortega", "Patel", "Quintana", "Reyes", "Stewart", "Taylor", "Upton", "Vasquez", "Wright", "Xu",
    "Yates", "Zimmerman", "Aguilar", "Bennett", "Chavez", "Duncan", "Elliott", "Flores", "Gomez", "Hernandez",
    "Ibrahim", "Jensen", "Klein", "Larson", "Martinez", "Navarro", "Ortiz", "Perez", "Ramirez", "Silva",
    "Torres", "Urbina", "Villa", "Wang", "Xiao", "Yoder", "Zimmer", "Armstrong", "Bailey", "Chen",
    "Duvall", "Erickson", "Gordon", "Holt", "Ingram", "Kumar", "Lyons", "Montoya", "Ng", "O'Malley",
    "Peterson", "Quintero", "Ramos", "Santos", "Tran", "Unger", "Vargas", "Watts", "Xavier", "Yates",
}
