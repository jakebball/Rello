local CommandQueue = {}

CommandQueue.queue = {}

function CommandQueue.addToQueue(actionType, arguments)
	table.insert(CommandQueue.queue, {actionType, unpack(arguments)})
end

return CommandQueue
