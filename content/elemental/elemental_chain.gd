## Shared bounded reaction-chain context; child damage requests inherit this object.
## It carries only transient safety bookkeeping, never gameplay authority.
extends RefCounted
class_name ElementalChain

const MAX_DEPTH: int = 4
const MAX_ACTIONS: int = 64

var depth: int = 0
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


## Returns a child context sharing the budget and visit set through its parent.
## A child is only permitted below the fixed maximum depth.
func can_descend() -> bool:
	if depth >= MAX_DEPTH:
		truncated = true
		return false
	return true
