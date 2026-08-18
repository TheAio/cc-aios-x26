shell.run("wget https://raw.githubusercontent.com/TheAio/cc-aios-x26/refs/heads/main/ver /.sys/tmp/short/.ver")
if fs.exists("/.sys/tmp/short/.ver") and fs.exists("/.sys/common/.ver") then
    j = fs.open("/.sys/common/.ver","r")
    h = fs.open("/.sys/tmp/short/.ver","r")
    if h.readLine() ~= j.readLine() then
        term.setBackgroundColor(colors.black)
        term.setCursorPos(1,1)
        term.clear()
        printError("New major update avaible, manual intervention needed!")
        sleep(5)
    end
    k = j.readLine()
    if h.readLine() ~= k then
        term.setBackgroundColor(colors.black)
        term.setCursorPos(1,1)
        term.clear()
        printError("System update in progress, please wait...")
        j.close()
        shell.run("rm /.sys/common/.ver")
        shell.run("cp /.sys/tmp/short/.ver /.sys/common/.ver")
        while true do
            k=h.readLine()
            if k == nil then break end
            shell.run(k)
            sleep(0)
        end
        sleep(3)
        h.close()
        j.close()
        os.reboot()
    end
    h.close()
    j.close()
end
