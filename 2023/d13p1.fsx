open System.IO

let lines = File.ReadAllLines "d13_input"

let parse_patterns (lines: string array) =
    let split_indexes =
        lines |> Seq.mapi (fun i line -> if line.Length = 0 then Some(i) else None)
        |> Seq.choose id
    Seq.append [|0|]
        (Seq.append split_indexes [| lines.Length |])
        |> Seq.windowed 2
        |> Seq.map (fun wind -> let (i, j) = (wind[0], wind[1]) in lines[i..j-1])
        |> Seq.toArray

printfn "%A" (parse_patterns lines)
