history = {
   _list = {},
   _numItems = 0,
   MAX_HISTORY_LENGTH = 8,
}

function history:load()
   self._items = {}
   self._numItems = 0
   local historyFile = self:getFilePathAndCreateDirectory()
   local info = love.filesystem.getInfo(historyFile)
   if info == nil then
      -- print('no history file exists')
   else
      local contents, size = love.filesystem.read(historyFile)
      if size > 0 then
         local items, numItems = self:split(contents, '\n')
         local firstListItem, prevListItem = nil, nil
         for k, item in pairs(items) do
            local listItem = { next = nil, value = item }
            if prevListItem then
               prevListItem.next = listItem
            else
               firstListItem = listItem
            end
            prevListItem = listItem
         end
         self._list = firstListItem
         self._numItems = numItems
      else
         -- print("unable to read file")
      end
   end
end

function history:split(str, sep)
   if sep == nil then
      sep = "%s"
   end
   local t = {} ; i = 0
   for str in string.gmatch(str, "([^"..sep.."]+)") do
      i = i + 1
      t[i] = str
   end
   return t, i
end

function history:get()
   local copy, index = {}, 1
   local listItr = self._list
   while listItr do
      copy[index] = listItr.value
      listItr = listItr.next
      index = index + 1
   end
   return copy, self._numItems
end

function history:push(item)
   -- insert at beginning
   self._list = { next = self._list, value = item }
   self._numItems = self._numItems + 1

   -- unique
   self:_ensureUnique()

   -- maybe trim
   self:_maybeTrimToLength(self.MAX_HISTORY_LENGTH)

   -- save to disk
   local success, message = self:write()
   if not success then
      print("unable to write history file:", message)
   end
end

function history:write()
   local historyFile = self:getFilePathAndCreateDirectory()
   local fileContents = ''
   local listItr = self._list
   while listItr do
      local item = listItr.value
      if item:len() > 0 then
         fileContents = fileContents .. item .. '\n'
      end
      listItr = listItr.next
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

function history:_ensureUnique()
   local values = {}
   local listItr, prev = self._list, nil
   while listItr do
      if values[listItr.value] == nil then
         values[listItr.value] = true
         prev = listItr
      else
         -- already exists, remove from list
         if prev then
            prev.next = listItr.next
         end
      end
      listItr = listItr.next
   end
end

function history:_maybeTrimToLength(maxLength)
   if self._numItems > maxLength then
      local listItr, prevItem, numItems = self._list, nil, 0
      while listItr and numItems < maxLength do
         prevItem = listItr
         listItr = listItr.next
         numItems = numItems + 1
      end
      prevItem.next = nil
      self._numItems = numItems
   end
end

return history
