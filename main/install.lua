term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1,1)
print("Welcome to AIOS X26 CARBON")
print("")
print("Please wait...")
sleep(0)
function fetch(file,path)
    shell.run("wget","https://raw.githubusercontent.com/TheAio/cc-aios-x26/refs/heads/main/"..file,path)
    if fs.exists(path) == false then
        sleep(math.random()*10)
        fetch(file,path)
    end
end
fetch("ver","/.sys/common/.ver")
fetch("main/10.prgm","/.boot/init/10.prgm")
fetch("main/COPYRIGHT.readme","/.sys/common/agreements/COPYRIGHT.readme")
fetch("main/MORAL.readme","/.sys/common/agreements/MORAL.readme")
fetch("main/main.lua","/.sys/main.lua")
fetch("main/OOTB.lua","/.sys/common/OOTB.lua")
fetch("main/update.lua","/.sys/common/update.lua")
fetch("main/boot.lua","boot.lua")
fetch("main/boot.wp","boot.wp")
if fs.exists("startup.lua") then
    term.clear()
    term.setCursorPos(1,1)
    print("startup.lua already exists, overwrite?")
    print("Y/n")
    i = string.upper(read())
    if i == "n" or i == "NO" then
        os.reboot()
    end
    h=fs.open("startup.lua","w")
    h.writeLine("shell.run('boot')")
    h.writeLine("os.reboot()")
    h.close()
else
    h=fs.open("startup.lua","w")
    h.writeLine("shell.run('boot')")
    h.writeLine("os.reboot()")
    h.close()
end
os.reboot()
