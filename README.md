# Roblox Secret GUI Key Combo + Redeem Codes

This repository now contains three scripts:

- `SecretGuiTemplate.client.lua` builds a clean, minimal `SecretGui` with a **code textbox** and buttons.
- `SecretGuiKeyCombo.client.lua` opens `SecretGui.Frame` when the player presses **K 5 times within 3 seconds**.
- `CodeRedeem.server.lua` validates codes and grants tools from `ReplicatedStorage`.

## 1) GUI template (client)

`SecretGuiTemplate.client.lua` creates the full UI in `PlayerGui` and replaces the old subtitle text with a redeem flow:

- `TextBox` for entering codes.
- `Redeem` button (and Enter key submit).
- Status message label.
- `Close` button.

## 2) Combo opener (client)

`SecretGuiKeyCombo.client.lua` shows the frame when users press **K 5 times within 3 seconds**.

## 3) Code rewards (server)

`CodeRedeem.server.lua` creates/uses `ReplicatedStorage.SecretCodeRedeemEvent` and handles rewards securely on the server.

### Default code behavior

- `PK9095` grants **every Tool in ReplicatedStorage**.
- `STARTER` grants selected item names.

### Easy customization

Edit this table in `CodeRedeem.server.lua`:

```lua
local codeRewards = {
    PK9095 = { grantAllTools = true },
    STARTER = { itemNames = { "LinkedSword", "Slingshot" } },
}
```

- Add more code keys (uppercase recommended).
- Use `grantAllTools = true` for “give all tools”.
- Use `itemNames = { "ToolName1", "ToolName2" }` for specific items.

## Placement in Roblox Studio

- Put `SecretGuiTemplate.client.lua` in `StarterPlayer > StarterPlayerScripts` as a **LocalScript**.
- Put `SecretGuiKeyCombo.client.lua` in `StarterPlayer > StarterPlayerScripts` as a **LocalScript**.
- Put `CodeRedeem.server.lua` in `ServerScriptService` as a **Script**.

## Important notes

- Rewards are granted only for instances of class `Tool` found in `ReplicatedStorage`.
- Invalid codes and already-used codes return feedback in the GUI.
- Codes are one-time per player per server session by default.
