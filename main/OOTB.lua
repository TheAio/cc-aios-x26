function transportColor(TARGET,HEX)
    term.setPaletteColor(TARGET,HEX)
end
function ditther(sx,sy,ex,ey)
    for i=sy,ey do
        for j=sx,ex do
            term.setCursorPos(j,i)
            print(string.char(127))
        end
    end
end

function clear()
    term.setBackgroundColor(colors.lightGray)
    term.setTextColor(colors.gray)
    term.clear()
    ditther(1,1,TW,TH-1)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
end
TW,TH = term.getSize()
transportColor(colors.black,0x0)
transportColor(colors.white,0xFFFFFF)
transportColor(colors.gray,0x111111)
transportColor(colors.lightGray,0xFBFFD6-(0x060606*4))
transportColor(colors.gray,0xFBFFD6-(0x060606*5))
clear()
term.setCursorPos(TW/2-(string.len("WELCOME TO AIOS X26 CARBON")/2),TH/4)
print("WELCOME TO AIOS X26 CARBON")
while true do
    term.setCursorPos(TW/2-(string.len("What is your GMT offset?")/2),TH/3)
    print("What is your GMT offset?")
    term.setCursorPos(TW/2-(string.len("For GMT+- please enter XX")/2),(TH/3)+1)
    local i = os.date("!*t")
    local j = os.date("*t")
    i = j.hour-i.hour
    j = i
    if i>-1 then j="+"..tostring(i) end
    i=tostring(i)
    print("For GMT"..j,"please enter",i)
    term.setCursorPos(TW/2-(string.len("     ")/2),(TH/3)+2)
    print("     ")
    term.setCursorPos(TW/2-(string.len("     ")/2),(TH/3)+2)
    GMT = read()
    if tonumber(GMT) ~= nil then
        break
    end
end

function lic(name,path,returnDeny)
    while true do
        clear()
        term.setCursorPos(TW/2-(string.len("LICENSES, NOTICES AND AGREEMENTS")/2),(TH/4)-2)
        print("LICENSES, NOTICES AND AGREEMENTS")
        term.setCursorPos(TW/2-(string.len("Please read and agree to the "..name)/2),TH/4)
        print("Please read and agree to the "..name)
        term.setCursorPos(TW/2-(string.len("Press R to read, Y to accept or N to deny.")/2),(TH/4)+1)
        print("Press R to read, Y to accept or N to deny.")
        sleep(0.25)
        e,k = os.pullEvent("key")
        if k == keys.n then
            if returnDeny then
                return false
            end
            os.shutdown()
        elseif k == keys.y then
            if returnDeny then
                return true
            end
            break
        elseif k == keys.r then
            term.clear()
            term.setCursorPos(1,1)
            local h = fs.open(path,"r")
            while true do
                local i = h.readLine()
                print(i)
                if i == nil then break end
                sleep(1)
            end
        end
    end
end
lic("copyright notice","/.sys/common/agreements/COPYRIGHT.readme")
lic("moral agreement","/.sys/common/agreements/MORAL.readme")
while true do
    clear()
    sleep(0)
    term.setCursorPos(TW/2-(string.len("Please enter the username you would prefer:")/2),(TH/4))
    print("Please enter the username you would prefer:")
    term.setCursorPos(TW/2-(string.len("ANAVARAGEUSERNAME")/2),(TH/4)+2)
    print(string.rep(" ",17))
    term.setCursorPos(TW/2-(string.len("ANAVARAGEUSERNAME")/2),(TH/4)+2)
    uname = read()
    if string.len(uname) > 0 then
        if fs.exists("/.sys/home/"..uname.."/") == false then
            break
        end
    end
    term.setCursorPos(TW/2-(string.len("Username too short or already in use!")/2),(TH/4)+2)
    transportColor(colors.red,0xFF0000)
    term.clearLine()
    term.setTextColor(colors.red)
    print("Username too short or already in use!")
    sleep(1)
end
clear()
local i = fs.exists("/.sys/home/")
h=fs.open("/.sys/home/"..uname.."/conf/permission.conf","w")
h.writeLine("error('This is not a program!')")
if i then
    h.writeLine(999)
else
    h.writeLine(0)
end
h.close()
if i then
    term.setCursorPos(TW/2-(string.len("By default new accounts other then the first")/2),(TH/4))
    print("By default new accounts other then the first")
    term.setCursorPos(TW/2-(string.len("get full restrictions for security purposes,")/2),(TH/4)+1)
    print("get full restrictions for security purposes,")
    term.setCursorPos(TW/2-(string.len("consider asking the administrator for assistance.")/2),(TH/4)+2)
    print("consider asking the administrator for assistance.")
    term.setCursorPos(TW/2-(string.len("Strike any key to continue")/2),(TH/4)+4)
    print("Strike any key to continue")
    sleep(1)
    os.pullEvent("key")
else
    term.setCursorPos(TW/2-(string.len("Install standard software? y/N")/2),(TH/4))
    print("Install standard software? y/N")
    term.setCursorPos(TW/2-(string.len(" ")/2),(TH/4)+1)
    if string.upper(read()) == "Y" then
        clear()
        shell.run("wget https://raw.githubusercontent.com/Xella37/PineStore-site/refs/heads/main/LICENSE /.sys/tmp/short/PSLIC")
        if lic("pinestore copyright notice","/.sys/tmp/short/PSLIC",true) then
            shell.run("wget https://raw.githubusercontent.com/TheAio/cc-aios-x26/refs/heads/main/software/standard/store/.ico.nfp /.sys/home/"..uname.."/desktop/store/.ico.nfp")
            shell.run("wget https://raw.githubusercontent.com/TheAio/cc-aios-x26/refs/heads/main/software/standard/store/entry.point /.sys/home/"..uname.."/desktop/store/entry.point")
            shell.run("wget https://raw.githubusercontent.com/TheAio/cc-aios-x26/refs/heads/main/software/standard/store/.info /.sys/home/"..uname.."/desktop/store/.info")
        end
        clear()
        sleep(math.random())
        shell.run("wget https://raw.githubusercontent.com/TheAio/cc-aios-x26/refs/heads/main/software/standard/systm/.ico.nfp /.sys/home/"..uname.."/desktop/systm/.ico.nfp")
        shell.run("wget https://raw.githubusercontent.com/TheAio/cc-aios-x26/refs/heads/main/software/standard/systm/.info /.sys/home/"..uname.."/desktop/systm/.info")
        shell.run("wget https://raw.githubusercontent.com/TheAio/cc-aios-x26/refs/heads/main/software/standard/systm/entry.point /.sys/home/"..uname.."/desktop/systm/entry.point")
        clear()
        sleep(math.random())
        shell.run("wget https://raw.githubusercontent.com/TheAio/cc-aios-x26/refs/heads/main/software/standard/files/.ico.nfp /.sys/home/"..uname.."/desktop/files/.ico.nfp")
        shell.run("wget https://raw.githubusercontent.com/TheAio/cc-aios-x26/refs/heads/main/software/standard/files/.info /.sys/home/"..uname.."/desktop/files/.info")
        shell.run("wget https://raw.githubusercontent.com/TheAio/cc-aios-x26/refs/heads/main/software/standard/files/entry.point /.sys/home/"..uname.."/desktop/files/entry.point")
        clear()
        sleep(0)
    end
    sleep(0)
end
clear()
term.setCursorPos(TW/2-(string.len("Please enter a password to use:")/2),(TH/4))
print("Please enter a password to use:")
term.setCursorPos(TW/2-(string.len("ANAVARAGEPASSWORDCANBEQUITELONG")/2),(TH/4)+2)
print(string.rep(" ",31))
term.setCursorPos(TW/2-(string.len("ANAVARAGEPASSWORDCANBEQUITELONG")/2),(TH/4)+2)
PASS = read("*")
sleep(1)
local j = 0
PASS = PASS..uname
for i=1,string.len(PASS) do
    j=j+string.byte(string.sub(PASS,i,i))
    j=j-i
end
PASS = j
h = fs.open("/.sys/home/"..uname.."/conf/.pass.key","w")
h.writeLine("error('This is not a program')")
h.writeLine(PASS)
h.close()
R = 14
G = 15
B = 12
C = 1
while true do
    clear()
    term.setCursorPos(TW/2-(string.len("Please select a color you enjoy!")/2),(TH/4))
    print("Please select a color you enjoy!")
    term.setCursorPos(TW/2-(string.len("Use left/right arrows or A/D to cycle hue")/2),(TH/4)+1)
    print("Use left/right arrows or A/D to cycle hue")
    term.setCursorPos(TW/2-(string.len("Use up/down arrows or W/S to cycle value")/2),(TH/4)+2)
    print("Use up/down arrows or W/S to cycle value")
    term.setCursorPos(TW/2-(string.len("[R]GB | [XXX] XXX XXX")/2),(TH/4)+5)
    print("                     ")
    term.setCursorPos(TW/2-(string.len("[R]GB | [XXX] XXX XXX")/2),(TH/4)+5)
    if C == 1 then
        print("[R]GB | ["..R.."]",G,B)
    elseif C == 2 then
        print("R[G]B | "..R.." ["..G.."]",B)
    else
        print("RG[B] | ",R,G,"["..B.."]")
    end
    e,k = os.pullEvent("key")
    if k == keys.left or k == keys.a then
        C = C - 1
    elseif k == keys.right or k == keys.d then
        C = C + 1
    elseif k == keys.up or k == keys.w then
        if C == 1 then R = R + 1 end
        if C == 2 then G = G + 1 end
        if C == 3 then B = B + 1 end
    elseif k == keys.down or k == keys.s then
        if C == 1 then R = R - 1 end
        if C == 2 then G = G - 1 end
        if C == 3 then B = B - 1 end
    elseif k == keys.enter then
        break
    end
    if C < 1 then C = 1 end
    if C > 3 then C = 3 end
    if R > 15 then R = 15 end
    if R < 5 then R = 5 end
    if G > 15 then G = 15 end
    if G < 5 then G = 5 end
    if B > 15 then B = 15 end
    if B < 5 then B = 5 end
    COLA = math.floor((R+G+B)/3)
    COLA = math.max(0xDDDDDD,COLA)
    L = {"A","B","C","D","E","F"}
    RR = R
    GG = G
    BB = B
    if RR > 9 then RR = L[R-9] end
    if GG > 9 then GG = L[G-9] end
    if BB > 9 then BB = L[B-9] end
    if COLA > 15 then COLA = 15 end
    if COLA > 9 then COLA = L[COLA-9] end
    COLA = "0x"..tostring(COLA)..tostring(COLA)..tostring(COLA)..tostring(COLA)..tostring(COLA)..tostring(COLA)
    COLB = "0x"..tostring(RR)..tostring(RR)..tostring(GG)..tostring(GG)..tostring(BB)..tostring(BB)
    COLC = tostring(tonumber(COLB)-0x050505)
    transportColor(colors.white,tonumber(COLA))
    transportColor(colors.lightGray,tonumber(COLB))
    transportColor(colors.gray,tonumber(COLC))
    sleep(0)
end
transportColor(colors.black,0x0)
transportColor(colors.white,0xFFFFFF)
transportColor(colors.lightGray,0xFBFFD6-(0x060606*4))
transportColor(colors.gray,0xFBFFD6-(0x060606*5))
clear()
term.setCursorPos(TW/2-(string.len("Select clock format")/2),(TH/4))
print("Select clock format")
ClockFormat = "12"
--TODO
clear()
term.setCursorPos(TW/2-(string.len("Please wait...")/2),(TH/4))
print("Please wait...")
h=fs.open("/.sys/home/"..uname.."/conf/desktop.conf","w")
h.writeLine("error('This is not a program!')")
h.writeLine(COLA)
h.writeLine(COLB)
h.writeLine(COLC)
h.writeLine(true)
h.writeLine(ClockFormat)
h.writeLine(GMT)
shell.run("mkdir","/.sys/home/"..uname.."/desktop/")
for i=1,150 do
    transportColor(colors.gray,(0xFBFFD6-(0x060606*5))-(i*0x010101))
    transportColor(colors.lightGray,(0xFBFFD6-(0x060606*4))-(i*0x010101))
    sleep(0)
end
transportColor(colors.lightGray,(0xFBFFD6-(0x060606*4))-(151*0x010101))
transportColor(colors.gray,(0xFBFFD6-(0x060606*4))-(151*0x010101))
os.reboot()
