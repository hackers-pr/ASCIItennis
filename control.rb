require "json"

lines,chars=10,60
xCounter,yCounter,score,fps=2,-1,0,20
points=Hash.new

JSON.parse(IO.read("obj.json")).each {|hash| points[hash["name"]]=hash.select{|k,v| k!="name"}}

loop do
    begin;case STDIN.read_nonblock(2).downcase
            when "q\n" then exit
            when "j\n" then fps*=2
            when "k\n" then fps=(fps/2).to_i
            when "w\n" then points.keys.each {|name| (points[name]["lines"]-=5 if points[name]["type"]=="flap")}
            when "s\n" then points.keys.each {|name| (points[name]["lines"]+=5 if points[name]["type"]=="flap")}
        end
    rescue Errno::EAGAIN;end
    onlyLCF=points.values.map {|val| (val.slice("lines","char") if val["type"]=="flap")}
    if points["b"]["lines"]<-(lines-1) or points["b"]["lines"]>-2
        yCounter=-yCounter 
    elsif points["b"]["char"]<=0
        xCounter=xCounter.abs
    elsif onlyLCF.include?(points["b"].slice("lines","char"))
        xCounter=-xCounter-1
        score+=1
    elsif xCounter>=3
        xCounter=1*xCounter.abs/xCounter 
    end

    points["b"]["lines"]+=yCounter
    points["b"]["char"]+=xCounter

    display=Array.new; lines.times {|l| display[l]="0#{" "*chars}0"}
    points.values.each {|hash| display[hash["lines"]][hash["char"]]=hash["fill"]}
    puts "\e[H\e[2J\e[3J",display,"\nScore: #{score}"

    break if points["b"]["char"]>chars-1

    sleep(fps**-1)
end 

puts "Game over!"
