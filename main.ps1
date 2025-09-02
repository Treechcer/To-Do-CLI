$global:version = "0.0.3"

function startThis{
    
    $mode = Read-Host "mode" 

    switch ($mode) {
        1 {  
            Write-Host "Creating a new To-Do list..."

            $tempList = [PSCustomObject]@{
                #Name = Value
                version = $version
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

            if (-not (checkIfExists $number)){
                Write-Host "This JSON number file doen't exists"
            }
            else {
                $JSON = Get-Content -Path (createPath $number) -Raw | ConvertFrom-Json

                $JSON.tasks += (createTask $false 1250 "test" "test" $JSON $true)
                fileWrite $JSON

                writeOutTasks $JSON

                editingJSON $JSON
            }
        }
        5 {

        }
        Default {
            Write-Host "incorrect input, starting again"
            startThis
        }
    }
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

        $isFinished = Read-Host "Is the task finished?"

        if ($isFinished.ToLower() -eq "true"){
            $isFinished = $true
        }
        elseif ($isFinished.ToLower() -eq "false"){
            $isFinished = $false
        }
        elseif ($isFinished.ToLower() -eq "none") {
            $isFinished = $JSON.tasks[$number].isFinished
        }
        elseif ($isFinished.ToLower() -eq "end") {
            break
        }
        else {
            Write-Host "it has to be true or false, restarting"
            continue
        }

        $percentage = Read-Host "how many percets it's done?"

        if (([int]$percentage) -gt 100){
            $percentage = 100
        }
        elseif ($percentage.ToLower() -eq "none") {
            $percentage = $JSON.tasks[$number].percentage
        }
        elseif ($percentage.ToLower() -eq "end") {
            break
        }
        else {
            $percentage = ([int] $percentage)
        }

        $name = Read-Host "what's the name of the task?"

        if ($name.ToLower() -eq "none") {
            $name = $JSON.tasks[$number].name
        }
        elseif ($name.ToLower() -eq "end") {
            break
        }
        
        $description = Read-Host "what's the description of the task?"

        $JSON.tasks[$number - 1] = (createTask $isFinished $percentage $name $description $JSON $false)

        fileWrite $JSON
    }

    writeOutStart
}

function fileWrite {
    param (
        [PSCustomObject]$JSON
    )
    
    $path = createPath ([int32]$JSON.id)

    ConvertTo-Json $JSON -Depth 3 | Out-File $path
}

function writeOutTasks{
    param(
        [PSCustomObject]$JSON
    )

    foreach($task in $JSON.tasks){
        Write-Host ""
        Write-Host "--------------------------------------"
        Write-Host "Task ID: $($task.id)"
        Write-Host "Name: $($task.name)"
        Write-Host "Description: $($task.description)"

        if ($task.isFinished){
            $status = "Completed"
        }
        else {
            $status = "In Progress"
        }
        Write-Host "Status: $status"
        
        $per = [int] ($task.percentage / 5)
        $out = "#" * $per -join ""
        $out += "-" * (20 - $per) -join ""
        Write-Host "Progress: [$out] $($task.percentage)%"
        Write-Host "--------------------------------------"
        Write-Host ""
    }
}

function createTask {
    param (
        [boolean]$isFinished,
        [int16]$percentage,
        [string]$name,
        [string]$description,
        [PSCustomObject]$JSON,
        [bool]$changeID
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
        id = $id
    }
}

function writeOutStart {
    Write-Host "--------------------------------------"
    Write-Host "Welcome to your personal To-Do Manager!"
    Write-Host ""
    Write-Host "This small app helps you create, view, and manage"
    Write-Host "your tasks efficiently. Track your progress and"
    Write-Host "stay organized with ease."
    Write-Host "--------------------------------------"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "1 - Create a new To-Do list"
    Write-Host "2 - Load an existing To-Do JSON and modify tasks"
    Write-Host "5 - end"
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