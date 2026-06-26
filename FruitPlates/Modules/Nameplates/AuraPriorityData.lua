local FP = _G.FruitPlates

FP.PriorityAuraData = {
    typePriority = {
        lockout = 80,
        immunities = 65,
        cc = 70,
        silence = 60,
        interrupts = 55,
        roots = 50,
        disarm = 45,
        buffs_defensive = 40,
        buffs_offensive = 35,
        buffs_other = 30,
        snare = 25,
        other = 20,
    },
    centerTypes = {
        cc = true,
        snare = true,
        roots = true,
    },
    leftTypes = {
        lockout = true,
        silence = true,
        interrupts = true,
    },
    rightTypes = {
        immunities = true,
        buffs_defensive = true,
        buffs_offensive = true,
        buffs_other = true,
        disarm = true,
    },
    otherTypes = {
        other = true,
    },
    spells = {
        -- IMMUNITIES
        [642] = {type = "immunities", priority = 1}, -- Divine Shield
        [8178] = {type = "immunities", priority = 1}, -- Grounding Totem Effect
        [19263] = {type = "immunities", priority = 1}, -- Deterrence
        [45438] = {type = "immunities", priority = 1, highlight = 1}, -- Ice Block
        [48707] = {type = "immunities", priority = 1, highlight = 1}, -- Anti-Magic Shell
        [51690] = {type = "immunities", priority = 1}, -- Killing Spree
        [6615] = {type = "immunities", priority = 2}, -- Free Action
        [10278] = {type = "immunities", priority = 2}, -- Hand of Protection
        [31224] = {type = "immunities", priority = 2}, -- Cloak of Shadows
        [34471] = {type = "immunities", priority = 2}, -- The Beast Within
        [34692] = {type = "immunities", priority = 2}, -- The Beast Within
        [46924] = {type = "immunities", priority = 2, highlight = 1}, -- Bladestorm
        [19574] = {type = "immunities", priority = 3}, -- Bestial Wrath
        [23920] = {type = "immunities", priority = 3, highlight = 3}, -- Spell Reflection
        [24364] = {type = "immunities", priority = 3}, -- Living Free Action

        -- CROWD CONTROL
        [2094] = {type = "cc", priority = 1}, -- Blind
        [3355] = {type = "cc", priority = 1}, -- Freezing Trap Effect
        [5782] = {type = "cc", priority = 1}, -- Fear
        [6213] = {type = "cc", priority = 1}, -- Fear
        [6215] = {type = "cc", priority = 1, highlight = 4}, -- Fear
        [10308] = {type = "cc", priority = 1, highlight = 4}, -- Hammer of Justice
        [12798] = {type = "cc", priority = 1}, -- Revenge Stun
        [14308] = {type = "cc", priority = 1}, -- Freezing Trap Effect
        [20549] = {type = "cc", priority = 1}, -- War Stomp
        [30216] = {type = "cc", priority = 1}, -- Fel Iron Bomb
        [33786] = {type = "cc", priority = 1}, -- Cyclone
        [44572] = {type = "cc", priority = 1}, -- Deep Freeze
        [47860] = {type = "cc", priority = 1}, -- Death Coil
        [53564] = {type = "cc", priority = 1}, -- Pin
        [53565] = {type = "cc", priority = 1}, -- Lock Jaw
        [53566] = {type = "cc", priority = 1}, -- Ravage
        [53567] = {type = "cc", priority = 1}, -- Serenity Dust
        [53568] = {type = "cc", priority = 1}, -- Sonic Blast
        [64843] = {type = "cc", priority = 1, highlight = 1}, -- Divine Hymn
        [64901] = {type = "cc", priority = 1, highlight = 1}, -- Hymn of Hope
        [71988] = {type = "cc", priority = 1}, -- Shield of Runes

        [118] = {type = "cc", priority = 2}, -- Polymorph
        [605] = {type = "cc", priority = 2, highlight = 4}, -- Mind Control
        [5484] = {type = "cc", priority = 2}, -- Howl of Terror
        [10326] = {type = "cc", priority = 2}, -- Turn Evil
        [12809] = {type = "cc", priority = 2}, -- Concussion Blow
        [13181] = {type = "cc", priority = 2}, -- Gnomish Mind Control Cap
        [24394] = {type = "cc", priority = 2}, -- Intimidation
        [30217] = {type = "cc", priority = 2}, -- Adamantite Grenade
        [39796] = {type = "cc", priority = 2}, -- Stoneclaw Stun
        [46968] = {type = "cc", priority = 2}, -- Shockwave
        [47847] = {type = "cc", priority = 2}, -- Shadowfury
        [49203] = {type = "cc", priority = 2}, -- Hungering Cold
        [49802] = {type = "cc", priority = 2}, -- Maim
        [50396] = {type = "cc", priority = 2}, -- Magic Dust
        [51209] = {type = "cc", priority = 2}, -- Hungering Cold
        [51724] = {type = "cc", priority = 2, highlight = 4}, -- Sap
        [64044] = {type = "cc", priority = 2, highlight = 4}, -- Psychic Horror

        [1776] = {type = "cc", priority = 3}, -- Gouge
        [2637] = {type = "cc", priority = 3}, -- Hibernate
        [5246] = {type = "cc", priority = 3, highlight = 2}, -- Intimidating Shout
        [6358] = {type = "cc", priority = 3}, -- Seduction
        [8983] = {type = "cc", priority = 3}, -- Bash
        [10890] = {type = "cc", priority = 3, highlight = 4}, -- Psychic Scream
        [13327] = {type = "cc", priority = 3}, -- Reckless Charge
        [18647] = {type = "cc", priority = 3}, -- Banish
        [18657] = {type = "cc", priority = 3}, -- Hibernate
        [19503] = {type = "cc", priority = 3}, -- Scatter Shot
        [20066] = {type = "cc", priority = 3}, -- Repentance
        [20511] = {type = "cc", priority = 3, highlight = 2}, -- Intimidating Shout
        [20685] = {type = "cc", priority = 3}, -- Storm Bolt
        [22570] = {type = "cc", priority = 3}, -- Maim
        [42950] = {type = "cc", priority = 3}, -- Dragon's Breath
        [47481] = {type = "cc", priority = 3}, -- Gnaw
        [51514] = {type = "cc", priority = 3}, -- Hex
        [60995] = {type = "cc", priority = 3}, -- Demon Charge
        [67769] = {type = "cc", priority = 3}, -- Cobalt Frag Bomb

        [6789] = {type = "cc", priority = 4}, -- Death Coil
        [7922] = {type = "cc", priority = 4, highlight = 4}, -- Charge Stun
        [8643] = {type = "cc", priority = 4, highlight = 4}, -- Kidney Shot
        [9005] = {type = "cc", priority = 4}, -- Pounce
        [9823] = {type = "cc", priority = 4}, -- Pounce
        [9827] = {type = "cc", priority = 4}, -- Pounce
        [10955] = {type = "cc", priority = 4}, -- Shackle Undead
        [12355] = {type = "cc", priority = 4}, -- Impact
        [17925] = {type = "cc", priority = 4}, -- Death Coil
        [17926] = {type = "cc", priority = 4}, -- Death Coil
        [17928] = {type = "cc", priority = 4, highlight = 2}, -- Howl of Terror
        [18658] = {type = "cc", priority = 4}, -- Hibernate
        [19386] = {type = "cc", priority = 4}, -- Wyvern Sting
        [24132] = {type = "cc", priority = 4}, -- Wyvern Sting
        [24133] = {type = "cc", priority = 4}, -- Wyvern Sting
        [27006] = {type = "cc", priority = 4}, -- Pounce
        [27068] = {type = "cc", priority = 4}, -- Wyvern Sting
        [27223] = {type = "cc", priority = 4}, -- Death Coil
        [31661] = {type = "cc", priority = 4}, -- Dragon's Breath
        [33041] = {type = "cc", priority = 4}, -- Dragon's Breath
        [33042] = {type = "cc", priority = 4}, -- Dragon's Breath
        [33043] = {type = "cc", priority = 4}, -- Dragon's Breath
        [42949] = {type = "cc", priority = 4}, -- Dragon's Breath
        [47859] = {type = "cc", priority = 4}, -- Death Coil
        [48817] = {type = "cc", priority = 4}, -- Holy Wrath
        [49011] = {type = "cc", priority = 4}, -- Wyvern Sting
        [49012] = {type = "cc", priority = 4}, -- Wyvern Sting
        [53562] = {type = "cc", priority = 4}, -- Ravage

        [1833] = {type = "cc", priority = 5, highlight = 4}, -- Cheap Shot
        [14309] = {type = "cc", priority = 5}, -- Freezing Trap Effect
        [20170] = {type = "cc", priority = 5}, -- Seal of Justice
        [20253] = {type = "cc", priority = 5}, -- Intercept Stun
        [49803] = {type = "cc", priority = 5}, -- Pounce
        [50519] = {type = "cc", priority = 5}, -- Sonic Blast

        [60210] = {type = "cc", priority = 6}, -- Freezing Arrow Effect
        [14327] = {type = "cc", priority = 7}, -- Scare Beast

        -- SILENCES
        [19821] = {type = "silence", priority = 1}, -- Arcane Torrent
        [24259] = {type = "silence", priority = 1, highlight = 4}, -- Spell Lock
        [31117] = {type = "silence", priority = 1}, -- Unstable Affliction
        [1330] = {type = "silence", priority = 2}, -- Garrote - Silence
        [15487] = {type = "silence", priority = 2, highlight = 4}, -- Silence
        [18469] = {type = "silence", priority = 2}, -- Improved Counterspell
        [28730] = {type = "silence", priority = 2}, -- Arcane Torrent
        [47476] = {type = "silence", priority = 2}, -- Strangulate
        [55021] = {type = "silence", priority = 2}, -- Improved Counterspell
        [18425] = {type = "silence", priority = 3}, -- Kick - Silenced
        [18498] = {type = "silence", priority = 3}, -- Gag Order
        [34490] = {type = "silence", priority = 3, highlight = 2}, -- Silencing Shot
        [63529] = {type = "silence", priority = 3, highlight = 5}, -- Shield of the Templar

        -- INTERRUPTS / SCHOOL LOCKOUTS
        [72] = {type = "interrupts", priority = 1}, -- Shield Bash
        [1766] = {type = "interrupts", priority = 1}, -- Kick
        [2139] = {type = "interrupts", priority = 1}, -- Counterspell
        [57994] = {type = "interrupts", priority = 1}, -- Wind Shear
        [6552] = {type = "interrupts", priority = 2}, -- Pummel
        [19647] = {type = "interrupts", priority = 2}, -- Spell Lock
        [16979] = {type = "interrupts", priority = 3}, -- Feral Charge - Bear
        [26090] = {type = "interrupts", priority = 3}, -- Pummel
        [47528] = {type = "interrupts", priority = 3}, -- Mind Freeze

        -- ROOTS
        [865] = {type = "roots", priority = 1}, -- Frost Nova
        [6131] = {type = "roots", priority = 1}, -- Frost Nova
        [10230] = {type = "roots", priority = 1}, -- Frost Nova
        [12494] = {type = "roots", priority = 1}, -- Frostbite
        [13099] = {type = "roots", priority = 1}, -- Net-o-Matic
        [27088] = {type = "roots", priority = 1}, -- Frost Nova
        [39965] = {type = "roots", priority = 1}, -- Frost Grenade
        [42917] = {type = "roots", priority = 1, highlight = 4}, -- Frost Nova

        [122] = {type = "roots", priority = 2}, -- Frost Nova
        [14030] = {type = "roots", priority = 2}, -- Hooked Net
        [19184] = {type = "roots", priority = 2}, -- Entrapment
        [19387] = {type = "roots", priority = 2}, -- Entrapment
        [19388] = {type = "roots", priority = 2}, -- Entrapment
        [45334] = {type = "roots", priority = 2}, -- Feral Charge Effect
        [48999] = {type = "roots", priority = 2}, -- Counterattack
        [55536] = {type = "roots", priority = 2}, -- Frostweave Net
        [58373] = {type = "roots", priority = 2}, -- Glyph of Hamstring
        [64695] = {type = "roots", priority = 2}, -- Earthgrab
        [64803] = {type = "roots", priority = 2}, -- Entrapment
        [64804] = {type = "roots", priority = 2}, -- Entrapment

        [339] = {type = "roots", priority = 3}, -- Entangling Roots
        [1062] = {type = "roots", priority = 3}, -- Entangling Roots
        [5195] = {type = "roots", priority = 3}, -- Entangling Roots
        [5196] = {type = "roots", priority = 3}, -- Entangling Roots
        [9852] = {type = "roots", priority = 3}, -- Entangling Roots
        [9853] = {type = "roots", priority = 3}, -- Entangling Roots
        [19185] = {type = "roots", priority = 3}, -- Entrapment
        [23694] = {type = "roots", priority = 3, highlight = 1}, -- Improved Hamstring
        [26989] = {type = "roots", priority = 3}, -- Entangling Roots
        [53308] = {type = "roots", priority = 3}, -- Entangling Roots
        [53313] = {type = "roots", priority = 3, highlight = 4}, -- Entangling Roots
        [55080] = {type = "roots", priority = 3}, -- Shattered Barrier
        [63685] = {type = "roots", priority = 3}, -- Freeze

        [19306] = {type = "roots", priority = 4}, -- Counterattack
        [20909] = {type = "roots", priority = 4}, -- Counterattack
        [20910] = {type = "roots", priority = 4}, -- Counterattack
        [27067] = {type = "roots", priority = 4}, -- Counterattack
        [33395] = {type = "roots", priority = 4}, -- Freeze
        [48998] = {type = "roots", priority = 4}, -- Counterattack
        [53548] = {type = "roots", priority = 4, highlight = 4}, -- Pin

        [4167] = {type = "roots", priority = 5, highlight = 4}, -- Web
        [54706] = {type = "roots", priority = 6, highlight = 4}, -- Venom Web Spray

        -- DISARMS
        [51722] = {type = "disarm", priority = 1, highlight = 4}, -- Dismantle
        [64346] = {type = "disarm", priority = 1, highlight = 4}, -- Fiery Payback
        [676] = {type = "disarm", priority = 2, highlight = 4}, -- Disarm
        [53359] = {type = "disarm", priority = 2, highlight = 4}, -- Chimera Shot - Scorpid
        [64058] = {type = "disarm", priority = 5, highlight = 4}, -- Psychic Horror

        -- DEFENSIVE BUFFS
        [12975] = {type = "buffs_defensive", priority = 1}, -- Last Stand
        [47585] = {type = "buffs_defensive", priority = 1, highlight = 2}, -- Dispersion
        [498] = {type = "buffs_defensive", priority = 2}, -- Divine Protection
        [18708] = {type = "buffs_defensive", priority = 2}, -- Fel Domination
        [20711] = {type = "buffs_defensive", priority = 2}, -- Spirit of Redemption
        [26669] = {type = "buffs_defensive", priority = 2}, -- Evasion
        [30823] = {type = "buffs_defensive", priority = 2}, -- Shamanistic Rage
        [48792] = {type = "buffs_defensive", priority = 2, highlight = 3}, -- Icebound Fortitude
        [54748] = {type = "buffs_defensive", priority = 2}, -- Burning Determination
        [55694] = {type = "buffs_defensive", priority = 2}, -- Enraged Regeneration
        [61336] = {type = "buffs_defensive", priority = 2}, -- Survival Instincts
        [871] = {type = "buffs_defensive", priority = 3, highlight = 1}, -- Shield Wall
        [16188] = {type = "buffs_defensive", priority = 3}, -- Nature's Swiftness
        [22812] = {type = "buffs_defensive", priority = 3, highlight = 3}, -- Barkskin
        [31821] = {type = "buffs_defensive", priority = 3}, -- Aura Mastery
        [47788] = {type = "buffs_defensive", priority = 3}, -- Guardian Spirit
        [54216] = {type = "buffs_defensive", priority = 3}, -- Master's Call
        [3411] = {type = "buffs_defensive", priority = 4}, -- Intervene
        [5384] = {type = "buffs_defensive", priority = 4}, -- Feign Death
        [17116] = {type = "buffs_defensive", priority = 4}, -- Nature's Swiftness
        [33206] = {type = "buffs_defensive", priority = 4}, -- Pain Suppression
        [49039] = {type = "buffs_defensive", priority = 4, highlight = 2}, -- Lichborne
        [2565] = {type = "buffs_defensive", priority = 5}, -- Shield Block
        [6940] = {type = "buffs_defensive", priority = 5}, -- Hand of Sacrifice
        [47484] = {type = "buffs_defensive", priority = 5}, -- Huddle
        [50461] = {type = "buffs_defensive", priority = 5}, -- Anti-Magic Zone
        [54428] = {type = "buffs_defensive", priority = 5, highlight = 4}, -- Divine Plea
        [1044] = {type = "buffs_defensive", priority = 6, highlight = 3}, -- Hand of Freedom
        [20230] = {type = "buffs_defensive", priority = 6, highlight = 1}, -- Retaliation
        [18499] = {type = "buffs_defensive", priority = 7, highlight = 3}, -- Berserker Rage
        [64205] = {type = "buffs_defensive", priority = 7}, -- Divine Sacrifice

        -- OFFENSIVE BUFFS
        [1719] = {type = "buffs_offensive", priority = 1, highlight = 3}, -- Recklessness
        [2825] = {type = "buffs_offensive", priority = 1}, -- Bloodlust
        [11719] = {type = "buffs_offensive", priority = 1}, -- Curse of Tongues
        [12042] = {type = "buffs_offensive", priority = 1}, -- Arcane Power
        [32182] = {type = "buffs_offensive", priority = 1}, -- Heroism
        [53201] = {type = "buffs_offensive", priority = 1}, -- Starfall
        [66] = {type = "buffs_offensive", priority = 2}, -- Invisibility
        [16166] = {type = "buffs_offensive", priority = 2}, -- Elemental Mastery
        [31884] = {type = "buffs_offensive", priority = 2, highlight = 1}, -- Avenging Wrath
        [50334] = {type = "buffs_offensive", priority = 2}, -- Berserk
        [54833] = {type = "buffs_offensive", priority = 2}, -- Glyph of Innervate
        [12472] = {type = "buffs_offensive", priority = 3}, -- Icy Veins
        [29166] = {type = "buffs_offensive", priority = 3}, -- Innervate
        [47241] = {type = "buffs_offensive", priority = 3}, -- Metamorphosis
        [51713] = {type = "buffs_offensive", priority = 3}, -- Shadow Dance
        [44544] = {type = "buffs_offensive", priority = 4}, -- Fingers of Frost
        [49028] = {type = "buffs_offensive", priority = 4}, -- Dancing Rune Weapon
        [69369] = {type = "buffs_offensive", priority = 4}, -- Predator's Swiftness
        [10060] = {type = "buffs_offensive", priority = 5, highlight = 5}, -- Power Infusion

        -- OTHER BUFFS / STATES
        [43183] = {type = "buffs_other", priority = 1, highlight = 5}, -- Drink
        [45548] = {type = "buffs_other", priority = 1, highlight = 5}, -- Drink
        [57073] = {type = "buffs_other", priority = 1, highlight = 5}, -- Drink
        [64356] = {type = "buffs_other", priority = 1, highlight = 5}, -- Drink

        [2457] = {type = "buffs_other", priority = 2}, -- Battle Stance
        [43180] = {type = "buffs_other", priority = 2, highlight = 5}, -- Drink
        [53312] = {type = "buffs_other", priority = 2}, -- Nature's Grasp
        [58875] = {type = "buffs_other", priority = 2}, -- Spirit Walk
        [71586] = {type = "buffs_other", priority = 2}, -- Food

        [2458] = {type = "buffs_other", priority = 3}, -- Berserker Stance
        [6346] = {type = "buffs_other", priority = 3, highlight = 2}, -- Fear Ward
        [29703] = {type = "buffs_other", priority = 3}, -- Dazed
        [33357] = {type = "buffs_other", priority = 3}, -- Dash
        [43020] = {type = "buffs_other", priority = 3}, -- Mana Shield
        [47986] = {type = "buffs_other", priority = 3}, -- Sacrifice
        [55277] = {type = "buffs_other", priority = 3}, -- Stoneclaw Totem

        [71] = {type = "buffs_other", priority = 4}, -- Defensive Stance
        [11305] = {type = "buffs_other", priority = 4}, -- Sprint
        [43012] = {type = "buffs_other", priority = 4}, -- Ice Barrier
        [48066] = {type = "buffs_other", priority = 4, highlight = 5}, -- Power Word: Shield
        [58597] = {type = "buffs_other", priority = 4}, -- Sacred Shield

        [3034] = {type = "buffs_other", priority = 5}, -- Viper Sting
        [5118] = {type = "buffs_other", priority = 6}, -- Aspect of the Cheetah
        [25771] = {type = "buffs_other", priority = 10}, -- Forbearance

        -- SNARES
        [18223] = {type = "snare", priority = 1, highlight = 5}, -- Curse of Exhaustion
        [31589] = {type = "snare", priority = 1, highlight = 5}, -- Slow

        [116] = {type = "snare", priority = 2, highlight = 5}, -- Frostbolt
        [13810] = {type = "snare", priority = 2, highlight = 5}, -- Frost Trap Aura
        [18118] = {type = "snare", priority = 2, highlight = 5}, -- Aftermath
        [45524] = {type = "snare", priority = 2, highlight = 5}, -- Chains of Ice
        [48827] = {type = "snare", priority = 2, highlight = 5}, -- Avenger's Shield
        [61391] = {type = "snare", priority = 2, highlight = 5}, -- Typhoon

        [8056] = {type = "snare", priority = 3, highlight = 5}, -- Frost Shock
        [11113] = {type = "snare", priority = 3}, -- Blast Wave
        [35101] = {type = "snare", priority = 3, highlight = 5}, -- Concussive Barrage
        [47610] = {type = "snare", priority = 3, highlight = 5}, -- Frostfire Bolt
        [55666] = {type = "snare", priority = 3, highlight = 5}, -- Desecration
        [58179] = {type = "snare", priority = 3, highlight = 5}, -- Infected Wounds

        [3409] = {type = "snare", priority = 4, highlight = 5}, -- Crippling Poison
        [3600] = {type = "snare", priority = 4, highlight = 5}, -- Earthbind
        [5116] = {type = "snare", priority = 4, highlight = 5}, -- Concussive Shot
        [6136] = {type = "snare", priority = 4, highlight = 5}, -- Chilled
        [8034] = {type = "snare", priority = 4, highlight = 5}, -- Frostbrand Attack
        [31125] = {type = "snare", priority = 4, highlight = 5}, -- Blade Twisting
        [50259] = {type = "snare", priority = 4, highlight = 5}, -- Dazed
        [51585] = {type = "snare", priority = 4, highlight = 5}, -- Deadly Throw
        [58617] = {type = "snare", priority = 4, highlight = 5}, -- Glyph of Heart Strike

        [120] = {type = "snare", priority = 5, highlight = 5}, -- Cone of Cold
        [48156] = {type = "snare", priority = 5, highlight = 5}, -- Mind Flay
        [50436] = {type = "snare", priority = 5, highlight = 5}, -- Icy Clutch
        [51693] = {type = "snare", priority = 5, highlight = 5}, -- Waylay
        [61394] = {type = "snare", priority = 5, highlight = 5}, -- Glyph of Freezing Trap

        [2974] = {type = "snare", priority = 6, highlight = 5}, -- Wing Clip

        -- OTHER DEBUFFS
        [47486] = {type = "other", priority = 1, highlight = 3}, -- Mortal Strike
        [12323] = {type = "other", priority = 2, highlight = 5}, -- Piercing Howl
        [47465] = {type = "other", priority = 2, highlight = 3}, -- Rend
        [1715] = {type = "other", priority = 3, highlight = 5}, -- Hamstring
    },
}