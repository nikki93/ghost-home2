history = {
   _items = {},
   _numItems = 0,
   MAX_HISTORY_LENGTH = 1, -- todo: increase this, make actual queue
}

function history:load()
   local item = nil
   local historyFile = self:getFilePathAndCreateDirectory()
   info = love.filesystem.getInfo(historyFile)
   if info == nil then
      -- print("no history exists")
   else
      local contents, size = love.filesystem.read(historyFile)
      if size > 0 then
         item = contents
      else
         -- print("unable to read file")
      end
   end

   if item then
      self._items = { item, }
      self._numItems = 1
   else
      self._items = {}
      self._numItems = 0
   end
end

function history:get()
   return self._items, self._numItems
end

function history:push(item)
   local historyFile = self:getFilePathAndCreateDirectory()
   local success, message = love.filesystem.write(historyFile, item)
   if success then
      -- print("wrote scores file")
      self._items = { item, }
      self._numItems = 1
   else
      print("unable to write scores file:", message)
   end
end

function history:getFilePathAndCreateDirectory()
   local saveDirectory = love.filesystem.getSaveDirectory()
   local historyDirectory = saveDirectory .. "/home/save"
   local info = love.filesystem.getInfo(historyDirectory)
   if info == nil then
      local success = love.filesystem.createDirectory(historyDirectory)
      if success == false then
         print("unable to create scores save path")
      end
   end
   local historyFilePath = historyDirectory .. "/history.dat"
   return historyFilePath
end

return history
