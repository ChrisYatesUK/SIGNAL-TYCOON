--!strict
-- Public DISPLAY contracts only. Do not replace the engineer's Shared/Types.lua.
export type Text = { key: string, args: {[string]: any}? }
export type Row = {
 id: string, kind: string, text: Text, detail: Text?,
 action: string?, payload: {[string]: any}?, enabled: boolean?, reason: Text?,
 field: string?, value: any?, options: {{id: string, text: Text}}?,
 current: number?, maximum: number?, deadline: number?,
 rarity: string?, confirm: Text?, notBefore: number?, bindings: {[string]:any}?,
}
export type Screen = { rows: {Row}, footer: Row?, revision: number }
export type Snapshot = {
 revision: number, screens: {[string]: Screen},
 hud: { credits: string, followers: string, phase: string, completesAt: number?, partner: string? },
 settings: {reducedEffects: boolean, volume: number, locale: string},
}
export type Intent = {
 requestId: string, screen: string, action: string, revision: number,
 payload: {[string]: any}, draft: {[string]: any},
}
return {}
