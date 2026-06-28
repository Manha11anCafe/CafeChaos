local CustomerState = {}

CustomerState.Spawning = "Spawning"
CustomerState.WalkingToQueue = "WalkingToQueue"
CustomerState.WaitingInQueue = "WaitingInQueue"
CustomerState.Ordering = "Ordering"
CustomerState.WaitingForDrink = "WaitingForDrink"
CustomerState.Leaving = "Leaving"
CustomerState.Finished = "Finished"

return table.freeze(CustomerState)