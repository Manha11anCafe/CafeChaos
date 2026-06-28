local Logger = {}

function Logger:Info(systemName, message)
	print(string.format("[%s] %s", systemName, message))
end

function Logger:Warn(systemName, message)
	warn(string.format("[%s] %s", systemName, message))
end

function Logger:Error(systemName, message)
	error(string.format("[%s] %s", systemName, message))
end

return Logger