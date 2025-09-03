$global:version = "0.1.0"

function startThis{
    while ($true){
        $mode = Read-Host "mode" 

        switch ($mode) {
            1 {  
                Write-Host "Creating a new To-Do list..."

                $tempList = [PSCustomObject]@{
                    #Name = Value
                    version = $version
                    name = "default"
                    id = 1 #temp value, we will check if the ID is correct
                    tasksNum = 0 #number of tasks, when it's created theres no TASKS
                    tasks = @(
                        
                    )
                    #... more might be added
                }

                $tempList.id = createTODO $tempList.id

                $path = createPath ([int32]$tempList.id)

                ConvertTo-Json $tempList -Depth 3 | Out-File $path

                Write-Host "Created new JSON file for you TO-DO list"

                writeOutStart
            }
            2 {
                $number = Read-Host "Number of JSON you want to load"
                try {
                    if (-not (checkIfExists $number)){
                        Write-Host "This JSON number file doen't exists"
                    }
                    else {
                        $JSON = Get-Content -Path (createPath $number) -Raw | ConvertFrom-Json

                        $workDays = @((Get-Date -Format "dd-MM-yyyy"))

                        $JSON.tasks += (createTask $false 1250 "test" "test" $JSON $true 0 $workDays)
                        fileWrite $JSON

                        writeOutTasks $JSON

                        editingJSON $JSON
                    }   
                }
                catch {
                    Write-Host "You have to write only number"
                }
            }
            3{
                $number = Read-Host "Number of JSON you want to load"
                try {
                    if (-not (checkIfExists $number)){
                        Write-Host "This JSON number file doen't exists"
                    }
                    else {
                        $JSON = Get-Content -Path (createPath $number) -Raw | ConvertFrom-Json

                        writeOutTasks $JSON
                    }
                }   
                catch {
                    Write-Host "You have to write only number"
                }

            }
            4{
                while ($true) {
                    $choice = Read-Host "Do you want to delte JSON or TASKs? ['end' to end]"

                    if ($choice.ToLower() -eq "json" -or $choice.ToLower() -eq "task"){
                        $number = Read-Host "Number of JSON you want to load"
                        try {
                            if (-not (checkIfExists $number)){
                                Write-Host "This JSON number file doen't exists"
                            }
                            else {
                                if ($choice.ToLower() -eq "json"){
                                    Remove-Item -Path ("TODO" + $number + ".json")
                                    break
                                }
                                else{
                                    $JSON = Get-Content -Path (createPath $number) -Raw | ConvertFrom-Json
                                    deleteTask $JSON
                                    break
                                }
                            }
                        }   
                        catch {
                            Write-Host "You have to write only number"
                        }
                    }
                    elseif ($choice.ToLower() -eq "end") {
                        break
                    }
                    else{
                        Write-Host "Incorrect output, I was looking for 'json' or 'task'"
                    }
                }
            }
            5 {
                return
            }
            Default {
                Write-Host "incorrect input, starting again"
                continue
            }
        }
    }
}

function deleteTask {
    param(
        [PSCustomObject]$JSON
    )

    if ($JSON.tasksNum -eq 0){
        Write-Host "This JSON has 0 tasks"
        return
    }

    writeOutTasks $JSON

    while($true){
        $number = Read-Host "Which task you want to delete ['end' for end]?"
        if ($number.ToString() -eq "end"){
            break
        }
        else {
            if ($number -gt $JSON.tasksNum){
                Write-Host "Too big number, you only have $($JSON.tasksNum)"
            }
            $JSON.tasks[$number - 1].deleted = $true
            break
        }
    }

    fileWrite $JSON

    writeOutStart
}

function editingJSON {
    param (
        $JSON
    )

    while($true){
        $number = Read-Host "Which task you want to modify?, 'none' as answer to any doesn't change the thing and 'end' in any stops this"


        if ($number.ToLower() -eq "end") {
            break
        }
        elseif ($number -gt $JSON.tasksNum){
            Write-Host "This task doesn't exist"
            continue
        }

        $change = Read-Host "What do you want to change? ['finished', 'percent', 'name', 'description', 'time', 'all', 'JSONname']"
        $change = $change.ToLower()

        $isFinished = $JSON.tasks[$number - 1].isFinished
        $percentage = $JSON.tasks[$number - 1].percentage
        $name = $JSON.tasks[$number - 1].name
        $description = $JSON.tasks[$number - 1].description
        $time = $JSON.tasks[$number - 1].time

        if ($change -eq "finished" -or $change -eq "all"){
            $isFinished = Read-Host "Is the task finished?"

            if ($isFinished.ToLower() -eq "true"){
                $isFinished = $true
            }
            elseif ($isFinished.ToLower() -eq "false"){
                $isFinished = $false
            }
            elseif ($isFinished.ToLower() -eq "none") {
                $isFinished = $JSON.tasks[$number - 1].isFinished
            }
            elseif ($isFinished.ToLower() -eq "end") {
                break
            }
            else {
                Write-Host "it has to be true or false, restarting"
                continue
            }
        }
        if ($change -eq "percent" -or $change -eq "all"){
            $percentage = Read-Host "how many percets it's done?"

            if (([int]$percentage) -gt 100){
                $percentage = 100
            }
            elseif ($percentage.ToLower() -eq "none") {
                $percentage = $JSON.tasks[$number - 1].percentage
            }
            elseif ($percentage.ToLower() -eq "end") {
                break
            }
            else {
                $percentage = ([int] $percentage)
            }
        }
        if ($change -eq "name" -or $change -eq "all"){
            $name = Read-Host "what's the name of the task?"

            if ($name.ToLower() -eq "none") {
                $name = $JSON.tasks[$number - 1].name
            }
            elseif ($name.ToLower() -eq "end") {
                break
            }
        }
        if ($change -eq "description" -or $change -eq "all"){
            $description = Read-Host "what's the description of the task?"

            if ($description.ToLower() -eq "none") {
                $description = $JSON.tasks[$number - 1].description
            }
            elseif ($description.ToLower() -eq "end") {
                break
            }
        }
        if ($change -eq "time" -or $change -eq "all"){
            $time = Read-Host "what's the description of the task?"

            if ($time.ToLower() -eq "none") {
                $time = $JSON.tasks[$number - 1].time
            }
            elseif ($time.ToLower() -eq "end") {
                break
            }

            try {
                $time = [double]$time   
            }
            catch {
                $time = 0
            }
        }
        if ($change -eq "JSONname" -or $change -eq "all"){
            changeName $JSON
        }

        $workDays = @($JSON.tasks[$number - 1].workDays)
        $currentDay = (Get-Date -Format "dd-MM-yyyy")

        if (-not ($workDays -contains $currentDay)){
            $workDays += $currentDay
        }

        $JSON.tasks[$number - 1] = (createTask $isFinished $percentage $name $description $JSON $false $time $workDays)

        fileWrite $JSON
    }

    writeOutStart
}

function fileWrite {
    param (
        [PSCustomObject]$JSON
    )
    
    $path = createPath ([int32]$JSON.id)

    ConvertTo-Json $JSON -Depth 10 | Out-File $path
}

function writeOutTasks{
    param(
        [PSCustomObject]$JSON
    )

    Write-Host "========== $($JSON.name) ==========" -ForegroundColor Cyan
    Write-Host ""

    foreach($task in $JSON.tasks){
        if (-not $task.deleted){
            Write-Host "========== TASK $($task.id) ==========" -ForegroundColor Magenta
            Write-Host "Name: $($task.name)" -ForegroundColor White
            Write-Host "Description: $($task.description)" -ForegroundColor White
            Write-Host "Task ID: $($task.id)" -ForegroundColor DarkGray

            if ($task.isFinished){
                $status = "Completed"
                $scol = "Green"
            }
            else {
                $status = "In Progress"
                $scol = "Yellow"
            }
            Write-Host "Status: $status" -ForegroundColor $scol

            $per = [int] ($task.percentage / 5)
            $out = "#" * $per -join ""
            $out += "-" * (20 - $per) -join ""

            if ($task.percentage -lt 70){
                $color = "Red"
            }
            else {
                $color = "Green"
            }

            Write-Host "Progress: [$out] $($task.percentage)%" -ForegroundColor $color
            Write-Host "Time: $($task.time)" -ForegroundColor Gray

            $str = "========== TASK $($task.id) ==========" 
            $end = ""

            for ($i = 1; $i -lt $str.Length; $i++) {
                $end += "="
            }

            Write-Host "$end" -ForegroundColor Magenta
            Write-Host ""
        }
    }

}

function changeName {
    param (
        [PSCustomObject]$JSON
    )
    
    $name = Read-Host "What do you want to change the name of this JSON TO-DO list?"

    $JSON.name = $name

    fileWrite $JSON
}

function createTask {
    param (
        [boolean]$isFinished,
        [int]$percentage,
        [string]$name,
        [string]$description,
        [PSCustomObject]$JSON,
        [bool]$changeID,
        [double]$time,
        [array]$date,
        [boolean]$deleted
    )

    if ($changeID){
        $JSON.tasksNum += 1
    }

    $id = $JSON.tasksNum

    if ($percentage -gt 100){
        $percentage = 100
    }

    if ($percentage -eq 100 -and $isFinished -eq $false){
        $isFinished = $true
    }

    return [PSCustomObject]@{
        isFinished = $isFinished
        percentage = $percentage
        name = $name
        description = $description
        time = $time
        id = $id
        workDays = $date
        deleted = $deleted
    }
}

function writeOutStart {
    Write-Host "`n======================================" -ForegroundColor Cyan
    Write-Host "        TO-DO MANAGER v$global:version        " -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Manage your tasks efficiently. Choose an option:"
    Write-Host "[1] Create a new To-Do list" -ForegroundColor Green
    Write-Host "[2] Load and modify an existing To-Do JSON" -ForegroundColor Yellow
    Write-Host "[3] View an existing To-Do JSON" -ForegroundColor Cyan
    Write-Host "[4] Delete Tasks and JSONs" -ForegroundColor Magenta
    Write-Host "[5] Exit the program" -ForegroundColor Red
    Write-Host ""


    startThis
}

function createPath {
    param (
        [int32]$id
    )

    $path = ("TODO" + $id + ".json")

    return $path
}

function checkIfExists {
    param (
        [int32]$id
    )

    if (-not (Test-Path ("TODO" + $id + ".json"))){
        return $false
    }
    else {
        return $true
    }
}

function createTODO {
    param (
        [int32]$id
    )

    if (-not (Test-Path ("TODO" + $id + ".json"))){
        New-Item ("TODO" + $id + ".json") | Out-Null
        return $id
    }
    else {
        return createTODO ($id + 1)
    }
}

writeOutStart