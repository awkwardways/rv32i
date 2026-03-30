local img = io.open(".\\img.mi", "w")
local depth = 4096
if not img then print("Could not open file") return end

img:write("#File_format=AddrHex\n#Address_depth=4096\n#Data_width=32\n")

for i = 0, depth - 1, 1 do
  img:write(string.format("%03x:%08x", i, i) .. "\n")
end