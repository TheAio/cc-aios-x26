args = {...}
memoryBank = {}
labels = {}
programCounter = 0
if #args == 0 then
    program = {"STORE STRING boot.wp 2","LOAD 2 2","RUN 2"}
else
    program = textutils.unserialise(args[1])
end
function splitSentance(line)
    local spaces = {}
    local quotes = {}
    local inQuote = false
    local escapeQuote = "\""
    for i=1,string.len(line) do
        if string.sub(line,i,i) == " " then
            if inQuote == false then
                spaces[#spaces+1] = i
            end
        elseif string.sub(line,i,i) == "\'" then
            if inQuote then
                if escapeQuote == "\'" then
                    inQuote = false
                    escapeQuote = "\""
                    quotes[#quotes+1]=i
                end
            else
                escapeQuote = "\'"
                inQuote = true
                quotes[#quotes+1]=i
            end
        elseif string.sub(line,i,i) == "\"" then
            if escapeQuote == "\"" then
                inQuote = (not inQuote)
                quotes[#quotes+1]=i
            end
        end
    end
    words = {}
    local last = 1
    for i=1,#spaces do
        words[#words+1] = string.sub(line,last,spaces[i]-1)
        last = spaces[i]+1
    end
    words[#words+1] = string.sub(line,last,string.len(line))
    return words
end

function findLabel(label)
    for i=1,#labels do
        if labels[i][1] == label then
            return labels[i]
        end
    end
end

function run(line)
    words = splitSentance(line)
    if words[1] == "STORE" then
        --- STORE TYPE VALUE #CELL ---
        local cell = tonumber(words[4])
        if cell == nil then error("Invalid cell number: " .. tostring(words[4])) end
        local val = words[3]
        if words[2] == "STRING" and val then
            local first = val:sub(1, 1)
            local last  = val:sub(-1)
            if (first == "'" and last == "'") or (first == '"' and last == '"') then
                val = val:sub(2, -2)
            end
        elseif words[2] == "NUMBER" then
            val = tonumber(val)
        end
        memoryBank[cell] = {words[2], val}
    elseif words[1] == "LOAD" then
        --- LOAD #CELL_A #CELL_B ---
        if fs.exists(memoryBank[tonumber(words[2])][2]) then
            local h = fs.open(memoryBank[tonumber(words[2])][2],"r")
            local j = {}
            while true do
                local i = h.readLine()
                if i == nil then break end
                j[#j+1] = i
            end
            h.close()
            memoryBank[tonumber(words[3])] = {"TABLE",j}
        end
    elseif words[1] == "RUN" then
        --- RUN #CELL ---
        program = memoryBank[tonumber(words[2])][2]
        programCounter = 0
        labels = {}
        memoryBank = {}
    elseif words[1] == "SAVE" then
        --- SAVE #TABLE_CELL PATH ---
        local t = memoryBank[tonumber(words[2])][2]
        local p = words[3]
        local h = fs.open(p,"w")
        for i=1,#t do
            h.writeLine(t[i])
        end
        h.close()
    elseif words[1] == "UNCOMPRESS" then
        --- UNCOMPRESS #TABLE_CELL_A #SUBCELL #CELL_B ---
        memoryBank[tonumber(words[4])] = {"STRING",memoryBank[tonumber(words[2])][2][tonumber(words[3])]}
    elseif words[1] == "COMPRESS" then
        --- COMPRESS #CELL_A #TABLE_CELL_B #SUBCELL
        local t = memoryBank[tonumber(words[3])][2]
        t[tonumber(words[4])] = memoryBank[tonumber(words[2])][2]
    elseif words[1] == "NEWTABLE" then
        --- NEWTABLE #CELL ---
        memoryBank[tonumber(words[2])] = {"TABLE",{}}
    elseif words[1] == "SOFTRESET" then
        --- SOFTRESET OPTIONAL_PC ---
        if tonumber(words[2]) ~= nil then
            programCounter = tonumber(words[2])
        end
        memoryBank = {}
        labels = {}
    elseif words[1] == "RESET" then
        --- RESET ---
        memoryBank = {}
        labels = {}
        programCounter = 0
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        term.setCursorPos(1,1)
        term.clear()
    elseif words[1] == "TERMINAL" then
        --- TERMINAL COMMAND ---
        -- SUBCOMMANDS:
        -- RESET
        -- CLEAR
        -- CURSOR X Y
        -- BG COLOR
        -- FG COLOR
        if words[2] == "CLEAR" then
            term.clear()
        elseif words[2] == "CURSOR" then
            term.setCursorPos(tonumber(words[3]),tonumber(words[4]))
        elseif words[2] == "BG" then
            term.setBackgroundColor(tonumber(words[3]))
        elseif words[2] == "FG" then
            term.setTextColor(tonumber(words[3]))
        elseif words[2] == "RESET" then
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
            term.setCursorPos(1,1)
            term.clear()
        end
    elseif words[1] == "SH" then
        --- SH #CELL ---
        shell.run(memoryBank[tonumber(words[2])][2])
    elseif words[1] == "PRINT" then
        --- PRINT #CELL ---
        print(memoryBank[tonumber(words[2])][2])
    elseif words[1] == "INPUT" then
        --- INPUT #CELL_A #CELL_B
        memoryBank[tonumber(words[2])] = {"STRING",read(words[3])}
    elseif words[1] == "LIVEINPUT" then
        --- LIVEINPUT #CELL ---
        local e,k = os.pullEvent("key")
        memoryBank[tonumber(words[2])] = {"NUMBER",k}
    elseif words[1] == "LETTERIZE" then
        --- LETTERIZE #CELL_A #CELL_B ---
        memoryBank[tonumber(words[2])] = {"STRING",string.char(memoryBank[tonumber(words[3])])}
    elseif words[1] == "TOSTRING" then
        --- TOSTRING #CELL ---
        memoryBank[tonumber(words[2])] = {"STRING",tostring(memoryBank[tonumber(words[2])][2])}
    elseif words[1] == "TONUMBER" then
        --- TONUMBER #CELL ---
        memoryBank[tonumber(words[2])] = {"NUMBER",tonumber(memoryBank[tonumber(words[2])][2])}
    elseif words[1] == "LABEL" then
        --- LABEL NAME TYPE VALUE ---
        labels[#labels+1] = {words[2],words[3],words[4]}
    elseif words[1] == "LABELLINE" then
        --- LABELLINE NAME ---
        labels[#labels+1] = {words[2],"NUMBER",programCounter}
    elseif words[1] == "JUMPIF" then
        --- JUMPIF #CELL_A #CELL_B LABEL ---
        if memoryBank[tonumber(words[2])][2] == memoryBank[tonumber(words[3])][2] then
            programCounter = tonumber(findLabel(words[4])[3])
        end
    elseif words[1] == "ADD" then
        --- ADD #CELL_A #CELL_B #CELL_C ---
        memoryBank[tonumber(words[4])] = {"NUMBER",memoryBank[tonumber(words[2])][2]+memoryBank[tonumber(words[3])][2]}
    elseif words[1] == "SUBTRACT" then
        --- SUB #CELL_A #CELL_B #CELL_C ---
        memoryBank[tonumber(words[4])] = {"NUMBER",memoryBank[tonumber(words[2])][2]-memoryBank[tonumber(words[3])][2]}
    elseif words[1] == "MULTIPLY" then
        --- MULTIPLY #CELL_A #CELL_B #CELL_C ---
        memoryBank[tonumber(words[4])] = {"NUMBER",memoryBank[tonumber(words[2])][2]*memoryBank[tonumber(words[3])][2]}
    elseif words[1] == "DIVIDE" then
        --- DIVIDE #CELL_A #CELL_B #CELL_C ---
        memoryBank[tonumber(words[4])] = {"NUMBER",memoryBank[tonumber(words[2])][2]/memoryBank[tonumber(words[3])][2]}
    elseif words[1] == "CONCAT" then
        --- CONCAT #CELL_A #CELL_B #CELL_C ---
        memoryBank[tonumber(words[4])] = {"STRING",memoryBank[tonumber(words[3])][2]..memoryBank[tonumber(words[2])][2]}
    elseif words[1] == "SUBSTRING" then
        --- SUBSTRING #CELL_A #CELL_B #CELL_C ---
        memoryBank[tonumber(words[2])] = {"STRING",string.sub(memoryBank[tonumber(words[2])][2],tonumber(memoryBank[tonumber(words[3])][2]),tonumber(memoryBank[tonumber(words[4])][2]))}
    end
end

function runProgram()
    while true do
        programCounter = programCounter+1
        if programCounter > #program then break end
        run(program[programCounter])
    end
end

run("RESET")
if #program == 0 then
    run("STORE STRING 'STANDARD LOAD:' 11")
    run("STORE STRING 'STORE STRING PATH PATHCELL' 12")
    run("STORE STRING 'LOAD PATHCELL PROGCELL' 13")
    run("STORE STRING 'RUN PROGCELL' 14")
    run("PRINT 11")
    run("PRINT 12")
    run("PRINT 13")
    run("PRINT 14")
    while true do
        run("LABELLINE BOOT_MAIN")
        run("INPUT 1")
        program = {memoryBank[1][2]}
        --STORE STRING PATH PATHCELL
        --LOAD PATHCELL PROGCELL
        --RUN PROGCELL
        runProgram()
        if #program > 1 then break end
        run("JUMPIF 1 1 BOOT_MAIN")
    end
else
    runProgram()
end
