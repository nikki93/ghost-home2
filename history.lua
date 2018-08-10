history = {
   _items = {},
   _numItems = 0,
   MAX_HISTORY_LENGTH = 9, -- todo: increase this, make actual queue
}

function history:load()
   self._items = {}
   self._numItems = 0
   local historyFile = self:getFilePathAndCreateDirectory()
   local info = love.filesystem.getInfo(historyFile)
   if info == nil then
      -- print('no history file exists')
   else
      for line in love.filesystem.lines(historyFile) do
         if line:len() > 0 then
            self._numItems = self._numItems + 1
            self._items[self._numItems] = line
         end
      end
   end
end

function history:get()
   return self._items, self._numItems
end

function history:push(item)
   -- insert at beginning
   -- (todo: efficient)
   for index = self._numItems, 1, -1 do
      self._items[index + 1] = self._items[index]
   end
   self._items[1] = item
   self._numItems = self._numItems + 1

   -- maybe trim
   if self._numItems > self.MAX_HISTORY_LENGTH then
      self._items[self._numItems] = nil
      self._numItems = self._numItems - 1
   end

   -- save to disk
   local success, message = self:write()
   if not success then
      print("unable to write history file:", message)
   end
end

function history:write()
   local historyFile = self:getFilePathAndCreateDirectory()
   local fileContents = ''
   for index, item in pairs(self._items) do
      print('trying to write item and index:', index, item)
      if item:len() > 0 then
         fileContents = fileContents .. item .. '\n'
      end
   end
   return love.filesystem.write(historyFile, fileContents)
end

function history:getFilePathAndCreateDirectory()
   -- TODO: nikki: fix this
   local saveDirectory = love.filesystem.getSaveDirectory()
   -- local saveDirectory = '~/Library/Application Support/package'
   local historyDirectory = saveDirectory .. "/home/save"
   local info = love.filesystem.getInfo(historyDirectory)
   if info == nil then
      local success = love.filesystem.createDirectory(historyDirectory)
      if success == false then
         print("unable to create history save path")
      end
   end
   local historyFilePath = historyDirectory .. "/history.dat"
   return historyFilePath
end

return history
