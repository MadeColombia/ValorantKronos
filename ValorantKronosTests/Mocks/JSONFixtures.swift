//
//  JSONFixtures.swift
//  ValorantKronosTests
//

import Foundation

/// Test fixtures and helpers providing realistic JSON payloads for unit tests.
public enum JSONFixtures {
    
    // MARK: - APIResponse Wrapper
    
    public static func wrapInAPIResponse(innerJSON: String, status: Int = 200) -> String {
        return """
        {
            "status": \(status),
            "data": \(innerJSON)
        }
        """
    }
    
    // MARK: - Agent JSON Fixtures
    
    public static let validAgentSovaJSON: String = """
    {
        "uuid": "320b2a48-4d9b-a075-30f1-1f93a9b638fa",
        "displayName": "Sova",
        "developerName": "Hunter",
        "description": "Born from the eternal winter of Russia's tundra, Sova tracks, finds, and eliminates enemies with ruthless efficiency and precision.",
        "fullPortrait": "https://media.valorant-api.com/agents/320b2a48-4d9b-a075-30f1-1f93a9b638fa/fullportrait.png",
        "background": "https://media.valorant-api.com/agents/320b2a48-4d9b-a075-30f1-1f93a9b638fa/background.png",
        "isPlayableCharacter": true,
        "role": {
            "uuid": "1b47567f-8f7b-444b-aae3-b0c634622d10",
            "displayName": "Initiator",
            "description": "Initiators challenge angles by setting up their team to enter contested ground and push defenders away.",
            "displayIcon": "https://media.valorant-api.com/agents/roles/1b47567f-8f7b-444b-aae3-b0c634622d10/displayicon.png"
        },
        "abilities": [
            {
                "slot": "Ability1",
                "displayName": "Shock Bolt",
                "description": "EQUIP a bow with a shock bolt.",
                "displayIcon": "https://media.valorant-api.com/agents/320b2a48-4d9b-a075-30f1-1f93a9b638fa/abilities/ability1/displayicon.png"
            },
            {
                "slot": "Ability2",
                "displayName": "Recon Bolt",
                "description": "EQUIP a bow with recon bolt.",
                "displayIcon": "https://media.valorant-api.com/agents/320b2a48-4d9b-a075-30f1-1f93a9b638fa/abilities/ability2/displayicon.png"
            },
            {
                "slot": "Grenade",
                "displayName": "Owl Drone",
                "description": "EQUIP an owl drone.",
                "displayIcon": "https://media.valorant-api.com/agents/320b2a48-4d9b-a075-30f1-1f93a9b638fa/abilities/grenade/displayicon.png"
            },
            {
                "slot": "Ultimate",
                "displayName": "Hunter's Fury",
                "description": "EQUIP a bow with three long-range, wall-piercing energy blasts.",
                "displayIcon": "https://media.valorant-api.com/agents/320b2a48-4d9b-a075-30f1-1f93a9b638fa/abilities/ultimate/displayicon.png"
            },
            {
                "slot": "Passive",
                "displayName": "Uncanny Marksman",
                "description": "Sova's custom bow can fire his arrows and bounce them off terrain.",
                "displayIcon": null
            }
        ]
    }
    """
    
    public static let agentWithNullRoleJSON: String = """
    {
        "uuid": "ded3520f-4264-bfed-162d-b080e2abccf9",
        "displayName": "Training Bot",
        "developerName": "TrainingBot",
        "description": "A target dummy bot for shooting range practice.",
        "fullPortrait": null,
        "background": null,
        "isPlayableCharacter": false,
        "role": null,
        "abilities": []
    }
    """
    
    public static let agentWithSpecialCharactersJSON: String = """
    {
        "uuid": "601dbbe7-43ce-be57-2a40-4abd24953621",
        "displayName": "KAY/O",
        "developerName": "Grenadier",
        "description": "KAY/O is a machine of war built for a single purpose: neutralizing radiants.",
        "fullPortrait": "https://media.valorant-api.com/agents/kayo/portrait.png",
        "background": "https://media.valorant-api.com/agents/kayo/bg.png",
        "isPlayableCharacter": true,
        "role": {
            "uuid": "1b47567f-8f7b-444b-aae3-b0c634622d10",
            "displayName": "Initiator",
            "description": "Initiators challenge angles.",
            "displayIcon": "https://media.valorant-api.com/agents/roles/initiator.png"
        },
        "abilities": [
            {
                "slot": "Ability1",
                "displayName": "FLASH/drive",
                "description": "EQUIP a flash grenade.",
                "displayIcon": "https://media.valorant-api.com/abilities/flashdrive.png"
            }
        ]
    }
    """
    
    public static let malformedAgentMissingUUIDJSON: String = """
    {
        "displayName": "Incomplete Agent",
        "developerName": "Incomplete",
        "description": "Missing UUID field"
    }
    """
    
    public static let malformedAgentTypeMismatchJSON: String = """
    {
        "uuid": 12345678,
        "displayName": "Type Mismatch Agent",
        "developerName": "Mismatch",
        "description": "UUID is an integer instead of string"
    }
    """
    
    // MARK: - Weapon JSON Fixtures
    
    public static let validStandardWeaponJSON: String = """
    {
        "uuid": "63e6c2b6-4a8e-869c-3d4c-e38355226584",
        "displayName": "Odin",
        "category": "Heavy",
        "defaultSkinUuid": "f454efd1-49cb-372f-7096-d394df615308",
        "displayIcon": "https://media.valorant-api.com/weapons/63e6c2b6-4a8e-869c-3d4c-e38355226584/displayicon.png",
        "killStreamIcon": "https://media.valorant-api.com/weapons/63e6c2b6-4a8e-869c-3d4c-e38355226584/killstreamicon.png",
        "weaponStats": {
            "fireRate": 12.0,
            "magazineSize": 100,
            "runSpeedMultiplier": 0.76,
            "equipTimeSeconds": 1.25,
            "reloadTimeSeconds": 5.0,
            "firstBulletAccuracy": 0.8,
            "shotgunPelletCount": 1,
            "wallPenetration": "EWallPenetrationDisplayType::High",
            "damageRanges": [
                {
                    "rangeStartMeters": 0,
                    "rangeEndMeters": 30,
                    "headDamage": 95.0,
                    "bodyDamage": 38.0,
                    "legDamage": 32.3
                }
            ]
        },
        "skins": [
            {
                "uuid": "89be9866-4807-6235-2a95-499cd23828df",
                "displayName": "Altitude Odin",
                "displayIcon": "https://media.valorant-api.com/weaponskins/89be9866-4807-6235-2a95-499cd23828df/displayicon.png",
                "wallpaper": "https://media.valorant-api.com/wallpaper.png",
                "contentTierUuid": "0cebb8be-46d7-c12a-d306-e9907bfc5a25",
                "chromas": [
                    {
                        "uuid": "092a25a4-422f-f577-37ac-26a5d489c155",
                        "displayName": "Altitude Odin Chroma 1",
                        "displayIcon": "https://media.valorant-api.com/chroma1.png",
                        "fullRender": "https://media.valorant-api.com/weaponskinchromas/092a25a4-422f-f577-37ac-26a5d489c155/fullrender.png",
                        "swatch": "https://media.valorant-api.com/swatch.png"
                    }
                ]
            }
        ]
    }
    """
    
    public static let meleeWeaponNullStatsJSON: String = """
    {
        "uuid": "2f59173c-4bed-b6c3-2191-dea9b58be9c7",
        "displayName": "Melee",
        "category": "Melee",
        "defaultSkinUuid": "f7845f3a-4467-336c-941a-a0b4c09d57a1",
        "displayIcon": "https://media.valorant-api.com/weapons/2f59173c-4bed-b6c3-2191-dea9b58be9c7/displayicon.png",
        "killStreamIcon": "https://media.valorant-api.com/weapons/2f59173c-4bed-b6c3-2191-dea9b58be9c7/killstreamicon.png",
        "weaponStats": null,
        "skins": [
            {
                "uuid": "f7845f3a-4467-336c-941a-a0b4c09d57a1",
                "displayName": "Standard Melee",
                "displayIcon": "https://media.valorant-api.com/weaponskins/standard_melee.png",
                "wallpaper": null,
                "contentTierUuid": null,
                "chromas": []
            }
        ]
    }
    """
    
    public static let weaponWithNilIconsJSON: String = """
    {
        "uuid": "ee824247-4563-30ec-4a5e-f4464c544d67",
        "displayName": "Ghost",
        "category": "Sidearms",
        "defaultSkinUuid": "ghost-default-uuid",
        "displayIcon": null,
        "killStreamIcon": null,
        "weaponStats": {
            "fireRate": 6.75,
            "magazineSize": 15,
            "runSpeedMultiplier": 1.0,
            "equipTimeSeconds": 0.75,
            "reloadTimeSeconds": 1.5,
            "damageRanges": [
                {
                    "rangeStartMeters": 0,
                    "rangeEndMeters": 30,
                    "headDamage": 105.0,
                    "bodyDamage": 30.0,
                    "legDamage": 25.5
                }
            ]
        },
        "skins": []
    }
    """
    
    public static let malformedWeaponMissingUUIDJSON: String = """
    {
        "displayName": "Phantom",
        "category": "Rifles"
    }
    """
    
    // MARK: - Map JSON Fixtures
    
    public static let validMapHavenJSON: String = """
    {
        "uuid": "2bee0dc9-4ffe-519b-1cbd-7fbe763a6047",
        "displayName": "Haven",
        "narrativeDescription": "Beneath a forgotten monastery, a clamour emerges from rival Agents clashing to control three sites.",
        "tacticalDescription": "A/B/C Sites",
        "coordinates": "27°28'A'N,89°38'WZ'E",
        "displayIcon": "https://media.valorant-api.com/maps/2bee0dc9-4ffe-519b-1cbd-7fbe763a6047/displayicon.png",
        "listViewIcon": "https://media.valorant-api.com/maps/2bee0dc9-4ffe-519b-1cbd-7fbe763a6047/listviewicon.png",
        "listViewIconTall": "https://media.valorant-api.com/maps/2bee0dc9-4ffe-519b-1cbd-7fbe763a6047/listviewicontall.png",
        "splash": "https://media.valorant-api.com/maps/2bee0dc9-4ffe-519b-1cbd-7fbe763a6047/splash.png",
        "stylizedBackgroundImage": "https://media.valorant-api.com/maps/2bee0dc9-4ffe-519b-1cbd-7fbe763a6047/stylizedbg.png",
        "premierBackgroundImage": "https://media.valorant-api.com/maps/2bee0dc9-4ffe-519b-1cbd-7fbe763a6047/premierbackgroundimage.png",
        "callouts": [
            {
                "regionName": "A Site",
                "superRegionName": "A",
                "location": {
                    "x": 4200.0,
                    "y": -6500.0
                }
            },
            {
                "regionName": "B Site",
                "superRegionName": "B",
                "location": {
                    "x": 0.0,
                    "y": -5000.0
                }
            }
        ]
    }
    """
    
    public static let mapWithoutDisplayIconJSON: String = """
    {
        "uuid": "ee6133b0-4ab5-8c0a-96eb-7ca16daac037",
        "displayName": "The Range",
        "tacticalDescription": null,
        "coordinates": null,
        "displayIcon": null,
        "listViewIconTall": "https://media.valorant-api.com/range/tall.png",
        "splash": "https://media.valorant-api.com/range/splash.png",
        "premierBackgroundImage": null
    }
    """
    
    public static let malformedMapMissingDisplayNameJSON: String = """
    {
        "uuid": "2bee0dc9-4ffe-519b-1cbd-7fbe763a6047",
        "coordinates": "Unknown"
    }
    """
}
