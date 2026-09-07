## Shared transient safety budget for one root impact and all secondary damage requests.
extends RefCounted
class_name ElementalChain

const MAX_DEPTH: int = 4
const MAX_ACTIONS: int = 64

var remaining_actions: int = MAX_ACTIONS
var visited: Dictionary = {}
var truncated: bool = false


## Reserves one action from the shared budget, rejecting exhaustion deterministically.
func spend() -> bool:
	if remaining_actions <= 0:
		truncated = true
		return false
	remaining_actions -= 1
	return true


## Rejects a secondary impact beyond the maximum depth; the caller supplies its current depth.
func can_descend(depth: int) -> bool:
	if depth >= MAX_DEPTH:
		truncated = true
		return false
	return true


## Claims one target/rule/channel signature to prevent repeated secondary damage cycles.
func claim(key: String) -> bool:
	if visited.has(key):
		truncated = true
		return false
	visited[key] = true
	return true
