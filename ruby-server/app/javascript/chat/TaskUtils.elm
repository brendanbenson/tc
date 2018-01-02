module TaskUtils exposing (..)

import Process
import Task
import Time


delay : Time.Time -> msg -> Cmd msg
delay time msg =
    Process.sleep time
        |> Task.perform (\_ -> msg)
