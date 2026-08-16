TW,TH = term.getSize()
function rgbToHex(R,G,B)
    local h = {
    {"A",10},{"B",11},
    {"C",12},{"D",13},
    {"E",14},{"F",15}
    }
    if R > 9 then R = h[R-9][1] end
    if G > 9 then G = h[G-9][1] end
    if B > 9 then B = h[B-9][1] end
    return tonumber("0x"..R..R..G..G..B..B)
end
function transportColor(TARGET,HEX)
    term.setPaletteColor(TARGET,HEX)
end
function fade(R,G,B,AMMOUNT)
    return math.floor(R*AMMOUNT),math.floor(G*AMMOUNT),math.floor(B*AMMOUNT)
end
function ditther(sx,sy,ex,ey)
    for i=sy,ey do
        for j=sx,ex do
            term.setCursorPos(j,i)
            print(string.char(127))
        end
    end
end
--
function checkAuth(user,minimum)
    if fs.exists("/.sys/home/"..uname.."/conf/permission.conf") then
        h=fs.open("/.sys/home/"..uname.."/conf/permission.conf","r")
        h.readLine()
        local k = tonumber(h.readLine())
        if k-1 < minimum then
            h.close()
            return true
        end
        h.close()
    end
    return false
end
function menu(opts,title,sy,six,siy,bga,bgb,fg)
    local TW,TH = term.getSize()
    local sel = 1
    while true do
        term.setBackgroundColor(bga)
        term.setTextColor(bgb)
        ditther((TW/2)-six,sy,(TW/2)+six,sy+siy)
        term.setTextColor(fg)
        term.setCursorPos((TW/2)-(string.len(title)/2),sy)
        print(title)
        for i=1,#opts do
            term.setCursorPos((TW/2)-six,sy+1+i)
            if i == sel then
                term.setCursorPos((TW/2)-six,sy+1+i)
                print(string.char(16),opts[i],string.char(17))
            else
                print(opts[i])
            end
        end
        e,k=os.pullEvent("key")
        if k == keys.up then
            sel = sel - 1
        elseif k == keys.down then
            sel = sel + 1
        elseif k == keys.enter then
            return opts[sel]
        end
        if sel < 1 then sel = 1 end
        if sel > #opts then sel = #opts end
    end
end
function AMenu(user)
    TW,TH = term.getSize()
    transportColor(colors.gray,0x222222)
    transportColor(colors.lightGray,0x555555)
    transportColor(colors.white,0xFFFFFF)
    if isAdmin then
        sel=menu({"DESKTOP","SHELL","REBOOT","SHUTDOWN","BOOTLOADER"},"AIOS",TH/4,10,TH/2,colors.gray,colors.lightGray,colors.white)
    else
        sel=menu({"DESKTOP","REBOOT","SHUTDOWN"},"AIOS",TH/4,10,TH/2,colors.gray,colors.lightGray,colors.white)
    end
    if sel == "SHELL" then
        term.setCursorPos(1,1)
        term.setBackgroundColor(colors.black)
        term.clear()
        shell.run("sh")
    elseif sel == "SHUTDOWN" then
        os.shutdown()
    elseif sel == "REBOOT" then
        os.reboot()
    elseif sel == "BOOTLOADER" then
        shell.run("/boot.lua",textutils.serialise({}))
    end
end
function desktop(user)
    isAdmin = checkAuth(user,0)
    while true do
        if fs.exists("/.sys/home/"..user.."/desktop/") then
            d = fs.list("/.sys/home/"..user.."/desktop/")
        else
            d = {}
        end
        local apps = {}
        --apps = {...{ type,name,description,icon,parameters }...}
        for i=1,#d do
            if fs.exists("/.sys/home/"..user.."/desktop/"..d[i].."/.info") then
                local h = fs.open("/.sys/home/"..user.."/desktop/"..d[i].."/.info","r")
                h.readLine()
                local j = {h.readLine(),h.readLine(),h.readLine(),h.readLine(),h.readLine()}
                h.close()
                apps[#apps+1]=j
            else
                apps[#apps+1]={"FILE",d[i],"",nil,"/.sys/home/"..user.."/desktop/"..d[i]}
            end
        end
        if fs.exists("/.sys/home/"..user.."/conf/desktop.conf") then
            local h = fs.open("/.sys/home/"..user.."/conf/desktop.conf","r")
            h.readLine()
            deskconf = {tonumber(h.readLine()),tonumber(h.readLine()),tonumber(h.readLine()),h.readLine(),h.readLine(),tonumber(h.readLine())}
            --deskconf = { colorA,colorB,colorC,doFade,timeFormat,timeZone}
            if deskconf[4] == "true" then
                deskconf[4] = true
            else
                deskconf[4] = false
            end
            h.close()
        else
            deskconf = {0xAAAAAA,0xAAAA00,0x00AAAA,true,"12",2}
        end
        TW,TH = term.getSize()
        transportColor(colors.magenta,deskconf[1])
        transportColor(colors.pink,deskconf[2])
        transportColor(colors.purple,deskconf[3])
        term.setBackgroundColor(colors.pink)
        term.clear()
        if deskconf[4] then
            term.setTextColor(colors.purple)
            ditther(1,1,TW,TH-1)
        end
        term.setBackgroundColor(colors.purple)
        term.setTextColor(colors.magenta)
        appPos={}
        j=1
        k=1
        for i=1,#apps do
            appPos[#appPos+1]={apps[i],j,k,j+5,k+5}
            term.setCursorPos(j,k)
            if apps[i][4] ~= nil then
                paintutils.drawImage(paintutils.loadImage(apps[i][4]),j,k)
            else
                term.setBackgroundColor(colors.yellow)
                paintutils.drawFilledBox(j,k,j+4,k+4)
            end
            term.setBackgroundColor(colors.purple)
            term.setCursorPos(j,k+5)
            if string.len(apps[i][2]) > 5 then
                print(string.sub(apps[i][2],1,5))
            else
                print(apps[i][2])
            end
            j=i*7
            if j+5 > TW then
                j=1
                k=k+6
            end
        end
        local function lnch(appInfo)
            --{ type,name,description,icon,parameters }
            if appInfo[1] == "FILE" then
                if isAdmin then
                    sel = menu({"EDIT","LUA","SHELL","WP","EXIT"},"How should AIOS run this?",10,15,8,colors.purple,colors.magenta,colors.white)
                else
                    sel = menu({"LUA","SHELL","WP","EXIT"},"How should AIOS run this?",10,15,8,colors.purple,colors.magenta,colors.white)
                end
                if sel == "EDIT" then
                    shell.run("edit",appInfo[5])
                elseif sel == "SHELL" then
                    shell.run(appInfo[5])
                elseif sel == "LUA" then
                    dofile(appInfo[5])
                elseif sel == "WP" then
                    local h = fs.open(appInfo[5],"r")
                    local i = {}
                    while true do
                        local j = h.readLine()
                        if j == nil then break end
                        i[#i+1] = j
                    end
                    h.close()
                    shell.run("/boot.lua",textutils.serialise(i))
                end
            elseif appInfo[1] == "LUA" then
                dofile(appInfo[5])
            elseif appInfo[1] == "SHELL" then
                shell.run(appInfo[5])
            elseif appInfo[1] == "WP" then
                shell.run("/boot.lua",appInfo[5])
            elseif appInfo[1] == "WGR" then
                shell.run("wget run",appInfo[5])
            elseif appInfo[1] == "PBR" then
                shell.run("pastebin run",appInfo[5])
            end
        end
        term.setCursorPos(1,TH)
        transportColor(colors.cyan,deskconf[3])
        term.setBackgroundColor(colors.cyan)
        term.clearLine()
        term.write("A")

        local daT = os.date("!*t")
        if math.floor(deskconf[6])-deskconf[6] ~= 0 then
            daM = math.floor(deskconf[6])-deskconf[6] * 60
            daM = daT.min - daM
        else
            daM = daT.min
        end
        daH = daT.hour + math.floor(deskconf[6])
        if deskconf[5] == "12" then
            daHPM = "AM"
            if daH > 12 then
                daHPM = "PM"
                daH = daH - 12
            end
            daS = tostring(daH)..":"..tostring(daM).." "..daHPM
        elseif deskconf[5] == "24" then
            daS = tostring(daH)..":"..tostring(daM)
        elseif deskconf[5] == "BEATS" then
            daT = os.date("!*t")
            daH = daT.hour+1
            daM = daT.min
            daB = ((daH+(daM/60))/24)*1000
            daS = "@"..tostring(math.floor(daB))
        elseif deskconf[5] == "MCR" then
            daS = math.floor(os.time())
        elseif deskconf[5] == "UPTIME" then
            daS = math.floor(os.clock())
        end
        term.setCursorPos(TW-string.len(daS),TH)
        term.write(daS)
        if term.isColor() then
            e,k,x,y = os.pullEvent("mouse_click")
            if x < 2 and y == TH then
                AMenu(user)
            else
                for i=1,#appPos do
                    if y-1>appPos[i][3] and y+1<appPos[i][5] then
                        if x-1>appPos[i][2] and x+1<appPos[i][4] then
                            lnch(appPos[i][1])
                        end
                    end
                end
            end
        else
            term.setCursorPos(1,1)
            x=tonumber(read())
            if x == "A" then
                AMenu(user)
            else
                if x ~= nil then
                    if x < #appPos+1 then
                        lnch(appPos[i][1])
                    end
                end
            end
        end
        sleep(0)
    end
end

function login()
    TW,TH = term.getSize()
    transportColor(colors.black,0x0)
    transportColor(colors.white,0xFFFFFF)
    transportColor(colors.gray,0x111111)
    term.setBackgroundColor(colors.lightGray)
    term.setTextColor(colors.gray)
    term.clear()
    ditther(TW/2-(TW/3),2,TW/2+(TW/3),TH-2)
    local i = 0x000000
    while i<0x505050 do
        i=i+0x111111
        transportColor(colors.gray,i)
        transportColor(colors.lightGray,i+0x505050)
        sleep(0)
    end
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.setCursorPos((TW/2)-string.len("LOGIN/REGISTER")/2,TH/4)
    print("LOGIN/REGISTER")
    term.setCursorPos((TW/2)-string.len("ANAVARAGEUSERNAME")/2,(TH/4)+3)
    print(string.rep(" ",17))
    term.setCursorPos((TW/2)-string.len("ANAVARAGEUSERNAME")/2,(TH/4)+3)
    term.setTextColor(colors.gray)
    print("NAME")
    term.setTextColor(colors.white)
    term.setCursorPos((TW/2)-string.len("ANAVARAGEUSERNAME")/2,(TH/4)+3)
    uname = read()
    if fs.exists("/.sys/home/"..uname.."/") then
        if fs.exists("/.sys/home/"..uname.."/conf/.pass.key") then
            term.setCursorPos((TW/2)-string.len("ANAVARAGEUSERNAME")/2,(TH/4)+5)
            print(string.rep(" ",17))
            term.setCursorPos((TW/2)-string.len("ANAVARAGEUSERNAME")/2,(TH/4)+5)
            term.setTextColor(colors.gray)
            print("PASSWORD")
            term.setTextColor(colors.white)
            term.setCursorPos((TW/2)-string.len("ANAVARAGEUSERNAME")/2,(TH/4)+5)
            PASS = read(" ")
            local j = 0
            PASS = PASS..uname
            for i=1,string.len(PASS) do
                j=j+string.byte(string.sub(PASS,i,i))
                j=j-i
            end
            PASS = j
            local h = fs.open("/.sys/home/"..uname.."/conf/.pass.key","r")
            h.readLine()
            if PASS == tonumber(h.readLine()) then
                h.close()
                desktop(uname)
            else
                h.close()
            end
        else
            desktop(uname)
        end
    else
        term.setCursorPos((TW/2)-string.len("REGISTER NEW USER? y/N")/2,TH/4)
        print("REGISTER NEW USER? Y/N")
        sleep(1)
        e,k = os.pullEvent("key")
        if k == keys.y then
            shell.run("/.sys/common/OOTB.lua")
            sleep(1)
            os.reboot()
        end
    end
end
login()
sleep(0)
