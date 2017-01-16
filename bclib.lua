-- write string to file

function str2file (string, file)
   temp = io.open(file,"w")
   temp:write(string)
   temp:close()
end

-- read string from file

function file2str (file)
 res = ""
   for i in io.lines(file) do
  res = res..i.."\n"
   end
 return res
end

-- append string to file

function append2file (string, file)
   temp = io.open(file,"a+")
   temp:write(string)
   temp:close()
end

-- removes newlines at end of string

function chomp (str)
   return string.gsub(str, "[\r\n]+$", "")
end

-- fake sha1 function that uses system call
-- TODO: do this better

function sha1 (string)
   str2file(string,"/tmp/lua-sha1.txt")
   os.execute("/usr/bin/sha1sum /tmp/lua-sha1.txt | /bin/cut -d ' ' -f 1 > /tmp/lua-sha1-out.txt")
   return chomp(file2str("/tmp/lua-sha1-out.txt"))
end

-- very ugly file_exists
-- TODO: find better way to do this

function file_exists (filename)
   return io.open(filename)
end
