$version = "0.0.1"

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
                "TEST"
                $JSON = Get-Content -Path (createPath $number) -Raw | ConvertFrom-Json

                #$JSON.tasks += (createTask $false 100 "test" "test") #TEST THINGY MAGINGy

                fileWrite $JSON

                writeOutTasks $JSON
            }
        }
        Default {
            Write-Host "incorrect input, starting again"
            startThis
        }
    }
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
        $task.name
        $task.description
        "-------"
        $task.isFinished
        $task.percentage
    }
}

function createTask {
    param (
        [boolean]$isFinished,
        [int16]$percentage,
        [string]$name,
        [string]$description
    )

    return [PSCustomObject]@{
        isFinished = $isFinished
        percentage = $percentage
        name = $name
        description = $description
    }
}

function writeOutStart {
    Write-Host "--------------------------------------"
    Write-Host "This app is small app for tasks, To-Do"
    Write-Host "list and similar functions, that can"
    Write-Host "help you with what you want to do"
    Write-Host "and tracking what you want to do"
    Write-Host "--------------------------------------"
    Write-Host ""
    Write-Host "You can press 1 to make a new To-Do"
    Write-Host "tasks"
    Write-Host "You can press 2 to load JSON and change"
    Write-Host "inside of the tasks"
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