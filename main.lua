local cells = {}
local width
local height
local w = 10
local generations 
local ruleSet = {0, 0, 0, 0, 0, 0, 0, 0}


function flip_bit(bit)
    b = tonumber(bit)
    ruleSet[b] = (ruleSet[b] + 1) % 2
end


function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
       love.event.quit()
    end

    if key == "r" then
        for i = 1, #ruleSet do
            ruleSet[i] = math.floor(math.random() + 0.5)
        end
        calculate_generations(generations)
    end

    if key == "1" or key == "2" or key == "3" or key == "4" or key == "5" or key == "6" or key == "7" or key == "8" then
        flip_bit(key)
        calculate_generations(generations)
    end
 end


function love.load()
    math.randomseed(os.time())
    love.graphics.setBackgroundColor(1, 1, 1, 1)
    love.graphics.setColor(0, 0, 0, 1)
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    generations = height / w
    calculate_generations(generations)
end


function initialise() 
    len = width / w
    local initial = {}
    for i = 1, len do
        if i == math.floor(len / 2) then
            initial[i] = 1
        else 
            initial[i] = 0
        end
    end
    return initial
end


function calc_new_state(neighbors)
    if neighbors[1] == 1 and neighbors[2] == 1 and neighbors[3] == 1 then
        return ruleSet[1]
    elseif neighbors[1] == 1 and neighbors[2] == 1 and neighbors[3] == 0 then
        return ruleSet[2]
    elseif neighbors[1] == 1 and neighbors[2] == 0 and neighbors[3] == 1 then
        return ruleSet[3]
    elseif neighbors[1] == 1 and neighbors[2] == 0 and neighbors[3] == 0 then
        return ruleSet[4]
    elseif neighbors[1] == 0 and neighbors[2] == 1 and neighbors[3] == 1 then
        return ruleSet[5]
    elseif neighbors[1] == 0 and neighbors[2] == 1 and neighbors[3] == 0 then
        return ruleSet[6]
    elseif neighbors[1] == 0 and neighbors[2] == 0 and neighbors[3] == 1 then
        return ruleSet[7]
    elseif neighbors[1] == 0 and neighbors[2] == 0 and neighbors[3] == 0 then
        return ruleSet[8]
    end
end


function generate_new(current)
    neighbors = {}
    newGen = {}
    local len = #current
    for i = 1, len do
        if i > 1 and i + 1 <= len then
            neighbors[1] = current[i - 1]
            neighbors[2] = current[i]
            neighbors[3] = current[i + 1]
        elseif i == 1 then
            neighbors[1] = current[len]
            neighbors[2] = current[i]
            neighbors[3] = current[i + 1]
        elseif i == len then
            neighbors[1] = current[i - 1]
            neighbors[2] = current[i]
            neighbors[3] = current[1]
        end
        newGen[i] = calc_new_state(neighbors)
    end
    return newGen
end


function table_to_string(tbl)
    local result = "{"
    for k, v in pairs(tbl) do
        -- Check the key type (ignore any numerical keys - assume its an array)
        if type(k) == "string" then
            result = result.."[\""..k.."\"]".."="
        end

        -- Check the value type
        if type(v) == "table" then
            result = result..table_to_string(v)
        elseif type(v) == "boolean" then
            result = result..tostring(v)
        else
            result = result.."\""..v.."\""
        end
        result = result..","
    end
    -- Remove leading commas from the result
    if result ~= "" then
        result = result:sub(1, result:len()-1)
    end
    return result.."}"
end


function calculate_generations(count) 
    init = initialise()
    cells[1] = init
    for i = 2, count do
        cells[i] = generate_new(cells[i-1])
    end
end


function rules_to_int(ruleSet)
    return 128 * ruleSet[1] + 
            64 * ruleSet[2] + 
            32 * ruleSet[3] + 
            16 * ruleSet[4] + 
            8  * ruleSet[5] + 
            4  * ruleSet[6] + 
            2  * ruleSet[7] +
            1  * ruleSet[8]
end


function love.draw()
    love.graphics.setColor(0, 0, 0, 1)
    for j = 1, #cells do
        for i = 1, #cells[j] do
            if  cells[j][i] == 1 then
                love.graphics.rectangle("fill", (i - 1) * w, (j - 1) * w, w, w)
            end
        end
    end
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.print("rules: " .. table_to_string(ruleSet) .. " = " .. rules_to_int(ruleSet) , 10, 10)
end

